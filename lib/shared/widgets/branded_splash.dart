import 'package:flutter/material.dart';

import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../constants/app_icons.dart';
import 'brand_logo.dart';

/// Launch splash: fade in the full logo once bootstrap is ready.
///
/// No spin loop on warm/fast starts. If init is still running after
/// [slowLoadThreshold], a quiet mark + "Loading…" cue appears.
class BrandedSplash extends StatefulWidget {
  const BrandedSplash({
    super.key,
    this.message = 'Loading Life Spark…',
    this.ready = false,
    this.onRevealComplete,
  });

  final String message;

  /// When true, fade in the full vertical logo then invoke [onRevealComplete].
  final bool ready;

  /// Called after the brand reveal finishes (if [ready] was set).
  final VoidCallback? onRevealComplete;

  /// How long init may take before we show a loading cue.
  static const slowLoadThreshold = Duration(milliseconds: 1000);

  /// Logo fade-in duration.
  static const revealDuration = Duration(milliseconds: 750);

  /// Hold after the logo is fully visible before entering the app.
  static const revealHold = Duration(milliseconds: 700);

  @override
  State<BrandedSplash> createState() => _BrandedSplashState();
}

class _BrandedSplashState extends State<BrandedSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  var _showLoadingCue = false;
  var _revealing = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: BrandedSplash.revealDuration,
    );
    if (widget.ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startReveal());
    } else {
      Future<void>.delayed(BrandedSplash.slowLoadThreshold, () {
        if (!mounted || widget.ready || _revealing) return;
        setState(() => _showLoadingCue = true);
      });
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
    if (_showLoadingCue && mounted) {
      setState(() => _showLoadingCue = false);
    }
    await _revealController.forward();
    if (!mounted) return;
    await Future<void>.delayed(BrandedSplash.revealHold);
    if (!mounted) return;
    widget.onRevealComplete?.call();
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pure black so the white brand mark/wordmark reads cleanly on launch.
    const splashBlack = Color(0xFF000000);
    return Scaffold(
      backgroundColor: splashBlack,
      body: ColoredBox(
        color: splashBlack,
        child: Center(
          child: AnimatedBuilder(
            animation: _revealController,
            builder: (context, _) {
              final reveal = Curves.easeOutCubic.transform(
                _revealController.value,
              );
              final logoOpacity = reveal.clamp(0.0, 1.0);
              // Quiet waiting mark only when bootstrap is actually slow.
              final cueOpacity =
                  (_showLoadingCue && !_revealing ? 1.0 : 0.0) *
                  (1.0 - reveal).clamp(0.0, 1.0);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: cueOpacity,
                          duration: const Duration(milliseconds: 280),
                          child: Image.asset(
                            AppIcons.splashLogo,
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Opacity(
                          opacity: logoOpacity,
                          child: Transform.scale(
                            scale: 0.96 + 0.04 * reveal,
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
                  if (cueOpacity > 0.01)
                    Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: FontTokens.sm,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    )
                  else
                    Opacity(
                      opacity: logoOpacity,
                      child: Text(
                        'Beta',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: FontTokens.caption,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.4,
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
