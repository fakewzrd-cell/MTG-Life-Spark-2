import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/persistence/providers.dart';
import '../../core/persistence/settings_repository.dart';
import '../../ui/tokens/app_color_palettes.dart';
import '../../ui/tokens/color_tokens.dart';
import 'app_theme.dart';

/// User's color scheme preference (persisted).
final colorSchemePreferenceProvider =
    StateNotifierProvider<ColorSchemePreferenceNotifier, AppColorSchemeId>(
        (ref) {
  final repo = ref.read(settingsRepositoryProvider);
  final initial = AppColorPalettes.parse(repo.settings.colorSchemeId);
  ColorTokens.applyScheme(initial);
  return ColorSchemePreferenceNotifier(initial, repo);
});

class ColorSchemePreferenceNotifier extends StateNotifier<AppColorSchemeId> {
  ColorSchemePreferenceNotifier(super.initial, this._repo);

  final SettingsRepository _repo;

  Future<void> setColorScheme(AppColorSchemeId id) async {
    if (state == id) return;
    state = id;
    ColorTokens.applyScheme(id);
    _invalidateThemeCache();
    final s = _repo.settings;
    s.colorSchemeId = AppColorPalettes.storageKey(id);
    await _repo.update(s);
  }

  /// Re-read scheme from Hive after an external settings write (e.g. restore).
  void hydrateFromRepository() {
    final id = AppColorPalettes.parse(_repo.settings.colorSchemeId);
    ColorTokens.applyScheme(id);
    _invalidateThemeCache();
    if (state != id) state = id;
  }
}

ThemeData? _cachedDarkTheme;
ThemeData? _cachedLightTheme;
AppColorSchemeId? _cachedSchemeId;

void _invalidateThemeCache() {
  _cachedDarkTheme = null;
  _cachedLightTheme = null;
  _cachedSchemeId = null;
}

ThemeData _darkTheme(AppColorSchemeId schemeId) {
  if (_cachedDarkTheme != null && _cachedSchemeId == schemeId) {
    return _cachedDarkTheme!;
  }
  ColorTokens.applyScheme(schemeId);
  _cachedSchemeId = schemeId;
  return _cachedDarkTheme = AppTheme.dark();
}

ThemeData _lightTheme(AppColorSchemeId schemeId) {
  if (_cachedLightTheme != null && _cachedSchemeId == schemeId) {
    return _cachedLightTheme!;
  }
  ColorTokens.applyScheme(schemeId);
  _cachedSchemeId = schemeId;
  return _cachedLightTheme = AppTheme.light();
}

/// Dark theme tinted by the selected color scheme.
final appDarkThemeProvider = Provider<ThemeData>((ref) {
  final schemeId = ref.watch(colorSchemePreferenceProvider);
  return _darkTheme(schemeId);
});

/// Light theme tinted by the selected color scheme.
final appLightThemeProvider = Provider<ThemeData>((ref) {
  final schemeId = ref.watch(colorSchemePreferenceProvider);
  return _lightTheme(schemeId);
});

/// Follows Settings → Appearance → Dark appearance.
final themeModeProvider = Provider<ThemeMode>((ref) {
  ref.watch(settingsRevisionProvider);
  final useDark = ref.read(settingsRepositoryProvider).settings.useDarkTheme;
  return useDark ? ThemeMode.dark : ThemeMode.light;
});

/// Back-compat alias for widgets/tests that expect a single resolved theme.
final effectiveThemeProvider = Provider<ThemeData>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == ThemeMode.light
      ? ref.watch(appLightThemeProvider)
      : ref.watch(appDarkThemeProvider);
});
