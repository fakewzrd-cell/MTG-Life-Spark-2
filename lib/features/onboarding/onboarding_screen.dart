import 'package:flutter/material.dart';
import '../../ui/tokens/motion_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/persistence/providers.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/color_tokens.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/game_icon.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/tokens/radius_tokens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static final _slides = [
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'Welcome to Life Spark',
      body:
          'Your Commander battlefield companion — life, counters, politics, '
          'and the stack, synced at the table.',
      color: ColorTokens.primaryAccent,
      showBrandLogo: true,
    ),
    _OnboardingSlide(
      icon: Icons.wifi_tethering,
      title: 'Host or Join',
      body:
          'One player hosts a game — others scan a QR code on the same Wi‑Fi network. No internet account needed. Works for 4 to 6 players at the same table.',
      color: ColorTokens.primaryAccent,
    ),
    _OnboardingSlide(
      icon: Icons.favorite,
      title: 'Track Your Life',
      body:
          'Tap +/- to change life by 1. Hold +/- for ±5. Drag left or right to adjust quickly. Double-tap the life total to set an exact number. Undo is on the bottom bar (or shake, if enabled).',
      color: ColorTokens.primaryAccent,
    ),
    _OnboardingSlide(
      icon: Icons.timer_outlined,
      title: 'Phase Bar & Turns',
      body:
          'Use the phase bar to step through the turn, or leave Phase tracker off in the lobby. Timeout pauses the whole game.',
      color: ColorTokens.primaryAccent,
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'Commander & Counters',
      body:
          'Commander damage opens as a threat list — how much each opponent has dealt you toward 21. Track poison (10), energy, experience, and rad. Use Proliferate to add 1 to all at once.',
      color: ColorTokens.primaryAccent,
      useCommanderDamageIcon: true,
    ),
    _OnboardingSlide(
      icon: Icons.handshake_outlined,
      title: 'Alliances & Politics',
      body:
          'Propose secret alliances with other players. They expire automatically or break when you attack each other. Track the Monarch and Initiative with a single tap.',
      color: ColorTokens.primaryAccent,
    ),
  ];

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).markOnboardingCompleted();
    bumpSettingsRevision(ref);
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: MotionTokens.slow,
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                return AnimatedContainer(
                  duration: MotionTokens.standard,
                  margin: EdgeInsets.symmetric(horizontal: LayoutTokens.gr0),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? _slides[i].color
                        : colors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: RadiusTokens.radiusControlMd,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: LayoutTokens.gr5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: LayoutTokens.ctaHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UiButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Enter the Battlefield'
                        : 'Next',
                    onPressed: _next,
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  UiButton(
                    label: 'Skip',
                    variant: UiButtonVariant.secondary,
                    onPressed: _finish,
                  ),
                ],
              ),
            ),
            SizedBox(height: LayoutTokens.gr5),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final bool showBrandLogo;
  final bool useCommanderDamageIcon;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    this.showBrandLogo = false,
    this.useCommanderDamageIcon = false,
  });
}

class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? LayoutTokens.gr4 : LayoutTokens.gr6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (slide.showBrandLogo)
            const BrandLogo(
              layout: BrandLogoLayout.horizontal,
              height: 48,
            )
          else
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    slide.color.withValues(alpha: 0.25),
                    slide.color.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: slide.color.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: slide.useCommanderDamageIcon
                  ? GameIcon.commanderDamage(size: 52, color: slide.color)
                  : Icon(slide.icon, size: 52, color: slide.color),
            ),
          SizedBox(height: LayoutTokens.gr5),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: LayoutTokens.gr4),
          Text(
            slide.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
