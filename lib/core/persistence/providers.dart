import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_profile.dart';
import 'profile_repository.dart';
import 'match_repository.dart';
import 'achievement_repository.dart';
import 'feedback_repository.dart';
import 'pod_repository.dart';
import 'deck_repository.dart';
import 'settings_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Bumped when [PlayerProfile] is mutated in place so [profileProvider] rebuilds.
/// (Same Hive object reference would otherwise satisfy `==` and skip Riverpod notify.)
final profileRevisionProvider = StateProvider<int>((ref) => 0);

/// Profile data. Watches [profileRevisionProvider]; call [bumpProfileRevision] after saves.
final profileProvider = Provider<PlayerProfile?>((ref) {
  ref.watch(profileRevisionProvider);
  return ref.watch(profileRepositoryProvider).getProfile();
});

void bumpProfileRevision(WidgetRef ref) {
  ref.read(profileRevisionProvider.notifier).state++;
}

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

final podRepositoryProvider = Provider<PodRepository>((ref) {
  return PodRepository();
});

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepository();
});

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
