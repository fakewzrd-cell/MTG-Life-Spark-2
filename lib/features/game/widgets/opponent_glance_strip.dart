import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'political_row_widget.dart';

/// Compact pod strip on the Play tab — full turn order including you.
///
/// Chips start at the active player and wrap clockwise. Tap opens Table.
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
    final pod = game.playersInTurnOrderFrom(game.activePlayerId);
    if (pod.isEmpty) return const SizedBox.shrink();

    return Semantics(
      button: true,
      label: 'Open table overview, turn order',
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
                        for (var i = 0; i < pod.length; i++) ...[
                          if (i > 0) SizedBox(width: LayoutTokens.gr1),
                          _PodGlanceChip(
                            player: pod[i],
                            isLocal: pod[i].playerId == localPlayerId,
                            isActive: pod[i].playerId == game.activePlayerId,
                          ),
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

class _PodGlanceChip extends StatelessWidget {
  const _PodGlanceChip({
    required this.player,
    required this.isLocal,
    required this.isActive,
  });

  final PlayerGameState player;
  final bool isLocal;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final eliminated = player.isEliminated;
    final lifeTone = eliminated
        ? colors.textSecondary
        : player.life <= 5
            ? colors.error
            : player.life <= 10
                ? colors.emphasis
                : colors.textPrimary;
    final name = isLocal
        ? 'You'
        : overviewShortPlayerName(player.username, maxChars: 8);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1,
        vertical: LayoutTokens.gr0,
      ),
      decoration: BoxDecoration(
        color: eliminated
            ? colors.backgroundSecondary.withValues(alpha: OpacityTokens.half)
            : player.playerColor.withValues(alpha: isLocal ? 0.22 : 0.12),
        borderRadius: RadiusTokens.radiusControlSm,
        border: isActive
            ? Border.all(
                color: colors.primaryAccent.withValues(alpha: 0.85),
                width: 1.5,
              )
            : isLocal
                ? Border.all(
                    color: player.playerColor.withValues(alpha: 0.55),
                  )
                : null,
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
