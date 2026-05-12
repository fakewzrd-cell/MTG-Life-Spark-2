import 'package:flutter/material.dart';

/// Static design-time palette. Dark values use the existing names;
/// light and M3 container/role variants are explicitly prefixed.
class ColorTokens {
  ColorTokens._();

  // ── Dark background ──────────────────────────────────────────────────────
  static const Color backgroundPrimary = Color(0xFF080C18);
  static const Color backgroundSecondary = Color(0xFF10192E);

  // ── Dark surface ─────────────────────────────────────────────────────────
  static const Color surface = Color(0xFF162038);
  static const Color surfaceElevated = Color(0xFF1E2A48);

  // ── Dark border ──────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFF3D4F78);

  // ── Dark text ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F4FF);
  static const Color textSecondary = Color(0xFFA8B8D8);
  static const Color textMuted = Color(0xFF6B7FA3);

  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color primaryAccent = Color(0xFF8B9CFF); // periwinkle / arcane
  static const Color optionalAccent = Color(0xFF57F287); // neon green
  /// Prestige / monarch highlights — used as M3 tertiary (dark).
  static const Color accentGold = Color(0xFFA5B4FC);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF57F287);
  static const Color danger = Color(0xFFED4245);
  static const Color dangerAmber = Color(0xFFF97316);
  static const Color warning = Color(0xFFFEE75C);

  // ── Player palette ───────────────────────────────────────────────────────
  static const List<Color> playerPalette = [
    Color(0xFFE94560),
    Color(0xFF4FC3F7),
    Color(0xFF81C784),
    Color(0xFFFFD54F),
    Color(0xFFCE93D8),
    Color(0xFFFF8A65),
  ];

  static Color playerColor(int index) =>
      playerPalette[index % playerPalette.length];

  // ══════════════════════════════════════════════════════════════════════════
  // Light theme palette
  // ══════════════════════════════════════════════════════════════════════════

  static const Color lightBackgroundPrimary = Color(0xFFF5F7FF);
  static const Color lightBackgroundSecondary = Color(0xFFE8ECFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F2FC);
  static const Color lightBorderSubtle = Color(0xFFD4DBF0);
  static const Color lightTextPrimary = Color(0xFF0D1224);
  static const Color lightTextSecondary = Color(0xFF3D4A6B);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightPrimaryAccent = Color(0xFF6366F1);

  // ══════════════════════════════════════════════════════════════════════════
  // M3 container / role tokens — dark
  // ══════════════════════════════════════════════════════════════════════════

  static const Color darkPrimaryContainer = Color(0xFF1E2A6B);
  static const Color darkOnPrimaryContainer = Color(0xFFCDD5FF);
  static const Color darkSecondaryContainer = Color(0xFF1A3830);
  static const Color darkOnSecondaryContainer = Color(0xFFA6F4C5);
  // tertiary == accentGold; reuse the existing constant in theme code.
  static const Color darkOnTertiary = Color(0xFF080C18);
  static const Color darkTertiaryContainer = Color(0xFF1C1F4A);
  static const Color darkOnTertiaryContainer = Color(0xFFD9DBFF);
  static const Color darkOutlineVariant = Color(0xFF2B3A5C);
  static const Color darkErrorContainer = Color(0xFF4A0E0E);
  static const Color darkOnErrorContainer = Color(0xFFFFB3B3);
  static const Color darkInverseSurface = Color(0xFFE8ECFA);
  static const Color darkOnInverseSurface = Color(0xFF0D1224);
  static const Color darkInversePrimary = Color(0xFF6366F1);
  static const Color darkSurfaceContainerLowest = Color(0xFF050810);
  static const Color darkSurfaceContainerLow = Color(0xFF0D1224);
  // darkSurfaceContainer == surface; darkSurfaceContainerHigh == surfaceElevated
  static const Color darkSurfaceContainerHighest = Color(0xFF253258);

  // ══════════════════════════════════════════════════════════════════════════
  // M3 container / role tokens — light
  // ══════════════════════════════════════════════════════════════════════════

  static const Color lightPrimaryContainer = Color(0xFFE0E5FF);
  static const Color lightOnPrimaryContainer = Color(0xFF1B1E6B);
  static const Color lightSecondaryContainer = Color(0xFFCCF5E0);
  static const Color lightOnSecondaryContainer = Color(0xFF0A3020);
  static const Color lightTertiary = Color(0xFF6366F1);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFE0E1FF);
  static const Color lightOnTertiaryContainer = Color(0xFF1B1C6B);
  static const Color lightOutline = Color(0xFF9BA5C5);
  // lightOutlineVariant == lightBorderSubtle
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);
  static const Color lightInverseSurface = Color(0xFF1E2A48);
  static const Color lightOnInverseSurface = Color(0xFFE8ECFA);
  static const Color lightInversePrimary = Color(0xFF8B9CFF);
  // lightSurfaceContainerLowest == lightSurface
  static const Color lightSurfaceContainerLow = Color(0xFFF5F7FF);
  static const Color lightSurfaceContainer = Color(0xFFEEF1FC);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8ECFA);
  static const Color lightSurfaceContainerHighest = Color(0xFFE0E5F5);
}
