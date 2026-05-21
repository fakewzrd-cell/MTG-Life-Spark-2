import 'package:flutter/material.dart';

/// MTG Life Spark color system — **dark-first**, minimal palette.
///
/// ### Structure (best practice)
/// - **Neutrals** — 4 surface steps + 1 border + 3 text levels (no extra grays in UI chrome).
/// - **Brand** — single red primary for actions, selection, and M3 `primary` role.
/// - **Semantic** — success / warning / error only for status (not navigation or cards).
/// - **Emphasis** — warm amber alias for in-game highlights (monarch, timers); not used in shell chrome.
/// - **Player** — 6 distinct hues for multiplayer identification only.
///
/// Shell UI (nav, cards, app bars) uses **primary** tints — not orange or green.
class ColorTokens {
  ColorTokens._();

  // ══════════════════════════════════════════════════════════════════════════
  // Brand
  // ══════════════════════════════════════════════════════════════════════════

  static const Color brandBlack = Color(0xFF0E0E0E);
  static const Color brandRed = Color(0xFFD41414);
  static const Color onAccent = Color(0xFFFFFFFF);

  // ══════════════════════════════════════════════════════════════════════════
  // Dark neutrals (Material-style elevation steps)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color backgroundPrimary = brandBlack;
  static const Color backgroundSecondary = Color(0xFF121212);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color borderSubtle = Color(0xFF2E2E2E);

  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textMuted = Color(0xFF6B6B6B);

  // ══════════════════════════════════════════════════════════════════════════
  // Semantic (status only)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  /// In-game warm highlight (monarch, energy, etc.). Prefer over raw orange in features.
  static const Color emphasis = warning;

  // ══════════════════════════════════════════════════════════════════════════
  // Aliases (backward compatibility — do not use in new shell UI)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color primaryAccent = brandRed;
  static const Color optionalAccent = success;
  static const Color blueprintOrange = emphasis;
  static const Color accentGold = emphasis;
  static const Color dangerAmber = warning;

  // ══════════════════════════════════════════════════════════════════════════
  // Player identification (multiplayer only — not app chrome)
  // ══════════════════════════════════════════════════════════════════════════

  static const List<Color> playerPalette = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFCA28),
    Color(0xFFAB47BC),
    Color(0xFFFF7043),
  ];

  static Color playerColor(int index) =>
      playerPalette[index % playerPalette.length];

  // ══════════════════════════════════════════════════════════════════════════
  // Light theme neutrals
  // ══════════════════════════════════════════════════════════════════════════

  static const Color lightBackgroundPrimary = Color(0xFFF5F5F5);
  static const Color lightBackgroundSecondary = Color(0xFFEEEEEE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F0F0);
  static const Color lightBorderSubtle = Color(0xFFD4D4D4);
  static const Color lightTextPrimary = Color(0xFF0E0E0E);
  static const Color lightTextSecondary = Color(0xFF525252);
  static const Color lightTextMuted = Color(0xFF737373);
  static const Color lightPrimaryAccent = brandRed;

  // ══════════════════════════════════════════════════════════════════════════
  // M3 ColorScheme roles — dark (tonal, derived from brand + neutrals)
  // ══════════════════════════════════════════════════════════════════════════

  static const Color darkPrimaryContainer = Color(0xFF3A1515);
  static const Color darkOnPrimaryContainer = Color(0xFFFFD6D6);
  static const Color darkSecondary = Color(0xFF9E9E9E);
  static const Color darkOnSecondary = Color(0xFF0E0E0E);
  static const Color darkSecondaryContainer = Color(0xFF252525);
  static const Color darkOnSecondaryContainer = Color(0xFFE0E0E0);
  static const Color darkTertiary = Color(0xFF8C8C8C);
  static const Color darkOnTertiary = Color(0xFF0E0E0E);
  static const Color darkTertiaryContainer = Color(0xFF2A2A2A);
  static const Color darkOnTertiaryContainer = Color(0xFFE5E5E5);
  static const Color darkOutlineVariant = borderSubtle;
  static const Color darkErrorContainer = Color(0xFF3D1515);
  static const Color darkOnErrorContainer = Color(0xFFFFD6D6);
  static const Color darkInverseSurface = Color(0xFFE8E8E8);
  static const Color darkOnInverseSurface = Color(0xFF0E0E0E);
  static const Color darkInversePrimary = Color(0xFFFF8A80);
  static const Color darkSurfaceContainerLowest = Color(0xFF080808);
  static const Color darkSurfaceContainerLow = Color(0xFF101010);
  static const Color darkSurfaceContainerHighest = surfaceElevated;

  // ══════════════════════════════════════════════════════════════════════════
  // M3 ColorScheme roles — light
  // ══════════════════════════════════════════════════════════════════════════

  static const Color lightPrimaryContainer = Color(0xFFFFDAD6);
  static const Color lightOnPrimaryContainer = Color(0xFF410008);
  static const Color lightSecondary = Color(0xFF5C5C5C);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE5E5E5);
  static const Color lightOnSecondaryContainer = Color(0xFF1A1A1A);
  static const Color lightTertiary = Color(0xFF737373);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFE0E0E0);
  static const Color lightOnTertiaryContainer = Color(0xFF262626);
  static const Color lightOutline = Color(0xFF9A9A9A);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);
  static const Color lightInverseSurface = Color(0xFF1E1E1E);
  static const Color lightOnInverseSurface = Color(0xFFF5F5F5);
  static const Color lightInversePrimary = Color(0xFFFF5449);
  static const Color lightSurfaceContainerLow = Color(0xFFF5F5F5);
  static const Color lightSurfaceContainer = Color(0xFFEEEEEE);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color lightSurfaceContainerHighest = Color(0xFFE0E0E0);
}
