import 'package:flutter/material.dart';

import 'game_colors.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_main_tab_bar.dart';

/// Optional status strip + Play/Stack/Lookup/History in one header card.
class GameHudHeader extends StatelessWidget {
  const GameHudHeader({
    super.key,
    this.statusStrip,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.accentColor,
    required this.tightVertical,
    this.isLocalPlayersTurn = false,
  });

  final Widget? statusStrip;
  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final Color accentColor;
  final bool tightVertical;

  /// When true, the header card uses [accentColor] for active-turn chrome.
  final bool isLocalPlayersTurn;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final dividerColor = colors.textSecondary.withValues(alpha: 0.12);
    final activeTurn = isLocalPlayersTurn;

    return Semantics(
      label: activeTurn ? 'Your turn' : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: activeTurn
              ? Color.alphaBlend(
                  accentColor.withValues(alpha: OpacityTokens.soft),
                  colors.surface,
                )
              : colors.surface,
          borderRadius: RadiusTokens.radiusMd,
          border: Border.all(
            color: activeTurn
                ? accentColor.withValues(alpha: OpacityTokens.moderate)
                : colors.textSecondary.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: OpacityTokens.faint),
              blurRadius: LayoutTokens.gr2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: RadiusTokens.radiusMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (statusStrip != null) ...[
                Padding(
                  padding: EdgeInsets.all(
                    tightVertical ? LayoutTokens.gr1 : LayoutTokens.gr2,
                  ),
                  child: statusStrip,
                ),
                Divider(height: 1, thickness: 1, color: dividerColor),
              ],
              GameMainTabBarStrip(
                selectedIndex: selectedTabIndex,
                accentColor: accentColor,
                onSelected: onTabSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
