import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color_tokens.dart';

/// System status / navigation bar styling aligned with app chrome.
abstract final class AppSystemUi {
  static Future<void> bootstrap() async {
    if (kIsWeb) return;
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  static SystemUiOverlayStyle overlayStyle(
    BuildContext context, {
    bool matchBottomNav = false,
  }) {
    final colors = AppColorTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dock nav uses backgroundPrimary @ 78% over the same scaffold tone.
    final navBarColor =
        matchBottomNav
            ? Color.alphaBlend(
              colors.backgroundPrimary.withValues(alpha: 0.78),
              colors.backgroundPrimary,
            )
            : colors.backgroundPrimary;

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: navBarColor,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarDividerColor:
          colors.borderSubtle.withValues(alpha: 0.22),
    );
  }
}

/// Applies [AppSystemUi.overlayStyle] to a subtree (Android nav bar + status bar).
class AppSystemUiScope extends StatelessWidget {
  const AppSystemUiScope({
    super.key,
    required this.child,
    this.matchBottomNav = false,
  });

  final Widget child;
  final bool matchBottomNav;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.overlayStyle(context, matchBottomNav: matchBottomNav),
      child: child,
    );
  }
}
