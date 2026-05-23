import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/game/game_providers.dart';
import '../../core/game/game_state.dart';
import '../../core/persistence/providers.dart';
import '../../core/persistence/settings_repository.dart';
import 'app_theme.dart';

/// User's theme preference (persisted). Updated by Settings and Day/Night.
final themePreferenceProvider =
    StateNotifierProvider<ThemePreferenceNotifier, bool>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return ThemePreferenceNotifier(repo.settings.useDarkTheme, repo);
});

class ThemePreferenceNotifier extends StateNotifier<bool> {
  ThemePreferenceNotifier(super.initial, this._repo);

  final SettingsRepository _repo;

  Future<void> setUseDarkTheme(bool value) async {
    state = value;
    final s = _repo.settings;
    s.useDarkTheme = value;
    await _repo.update(s);
  }
}

ThemeData? _cachedDarkTheme;
ThemeData? _cachedLightTheme;

ThemeData _darkTheme() => _cachedDarkTheme ??= AppTheme.dark();
ThemeData _lightTheme() => _cachedLightTheme ??= AppTheme.light();

/// Effective theme: when in game, Day/Night overrides settings.
/// Day → light, Night → dark, None → use settings.
///
/// Watches only day/night + in-game flag — not life/counters/phases.
final effectiveThemeProvider = Provider<ThemeData>((ref) {
  final useDarkTheme = ref.watch(themePreferenceProvider);
  final inGame = ref.watch(
    gameProvider.select((g) => g.players.isNotEmpty),
  );
  final dayNight = ref.watch(gameProvider.select((g) => g.dayNight));

  if (inGame) {
    switch (dayNight) {
      case DayNightState.day:
        return _lightTheme();
      case DayNightState.night:
        return _darkTheme();
      case DayNightState.none:
        return useDarkTheme ? _darkTheme() : _lightTheme();
    }
  }

  return useDarkTheme ? _darkTheme() : _lightTheme();
});
