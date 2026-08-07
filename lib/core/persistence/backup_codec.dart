import '../models/app_settings.dart';
import '../models/commander_stats.dart';
import '../models/player_deck.dart';
import '../models/player_profile.dart';

/// Marker + schema version for `.lifespark` backup files.
const kLifeSparkBackupFormat = 'life-spark-backup';
const kLifeSparkBackupVersion = 1;

class LifeSparkBackup {
  const LifeSparkBackup({
    required this.version,
    required this.exportedAt,
    required this.profile,
    required this.settings,
    required this.decks,
    required this.commanderStats,
  });

  final int version;
  final DateTime exportedAt;
  final PlayerProfile profile;
  final AppSettings settings;
  final List<PlayerDeck> decks;
  final List<CommanderStats> commanderStats;

  Map<String, dynamic> toJson() => {
        'format': kLifeSparkBackupFormat,
        'version': version,
        'exportedAt': exportedAt.toUtc().toIso8601String(),
        'profile': profileToJson(profile),
        'settings': settingsToJson(settings),
        'decks': decks.map(deckToJson).toList(),
        // Legacy key kept empty so older app builds can still parse exports.
        'pods': const <Map<String, dynamic>>[],
        'commanderStats': commanderStats.map(commanderStatsToJson).toList(),
      };

  static LifeSparkBackup fromJson(Map<String, dynamic> json) {
    final format = json['format'] as String?;
    if (format != kLifeSparkBackupFormat) {
      throw const FormatException('Not a Life Spark backup file.');
    }
    final version = json['version'] as int? ?? 0;
    if (version < 1 || version > kLifeSparkBackupVersion) {
      throw FormatException('Unsupported backup version: $version');
    }
    final exportedRaw = json['exportedAt'] as String?;
    final profileJson = json['profile'];
    final settingsJson = json['settings'];
    if (profileJson is! Map || settingsJson is! Map) {
      throw const FormatException('Backup is missing profile or settings.');
    }

    return LifeSparkBackup(
      version: version,
      exportedAt: exportedRaw != null
          ? DateTime.tryParse(exportedRaw)?.toUtc() ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      profile: profileFromJson(Map<String, dynamic>.from(profileJson)),
      settings: settingsFromJson(Map<String, dynamic>.from(settingsJson)),
      decks: _listOfMaps(json['decks']).map(deckFromJson).toList(),
      // Older backups may still include pods; they are ignored.
      commanderStats:
          _listOfMaps(json['commanderStats']).map(commanderStatsFromJson).toList(),
    );
  }
}

