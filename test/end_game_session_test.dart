import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/core/game/session_exit_helpers.dart';

PlayerGameState _p(String id, {int life = 40}) => PlayerGameState(
      playerId: id,
      username: id,
      playerColor: Colors.blue,
      life: life,
    );

void main() {
  group('end-game session helpers', () {
    test('stableMatchId is deterministic for the same start + local id', () {
      final start = DateTime(2026, 7, 28, 12);
      final a = GameState(
        players: [_p('alice')],
        turnOrder: const ['alice'],
        localPlayerId: 'alice',
        gameOver: true,
        gameStartTime: start,
      );
      expect(stableMatchIdForGame(a), '${start.millisecondsSinceEpoch}_alice');
      expect(stableMatchIdForGame(a.copyWith()), stableMatchIdForGame(a));
    });

    test('stableMatchId is null without start time', () {
      final game = GameState(
        players: [_p('alice')],
        turnOrder: const ['alice'],
        localPlayerId: 'alice',
        gameOver: true,
      );
      expect(stableMatchIdForGame(game), isNull);
    });
  });
}
