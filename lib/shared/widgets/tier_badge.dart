import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../utils/wizard_rank_titles.dart';

/// Accent color for a metal progression tier. Light surfaces get darker metals
/// so labels stay readable (pale silver/gold wash out on Fog/Slate light).
Color wizardTierColor(String tier, AppColorTokens colors) {
  final light = colors.backgroundPrimary.computeLuminance() > 0.5;
  switch (tier) {
    case 'Silver':
      return light ? const Color(0xFF475569) : const Color(0xFFC0C0C0);
    case 'Gold':
      return light ? const Color(0xFFB45309) : const Color(0xFFFBBF24);
    case 'Platinum':
      return light ? const Color(0xFF57534E) : const Color(0xFFE5E4E2);
    case 'Diamond':
      return light ? const Color(0xFF0369A1) : const Color(0xFF7DD3FC);
    default:
      return light ? const Color(0xFF9A3412) : const Color(0xFFCD7F32);
  }
}

Color wizardTierColorForLevel(int level, AppColorTokens colors) =>
    wizardTierColor(tierForLevel(level), colors);

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
    final l10n = AppLocalizations.of(context);
    final colors = AppColorTokens.of(context);
    // Color always follows [level] so a stale [tier] string cannot desync chrome.
    final color = wizardTierColorForLevel(level, colors);
    final label = l10n.tierBadgeLabel(wizardRankTitle(l10n, level), level);
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
      label: l10n.tierBadgeA11y(label),
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
