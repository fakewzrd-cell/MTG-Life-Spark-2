import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../constants/app_icons.dart';

/// Branded launch splash — lightning mark + speed lines ([AppIcons.splashLogo]).
class BrandedSplash extends StatefulWidget {
  const BrandedSplash({
    super.key,
    this.message = 'Loading MTG Life Spark…',
  });

  final String message;

  @override
  State<BrandedSplash> createState() => _BrandedSplashState();
}

class _BrandedSplashState extends State<BrandedSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    final glow = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    return Scaffold(
      backgroundColor: ColorTokens.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: scale.value,
                  child: Opacity(opacity: glow.value, child: child),
                );
              },
              child: SvgPicture.asset(
                AppIcons.splashLogo,
                width: 128,
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: LayoutTokens.gr4),
            Text(
              widget.message,
              style: TextStyle(
                color: ColorTokens.textPrimary.withValues(alpha: 0.75),
                fontSize: FontTokens.sm,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
