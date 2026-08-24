import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/shared/utils/app_locale.dart';

void main() {
  group('app locale helpers', () {
    test('system preference yields null locale', () {
      expect(localeFromPreference(null), isNull);
      expect(localeFromPreference(''), isNull);
      expect(localeFromPreference(kLocaleSystem), isNull);
    });

    test('parses phase-1 language codes', () {
      expect(localeFromPreference('en'), const Locale('en'));
      expect(localeFromPreference('es'), const Locale('es'));
      expect(localeFromPreference('fr'), const Locale('fr'));
      expect(localeFromPreference('de'), const Locale('de'));
      expect(localeFromPreference('ja'), const Locale('ja'));
      expect(
        localeFromPreference('pt_BR'),
        const Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
      );
    });

    test('preference code round-trips Portuguese', () {
      expect(
        localePreferenceCode(
          const Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
        ),
        'pt_BR',
      );
      expect(localePreferenceCode(null), kLocaleSystem);
    });
  });
}
