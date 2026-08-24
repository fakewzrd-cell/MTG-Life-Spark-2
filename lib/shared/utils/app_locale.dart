import 'package:flutter/material.dart';
import 'package:mgt_life_spark/l10n/app_localizations.dart';

/// Persisted preference: empty / `system` follows the device language.
const kLocaleSystem = 'system';

/// Phase 1 app locales (plus English template).
const kSupportedLocaleCodes = <String>[
  'en',
  'es',
  'pt_BR',
  'fr',
  'de',
  'ja',
];

/// Maps a stored locale code to a Flutter [Locale], or null for system default.
Locale? localeFromPreference(String? code) {
  final raw = (code ?? '').trim();
  if (raw.isEmpty || raw == kLocaleSystem) return null;
  if (raw == 'pt_BR' || raw == 'pt-BR') {
    return const Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR');
  }
  return Locale(raw);
}

String localePreferenceCode(Locale? locale) {
  if (locale == null) return kLocaleSystem;
  if (locale.languageCode == 'pt') return 'pt_BR';
  return locale.languageCode;
}

String languageLabel(AppLocalizations l10n, String code) {
  return switch (code) {
    kLocaleSystem => l10n.settingsLanguageSystem,
    'en' => l10n.languageEnglish,
    'es' => l10n.languageSpanish,
    'pt_BR' => l10n.languagePortugueseBrazil,
    'fr' => l10n.languageFrench,
    'de' => l10n.languageGerman,
    'ja' => l10n.languageJapanese,
    _ => code,
  };
}
