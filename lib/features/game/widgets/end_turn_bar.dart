import 'package:flutter/material.dart';

import '../../../shared/utils/game_haptics.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';

/// Full-width End turn control used when the phase tracker is off.
class EndTurnBar extends StatelessWidget {
  const EndTurnBar({
    super.key,
    required this.accentColor,
    required this.enabled,
    required this.onEndTurn,
    this.waitingForName,
  });

  final Color accentColor;
  final bool enabled;
  final VoidCallback onEndTurn;
  final String? waitingForName;

  static const double barHeight = 60;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final bg = enabled
        ? accentColor.withValues(alpha: OpacityTokens.soft)
        : colors.backgroundSecondary.withValues(alpha: 0.4);
    final fg = enabled
        ? accentColor
        : colors.textSecondary.withValues(alpha: OpacityTokens.disabled);
    final subtitle = !enabled && waitingForName != null && waitingForName!.isNotEmpty
        ? 'Waiting for $waitingForName…'
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.94),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      child: ClipRRect(
        borderRadius: RadiusTokens.radiusControlSm,
        child: SizedBox(
          height: barHeight,
          child: Material(
            color: bg,
            child: InkWell(
              onTap: enabled
                  ? () {
                      context.gameHapticLight();
                      onEndTurn();
                    }
                  : null,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutTokens.gr3,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'End turn',
                        style: TextStyle(
                          fontSize: FontTokens.title,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          height: 1.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: LayoutTokens.gr0),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: FontTokens.hudXs,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
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
