import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/tokens/layout_tokens.dart';

/// Layout metrics for the profile hero banner (single source of truth).
///
/// Precomputes height from theme + text scale so overlay content is never
/// clipped inside the banner [Stack].
@immutable
class ProfileHeroLayoutMetrics {
  const ProfileHeroLayoutMetrics({
    required this.cardHeight,
    required this.overlayHPadding,
    required this.topInset,
    required this.overlayBottomPadding,
    required this.overlayTopReserve,
  });

  /// Circular avatar diameter in the hero.
  static const double avatarDiameter = 104;

  final double cardHeight;
  final double overlayHPadding;
  final double topInset;
  final double overlayBottomPadding;
  final double overlayTopReserve;

  factory ProfileHeroLayoutMetrics.resolve(
    BuildContext context, {
    required bool isNarrow,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final textScale = _clampedUnitScale(textScaler.scale(1));
    final padding = MediaQuery.paddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final textTheme = Theme.of(context).textTheme;

    final titleStyle = textTheme.titleLarge;
    final titleLineHeight =
        (titleStyle?.fontSize ?? 22) * (titleStyle?.height ?? 1.2) * textScale;

    const tierBadgeHeight = 30.0;
    const statsPillHeight = 56.0;

    // Identity is a horizontal row (avatar | name+tier); avatar height dominates.
    final identityRowHeight = math.max(
      avatarDiameter,
      titleLineHeight + LayoutTokens.gr0 + tierBadgeHeight * textScale,
    );

    final overlayContentHeight =
        identityRowHeight + LayoutTokens.gr4 + statsPillHeight;

    final topInset = padding.top;
    // No overlay controls sit above the avatar anymore (banner is a fixed
    // default graphic), so this only needs to clear the status bar/notch.
    final overlayTopReserve = topInset + LayoutTokens.gr2;
    const overlayBottomPadding = LayoutTokens.gr3;
    final minCardHeight =
        overlayTopReserve +
        LayoutTokens.gr2 +
        overlayContentHeight +
        overlayBottomPadding;

    final availH = math.max(200.0, size.height - padding.vertical);
    final portrait = size.height >= size.width;
    final visualFrac = portrait ? 0.32 : 0.28;
    final visualHeight =
        (availH * visualFrac * (0.88 + 0.12 * (textScale - 1))).clamp(
          240.0,
          360.0,
        );

    final cardHeight = math.max(visualHeight, minCardHeight).clamp(260.0, 400.0);

    final overlayHPadding = LayoutTokens.shellPageInset;

    return ProfileHeroLayoutMetrics(
      cardHeight: cardHeight,
      overlayHPadding: overlayHPadding,
      topInset: topInset,
      overlayBottomPadding: overlayBottomPadding,
      overlayTopReserve: overlayTopReserve,
    );
  }
}

double _clampedUnitScale(double scale) {
  if (!scale.isFinite || scale <= 0) return 1.0;
  return scale.clamp(1.0, 1.45);
}

/// Clamped text scale for carousel sections below the hero.
double profileSectionTextScale(BuildContext context) {
  return _clampedUnitScale(MediaQuery.textScalerOf(context).scale(1));
}
