import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/features/profile/profile_player_stats_section.dart';

void main() {
  PlayerDeck deck({
    required String id,
    required int wins,
    required int losses,
  }) {
    return PlayerDeck(
      id: id,
      displayName: id,
      commanderName: 'Commander $id',
      wins: wins,
      losses: losses,
      gamesPlayed: wins + losses,
    );
  }

  group('pickMostPlayedDeck', () {
    test('picks deck with most games, then more wins', () {
      final top = pickMostPlayedDeck([
        deck(id: 'a', wins: 1, losses: 1),
        deck(id: 'b', wins: 3, losses: 0),
        deck(id: 'c', wins: 2, losses: 1),
      ]);
      expect(top?.id, 'b');
    });

    test('returns null when no played decks', () {
      expect(
        pickMostPlayedDeck([
          deck(id: 'fresh', wins: 0, losses: 0),
        ]),
        isNull,
      );
    });
  });

  group('pickWorstDeck', () {
    test('ignores undefeated decks', () {
      final worst = pickWorstDeck([
        deck(id: 'winner', wins: 1, losses: 0),
        deck(id: 'perfect', wins: 5, losses: 0),
      ]);
      expect(worst, isNull);
    });

    test('picks lowest win rate among decks with losses', () {
      final worst = pickWorstDeck([
        deck(id: 'winner', wins: 3, losses: 0),
        deck(id: 'struggling', wins: 1, losses: 3),
        deck(id: 'ok', wins: 2, losses: 2),
      ]);
      expect(worst?.id, 'struggling');
    });
  });
}
