import 'package:flutter/material.dart';

import '../../shared/theme/app_theme.dart';

/// Maps Scryfall `color_identity` letters (W,U,B,R,G) to splash colors for gameplay chrome.
abstract final class CommanderIdentityColors {
  static const Map<String, Color> mana = {
    'W': Color(0xFFF8F6D8),
    'U': Color(0xFF0E68AB),
    'B': Color(0xFF494949),
    'R': Color(0xFFD32029),
    'G': Color(0xFF00733E),
  };

  /// Gradient stops for scaffold background (deep purple base + identity accents).
  static List<Color> gameplayGradient(List<String> identity, Color fallbackAccent) {
    if (identity.isEmpty) {
      return [
        AppTheme.primary,
        Color.lerp(AppTheme.primary, fallbackAccent, 0.35)!,
        AppTheme.surface,
      ];
    }
    final accents = identity.map((k) => mana[k] ?? fallbackAccent).toList();
    return [
      AppTheme.primary,
      Color.lerp(accents.first, AppTheme.primary, 0.55)!,
      if (accents.length > 1)
        Color.lerp(accents[1], AppTheme.surface, 0.4)!
      else
        Color.lerp(accents.first, AppTheme.surface, 0.35)!,
      AppTheme.surface.withValues(alpha: 0.92),
    ];
  }

  static Color emphasisBorder(List<String> identity, Color fallback) {
    if (identity.isEmpty) return fallback;
    final c = mana[identity.first] ?? fallback;
    return Color.lerp(c, fallback, 0.45)!;
  }
}
