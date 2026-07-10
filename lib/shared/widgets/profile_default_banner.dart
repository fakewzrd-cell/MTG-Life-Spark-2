import 'package:flutter/material.dart';

import '../constants/app_icons.dart';

/// Shared fallback background for profile/commander banner art — used
/// whenever a banner image is missing, loading, or fails to load.
///
/// Single source of truth: keep this in sync instead of copy-pasting into
/// each screen that shows banner art (hero header, carousel cards, etc.).
Widget defaultBannerFill(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return ColoredBox(
    color: scheme.surfaceContainer,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerLow,
            scheme.surfaceContainer,
            Color.lerp(scheme.surfaceContainer, scheme.primary, 0.06)!,
          ],
        ),
      ),
    ),
  );
}

/// Bundled profile / commander art shown when no network image is available.
Widget defaultProfileBannerArt(
  BuildContext context, {
  double? height,
}) {
  return Image.asset(
    AppIcons.defaultProfileBanner,
    fit: BoxFit.cover,
    width: double.infinity,
    height: height,
    alignment: const Alignment(0, -0.15),
    errorBuilder: (ctx, _, __) => defaultBannerFill(ctx),
  );
}
