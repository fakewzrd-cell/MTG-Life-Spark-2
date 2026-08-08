import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/match_record.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/shared/utils/commander_image_resolver.dart';

void main() {
  group('resolveCommanderArtByName', () {
    test('does not use profile art when selected commander differs', () {
      final profile = PlayerProfile(
        playerId: 'p1',
        username: 'Host',
        selectedCommanderName: 'Atraxa, Praetors\' Voice',
        selectedCommanderImageUrl: 'https://example.com/atraxa.jpg',
      );

      final url = resolveCommanderArtByName(
        commanderName: 'Krenko, Mob Boss',
        decks: const [],
        profile: profile,
      );

      expect(url, isNull);
    });

    test('uses profile art only when selected name matches', () {
      final profile = PlayerProfile(
        playerId: 'p1',
        username: 'Host',
        selectedCommanderName: 'Krenko, Mob Boss',
        selectedCommanderImageUrl: 'https://example.com/krenko.jpg',
      );

      final url = resolveCommanderArtByName(
        commanderName: 'Krenko, Mob Boss',
        decks: const [],
        profile: profile,
      );

      expect(url, 'https://example.com/krenko.jpg');
    });

    test('prefers matching deck art over mismatched profile art', () {
      final profile = PlayerProfile(
        playerId: 'p1',
        username: 'Host',
        selectedCommanderName: 'Atraxa, Praetors\' Voice',
        selectedCommanderImageUrl: 'https://example.com/atraxa.jpg',
      );
      final deck = PlayerDeck(
        id: 'd1',
        displayName: 'Goblin tribal',
        commanderName: 'Krenko, Mob Boss',
        format: 'Commander',
        commanderImageUrl: 'https://example.com/krenko.jpg',
      );

      final url = resolveCommanderArtByName(
        commanderName: 'Krenko, Mob Boss',
        decks: [deck],
        profile: profile,
      );

      expect(url, 'https://example.com/krenko.jpg');
    });

    test('falls back to local match snapshot art', () {
      final profile = PlayerProfile(playerId: 'p1', username: 'Host');
      final match = MatchRecord(
        matchId: 'm1',
        date: DateTime(2026, 8, 8),
        commanderName: 'Krenko, Mob Boss',
        opponentNames: const ['Opp'],
        result: 'win',
        eliminationReason: 'survived',
        format: 'Commander',
        durationMinutes: 40,
        startingLifeTotal: 40,
        playerCount: 2,
        participantsJson:
            '[{"playerId":"p1","username":"Host","commanderName":"Krenko, Mob Boss","commanderImageUrl":"https://example.com/krenko.jpg","teamIndex":0,"isWinner":true,"placementRank":1}]',
      );

      final url = resolveCommanderArtByName(
        commanderName: 'Krenko, Mob Boss',
        decks: const [],
        profile: profile,
        matches: [match],
        localPlayerId: 'p1',
      );

      expect(url, 'https://example.com/krenko.jpg');
    });
  });
}
