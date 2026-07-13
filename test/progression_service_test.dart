import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/core/game/progression_service.dart';

PlayerGameState _player(String id) => PlayerGameState(
      playerId: id,
      username: id,
      life: 40,
      playerColor: Colors.blue,
    );

GameState _state(List<String> ids) => GameState(
      players: ids.map(_player).toList(),
      turnOrder: ids,
      localPlayerId: ids.first,
    );

void main() {
  test('solo / practice does not award progression', () {
    expect(matchAwardsProgression(_state(['alice'])), isFalse);
  });

  test('multiplayer against opponents awards progression', () {
    expect(matchAwardsProgression(_state(['alice', 'bob'])), isTrue);
    expect(
      matchAwardsProgression(_state(['alice', 'bob', 'carol'])),
      isTrue,
    );
  });
}
