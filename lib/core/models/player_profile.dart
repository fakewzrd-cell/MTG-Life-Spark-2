import 'package:hive/hive.dart';

part 'player_profile.g.dart';

@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  int level;

  @HiveField(2)
  int xp;

  @HiveField(3)
  String tier; // 'Bronze' | 'Silver' | 'Gold' | 'Platinum' | 'Diamond'

  @HiveField(4)
  int totalWins;

  @HiveField(5)
  int totalLosses;

  @HiveField(6)
  String? selectedCommanderName;

  @HiveField(7)
  String? selectedCommanderImageUrl;

  @HiveField(8)
  String? selectedPartnerCommanderName;

  @HiveField(9)
  String? selectedPartnerCommanderImageUrl;

  @HiveField(10)
  List<String> unlockedThemes;

  @HiveField(11)
  List<String> unlockedBadges;

  @HiveField(12)
  int lifetimePoisonDealt;

  @HiveField(13)
  int lifetimeCommanderKills;

  @HiveField(14)
  int currentWinStreak;

  @HiveField(15)
  int totalGamesPlayed;

  @HiveField(16)
  /// Circular profile picture URL (Scryfall card art), chosen in the avatar picker.
  String? profileAvatarImageUrl;

  /// Community: likes received from other players' feedback (aggregated).
  @HiveField(17)
  int likesReceived;

  @HiveField(18)
  int dislikesReceived;

  @HiveField(19)
  /// Stars of the game received (Hive field 19 was formerly MVP count).
  int honorsStarReceived;

  /// Legacy Hive field — no longer shown; retained for storage compatibility.
  @HiveField(20)
  int honorsTeamPlayerReceived;

  /// Legacy Hive field — no longer shown; retained for storage compatibility.
  @HiveField(21)
  int honorsUnderdogReceived;

  /// Optional wide art URL for the profile hero (falls back to bundled banner).
  @HiveField(22)
  String? profileBannerImageUrl;

  /// Legacy Hive field retained for storage compatibility; unused by the UI.
  @HiveField(23, defaultValue: <String>[])
  List<String> profileExtraStatIds;

  PlayerProfile({
    required this.username,
    this.level = 1,
    this.xp = 0,
    this.tier = 'Bronze',
    this.totalWins = 0,
    this.totalLosses = 0,
    this.selectedCommanderName,
    this.selectedCommanderImageUrl,
    this.selectedPartnerCommanderName,
    this.selectedPartnerCommanderImageUrl,
    this.unlockedThemes = const ['default'],
    this.unlockedBadges = const [],
    this.lifetimePoisonDealt = 0,
    this.lifetimeCommanderKills = 0,
    this.currentWinStreak = 0,
    this.totalGamesPlayed = 0,
    this.profileAvatarImageUrl,
    this.likesReceived = 0,
    this.dislikesReceived = 0,
    this.honorsStarReceived = 0,
    this.honorsTeamPlayerReceived = 0,
    this.honorsUnderdogReceived = 0,
    this.profileBannerImageUrl,
    List<String>? profileExtraStatIds,
  }) : profileExtraStatIds = profileExtraStatIds ?? [];
}
