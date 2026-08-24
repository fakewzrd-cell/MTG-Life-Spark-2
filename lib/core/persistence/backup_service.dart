import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';

import '../../shared/utils/profile_avatar_storage.dart';
import '../debug/app_log.dart';
import '../models/player_identity.dart';
import 'backup_codec.dart';
import 'deck_repository.dart';
import 'feedback_repository.dart';
import 'match_repository.dart';
import 'profile_repository.dart';
import 'settings_repository.dart';

/// Builds, shares, and restores local Life Spark backups (`.lifespark`).
class BackupService {
  BackupService({
    required ProfileRepository profileRepo,
    required SettingsRepository settingsRepo,
    required DeckRepository deckRepo,
    required MatchRepository matchRepo,
    required FeedbackRepository feedbackRepo,
  })  : _profileRepo = profileRepo,
        _settingsRepo = settingsRepo,
        _deckRepo = deckRepo,
        _matchRepo = matchRepo,
        _feedbackRepo = feedbackRepo;

  final ProfileRepository _profileRepo;
  final SettingsRepository _settingsRepo;
  final DeckRepository _deckRepo;
  final MatchRepository _matchRepo;
  final FeedbackRepository _feedbackRepo;

  static const _backupExtensions = <String>['lifespark', 'json'];
  static const _backupMimes = <String>[
    'application/json',
    'application/octet-stream',
  ];

  XTypeGroup _backupTypeGroup(String label) => XTypeGroup(
        label: label,
        extensions: _backupExtensions,
        mimeTypes: _backupMimes,
      );

  Future<LifeSparkBackup> buildBackup({DateTime? exportedAt}) async {
    final profile = _profileRepo.getProfile();
    if (profile == null) {
      throw StateError('No profile to export.');
    }
    final avatarBytes =
        await encodeLocalAvatarForBackup(profile.profileAvatarImageUrl);
    return LifeSparkBackup(
      version: kLifeSparkBackupVersion,
      exportedAt: exportedAt ?? DateTime.now().toUtc(),
      profile: profile,
      settings: _settingsRepo.settings,
      decks: _deckRepo.getAll(),
      commanderStats: _profileRepo.getAllCommanderStats(),
      matches: _matchRepo.snapshotAll(),
      feedbackByKey: _feedbackRepo.snapshotRaw(),
      profileAvatarImageBase64: avatarBytes?.base64,
      profileAvatarImageMime: avatarBytes?.mime,
    );
  }

  /// Detached copy of current device data (safe to re-apply after failed restore).
  Future<LifeSparkBackup> captureDetachedBackup({DateTime? exportedAt}) async {
    final live = await buildBackup(exportedAt: exportedAt);
    return LifeSparkBackup.fromJson(
      Map<String, dynamic>.from(live.toJson()),
    );
  }

  String encodeBackup(LifeSparkBackup backup) =>
      const JsonEncoder.withIndent('  ').convert(backup.toJson());

  LifeSparkBackup decodeBackup(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Backup file is not valid JSON.');
    }
    return LifeSparkBackup.fromJson(Map<String, dynamic>.from(decoded));
  }

  LifeSparkBackup decodeBackupBytes(Uint8List bytes) =>
      decodeBackup(utf8.decode(bytes));

  Future<void> _commitAll(LifeSparkBackup backup) async {
    await _profileRepo.saveProfile(backup.profile);
    await _profileRepo.replaceAllCommanderStats(backup.commanderStats);
    await _settingsRepo.update(backup.settings);
    await _deckRepo.replaceAll(backup.decks);
    await _matchRepo.replaceAll(backup.matches);
    await _feedbackRepo.replaceRaw(backup.feedbackByKey);
  }

  /// Materialize embedded avatar bytes / clear stale local paths before commit.
  Future<LifeSparkBackup> _prepareIncomingAvatar(LifeSparkBackup backup) async {
    final json = Map<String, dynamic>.from(backup.toJson());
    final prepared = LifeSparkBackup.fromJson(json);
    final profile = prepared.profile;
    final embedded = prepared.profileAvatarImageBase64;

    if (embedded != null && embedded.isNotEmpty) {
      final path = await restoreAvatarFromBackupBase64(
        embedded,
        mime: prepared.profileAvatarImageMime,
      );
      profile.profileAvatarImageUrl = path;
      return LifeSparkBackup(
        version: prepared.version,
        exportedAt: prepared.exportedAt,
        profile: profile,
        settings: prepared.settings,
        decks: prepared.decks,
        commanderStats: prepared.commanderStats,
        matches: prepared.matches,
        feedbackByKey: prepared.feedbackByKey,
        profileAvatarImageBase64: prepared.profileAvatarImageBase64,
        profileAvatarImageMime: prepared.profileAvatarImageMime,
      );
    }

    // Stale absolute path from another device — drop rather than broken image.
    final ref = profile.profileAvatarImageUrl;
    if (isLocalAvatarRef(ref) && localFileFromRef(ref) == null) {
      profile.profileAvatarImageUrl = null;
    }
    return prepared;
  }

  /// Writes backup data into Hive. On failure, rolls device data back.
  Future<LifeSparkBackup> restoreBackup(LifeSparkBackup backup) async {
    final profile = backup.profile;
    if (profile.playerId.trim().isEmpty) {
      profile.playerId = generatePlayerId();
    }
    // Restored installs should not re-show onboarding.
    backup.settings.onboardingCompleted = true;

    var incoming = await _prepareIncomingAvatar(backup);
    incoming.settings.onboardingCompleted = true;
    if (incoming.profile.playerId.trim().isEmpty) {
      incoming.profile.playerId = profile.playerId;
    }

    final rollback = await captureDetachedBackup();
    try {
      await _commitAll(incoming);
      return incoming;
    } catch (e, st) {
      appLog('BackupService: restore failed; rolling back',
          error: e, stackTrace: st);
      try {
        await _commitAll(rollback);
      } catch (rollbackError, rollbackSt) {
        appLog('BackupService: rollback failed',
            error: rollbackError, stackTrace: rollbackSt);
      }
      rethrow;
    }
  }

  /// Opens the system Save dialog and writes a `.lifespark` file.
  /// Returns `true` when the user picked a location; `false` if canceled.
  Future<bool> exportToFile() async {
    final backup = await buildBackup();
    final json = encodeBackup(backup);
    final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
    final bytes = Uint8List.fromList(utf8.encode(json));

    final path = await FileSaver.instance.saveAs(
      name: 'life-spark-backup-$stamp',
      bytes: bytes,
      fileExtension: 'lifespark',
      mimeType: MimeType.json,
    );
    return path != null && path.isNotEmpty;
  }

  /// Picks and decodes a backup without writing Hive. Null if canceled.
  ///
  /// [fileTypeLabel] is shown in the system file picker (localized by caller).
  Future<LifeSparkBackup?> pickBackupFile({
    String fileTypeLabel = 'Life Spark backup',
  }) async {
    final file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[_backupTypeGroup(fileTypeLabel)],
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Could not read the selected backup file.');
    }
    return decodeBackupBytes(bytes);
  }
}
