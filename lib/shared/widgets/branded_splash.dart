import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../constants/app_icons.dart';
import 'brand_logo.dart';

/// Launch splash: rolling mark while loading, then full vertical wordmark reveal.
class BrandedSplash extends StatefulWidget {
  const BrandedSplash({
    super.key,
    this.message = 'Loading MTG Life Spark…',
    this.ready = false,
    this.onRevealComplete,
  });

  final String message;

  /// When true, stop the dice roll and reveal the full vertical logo.
  final bool ready;

  /// Called after the post-load brand reveal finishes (if [ready] was set).
  final VoidCallback? onRevealComplete;

  @override
  State<BrandedSplash> createState() => _BrandedSplashState();
}

class _BrandedSplashState extends State<BrandedSplash>
    with TickerProviderStateMixin {
  late final AnimationController _rollController;
  late final AnimationController _revealController;
  var _revealing = false;

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
    _rollController.stop();
    await _revealController.forward();
    if (!mounted) return;
    // Brief hold on the full mark.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.onRevealComplete?.call();
  }

  @override
  void dispose() {
    _rollController.dispose();
    _revealController.dispose();
    super.dispose();
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
            animation: Listenable.merge([_rollController, _revealController]),
            builder: (context, _) {
              final reveal = Curves.easeOutCubic.transform(
                _revealController.value,
              );
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reveal < 0.55)
                    Opacity(
                      opacity: (1 - reveal / 0.55).clamp(0.0, 1.0),
                      child: _DiceMark(t: _rollController.value),
                    )
                  else
                    Opacity(
                      opacity: ((reveal - 0.55) / 0.45).clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * ((reveal - 0.55) / 0.45),
                        child: const BrandLogo(
                          layout: BrandLogoLayout.vertical,
                          height: 168,
                        ),
                      ),
                    ),
                  SizedBox(height: LayoutTokens.gr5),
                  AnimatedOpacity(
                    opacity: reveal < 0.4 ? 1 : 0,
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

class _DiceMark extends StatelessWidget {
  const _DiceMark({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final hopPhase = (t * 2) % 1.0;
    final hop = 4 * hopPhase * (1 - hopPhase);
    final bounceY = -36.0 * hop;
    final rotateX = t * 2 * math.pi * 2;
    final rotateY = math.sin(t * 2 * math.pi) * 0.55;
    final rotateZ = math.sin(t * 4 * math.pi) * 0.12;
    final scale = 0.92 + hop * 0.1;

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.002)
      ..translateByDouble(0, bounceY, 0, 1)
      ..rotateX(rotateX)
      ..rotateY(rotateY)
      ..rotateZ(rotateZ)
      ..scaleByDouble(scale, scale, scale, 1);

    return Transform(
      alignment: Alignment.center,
      transform: matrix,
      child: Image.asset(
        AppIcons.splashLogo,
        width: 112,
        height: 112,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
