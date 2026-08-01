import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../debug/app_log.dart';
import '../models/match_record.dart';
import '../models/player_identity.dart';
import 'backup_codec.dart';
import 'deck_repository.dart';
import 'feedback_repository.dart';
import 'match_repository.dart';
import 'pod_repository.dart';
import 'profile_repository.dart';
import 'settings_repository.dart';

class _DeviceSnapshot {
  const _DeviceSnapshot({
    required this.core,
    required this.matches,
    required this.feedbackByKey,
  });

  final LifeSparkBackup core;
  final List<MatchRecord> matches;
  final Map<String, String> feedbackByKey;
}

/// Builds, shares, and restores local Life Spark backups (`.lifespark`).
class BackupService {
  BackupService({
    required ProfileRepository profileRepo,
    required SettingsRepository settingsRepo,
    required DeckRepository deckRepo,
    required PodRepository podRepo,
    required MatchRepository matchRepo,
    required FeedbackRepository feedbackRepo,
  })  : _profileRepo = profileRepo,
        _settingsRepo = settingsRepo,
        _deckRepo = deckRepo,
        _podRepo = podRepo,
        _matchRepo = matchRepo,
        _feedbackRepo = feedbackRepo;

  final ProfileRepository _profileRepo;
  final SettingsRepository _settingsRepo;
  final DeckRepository _deckRepo;
  final PodRepository _podRepo;
  final MatchRepository _matchRepo;
  final FeedbackRepository _feedbackRepo;

  static const _backupTypeGroup = XTypeGroup(
    label: 'Life Spark backup',
    extensions: <String>['lifespark', 'json'],
    mimeTypes: <String>['application/json', 'application/octet-stream'],
  );

  LifeSparkBackup buildBackup({DateTime? exportedAt}) {
    final profile = _profileRepo.getProfile();
    if (profile == null) {
      throw StateError('No profile to export.');
    }
    return LifeSparkBackup(
      version: kLifeSparkBackupVersion,
      exportedAt: exportedAt ?? DateTime.now().toUtc(),
      profile: profile,
      settings: _settingsRepo.settings,
      decks: _deckRepo.getAll(),
      pods: _podRepo.getAll(),
      commanderStats: _profileRepo.getAllCommanderStats(),
    );
  }

  /// Detached copy of current device data (safe to re-apply after failed restore).
  LifeSparkBackup captureDetachedBackup({DateTime? exportedAt}) {
    final live = buildBackup(exportedAt: exportedAt);
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

  _DeviceSnapshot _captureDeviceSnapshot() => _DeviceSnapshot(
        core: captureDetachedBackup(),
        matches: _matchRepo.snapshotAll(),
        feedbackByKey: _feedbackRepo.snapshotRaw(),
      );

  Future<void> _commitCore(LifeSparkBackup backup) async {
    await _profileRepo.saveProfile(backup.profile);
    await _profileRepo.replaceAllCommanderStats(backup.commanderStats);
    await _settingsRepo.update(backup.settings);
    await _deckRepo.replaceAll(backup.decks);
    await _podRepo.replaceAll(backup.pods);
  }

  Future<void> _commitSnapshot(_DeviceSnapshot snapshot) async {
    await _commitCore(snapshot.core);
    await _matchRepo.replaceAll(snapshot.matches);
    await _feedbackRepo.replaceRaw(snapshot.feedbackByKey);
  }

  /// Writes backup data into Hive. On failure, rolls device data back.
  Future<LifeSparkBackup> restoreBackup(LifeSparkBackup backup) async {
    final profile = backup.profile;
    if (profile.playerId.trim().isEmpty) {
      profile.playerId = generatePlayerId();
    }
    // Restored installs should not re-show onboarding.
    backup.settings.onboardingCompleted = true;

    // Detach so rollback cannot accidentally share mutated Hive instances.
    final incoming = LifeSparkBackup.fromJson(
      Map<String, dynamic>.from(backup.toJson()),
    );
    incoming.settings.onboardingCompleted = true;
    if (incoming.profile.playerId.trim().isEmpty) {
      incoming.profile.playerId = profile.playerId;
    }

    final rollback = _captureDeviceSnapshot();
    try {
      await _commitCore(incoming);
      // History is not in the backup file — drop stale local rows so they
      // don't linger under a previous playerId after restore.
      await _matchRepo.clearAll();
      await _feedbackRepo.clearAll();
      return incoming;
    } catch (e, st) {
      appLog('BackupService: restore failed; rolling back',
          error: e, stackTrace: st);
      try {
        await _commitSnapshot(rollback);
      } catch (rollbackError, rollbackSt) {
        appLog('BackupService: rollback failed',
            error: rollbackError, stackTrace: rollbackSt);
      }
      rethrow;
    }
  }

  /// Shares a backup file. Returns `true` only when the user completed a share.
  Future<bool> exportAndShare() async {
    final backup = buildBackup();
    final json = encodeBackup(backup);
    final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
    final filename = 'life-spark-backup-$stamp.lifespark';
    final bytes = Uint8List.fromList(utf8.encode(json));

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'application/json',
            name: filename,
          ),
        ],
        subject: 'Life Spark backup',
        text: 'Life Spark profile backup',
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  /// Picks and decodes a backup without writing Hive. Null if canceled.
  Future<LifeSparkBackup?> pickBackupFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [_backupTypeGroup],
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Could not read the selected backup file.');
    }
    return decodeBackupBytes(bytes);
  }
}
