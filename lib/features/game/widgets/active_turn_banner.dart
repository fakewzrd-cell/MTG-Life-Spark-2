import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'political_row_widget.dart';

/// Whose-turn strip on the Play tab — full-width so it reads at arm's length.
class ActiveTurnBanner extends StatelessWidget {
  const ActiveTurnBanner({super.key, required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final active = game.playerById(game.activePlayerId);
    final isLocal = game.isLocalPlayersTurn;
    final accent = isLocal
        ? colors.primaryAccent
        : (active?.playerColor ?? colors.primaryAccent);
    final name = isLocal
        ? 'You'
        : overviewShortPlayerName(active?.username ?? '—', maxChars: 14);
    final turnLabel = isLocal ? 'Your turn' : "$name's turn";
    final initial = isLocal
        ? 'Y'
        : (active?.username.isNotEmpty == true
            ? active!.username[0].toUpperCase()
            : '?');

    return Semantics(
      label: turnLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accent.withValues(alpha: isLocal ? 0.18 : 0.10),
              colors.surface.withValues(alpha: OpacityTokens.nearOpaque),
            ],
          ),
          borderRadius: RadiusTokens.radiusControlMd,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.gr2,
            vertical: LayoutTokens.gr1,
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: LayoutTokens.gr4,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: RadiusTokens.radiusXs,
                ),
              ),
              SizedBox(width: LayoutTokens.gr2),
              CircleAvatar(
                radius: 14,
                backgroundColor: accent,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: ColorTokens.onAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: FontTokens.hudSm,
                  ),
                ),
              ),
              SizedBox(width: LayoutTokens.gr2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLocal ? 'NOW PLAYING' : 'ACTIVE TURN',
                      style: TextStyle(
                        color: accent,
                        fontSize: FontTokens.hudXs,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      turnLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: FontTokens.title,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
