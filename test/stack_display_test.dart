import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/stack_display.dart';
import 'package:mgt_life_spark/core/game/stack_item.dart';

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
}
