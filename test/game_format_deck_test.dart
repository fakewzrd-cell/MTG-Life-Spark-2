import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/game/game_format.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';

void main() {
  group('PlayerDeck format', () {
    test('matchesLobbyFormat when formats align', () {
      final deck = PlayerDeck.create(
        displayName: 'Azorius Control',
        format: GameFormat.standard,
        commanderName: 'Teferi, Hero of Dominaria',
      );
      expect(deck.matchesLobbyFormat(GameFormat.standard), isTrue);
      expect(deck.matchesLobbyFormat(GameFormat.commander), isFalse);
    });

    test('isCommanderDeck only for commander format', () {
      final cmd = PlayerDeck.create(
        displayName: 'EDH',
        format: GameFormat.commander,
        commanderName: 'Atraxa',
      );
      final std = PlayerDeck.create(
        displayName: 'Std',
        format: GameFormat.standard,
        commanderName: 'Lightning Bolt',
      );
      expect(cmd.isCommanderDeck, isTrue);
      expect(std.isCommanderDeck, isFalse);
      expect(std.hasPartner, isFalse);
    });

    test('create clears partner for constructed', () {
      final deck = PlayerDeck.create(
        displayName: 'Rakdos',
        format: GameFormat.modern,
        commanderName: 'Ragavan',
        partnerCommanderName: 'Should Not Stick',
      );
      expect(deck.partnerCommanderName, isNull);
      expect(deck.format, GameFormat.modern.name);
    });
  });

  group('GameFormatDetails', () {
    test('fromDisplayName parses settings labels', () {
      expect(
        GameFormatDetails.fromDisplayName('Standard'),
        GameFormat.standard,
      );
      expect(
        GameFormatDetails.fromDisplayName('Commander'),
        GameFormat.commander,
      );
    });

    test('fromName parses hive keys', () {
      expect(GameFormatDetails.fromName('pioneer'), GameFormat.pioneer);
    });
  });
}
