import 'package:flutter/material.dart';
import 'package:mgt_life_spark/l10n/app_localizations.dart';

/// Minimal [MaterialApp] wrappers for widget tests that need l10n.
List<LocalizationsDelegate<dynamic>> get testLocalizationDelegates =>
    AppLocalizations.localizationsDelegates;

List<Locale> get testSupportedLocales => AppLocalizations.supportedLocales;
