import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../debug/app_log.dart';
import '../models/game_feedback.dart';
import 'game_state.dart';
import 'game_state_notifier.dart';
import 'player_game_state.dart';
import 'scryfall_service.dart';

/// The single source of truth for the active game session.
final gameProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier(ref);
});

/// Convenience: local player's game state (null when not in a game).
final localPlayerProvider = Provider<PlayerGameState?>((ref) {
  return ref.watch(gameProvider).localPlayer;
});

/// Convenience: the current active player's ID.
final activePlayerIdProvider = Provider<String>((ref) {
  return ref.watch(gameProvider).activePlayerId;
});

/// Convenience: true when the game is over.
final gameOverProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider).gameOver;
});

/// Feedback given when conceding, saved when game ends.
final pendingFeedbackProvider =
    StateProvider<PendingFeedbackData?>((ref) => null);

/// Variant decks (planar, scheme, bounty) loaded from Scryfall when enabled.
/// Returns null keys when not enabled or loading failed.
final variantDecksProvider =
    FutureProvider<Map<String, List<ScryfallCard>>>((ref) async {
  final flags = ref.watch(
    gameProvider.select(
      (g) => (
        planechaseEnabled: g.planechaseEnabled,
        archenemyEnabled: g.archenemyEnabled,
        bountyEnabled: g.bountyEnabled,
      ),
    ),
  );
  if (!flags.planechaseEnabled &&
      !flags.archenemyEnabled &&
      !flags.bountyEnabled) {
    return {};
  }
  final service = ref.read(scryfallServiceProvider);
  final result = <String, List<ScryfallCard>>{};
  if (flags.planechaseEnabled) {
    try {
      result['planar'] = await service.fetchPlanarDeck();
    } catch (e, st) {
      appLog('fetchPlanarDeck failed', error: e, stackTrace: st);
      result['planar'] = [];
    }
  }
  if (flags.archenemyEnabled) {
    try {
      result['scheme'] = await service.fetchSchemeDeck();
    } catch (e, st) {
      appLog('fetchSchemeDeck failed', error: e, stackTrace: st);
      result['scheme'] = [];
    }
  }
  if (flags.bountyEnabled) {
    try {
      result['bounty'] = await service.fetchBountyDeck();
    } catch (e, st) {
      appLog('fetchBountyDeck failed', error: e, stackTrace: st);
      result['bounty'] = [];
    }
  }
  return result;
});
