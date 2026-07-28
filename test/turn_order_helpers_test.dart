import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';

PlayerGameState _p(String id, {int life = 40}) => PlayerGameState(
      playerId: id,
      username: id,
      playerColor: Colors.blue,
      life: life,
    );

void main() {
  test('playersInTurnOrder follows turnOrder and appends missing', () {
    final game = GameState(
      localPlayerId: 'a',
      players: [_p('a'), _p('b'), _p('c')],
      turnOrder: const ['c', 'a'],
      activePlayerIndex: 0,
    );
    expect(
      game.playersInTurnOrder.map((p) => p.playerId).toList(),
      ['c', 'a', 'b'],
    );
  });

  test('playersInTurnOrderFrom rotates to start player', () {
    final game = GameState(
      localPlayerId: 'a',
      players: [_p('a'), _p('b'), _p('c')],
      turnOrder: const ['a', 'b', 'c'],
      activePlayerIndex: 1,
    );
    expect(
      game.playersInTurnOrderFrom('b').map((p) => p.playerId).toList(),
      ['b', 'c', 'a'],
    );
    expect(game.activePlayerId, 'b');
  });

  test('groupTurnOrderByTeams clusters teammates without jumping to front', () {
    // Assigning only C to team 1 must not move C before A/B.
    expect(
      GameState.groupTurnOrderByTeams(
        const ['a', 'b', 'c', 'd'],
        const {'c': 1},
      ),
      ['a', 'b', 'c', 'd'],
    );
  });

  test('groupTurnOrderByTeams pulls later teammate up to first teammate', () {
    expect(
      GameState.groupTurnOrderByTeams(
        const ['a', 'b', 'c', 'd'],
        const {'b': 1, 'd': 1},
      ),
      ['a', 'b', 'd', 'c'],
    );
  });

  test('groupTurnOrderByTeams keeps multiple teams in encounter order', () {
    expect(
      GameState.groupTurnOrderByTeams(
        const ['a', 'b', 'c', 'd'],
        const {'a': 2, 'b': 1, 'c': 2, 'd': 0},
      ),
      ['a', 'c', 'b', 'd'],
    );
  });

  test('groupTurnOrderByTeams is a no-op when no teams assigned', () {
    expect(
      GameState.groupTurnOrderByTeams(
        const ['c', 'a', 'b'],
        const {'a': 0, 'b': 0, 'c': 0},
      ),
      ['c', 'a', 'b'],
    );
  });
}
