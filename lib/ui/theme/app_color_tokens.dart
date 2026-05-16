import 'package:flutter/material.dart';

/// Theme-aware color tokens. Use [AppColorTokens.of] to resolve for current theme.
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceElevated,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primaryAccent,
  });

  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceElevated;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primaryAccent;

  static AppColorTokens of(BuildContext context) {
    return Theme.of(context).extension<AppColorTokens>()!;
  }

  static const AppColorTokens dark = AppColorTokens(
    backgroundPrimary: Color(0xFF14091F),
    backgroundSecondary: Color(0xFF1C0F2E),
    surface: Color(0xFF261538),
    surfaceElevated: Color(0xFF321F47),
    borderSubtle: Color(0xFF5A4570),
    textPrimary: Color(0xFFF8F3FF),
    textSecondary: Color(0xFFC9B8DC),
    textMuted: Color(0xFF8F7FA8),
    primaryAccent: Color(0xFFFF6D00),
  );

  static const AppColorTokens light = AppColorTokens(
    backgroundPrimary: Color(0xFFF9F5FC),
    backgroundSecondary: Color(0xFFF0E8FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF5F0FA),
    borderSubtle: Color(0xFFD4C8E8),
    textPrimary: Color(0xFF1A0D24),
    textSecondary: Color(0xFF4A3D5C),
    textMuted: Color(0xFF6B7280),
    primaryAccent: Color(0xFFFF6D00),
  );

  @override
  AppColorTokens copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? surface,
    Color? surfaceElevated,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primaryAccent,
  }) {
    return AppColorTokens(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryAccent: primaryAccent ?? this.primaryAccent,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
    );
  }
}
