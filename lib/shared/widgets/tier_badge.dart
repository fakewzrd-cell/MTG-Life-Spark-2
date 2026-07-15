import 'package:flutter/material.dart';

import '../../ui/tokens/color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../utils/wizard_rank_titles.dart';

/// Accent color for a metal progression tier.
Color wizardTierColor(String tier) {
  switch (tier) {
    case 'Silver':
      return const Color(0xFFC0C0C0);
    case 'Gold':
      return ColorTokens.accentGold;
    case 'Platinum':
      return const Color(0xFFE5E4E2);
    case 'Diamond':
      return const Color(0xFFB9F2FF);
    default:
      return const Color(0xFFCD7F32); // Bronze
  }
}

Color wizardTierColorForLevel(int level) =>
    wizardTierColor(tierForLevel(level));

class TierBadge extends StatelessWidget {
  final String tier;
  final int level;

  /// When set, the badge is tappable (e.g. open ranks info).
  final VoidCallback? onTap;

  /// Shows a small info glyph to hint the badge is explorable.
  final bool showInfoIcon;

  const TierBadge({
    super.key,
    required this.tier,
    required this.level,
    this.onTap,
    this.showInfoIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    // Color always follows [level] so a stale [tier] string cannot desync chrome.
    final color = wizardTierColorForLevel(level);
    final label = '${wizardRankTitle(level)} · Lv $level';
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: RadiusTokens.radiusSm,
        border: Border.all(color: color, width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: FontTokens.hudXs,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showInfoIcon) ...[
              SizedBox(width: LayoutTokens.gr1),
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: color.withValues(alpha: 0.9),
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return child;

    return Semantics(
      button: true,
      label: 'Rank $label. View all ranks.',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.radiusSm,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: LayoutTokens.minTapTarget,
              minHeight: LayoutTokens.minTapTarget,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
