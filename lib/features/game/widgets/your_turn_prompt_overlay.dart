import 'package:flutter/material.dart';

import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

/// Full-screen glance cue when the active seat becomes yours. Tap anywhere to dismiss.
class YourTurnPromptOverlay extends StatelessWidget {
  const YourTurnPromptOverlay({
    super.key,
    required this.onDismiss,
  });

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;

    return Positioned.fill(
      child: Semantics(
        button: true,
        label: 'Your turn. Double tap to dismiss.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDismiss,
          child: AnimatedOpacity(
            opacity: 1,
            duration: MotionTokens.standard,
            child: ColoredBox(
              color: colors.backgroundPrimary.withValues(
                alpha: OpacityTokens.strong,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primaryAccent,
                          borderRadius: RadiusTokens.radiusLg,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: LayoutTokens.gr5,
                            vertical: LayoutTokens.gr4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Your turn',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorTokens.onAccent,
                                  fontSize: FontTokens.displayCommander,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: LayoutTokens.gr2),
                              Text(
                                'Tap to continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ColorTokens.onAccent.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontSize: FontTokens.body,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
