import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/deck_style.dart';
import 'package:mgt_life_spark/l10n/app_localizations_en.dart';
import 'package:mgt_life_spark/l10n/app_localizations_es.dart';
import 'package:mgt_life_spark/shared/utils/deck_style_l10n.dart';

void main() {
  group('localizedDeckStyleName', () {
    test('English matches canonical displayName', () {
      final l10n = AppLocalizationsEn();
      for (final style in DeckStyle.values) {
        expect(
          localizedDeckStyleName(l10n, style),
          style.displayName,
          reason: style.id,
        );
      }
    });

    test('Spanish translates Tokens and Control', () {
      final l10n = AppLocalizationsEs();
      expect(
        localizedDeckStyleName(l10n, DeckStyle.tokens),
        'Fichas',
      );
      expect(
        localizedDeckStyleName(l10n, DeckStyle.control),
        'Control',
      );
      expect(
        localizedDeckStyleDescription(l10n, DeckStyle.mill),
        isNot(equals(DeckStyle.mill.description)),
      );
    });
  });
}