List<Map<String, dynamic>> _listOfMaps(Object? raw) {
  if (raw == null) return const [];
  if (raw is! List) {
    throw const FormatException('Expected a JSON list.');
  }
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

String? _stringOrNull(Object? v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

List<String> _stringList(Object? raw) {
  if (raw is! List) return const [];
  return raw.map((e) => e.toString()).toList();
}

Map<String, dynamic> profileToJson(PlayerProfile p) => {
      'username': p.username,
      'playerId': p.playerId,
      'level': p.level,
      'xp': p.xp,
      'tier': p.tier,
      'totalWins': p.totalWins,
      'totalLosses': p.totalLosses,
      'selectedCommanderName': p.selectedCommanderName,
      'selectedCommanderImageUrl': p.selectedCommanderImageUrl,
      'selectedPartnerCommanderName': p.selectedPartnerCommanderName,
      'selectedPartnerCommanderImageUrl': p.selectedPartnerCommanderImageUrl,
      'unlockedThemes': p.unlockedThemes,
      'unlockedBadges': p.unlockedBadges,
      'lifetimePoisonDealt': p.lifetimePoisonDealt,
      'lifetimeCommanderKills': p.lifetimeCommanderKills,
      'currentWinStreak': p.currentWinStreak,
      'totalGamesPlayed': p.totalGamesPlayed,
      'profileAvatarImageUrl': p.profileAvatarImageUrl,
      'likesReceived': p.likesReceived,
      'dislikesReceived': p.dislikesReceived,
      'honorsStarReceived': p.honorsStarReceived,
      'honorsTeamPlayerReceived': p.honorsTeamPlayerReceived,
      'honorsUnderdogReceived': p.honorsUnderdogReceived,
      'profileBannerImageUrl': p.profileBannerImageUrl,
      'profileExtraStatIds': p.profileExtraStatIds,
    };

PlayerProfile profileFromJson(Map<String, dynamic> json) => PlayerProfile(
      username: (json['username'] as String?)?.trim().isNotEmpty == true
          ? (json['username'] as String).trim()
          : 'Planeswalker',
      playerId: (json['playerId'] as String?) ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      tier: (json['tier'] as String?) ?? 'Bronze',
      totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
      totalLosses: (json['totalLosses'] as num?)?.toInt() ?? 0,
      selectedCommanderName: _stringOrNull(json['selectedCommanderName']),
      selectedCommanderImageUrl: _stringOrNull(json['selectedCommanderImageUrl']),
      selectedPartnerCommanderName:
          _stringOrNull(json['selectedPartnerCommanderName']),
      selectedPartnerCommanderImageUrl:
          _stringOrNull(json['selectedPartnerCommanderImageUrl']),
      unlockedThemes: _stringList(json['unlockedThemes']).isEmpty
          ? const ['default']
          : _stringList(json['unlockedThemes']),
      unlockedBadges: _stringList(json['unlockedBadges']),
      lifetimePoisonDealt: (json['lifetimePoisonDealt'] as num?)?.toInt() ?? 0,
      lifetimeCommanderKills:
          (json['lifetimeCommanderKills'] as num?)?.toInt() ?? 0,
      currentWinStreak: (json['currentWinStreak'] as num?)?.toInt() ?? 0,
      totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      profileAvatarImageUrl: _stringOrNull(json['profileAvatarImageUrl']),
      likesReceived: (json['likesReceived'] as num?)?.toInt() ?? 0,
      dislikesReceived: (json['dislikesReceived'] as num?)?.toInt() ?? 0,
      honorsStarReceived: (json['honorsStarReceived'] as num?)?.toInt() ?? 0,
      honorsTeamPlayerReceived:
          (json['honorsTeamPlayerReceived'] as num?)?.toInt() ?? 0,
      honorsUnderdogReceived:
          (json['honorsUnderdogReceived'] as num?)?.toInt() ?? 0,
      profileBannerImageUrl: _stringOrNull(json['profileBannerImageUrl']),
      profileExtraStatIds: _stringList(json['profileExtraStatIds']),
    );

Map<String, dynamic> settingsToJson(AppSettings s) => {
      'hapticEnabled': s.hapticEnabled,
      'soundEnabled': s.soundEnabled,
      'defaultFormat': s.defaultFormat,
      'defaultStartingLife': s.defaultStartingLife,
      'scryfallCacheEnabled': s.scryfallCacheEnabled,
      'shakeToUndoEnabled': s.shakeToUndoEnabled,
      'onboardingCompleted': s.onboardingCompleted,
      'keepDisplayAwake': s.keepDisplayAwake,
      'hideSystemBars': s.hideSystemBars,
      'useDarkTheme': s.useDarkTheme,
      'colorSchemeId': s.colorSchemeId,
      'lifeGestureHintDismissed': s.lifeGestureHintDismissed,
      'hubGuideCompleted': s.hubGuideCompleted,
    };

AppSettings settingsFromJson(Map<String, dynamic> json) => AppSettings(
      hapticEnabled: json['hapticEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      defaultFormat: (json['defaultFormat'] as String?) ?? 'Commander',
      defaultStartingLife: (json['defaultStartingLife'] as num?)?.toInt() ?? 40,
      scryfallCacheEnabled: json['scryfallCacheEnabled'] as bool? ?? true,
      shakeToUndoEnabled: json['shakeToUndoEnabled'] as bool? ?? true,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? true,
      keepDisplayAwake: json['keepDisplayAwake'] as bool? ?? true,
      hideSystemBars: json['hideSystemBars'] as bool? ?? false,
      useDarkTheme: json['useDarkTheme'] as bool? ?? true,
      colorSchemeId: (json['colorSchemeId'] as String?) ?? 'violet',
      lifeGestureHintDismissed:
          json['lifeGestureHintDismissed'] as bool? ?? false,
      hubGuideCompleted: json['hubGuideCompleted'] as bool? ?? false,
    );

Map<String, dynamic> deckToJson(PlayerDeck d) => {
      'id': d.id,
      'displayName': d.displayName,
      'commanderName': d.commanderName,
      'commanderImageUrl': d.commanderImageUrl,
      'partnerCommanderName': d.partnerCommanderName,
      'partnerCommanderImageUrl': d.partnerCommanderImageUrl,
      'wins': d.wins,
      'losses': d.losses,
      'gamesPlayed': d.gamesPlayed,
      'commanderManaCost': d.commanderManaCost,
      'partnerManaCost': d.partnerManaCost,
      'commanderColorIdentity': d.commanderColorIdentity,
      'format': d.format,
      'deckStyleId': d.deckStyleId,
      'isPinned': d.isPinned,
    };

PlayerDeck deckFromJson(Map<String, dynamic> json) {
  final id = (json['id'] as String?)?.trim();
  final displayName = (json['displayName'] as String?)?.trim();
  final commanderName = (json['commanderName'] as String?)?.trim();
  if (id == null ||
      id.isEmpty ||
      displayName == null ||
      displayName.isEmpty ||
      commanderName == null ||
      commanderName.isEmpty) {
    throw const FormatException('Deck entry is missing required fields.');
  }
  return PlayerDeck(
    id: id,
    displayName: displayName,
    commanderName: commanderName,
    commanderImageUrl: _stringOrNull(json['commanderImageUrl']),
    partnerCommanderName: _stringOrNull(json['partnerCommanderName']),
    partnerCommanderImageUrl: _stringOrNull(json['partnerCommanderImageUrl']),
    wins: (json['wins'] as num?)?.toInt() ?? 0,
    losses: (json['losses'] as num?)?.toInt() ?? 0,
    gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
    commanderManaCost: _stringOrNull(json['commanderManaCost']),
    partnerManaCost: _stringOrNull(json['partnerManaCost']),
    commanderColorIdentity: _stringList(json['commanderColorIdentity']),
    format: (json['format'] as String?) ?? 'commander',
    deckStyleId: (json['deckStyleId'] as String?) ?? '',
    isPinned: json['isPinned'] as bool? ?? false,
  );
}

Map<String, dynamic> commanderStatsToJson(CommanderStats s) => {
      'commanderName': s.commanderName,
      'wins': s.wins,
      'losses': s.losses,
      'gamesPlayed': s.gamesPlayed,
    };

CommanderStats commanderStatsFromJson(Map<String, dynamic> json) {
  final name = (json['commanderName'] as String?)?.trim();
  if (name == null || name.isEmpty) {
    throw const FormatException('Commander stats entry is missing a name.');
  }
  return CommanderStats(
    commanderName: name,
    wins: (json['wins'] as num?)?.toInt() ?? 0,
    losses: (json['losses'] as num?)?.toInt() ?? 0,
    gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
  );
}
