import 'package:flutter/material.dart';

/// Static design-time palette (P2P Magic blueprint: deep purple + orange accent).
class ColorTokens {
  ColorTokens._();

  /// Blueprint accent orange (high contrast on purple base).
  static const Color blueprintOrange = Color(0xFFFF6D00);

  // ── Dark background ──────────────────────────────────────────────────────
  static const Color backgroundPrimary = Color(0xFF14091F);
  static const Color backgroundSecondary = Color(0xFF1C0F2E);

  // ── Dark surface ─────────────────────────────────────────────────────────
  static const Color surface = Color(0xFF261538);
  static const Color surfaceElevated = Color(0xFF321F47);

  // ── Dark border ──────────────────────────────────────────────────────────
  static const Color borderSubtle = Color(0xFF5A4570);

  // ── Dark text ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF8F3FF);
  static const Color textSecondary = Color(0xFFC9B8DC);
  static const Color textMuted = Color(0xFF8F7FA8);

  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color primaryAccent = blueprintOrange;
  static const Color optionalAccent = Color(0xFF57F287); // neon green (secondary emphasis)
  /// Prestige / monarch highlights — M3 tertiary (dark).
  static const Color accentGold = Color(0xFFE8B86D);

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

  static const Color lightBackgroundPrimary = Color(0xFFF9F5FC);
  static const Color lightBackgroundSecondary = Color(0xFFF0E8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF5F0FA);
  static const Color lightBorderSubtle = Color(0xFFD4C8E8);
  static const Color lightTextPrimary = Color(0xFF0D1224);
  static const Color lightTextSecondary = Color(0xFF3D4A6B);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightPrimaryAccent = blueprintOrange;

  // ══════════════════════════════════════════════════════════════════════════
  // M3 container / role tokens — dark
  // ══════════════════════════════════════════════════════════════════════════

  static const Color darkPrimaryContainer = Color(0xFF5C2800);
  static const Color darkOnPrimaryContainer = Color(0xFFFFDBC8);
  static const Color darkSecondaryContainer = Color(0xFF1A3830);
  static const Color darkOnSecondaryContainer = Color(0xFFA6F4C5);
  // tertiary == accentGold; reuse the existing constant in theme code.
  static const Color darkOnTertiary = Color(0xFF1A0D12);
  static const Color darkTertiaryContainer = Color(0xFF3D2658);
  static const Color darkOnTertiaryContainer = Color(0xFFE8D5FF);
  static const Color darkOutlineVariant = Color(0xFF2B3A5C);
  static const Color darkErrorContainer = Color(0xFF4A0E0E);
  static const Color darkOnErrorContainer = Color(0xFFFFB3B3);
  static const Color darkInverseSurface = Color(0xFFE8ECFA);
  static const Color darkOnInverseSurface = Color(0xFF0D1224);
  static const Color darkInversePrimary = Color(0xFFFFB088);
  static const Color darkSurfaceContainerLowest = Color(0xFF0C0614);
  static const Color darkSurfaceContainerLow = Color(0xFF120A1C);
  // darkSurfaceContainer == surface; darkSurfaceContainerHigh == surfaceElevated
  static const Color darkSurfaceContainerHighest = Color(0xFF3E2A52);

  // ══════════════════════════════════════════════════════════════════════════
  // M3 container / role tokens — light
  // ══════════════════════════════════════════════════════════════════════════

  static const Color lightPrimaryContainer = Color(0xFFFFDBBF);
  static const Color lightOnPrimaryContainer = Color(0xFF331800);
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
  static const Color lightInversePrimary = Color(0xFFE65100);
  // lightSurfaceContainerLowest == lightSurface
  static const Color lightSurfaceContainerLow = Color(0xFFF5F7FF);
  static const Color lightSurfaceContainer = Color(0xFFEEF1FC);
  static const Color lightSurfaceContainerHigh = Color(0xFFE8ECFA);
  static const Color lightSurfaceContainerHighest = Color(0xFFE0E5F5);
}
