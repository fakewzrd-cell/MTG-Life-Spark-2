import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/debug/web_logo_splash.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';

/// Launch splash: play the Life Spark logo animation, then enter the app.
///
/// Completes only after the intro finishes **and** [ready] is true (bootstrap
/// done). On web, the HTML shell plays the clip once — Flutter stays black so
/// we never flash a second static logo or Beta label.
class BrandedSplash extends StatefulWidget {
  const BrandedSplash({
    super.key,
    this.message = 'Loading Life Spark…',
    this.ready = false,
    this.onRevealComplete,
    this.useVideoIntro,
  });

  final String message;

  /// When true (and intro finished), invoke [onRevealComplete] after a short hold.
  final bool ready;

  final VoidCallback? onRevealComplete;

  /// Defaults to true on IO, false on web (HTML owns the intro there).
  /// Set false in widget tests (no video platform).
  final bool? useVideoIntro;

  /// Bundled logo open animation (512² H.264 for smooth decode).
  static const logoAnimationAsset = 'assets/animations/logo_splash.mp4';

  /// Source length of [logoAnimationAsset] (encoded ~3.0s).
  static const logoAnimationSourceDuration = Duration(milliseconds: 3000);

  /// On-screen intro length — slightly faster than the source clip.
  static const logoAnimationDuration = Duration(milliseconds: 2500);

  /// Playback speed so the ~3s asset finishes in [logoAnimationDuration].
  static double get logoAnimationPlaybackRate =>
      logoAnimationSourceDuration.inMilliseconds /
      logoAnimationDuration.inMilliseconds;

  /// Max display size for the intro video (scaled down on narrow screens).
  static const double introSize = 340;

  /// Fraction of the shortest screen side used for the intro box.
  static const double introViewportFraction = 0.72;

  /// Tagline under the logo animation (native / APK intro).
  static const String tagline = 'Your MTG Companion';

  /// Fade-in for [tagline] — timed to the LIFE SPARK wordmark in the clip.
  static const taglineFade = Duration(milliseconds: 320);

  /// Source-media time when "LIFE SPARK" appears in [logoAnimationAsset] (~1.25s).
  static const taglineAtSource = Duration(milliseconds: 1250);

  /// Brief hold after the clip ends before entering the app.
  static const taglineHold = Duration(milliseconds: 160);

  /// How long init may take before we show a loading cue under the intro.
  static const slowLoadThreshold = Duration(milliseconds: 1000);

  /// Brief black hold when video cannot play (tests / decode failure).
  static const revealDuration = Duration(milliseconds: 300);

  /// Hold after the intro before entering the app (IO only; web jumps straight in).
  static const revealHold = Duration(milliseconds: 80);

  static bool get defaultUseVideoIntro => !kIsWeb;

  @override
  State<BrandedSplash> createState() => _BrandedSplashState();
}

class _BrandedSplashState extends State<BrandedSplash> {
  VideoPlayerController? _video;

  var _showLoadingCue = false;
  var _finishing = false;
  var _introFinished = false;
  var _taglineVisible = false;
  var _videoReady = false;

  bool get _playVideo =>
      widget.useVideoIntro ?? BrandedSplash.defaultUseVideoIntro;

