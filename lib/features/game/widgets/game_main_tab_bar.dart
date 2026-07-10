import 'package:flutter/material.dart';

import '../../../shared/constants/app_icons.dart';
import 'game_colors.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';

/// Asset for the Play tab (fanned cards) — replaces generic controller icon.
const String kGamePlayTabIconAsset = AppIcons.playTabCards;

/// Play · Stack · History row — use inside [GameHudHeader].
class GameMainTabBarStrip extends StatelessWidget {
  const GameMainTabBarStrip({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.accentColor,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? accentColor;

  static const _segments = <_GameMainTabSpec>[
    _GameMainTabSpec(index: 0, label: 'Play', iconAsset: kGamePlayTabIconAsset),
    _GameMainTabSpec(index: 1, label: 'Stack', icon: Icons.layers_rounded),
    _GameMainTabSpec(index: 2, label: 'History', icon: Icons.history_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final dividerColor = colors.textSecondary.withValues(alpha: 0.12);
    final resolvedAccent = accentColor ?? colors.primaryAccent;

    return SizedBox(
      height: LayoutTokens.minTapTarget,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _segments.length; i++) ...[
            if (i > 0)
              VerticalDivider(width: 1, thickness: 1, color: dividerColor),
            Expanded(
              child: _GameMainTab(
                label: _segments[i].label,
                icon: _segments[i].icon,
                iconAsset: _segments[i].iconAsset,
                selected: selectedIndex == _segments[i].index,
                accentColor: resolvedAccent,
                onTap: () => onSelected(_segments[i].index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GameMainTabSpec {
  const _GameMainTabSpec({
    required this.index,
    required this.label,
    this.icon,
    this.iconAsset,
  });

  final int index;
  final String label;
  final IconData? icon;
  final String? iconAsset;
}

class _GameMainTab extends StatelessWidget {
  const _GameMainTab({
    required this.label,
    this.icon,
    this.iconAsset,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  static const double _iconSize = 20;

  Widget _buildIcon(Color fg) {
    final asset = iconAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        width: _iconSize,
        height: _iconSize,
        fit: BoxFit.contain,
        color: fg,
        colorBlendMode: BlendMode.srcIn,
        filterQuality: FilterQuality.medium,
      );
    }
    return Icon(icon ?? Icons.help_outline, size: _iconSize, color: fg);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final fg =
        selected
            ? accentColor
            : colors.textSecondary.withValues(alpha: OpacityTokens.mutedTextMin);
    final bg =
        selected
            ? accentColor.withValues(alpha: OpacityTokens.soft)
            : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: LayoutTokens.gr1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIcon(fg),
                    const SizedBox(width: LayoutTokens.gr0),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: FontTokens.hudSm,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        color: fg,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
