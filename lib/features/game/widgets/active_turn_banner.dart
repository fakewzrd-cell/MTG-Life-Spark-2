import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'political_row_widget.dart';

/// Whose-turn label on the Play tab — sized to read at a glance above the life counter.
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
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isLocal
                ? colors.primaryAccent.withValues(alpha: OpacityTokens.soft)
                : colors.backgroundSecondary.withValues(
                    alpha: OpacityTokens.soft,
                  ),
            borderRadius: RadiusTokens.radiusPill,
            border: Border.all(
              color: isLocal
                  ? colors.primaryAccent.withValues(alpha: OpacityTokens.moderate)
                  : colors.borderSubtle.withValues(alpha: OpacityTokens.strong),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr2,
              vertical: LayoutTokens.gr0 + 1,
            ),
            child: Text(
              turnLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLocal ? colors.primaryAccent : colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: FontTokens.hudSm,
                height: 1.1,
                letterSpacing: 0.15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
