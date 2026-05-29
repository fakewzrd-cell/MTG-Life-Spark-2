import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/game_state_notifier.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/core/game/progression_service.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';
import 'package:mgt_life_spark/shared/theme/app_theme.dart';

import 'fake_ble_service.dart';
import 'test_profile_repository.dart';
import 'test_progression_service.dart';

PlayerGameState harnessPlayer({
  required String id,
  int life = 40,
  bool eliminated = false,
}) {
  return PlayerGameState(
    playerId: id,
    username: id,
    playerColor: Colors.blue,
    life: life,
    isEliminated: eliminated,
    eliminationReason: eliminated ? 'concede' : null,
  );
}

GameState harnessGame({
  required String localId,
  bool gameOver = false,
  String? winnerId,
  List<PlayerGameState>? players,
}) {
  final ps = players ??
      [
        harnessPlayer(id: 'alice'),
        harnessPlayer(id: 'bob'),
      ];
  return GameState(
    players: ps,
    turnOrder: ps.map((p) => p.playerId).toList(),
    localPlayerId: localId,
    gameStartTime: DateTime(2026, 1, 1),
    gameOver: gameOver,
    winnerPlayerId: winnerId,
    autoKoFromCommanderDamage: true,
    commanderDamageReducesLife: true,
  );
}

List<Override> gameTestOverrides({
  required GameState game,
  ProgressionService? progression,
}) {
  final ble = FakeBleService();
  return [
    sessionServiceProvider.overrideWith((ref) => ble),
    profileRepositoryProvider.overrideWithValue(TestProfileRepository()),
    progressionServiceProvider.overrideWithValue(
      progression ?? TestProgressionService(),
    ),
    gameProvider.overrideWith((ref) {
      final notifier = GameStateNotifier(ref);
      notifier.setGameStateForTest(game);
      return notifier;
    }),
  ];
}

Widget wrapGameWidget({
  required Widget child,
  required GameState game,
  ProgressionService? progression,
  List<Override> extraOverrides = const [],
}) {
  return ProviderScope(
    overrides: [
      ...gameTestOverrides(game: game, progression: progression),
      ...extraOverrides,
    ],
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: child,
    ),
  );
}
