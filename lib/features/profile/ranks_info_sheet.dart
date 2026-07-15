import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../shared/utils/wizard_rank_titles.dart';
import '../../shared/widgets/tier_badge.dart';
import '../game/widgets/game_modal_chrome.dart';

/// Explains Level + Rank + metal tiers for the progression system.
Future<void> showRanksInfoSheet(
  BuildContext context, {
  int? currentLevel,
}) {
  HapticFeedback.selectionClick();
  return showGameBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _RanksInfoSheet(currentLevel: currentLevel),
  );
}

class _RanksInfoSheet extends StatelessWidget {
  const _RanksInfoSheet({this.currentLevel});

  final int? currentLevel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final maxH = MediaQuery.sizeOf(context).height * 0.78;
    final level = currentLevel?.clamp(1, 100);

    return SizedBox(
      height: maxH,
      child: GameSheetBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GameSheetHeader(
              title: 'Ranks & levels',
              subtitle:
                  'Level is your exact progress. Rank is the title for your '
                  'current level band. Metal tiers group those ranks.',
            ),
            SizedBox(height: LayoutTokens.gr2),
            Expanded(
              child: ListView(
                children: [
                  for (final tierBand in kWizardTierBands) ...[
                    _TierSectionHeader(
                      tier: tierBand.tier,
                      levelsLabel:
                          'Lv ${tierBand.minLevel}–${tierBand.maxLevel}',
                      color: wizardTierColor(tierBand.tier),
                      colors: colors,
                    ),
                    for (final rank in kWizardRankBands.where(
                      (r) =>
                          r.minLevel >= tierBand.minLevel &&
                          r.maxLevel <= tierBand.maxLevel,
                    ))
                      _RankRow(
                        title: rank.title,
                        levelsLabel: 'Lv ${rank.minLevel}–${rank.maxLevel}',
                        isCurrent: level != null &&
                            level >= rank.minLevel &&
                            level <= rank.maxLevel,
                        colors: colors,
                        accent: wizardTierColor(tierBand.tier),
                      ),
                    SizedBox(height: LayoutTokens.gr3),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierSectionHeader extends StatelessWidget {
  const _TierSectionHeader({
    required this.tier,
    required this.levelsLabel,
    required this.color,
    required this.colors,
  });

  final String tier;
  final String levelsLabel;
  final Color color;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: LayoutTokens.gr2),
          Expanded(
            child: Text(
              tier,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: FontTokens.body,
              ),
            ),
          ),
          Text(
            levelsLabel,
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: FontTokens.sm,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({
    required this.title,
    required this.levelsLabel,
    required this.isCurrent,
    required this.colors,
    required this.accent,
  });

  final String title;
  final String levelsLabel;
  final bool isCurrent;
  final AppColorTokens colors;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: LayoutTokens.gr4,
        bottom: LayoutTokens.gr1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCurrent ? accent : colors.textPrimary,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                fontSize: FontTokens.sm,
              ),
            ),
          ),
          Text(
            isCurrent ? '$levelsLabel · you' : levelsLabel,
            style: TextStyle(
              color: isCurrent ? accent : colors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: FontTokens.caption,
            ),
          ),
        ],
      ),
    );
  }
}
