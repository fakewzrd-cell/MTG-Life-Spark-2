import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../ui/tokens/font_tokens.dart';
import 'game_colors.dart';
import 'political_row_widget.dart';

/// Minimal whose-turn label on the Play tab (and HUD when no commander bar).
class ActiveTurnBanner extends StatelessWidget {
  const ActiveTurnBanner({super.key, required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final active = game.playerById(game.activePlayerId);
    final isLocal = game.isLocalPlayersTurn;
    final name = isLocal
        ? 'You'
        : overviewShortPlayerName(active?.username ?? '—', maxChars: 14);
    final turnLabel = isLocal ? 'Your turn' : "$name's turn";

    return Semantics(
      label: turnLabel,
      child: Text(
        turnLabel,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isLocal ? colors.primaryAccent : colors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: FontTokens.hudXs,
          height: 1,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
