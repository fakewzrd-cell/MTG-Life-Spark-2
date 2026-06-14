import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_feedback.dart';
import '../persistence/providers.dart';
import 'game_providers.dart';
import 'game_state.dart';
import 'lobby_state.dart';
import 'progression_service.dart';

/// Stable match id shared with [EndGameScreen].
String? stableMatchIdForGame(GameState game) {
  if (game.gameStartTime == null || game.localPlayerId.isEmpty) return null;
  return '${game.gameStartTime!.millisecondsSinceEpoch}_${game.localPlayerId}';
}

/// True when the local player forfeited but the table may still be playing.
bool localConcededWhileTableActive(WidgetRef ref) {
  final game = ref.read(gameProvider);
  final local = game.localPlayer;
  if (local == null || !local.isEliminated) return false;
  if (local.eliminationReason != 'concede') return false;
  return !game.gameOver;
}

/// Persists concede stats/feedback before leaving a still-active session.
Future<void> recordLocalConcedeBeforeExit(WidgetRef ref) async {
  final game = ref.read(gameProvider);
  final local = game.localPlayer;
  if (local == null ||
      !local.isEliminated ||
      local.eliminationReason != 'concede') {
    return;
  }

  final matchId = stableMatchIdForGame(game);
  if (matchId == null) return;
  if (ref.read(matchRepositoryProvider).hasMatch(matchId)) return;

  final service = ref.read(progressionServiceProvider);
  final lobby = ref.read(lobbyProvider);

  await service.recordMatch(
    finalState: game,
    lobbyState: lobby,
    startTime: game.gameStartTime ?? DateTime.now(),
    matchId: matchId,
  );

  final pending = ref.read(pendingFeedbackProvider);
  if (pending?.hasContent ?? false) {
    await service.saveFeedback(GameFeedback(
      matchId: matchId,
      voterPlayerId: game.localPlayerId,
      likePlayerIds: pending!.likePlayerIds,
      dislikePlayerIds: pending.dislikePlayerIds,
      mvpPlayerId: pending.mvpPlayerId,
      teamPlayerId: pending.teamPlayerId,
      underdogPlayerId: pending.underdogPlayerId,
    ));
    ref.read(pendingFeedbackProvider.notifier).state = null;
  }

  bumpProfileRevision(ref);
  bumpDeckListRevision(ref);
}
