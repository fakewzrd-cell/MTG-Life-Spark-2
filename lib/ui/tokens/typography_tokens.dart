import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_color_tokens.dart';
import 'font_tokens.dart';

/// Typography helpers. **Lato** — matches [AppTheme] / Material [TextTheme].
///
/// Hierarchy rule: at most one heavy weight (`w700`) per screen for the hero
/// title; section headers use `w600`; body stays `w400`/`w500`.
class TypographyTokens {
  TypographyTokens._();

  static TextStyle headline(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );
  }

  static TextStyle title(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }

  /// Module headers — profile sections, lobby blocks, decks screen.
  static TextStyle sectionTitle(Color primary) => GoogleFonts.lato(
        fontSize: FontTokens.headline,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.2,
        color: primary,
      );

  /// In-card titles — profile carousel cards.
  static TextStyle cardTitle(Color primary) => GoogleFonts.lato(
        fontSize: FontTokens.title,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.2,
        color: primary,
      );

  static TextStyle body(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
    );
  }

  static TextStyle bodySecondary(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
    );
  }

  static TextStyle label(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }

  static TextStyle caption(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: colors.textMuted,
    );
  }

  static TextStyle button(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return GoogleFonts.lato(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }
}
