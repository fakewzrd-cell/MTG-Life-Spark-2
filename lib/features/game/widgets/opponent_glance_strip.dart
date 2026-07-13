import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'political_row_widget.dart';

/// Compact opponent life strip on the Play tab — tap to open Table overview.
class OpponentGlanceStrip extends StatelessWidget {
  const OpponentGlanceStrip({
    super.key,
    required this.game,
    required this.localPlayerId,
    required this.onOpenTable,
  });

  final GameState game;
  final String localPlayerId;
  final VoidCallback onOpenTable;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final opponents = game.players
        .where((p) => p.playerId != localPlayerId)
        .toList()
      ..sort((a, b) {
        if (a.isEliminated != b.isEliminated) {
          return a.isEliminated ? 1 : -1;
        }
        return a.life.compareTo(b.life);
      });

    if (opponents.isEmpty) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: 'Open table overview',
      child: Material(
        color: colors.surface.withValues(alpha: OpacityTokens.nearOpaque),
        borderRadius: RadiusTokens.radiusControlMd,
        child: InkWell(
          onTap: onOpenTable,
          borderRadius: RadiusTokens.radiusControlMd,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: RadiusTokens.radiusControlMd,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr1,
              vertical: LayoutTokens.gr1,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < opponents.length; i++) ...[
                          if (i > 0) SizedBox(width: LayoutTokens.gr1),
                          _OpponentGlanceChip(player: opponents[i]),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(width: LayoutTokens.gr0),
                Icon(
                  Icons.grid_view_rounded,
                  size: 18,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpponentGlanceChip extends StatelessWidget {
  const _OpponentGlanceChip({required this.player});

  final PlayerGameState player;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final eliminated = player.isEliminated;
    final lifeTone = eliminated
        ? colors.textSecondary
        : player.life <= 5
            ? ColorTokens.danger
            : player.life <= 10
                ? ColorTokens.emphasis
                : colors.textPrimary;
    final name = overviewShortPlayerName(player.username, maxChars: 8);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1,
        vertical: LayoutTokens.gr0,
      ),
      decoration: BoxDecoration(
        color: eliminated
            ? colors.backgroundSecondary.withValues(alpha: OpacityTokens.half)
            : player.playerColor.withValues(alpha: 0.12),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: player.playerColor.withValues(
                alpha: eliminated ? 0.4 : 1,
              ),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: LayoutTokens.gr0),
          Text(
            name,
            style: TextStyle(
              color: eliminated ? colors.textSecondary : colors.textPrimary,
              fontSize: FontTokens.hudXs,
              fontWeight: FontWeight.w700,
              decoration: eliminated ? TextDecoration.lineThrough : null,
            ),
          ),
          SizedBox(width: LayoutTokens.gr0),
          Text(
            eliminated ? 'OUT' : '${player.life}',
            style: TextStyle(
              color: lifeTone,
              fontSize: FontTokens.hudSm,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
