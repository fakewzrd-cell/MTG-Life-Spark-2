import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../core/game/stack_item.dart';
import '../../../core/services/haptic_service.dart';
import 'commander_damage_panel.dart';
import 'gameplay_dials_strip_widget.dart';
import 'life_counter_widget.dart';

/// HUD header rebuild trigger — keeps commander bar live on every tab.
int gameHudHeaderRebuildFingerprint(GameState game) {
  final local = game.localPlayer;
  final opponents =
      game.players.where((p) => p.playerId != game.localPlayerId).toList();
  return Object.hash(
    game.roundNumber,
    game.activePlayerId,
    local?.commanderCastCount,
    local?.allyPlayerId,
    local?.commanderName,
    local?.hasPartner,
    local?.isEliminated,
    local?.totalCommanderDamageReceived,
    local != null ? maxCommanderDamageTrack(local, opponents) : 0,
    Object.hashAll(local?.commanderColorIdentity ?? const []),
  );
}

/// Play-tab rebuild trigger — excludes life so life taps stay scoped to [ScopedLifeCounter].
int playTabRebuildFingerprint(GameState game) {
  final local = game.localPlayer;
  return Object.hash(
    game.currentPhase,
    game.activePlayerId,
    game.isHost,
    game.timeoutActive,
    game.isLocalPlayersTurn,
    game.pendingProposalFor(local?.playerId ?? ''),
    game.turnStartTime,
    game.turnTimeLimitSeconds,
    game.trackTurnDuration,
    local?.isEliminated,
    localPlayerDialFingerprint(local),
    gameHudHeaderRebuildFingerprint(game),
  );
}

/// Stack-tab rebuild trigger — stack list + player metadata for filters.
int stackTabRebuildFingerprint(GameState game) {
  return Object.hash(
    game.isHost,
    game.localPlayerId,
    Object.hashAll(
      game.stackItems.map(
        (StackItem i) => Object.hash(
          i.id,
          i.name,
          i.playerId,
          i.parentId,
          i.status,
          i.createdAt,
        ),
      ),
    ),
    Object.hashAll(
      game.players.map(
        (PlayerGameState p) =>
            Object.hash(p.playerId, p.username, p.playerColor, p.isEliminated),
      ),
    ),
  );
}

/// Fingerprint of dial-related fields — life changes do not affect this hash.
int localPlayerDialFingerprint(PlayerGameState? player) {
  if (player == null) return 0;
  return Object.hash(
    player.isEliminated,
    player.poison,
    player.energy,
    player.experience,
    player.rad,
    Object.hashAll(player.visibleGameplayDials),
    Object.hashAllUnordered(player.extraDials.entries),
    Object.hashAllUnordered(player.customDialLabels.entries),
  );
}

/// Life counter that rebuilds only when life / elimination / colors change.
///
/// Sizes itself to whatever height its parent gives it (its own internal
/// `LayoutBuilder` derives font sizes from those constraints) — callers
/// should bound it with `Expanded`/`ConstrainedBox` rather than passing a
/// pre-computed pixel height.
class ScopedLifeCounter extends ConsumerWidget {
  const ScopedLifeCounter({
    super.key,
    required this.playerId,
    required this.onLifeChange,
  });

  final String playerId;
  final void Function(int delta) onLifeChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(
      gameProvider.select((game) {
        final player = game.playerById(playerId);
        if (player == null) return null;
        return (
          player.life,
          player.isEliminated,
          player.playerColor,
          Object.hashAll(player.commanderColorIdentity),
        );
      }),
    );

    if (snapshot == null) {
      return const SizedBox.shrink();
    }

    final (life, isEliminated, playerColor, _) = snapshot;
    final player = ref.read(gameProvider).playerById(playerId)!;

    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        child: LifeCounterWidget(
          life: life,
          playerColor: playerColor,
          commanderColorIdentity: player.commanderColorIdentity,
          isEliminated: isEliminated,
          onLifeChange: onLifeChange,
          onHaptic: () => ref.read(hapticServiceProvider).light(),
        ),
      ),
    );
  }
}

/// Dial strip that rebuilds when counters/dial layout change, not on life-only updates.
class ScopedGameplayDials extends ConsumerWidget {
  const ScopedGameplayDials({
    super.key,
    required this.playerId,
    required this.onAdjustCounter,
    required this.onSetCounterAbsolute,
    required this.onRegisterCustomDial,
    required this.onAddDialToStrip,
    required this.onRemoveDialFromStrip,
    this.compactVertical = false,
  });

  final String playerId;
  final void Function(String field, int delta) onAdjustCounter;
  final void Function(String field, int absoluteValue) onSetCounterAbsolute;
  final bool Function(String dialKey, String label) onRegisterCustomDial;
  final bool Function(String field) onAddDialToStrip;
  final void Function(String field) onRemoveDialFromStrip;
  final bool compactVertical;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(
      gameProvider.select(
        (g) => localPlayerDialFingerprint(g.playerById(playerId)),
      ),
    );
    final player = ref.read(gameProvider).playerById(playerId);
    if (player == null) return const SizedBox.shrink();

    return RepaintBoundary(
      child: GameplayDialsStripWidget(
        getPlayer: () => ref.read(gameProvider).playerById(playerId)!,
        isEliminated: player.isEliminated,
        compactVertical: compactVertical,
        onAdjustCounter: onAdjustCounter,
        onSetCounterAbsolute: onSetCounterAbsolute,
        onRegisterCustomDial: onRegisterCustomDial,
        onAddDialToStrip: onAddDialToStrip,
        onRemoveDialFromStrip: onRemoveDialFromStrip,
      ),
    );
  }
}
