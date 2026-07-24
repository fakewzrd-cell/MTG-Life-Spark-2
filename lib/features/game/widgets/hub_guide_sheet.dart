import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/providers.dart';
import '../../../shared/constants/app_icons.dart';
import '../../../shared/widgets/game_icon.dart';
import '../../../ui/components/ui_button.dart';
import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';

/// Full-screen hub chrome guide — first match and Settings replay.
Future<void> showHubGuideSheet(BuildContext context) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (ctx) => const _HubGuideDialog(),
  );
}

class _HubGuideDialog extends ConsumerStatefulWidget {
  const _HubGuideDialog();

  @override
  ConsumerState<_HubGuideDialog> createState() => _HubGuideDialogState();
}

class _HubGuideDialogState extends ConsumerState<_HubGuideDialog> {
  final _controller = PageController();
  int _currentPage = 0;

  static final _slides = <_HubGuideSlide>[
    _HubGuideSlide(
      icon: Icons.style_outlined,
      iconAsset: AppIcons.playTabCards,
      title: 'Play',
      body:
          'Track life and counters here. End turn sits under the phase bar — '
          'or leave Phase tracker off in the lobby for a large End turn control.',
    ),
    _HubGuideSlide(
      icon: Icons.layers_rounded,
      title: 'Stack & Lookup',
      body:
          'Stack is for Hold Priority and resolving effects. Lookup opens '
          'Scryfall without leaving your seat — oracle text and rulings.',
    ),
    _HubGuideSlide(
      icon: Icons.grid_view_rounded,
      title: 'Table overview',
      body:
          'Open Table for the whole pod. History lives in the header; a full-width '
          'End turn stays pinned at the bottom.',
    ),
    _HubGuideSlide(
      icon: Icons.favorite_rounded,
      useCommanderDamageIcon: true,
      title: 'Your turn & commander',
      body:
          'When the seat becomes yours, tap the Your turn cue to dismiss it. '
          'The heart tracks commander damage toward 21.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsRepositoryProvider).markHubGuideCompleted();
    bumpSettingsRevision(ref);
    if (mounted) Navigator.of(context).pop();
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
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final accent = ColorTokens.primaryAccent;

    return Dialog.fullscreen(
      backgroundColor: colors.backgroundPrimary,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                LayoutTokens.gr4,
                LayoutTokens.gr2,
                LayoutTokens.gr2,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'How the hub works',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) => _HubGuideSlideView(
                  slide: _slides[i],
                  accent: accent,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final selected = _currentPage == i;
                return AnimatedContainer(
                  duration: MotionTokens.standard,
                  margin: EdgeInsets.symmetric(horizontal: LayoutTokens.gr0),
                  width: selected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? accent
                        : colors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: RadiusTokens.radiusControlMd,
                  ),
                );
              }),
            ),
            SizedBox(height: LayoutTokens.gr4),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LayoutTokens.ctaHorizontal,
              ),
              child: UiButton(
                label: _currentPage == _slides.length - 1 ? 'Got it' : 'Next',
                onPressed: _next,
              ),
            ),
            SizedBox(height: LayoutTokens.gr4),
          ],
        ),
      ),
    );
  }
}

class _HubGuideSlide {
  const _HubGuideSlide({
    required this.icon,
    required this.title,
    required this.body,
    this.iconAsset,
    this.useCommanderDamageIcon = false,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String body;
  final bool useCommanderDamageIcon;
}

class _HubGuideSlideView extends StatelessWidget {
  const _HubGuideSlideView({
    required this.slide,
    required this.accent,
  });

  final _HubGuideSlide slide;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? LayoutTokens.gr4 : LayoutTokens.gr6,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.25),
                  accent.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: slide.useCommanderDamageIcon
                  ? GameIcon.commanderDamage(size: 52, color: accent)
                  : slide.iconAsset != null
                      ? Image.asset(
                          slide.iconAsset!,
                          width: 52,
                          height: 52,
                          color: accent,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            slide.icon,
                            size: 52,
                            color: accent,
                          ),
                        )
                      : Icon(slide.icon, size: 52, color: accent),
            ),
          ),
          SizedBox(height: LayoutTokens.gr5),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: LayoutTokens.gr3),
          Text(
            slide.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                  height: 1.55,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
