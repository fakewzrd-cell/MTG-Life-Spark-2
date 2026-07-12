import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../constants/app_icons.dart';
import 'brand_logo.dart';

/// Launch splash: mark rotates → pauses in a loop, then full logo fades in.
class BrandedSplash extends StatefulWidget {
  const BrandedSplash({
    super.key,
    this.message = 'Loading MTG Life Spark…',
    this.ready = false,
    this.onRevealComplete,
  });

  final String message;

  /// When true, stop the spin loop and fade in the full vertical logo.
  final bool ready;

  /// Called after the post-load brand reveal finishes (if [ready] was set).
  final VoidCallback? onRevealComplete;

  @override
  State<BrandedSplash> createState() => _BrandedSplashState();
}

class _BrandedSplashState extends State<BrandedSplash>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _revealController;
  var _revealing = false;

  @override
  void initState() {
    super.initState();
    // One cycle = rotate once, then pause, then repeat.
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startReveal());
    }
  }

  @override
  void didUpdateWidget(covariant BrandedSplash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && !oldWidget.ready) {
      _startReveal();
    }
  }

  Future<void> _startReveal() async {
    if (_revealing) return;
    _revealing = true;
    _spinController.stop();
    await _revealController.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;
    widget.onRevealComplete?.call();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  /// Maps 0→1 cycle to angle: spin for first 55%, hold for the rest.
  static double _spinAngle(double t) {
    const spinEnd = 0.55;
    if (t <= spinEnd) {
      final u = Curves.easeInOutCubic.transform(t / spinEnd);
      return u * 2 * math.pi;
    }
    return 2 * math.pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.backgroundPrimary,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.backgroundPrimary,
              Color.lerp(
                    ColorTokens.backgroundPrimary,
                    ColorTokens.primaryAccent,
                    0.18,
                  ) ??
                  ColorTokens.backgroundPrimary,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_spinController, _revealController]),
            builder: (context, _) {
              final reveal = Curves.easeOutCubic.transform(
                _revealController.value,
              );
              final markOpacity = (1.0 - reveal).clamp(0.0, 1.0);
              final logoOpacity = reveal.clamp(0.0, 1.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: markOpacity,
                          child: Transform.rotate(
                            angle: _spinAngle(_spinController.value),
                            child: Image.asset(
                              AppIcons.splashLogo,
                              width: 112,
                              height: 112,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: logoOpacity,
                          child: Transform.scale(
                            scale: 0.94 + 0.06 * reveal,
                            child: const BrandLogo(
                              layout: BrandLogoLayout.vertical,
                              height: 168,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: LayoutTokens.gr4),
                  AnimatedOpacity(
                    opacity: reveal < 0.35 ? 1 : 0,
                    duration: MotionTokens.standard,
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: ColorTokens.textPrimary.withValues(alpha: 0.75),
                        fontSize: FontTokens.sm,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
