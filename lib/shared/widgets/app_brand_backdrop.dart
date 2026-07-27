import 'package:flutter/material.dart';

import '../../ui/theme/app_color_tokens.dart';

/// True app wallpaper: a quiet scheme-aware wash behind transparent scaffolds.
///
/// Uses [AppColorTokens] so violet / crimson / slate / forest (and light/dark)
/// all stay in sync — depth without logo noise.
class AppBrandBackdrop extends StatelessWidget {
  const AppBrandBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Bottom picks up a whisper of accent so the wash feels branded, not flat.
    final bottom = Color.lerp(
      colors.backgroundSecondary,
      colors.primaryAccent,
      isDark ? 0.055 : 0.04,
    )!;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.backgroundPrimary,
              Color.lerp(
                colors.backgroundPrimary,
                colors.backgroundSecondary,
                isDark ? 0.55 : 0.4,
              )!,
              bottom,
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
