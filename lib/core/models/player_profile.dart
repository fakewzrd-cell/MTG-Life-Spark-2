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
  /// Legacy; profile UI no longer exposes avatar selection (bundled MTG mark instead).
  String? profileAvatarImageUrl;

  /// Community: likes received from other players' feedback (aggregated).
  @HiveField(17)
  int likesReceived;

  @HiveField(18)
  int dislikesReceived;

  @HiveField(19)
  int honorsMvpReceived;

  @HiveField(20)
  int honorsTeamPlayerReceived;

  @HiveField(21)
  int honorsUnderdogReceived;

  /// Wide art URL for profile header banner (e.g. Scryfall card art).
  @HiveField(22)
  String? profileBannerImageUrl;

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
    this.honorsMvpReceived = 0,
    this.honorsTeamPlayerReceived = 0,
    this.honorsUnderdogReceived = 0,
    this.profileBannerImageUrl,
  });
}
