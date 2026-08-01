import 'package:flutter/material.dart';

import '../../ui/theme/app_color_tokens.dart';

/// Maps Scryfall `color_identity` letters (W,U,B,R,G) to splash colors for gameplay chrome.
abstract final class CommanderIdentityColors {
  static const Map<String, Color> mana = {
    'W': Color(0xFFF8F6D8),
    'U': Color(0xFF0E68AB),
    'B': Color(0xFF494949),
    'R': Color(0xFFD32029),
    'G': Color(0xFF00733E),
  };

  /// Gradient stops for scaffold / overview / life counter — follows [colors].
  static List<Color> gameplayGradient(
    AppColorTokens colors, [
    List<String> identity = const [],
  ]) {
    final base = colors.backgroundPrimary;
    final mid = colors.backgroundSecondary;
    final end = colors.surface;
    final brand = colors.primaryAccent;
    final soft = Color.lerp(brand, base, 0.82)!;

    return [
      base,
      Color.lerp(base, soft, 0.08)!,
      Color.lerp(mid, brand, 0.10)!,
      Color.lerp(end, brand, 0.06)!.withValues(alpha: 0.95),
    ];
  }

  /// Accent for phase nav, tabs, and HUD chrome — brand tint, not seat color.
  static Color gameChromeAccent(
    AppColorTokens colors, [
    List<String> identity = const [],
  ]) {
    if (identity.isEmpty) return colors.primaryAccent;
    final tint = _identityTint(identity, colors.primaryAccent);
    return Color.lerp(colors.primaryAccent, tint, 0.12)!;
  }

  static Color emphasisBorder(
    AppColorTokens colors, [
    List<String> identity = const [],
  ]) {
    final soft = Color.lerp(colors.primaryAccent, colors.backgroundPrimary, 0.65)!;
    return Color.lerp(
      soft,
      gameChromeAccent(colors, identity),
      0.35,
    )!;
  }

  /// Blended WUBRG tint for a commander (falls back to app accent when unknown).
  static Color identityTint(AppColorTokens colors, List<String> identity) {
    return _identityTint(identity, colors.primaryAccent);
  }

  static Color _identityTint(List<String> identity, Color fallback) {
    if (identity.isEmpty) return fallback;
    if (identity.length == 1) {
      return mana[identity.first] ?? fallback;
    }
    final first = mana[identity.first] ?? fallback;
    final second = mana[identity[1]] ?? fallback;
    return Color.lerp(first, second, 0.5)!;
  }
}
