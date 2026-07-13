import 'package:flutter/material.dart';

/// Corner radius scale — calm / premium (not pill-heavy).
///
/// Scale: sm(8) → md(12) → lg(16) → xl(20). Hero surfaces cap at [xl].
/// Compact slots ([controlXs]…[controlSm]) cover dense HUD / chips.
class RadiusTokens {
  RadiusTokens._();

  // ── Standard UI scale ─────────────────────────────────────────────────────
  /// Controls / compact tiles (8).
  static const double sm = 8;

  /// Default cards and buttons (12).
  static const double md = 12;

  /// Larger cards / dialogs (16).
  static const double lg = 16;

  /// Hero / sheet tops (20) — max for large surfaces.
  static const double xl = 20;

  /// True pills only (segmented controls, avatars). Prefer [sm]/[md] elsewhere.
  static const double pill = 999;

  // ── Compact UI / controls ─────────────────────────────────────────────────

  /// Small control corner (6). QR frame, code chips, compact badges.
  static const double controlXs = 6;

  /// Compact tile corner (8). Commander grid cells, onboarding dots.
  static const double controlMd = 8;

  /// Small control corner (10). Pill-adjacent buttons, HUD chips.
  static const double controlSm = 10;

  /// Card / deck chip (12). Lobby slot cards, end-game tiles.
  static const double chip = 12;

  // ── Hero cards ────────────────────────────────────────────────────────────

  /// Profile carousel / deck shelf cards (20). Alias: [bento].
  static const double carouselCard = xl;

  /// Legacy name for [carouselCard].
  static const double bento = carouselCard;

  // ── BorderRadius constants ────────────────────────────────────────────────
  static const BorderRadius radiusXs =
      BorderRadius.all(Radius.circular(controlXs));
  static const BorderRadius radiusControlMd =
      BorderRadius.all(Radius.circular(controlMd));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusCarouselCard =
      BorderRadius.all(Radius.circular(carouselCard));
  static const BorderRadius radiusBento = radiusCarouselCard;
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius radiusControlSm =
      BorderRadius.all(Radius.circular(controlSm));
  static const BorderRadius radiusChip = BorderRadius.all(Radius.circular(chip));

  /// Modal bottom sheets in game / profile flows.
  static const BorderRadius radiusSheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}
