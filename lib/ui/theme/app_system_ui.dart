import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double kLargeScreenOrientationBreakpoint = 600;

/// Phones stay portrait for table readability. Android 16 ignores orientation
/// locks on large screens, so tablets, foldables, and desktop windows are left
/// unrestricted and must use the app's responsive layouts.
List<DeviceOrientation> preferredOrientationsForLogicalWidth(double width) {
  if (width >= kLargeScreenOrientationBreakpoint) {
    return const <DeviceOrientation>[];
  }
  return const <DeviceOrientation>[DeviceOrientation.portraitUp];
}

/// System status / navigation bar styling aligned with app chrome.
abstract final class AppSystemUi {
  static Future<void> bootstrap() async {
    if (kIsWeb) return;
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view != null) {
      await _applyOrientationForView(view);
    }
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  static Future<void> _applyOrientationForView(ui.FlutterView view) {
    final display = view.display;
    final logicalWidth = display.size.width / display.devicePixelRatio;
    return SystemChrome.setPreferredOrientations(
      preferredOrientationsForLogicalWidth(logicalWidth),
    );
  }

  static SystemUiOverlayStyle overlayStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
  }
}

/// Reapplies orientation policy when a fold, rotation, or window resize changes
/// the display dimensions.
class AppAdaptiveOrientationScope extends StatefulWidget {
  const AppAdaptiveOrientationScope({super.key, required this.child});

  final Widget child;

  @override
  State<AppAdaptiveOrientationScope> createState() =>
      _AppAdaptiveOrientationScopeState();
}

class _AppAdaptiveOrientationScopeState
    extends State<AppAdaptiveOrientationScope>
    with WidgetsBindingObserver {
  bool? _wasLargeScreen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyOrientation();
  }

  @override
  void didChangeMetrics() {
    _applyOrientation();
  }

  void _applyOrientation() {
    if (kIsWeb || !mounted) return;
    final display = View.of(context).display;
    final logicalWidth = display.size.width / display.devicePixelRatio;
    final isLargeScreen = logicalWidth >= kLargeScreenOrientationBreakpoint;
    if (_wasLargeScreen == isLargeScreen) return;
    _wasLargeScreen = isLargeScreen;
    unawaited(
      SystemChrome.setPreferredOrientations(
        preferredOrientationsForLogicalWidth(logicalWidth),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Applies icon brightness to a subtree. Bar backgrounds are drawn by Flutter
/// content behind the Android system insets rather than deprecated Window APIs.
class AppSystemUiScope extends StatelessWidget {
  const AppSystemUiScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.overlayStyle(context),
      child: child,
    );
  }
}
