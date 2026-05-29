import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/core/game/stack_display.dart';
import 'package:mgt_life_spark/core/game/stack_item.dart';

PlayerGameState _stackPlayer(String id) => PlayerGameState(
      playerId: id,
      username: id,
      playerColor: Colors.blue,
      life: 40,
    );

void main() {
  test('hasInvalidStackTarget when parent is countered', () {
    const parent = StackItem(
      id: 'p',
      playerId: 'a',
      name: 'Bolt',
      createdAt: 1,
      status: StackItemStatus.countered,
    );
    const child = StackItem(
      id: 'c',
      playerId: 'b',
      name: 'Protection',
      parentId: 'p',
      createdAt: 2,
    );
    expect(
      StackDisplay.hasInvalidStackTarget(child, [parent, child]),
      isTrue,
    );
  });

  test('resolved items show on stack', () {
    const resolved = StackItem(
      id: 'r',
      playerId: 'a',
      name: 'Bolt',
      createdAt: 1,
      status: StackItemStatus.resolved,
    );
    expect(resolved.showsOnStack, isTrue);
  });

  test('hasInvalidStackTarget false when parent still active', () {
    const parent = StackItem(
      id: 'p',
      playerId: 'a',
      name: 'Bolt',
      createdAt: 1,
    );
    const child = StackItem(
      id: 'c',
      playerId: 'b',
      name: 'Protection',
      parentId: 'p',
      createdAt: 2,
    );
    expect(
      StackDisplay.hasInvalidStackTarget(child, [parent, child]),
      isFalse,
    );
  });

  test('resolveOrderNumbers are chronological (1 = oldest active)', () {
    const items = [
      StackItem(id: 'a', playerId: 'p', name: 'Rift', createdAt: 100),
      StackItem(
        id: 'b',
        playerId: 'p',
        name: 'Swan',
        parentId: 'a',
        createdAt: 101,
      ),
      StackItem(
        id: 'c',
        playerId: 'p',
        name: 'Dispel',
        parentId: 'b',
        createdAt: 102,
      ),
    ];
    final numbers = StackDisplay.resolveOrderNumbers(items);
    expect(numbers['a'], 1);
    expect(numbers['b'], 2);
    expect(numbers['c'], 3);
    expect(StackDisplay.resolvesNextItem(items)?.id, 'c');
  });

  test('apnap order uses stack anchor instead of current active player', () {
    final game = GameState(
      players: [
        _stackPlayer('a'),
        _stackPlayer('b'),
        _stackPlayer('c'),
      ],
      turnOrder: const ['a', 'b', 'c'],
      activePlayerIndex: 2,
      stackApnapAnchorPlayerId: 'a',
      stackItems: const [
        StackItem(
          id: 's1',
          playerId: 'a',
          name: 'Spell',
          createdAt: 1,
        ),
      ],
    );

    expect(StackDisplay.apnapPlayerOrder(game), ['a', 'b', 'c']);
  });
}
