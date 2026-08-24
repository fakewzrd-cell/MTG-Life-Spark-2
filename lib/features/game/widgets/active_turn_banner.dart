import 'package:flutter/material.dart';

import '../../../core/game/game_state.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final active = game.playerById(game.activePlayerId);
    final isLocal = game.isLocalPlayersTurn;
    // Seat identity uses player color — brand accent is reserved for CTAs.
    final accent = active?.playerColor ?? colors.primaryAccent;
    final name = isLocal
        ? 'You'
        : overviewShortPlayerName(active?.username ?? '—', maxChars: 14);
    final turnLabel =
        isLocal ? l10n.gameYourTurn : l10n.gamePlayersTurn(name);
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
              accent.withValues(alpha: isLocal ? OpacityTokens.soft : OpacityTokens.faint),
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
                    color: ColorTokens.onColor(accent),
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
                      isLocal ? l10n.gameNowPlaying : l10n.gameActiveTurn,
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
