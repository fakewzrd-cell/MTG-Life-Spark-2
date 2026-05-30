import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/deck_style.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/game/game_format.dart';

void main() {
  group('DeckStyle', () {
    test('fromId resolves known styles', () {
      expect(DeckStyle.fromId('group_hug'), DeckStyle.groupHug);
      expect(DeckStyle.fromId('steal_theft'), DeckStyle.stealTheft);
      expect(DeckStyle.fromId(''), isNull);
      expect(DeckStyle.fromId('unknown'), isNull);
    });

    test('values count matches archetype list', () {
      expect(DeckStyle.values.length, 23);
    });
  });

  group('PlayerDeck deck style', () {
    test('hasDeckStyle when id is valid', () {
      final deck = PlayerDeck.create(
        displayName: 'Test',
        format: GameFormat.commander,
        deckStyleId: DeckStyle.mill.id,
        commanderName: 'Bruvac',
      );
      expect(deck.hasDeckStyle, isTrue);
      expect(deck.deckStyleDisplayName, 'Mill');
    });

    test('unset style shows required label', () {
      final deck = PlayerDeck(
        id: 'x',
        displayName: 'Legacy',
        commanderName: 'Sol Ring',
      );
      expect(deck.hasDeckStyle, isFalse);
      expect(deck.deckStyleDisplayName, DeckStyle.unsetLabel);
    });
  });
}
