import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/lobby_state.dart';
import 'package:mgt_life_spark/core/game/progression_service.dart';
import 'package:mgt_life_spark/core/models/game_feedback.dart';
import 'package:mgt_life_spark/core/persistence/achievement_repository.dart';
import 'package:mgt_life_spark/core/persistence/deck_repository.dart';
import 'package:mgt_life_spark/core/persistence/feedback_repository.dart';
import 'package:mgt_life_spark/core/persistence/match_repository.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';

import 'test_profile_repository.dart';

/// Records matches in-memory for widget tests (no Hive writes).
class TestProgressionService extends ProgressionService {
  TestProgressionService()
      : super(
          profileRepo: TestProfileRepository(
            profile: PlayerProfile(username: 'tester'),
          ),
          achievementRepo: AchievementRepository(),
          matchRepo: MatchRepository(),
          feedbackRepo: FeedbackRepository(),
          deckRepo: DeckRepository(),
        );

  int recordMatchCalls = 0;

  @override
  Future<ProgressResult> recordMatch({
    required GameState finalState,
    required LobbyState lobbyState,
    required DateTime startTime,
    String? matchId,
  }) async {
    recordMatchCalls++;
    return const ProgressResult(
      matchId: 'test-match-1',
      xpGained: 50,
      oldLevel: 1,
      newLevel: 1,
      newAchievementIds: [],
    );
  }

  @override
  Future<void> saveFeedback(
    GameFeedback feedback, {
    bool awardGiverXp = true,
  }) async {}
}
