import 'package:flutter/material.dart';
import '../../ui/tokens/motion_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/persistence/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/widgets/block_system_app_exit.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/game_icon.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
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

  List<_OnboardingSlide> _slidesFor(AppLocalizations l10n) => [
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: l10n.onboardingSlide1Title,
      body: l10n.onboardingSlide1Body,
      showBrandLogo: true,
    ),
    _OnboardingSlide(
      icon: Icons.wifi_tethering,
      title: l10n.onboardingSlide2Title,
      body: l10n.onboardingSlide2Body,
    ),
    _OnboardingSlide(
      icon: Icons.favorite,
      title: l10n.onboardingSlide3Title,
      body: l10n.onboardingSlide3Body,
    ),
    _OnboardingSlide(
      icon: Icons.timer_outlined,
      title: l10n.onboardingSlide4Title,
      body: l10n.onboardingSlide4Body,
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: l10n.onboardingSlide5Title,
      body: l10n.onboardingSlide5Body,
      useCommanderDamageIcon: true,
    ),
    _OnboardingSlide(
      icon: Icons.handshake_outlined,
      title: l10n.onboardingSlide6Title,
      body: l10n.onboardingSlide6Body,
    ),
  ];

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).markOnboardingCompleted();
    bumpSettingsRevision(ref);
    if (mounted) context.go(AppRoutes.home);
  }

  void _next(int slideCount) {
    if (_currentPage < slideCount - 1) {
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
    final l10n = AppLocalizations.of(context);
    final slides = _slidesFor(l10n);
    return BlockSystemAppExit(
      child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: slides.length,
                itemBuilder: (context, i) => _SlideView(slide: slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                return AnimatedContainer(
                  duration: MotionTokens.standard,
                  margin: EdgeInsets.symmetric(horizontal: LayoutTokens.gr0),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? colors.primaryAccent
                        : colors.textSecondary.withValues(alpha: OpacityTokens.moderate),
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
                    label: _currentPage == slides.length - 1
                        ? l10n.onboardingReadyToPlay
                        : l10n.onboardingNext,
                    onPressed: () => _next(slides.length),
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  UiButton(
                    label: l10n.onboardingSkip,
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
    ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String body;
  final bool showBrandLogo;
  final bool useCommanderDamageIcon;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    this.showBrandLogo = false,
    this.useCommanderDamageIcon = false,
  });
}

class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 360;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? LayoutTokens.gr4 : LayoutTokens.gr6),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.55,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (slide.showBrandLogo)
                BrandLogo(
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
                        colors.primaryAccent.withValues(alpha: OpacityTokens.soft),
                        colors.primaryAccent.withValues(alpha: OpacityTokens.faint),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primaryAccent.withValues(alpha: OpacityTokens.soft),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: slide.useCommanderDamageIcon
                      ? GameIcon.commanderDamage(size: 52, color: colors.primaryAccent)
                      : Icon(slide.icon, size: 52, color: colors.primaryAccent),
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
                      color: colors.textSecondary,
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