  @override
  void initState() {
    super.initState();
    if (_playVideo) {
      _initVideo();
    } else if (kIsWeb) {
      // HTML owns the clip — finish as soon as it reports `ended` (no extra black wait).
      listenForWebLogoSplashDone(() {
        if (!mounted) return;
        _markIntroFinished();
      });
    } else {
      Future<void>.delayed(BrandedSplash.revealDuration, () {
        if (!mounted) return;
        _markIntroFinished();
      });
    }

    if (!widget.ready) {
      Future<void>.delayed(BrandedSplash.slowLoadThreshold, () {
        if (!mounted || widget.ready || _finishing) return;
        setState(() => _showLoadingCue = true);
      });
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(
      BrandedSplash.logoAnimationAsset,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );
    _video = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setLooping(false);
      await controller.setVolume(0);
      await controller.setPlaybackSpeed(BrandedSplash.logoAnimationPlaybackRate);
      await controller.seekTo(Duration.zero);
      if (!mounted) return;
      controller.addListener(_onVideoTick);
      setState(() => _videoReady = true);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _video != controller) return;
        await controller.play();
      });
    } catch (_) {
      if (!mounted) return;
      await _disposeVideo();
      Future<void>.delayed(BrandedSplash.revealDuration, () {
        if (!mounted) return;
        _markIntroFinished();
      });
    }
  }

  Future<void> _disposeVideo() async {
    final c = _video;
    _video = null;
    if (c == null) return;
    c.removeListener(_onVideoTick);
    await c.dispose();
  }

  void _showTagline() {
    if (_taglineVisible) return;
    _taglineVisible = true;
    if (mounted) setState(() {});
  }

  void _markIntroFinished() {
    if (_introFinished) return;
    _introFinished = true;
    _showTagline();
    if (mounted) setState(() {});
    // Tagline is already fading in mid-clip — short hold after the end.
    if (_playVideo) {
      Future<void>.delayed(BrandedSplash.taglineHold, () {
        if (!mounted) return;
        _tryFinish();
      });
      return;
    }
    _tryFinish();
  }

  void _onVideoTick() {
    final c = _video;
    if (c == null || !c.value.isInitialized || _introFinished) return;
    final value = c.value;
    final duration = value.duration;
    if (duration <= Duration.zero) return;

    // Match HTML splash: reveal when the LIFE SPARK title appears in-frame.
    if (value.position >= BrandedSplash.taglineAtSource) {
      _showTagline();
    }

    final atEnd = value.isCompleted || value.position >= duration;
    if (!atEnd) return;
    if (value.isPlaying) {
      c.pause();
    }
    _markIntroFinished();
  }

  @override
  void didUpdateWidget(covariant BrandedSplash oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ready && !oldWidget.ready) {
      _tryFinish();
    }
  }

  Future<void> _tryFinish() async {
    if (_finishing || !widget.ready || !_introFinished) return;
    _finishing = true;
    if (_showLoadingCue && mounted) {
      setState(() => _showLoadingCue = false);
    }
    // Web: jump straight into the app under the HTML layer (no black hold).
    if (!kIsWeb) {
      await Future<void>.delayed(BrandedSplash.revealHold);
      if (!mounted) return;
    }
    widget.onRevealComplete?.call();
  }

  @override
  void dispose() {
    final c = _video;
    if (c != null) {
      c.removeListener(_onVideoTick);
      c.dispose();
    }
    super.dispose();
  }

  double _introBoxSize(BuildContext context) {
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    return (shortest * BrandedSplash.introViewportFraction)
        .clamp(220.0, BrandedSplash.introSize);
  }

  @override
  Widget build(BuildContext context) {
    const splashBlack = Color(0xFF000000);
    final showLoading = _showLoadingCue && !_finishing;
    final introSize = _introBoxSize(context);

    return Scaffold(
      backgroundColor: splashBlack,
      body: ColoredBox(
        color: splashBlack,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: introSize,
                height: introSize,
                child: _buildIntro(),
              ),
              // Web HTML owns the tagline; native fades it in after the clip.
              if (_playVideo) ...[
                SizedBox(height: LayoutTokens.gr3),
                AnimatedOpacity(
                  opacity: _taglineVisible ? 1 : 0,
                  duration: BrandedSplash.taglineFade,
                  curve: Curves.easeOut,
                  child: Text(
                    BrandedSplash.tagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: FontTokens.sm,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (showLoading) ...[
                SizedBox(height: LayoutTokens.gr4),
                Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: FontTokens.sm,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    // Web: HTML owns the animation — keep Flutter black (no static logo).
    if (!_playVideo) {
      return const SizedBox.shrink();
    }

    final video = _video;
    if (!_videoReady || video == null || !video.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: video.value.size.width,
          height: video.value.size.height,
          child: VideoPlayer(video),
        ),
      ),
    );
  }
}
