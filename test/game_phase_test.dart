import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_phase.dart';

void main() {
  test('navigation order has five player-facing steps', () {
    expect(GamePhase.navigationOrder, [
      GamePhase.untap,
      GamePhase.draw,
      GamePhase.preCombatMain,
      GamePhase.combat,
      GamePhase.postCombatMain,
    ]);
  });

  test('next and previous walk the simplified loop', () {
    expect(GamePhase.untap.next, GamePhase.draw);
    expect(GamePhase.draw.next, GamePhase.preCombatMain);
    expect(GamePhase.preCombatMain.next, GamePhase.combat);
    expect(GamePhase.combat.next, GamePhase.postCombatMain);
    expect(GamePhase.postCombatMain.next, GamePhase.postCombatMain);

    expect(GamePhase.postCombatMain.previous, GamePhase.combat);
    expect(GamePhase.combat.previous, GamePhase.preCombatMain);
  });

  test('normalize maps legacy granular phases', () {
    expect(GamePhase.normalize('upkeep'), GamePhase.draw);
    expect(GamePhase.normalize('declareAttackers'), GamePhase.combat);
    expect(GamePhase.normalize('combatDamage'), GamePhase.combat);
    expect(GamePhase.normalize('endStep'), GamePhase.postCombatMain);
    expect(GamePhase.normalize('cleanup'), GamePhase.postCombatMain);
    expect(GamePhase.normalize('combat'), GamePhase.combat);
  });

  test('postCombatMain is the final navigable phase', () {
    expect(GamePhase.postCombatMain.isFinalPhase, isTrue);
    expect(GamePhase.combat.isFinalPhase, isFalse);
  });
}
