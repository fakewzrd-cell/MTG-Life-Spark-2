import 'package:flutter/material.dart';

import '../../../core/game/player_game_state.dart';
import 'game_colors.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'resolved_commander_avatar.dart';

/// Top bar of the personal view: commander avatar (tap to cast), tax, round.
class CommanderInfoBar extends StatelessWidget {
  final PlayerGameState player;
  final VoidCallback onCastCommander;
  final VoidCallback onUncastCommander;
  /// When true, use tighter padding for embedding inside a parent card.
  final bool embeddedInCard;
  /// Optional round number to show under tax (extra info).
  final int? roundNumber;
  /// Optional trailing control (e.g. commander damage status).
  final Widget? statusTrailing;
  /// Resolved ally display name when [player.allyPlayerId] is set.
  final String? allyUsername;

  const CommanderInfoBar({
    super.key,
    required this.player,
    required this.onCastCommander,
    required this.onUncastCommander,
    this.embeddedInCard = false,
    this.roundNumber,
    this.statusTrailing,
    this.allyUsername,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final w = MediaQuery.sizeOf(context).width;
    final isCompact = w < GameLayoutBreakpoints.compact;
    final isVeryNarrow = w < GameLayoutBreakpoints.narrow;
    final avatarSize = LayoutTokens.minTapTarget;
    final partnerSize = LayoutTokens.minTapTarget;
    final gap = isVeryNarrow
        ? LayoutTokens.gr0
        : (isCompact ? LayoutTokens.gr1 : LayoutTokens.gr3);

    return Container(
      padding:
          embeddedInCard
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                horizontal:
                    isVeryNarrow ? LayoutTokens.gr1 : (isCompact ? LayoutTokens.gr2 : LayoutTokens.gr3),
                vertical:
                    isVeryNarrow ? LayoutTokens.gr1 : (isCompact ? LayoutTokens.gr2 : LayoutTokens.gr3),
              ),
      child: Row(
        children: [
          _CastableCommanderAvatar(
            playerId: player.playerId,
            commanderName: player.commanderName,
            imageUrl: player.commanderImageUrl,
            selectedDeckId: player.selectedDeckId,
            playerColor: player.playerColor,
            size: avatarSize,
            enabled: !player.isEliminated,
            onCast: onCastCommander,
          ),

          if (player.hasPartner && player.partnerCommanderName != null) ...[
            SizedBox(width: gap),
            ResolvedCommanderAvatar(
              playerId: player.playerId,
              commanderName: player.partnerCommanderName,
              imageUrl: player.partnerCommanderImageUrl,
              selectedDeckId: player.selectedDeckId,
              playerColor: player.playerColor,
              size: partnerSize,
              isPartner: true,
            ),
          ],

          SizedBox(width: gap),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.commanderName ?? 'No Commander',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: isVeryNarrow
                        ? FontTokens.hudXs
                        : (isCompact ? FontTokens.hudSm : FontTokens.body),
                  ),
                ),
                if (player.hasPartner && player.partnerCommanderName != null)
                  Text(
                    '+ ${player.partnerCommanderName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.hudXs,
                    ),
                  ),
                SizedBox(height: isVeryNarrow ? 3 : 4),
                _CommanderTaxBadge(
                  castCount: player.commanderCastCount,
                  tax: player.commanderTax,
                  compact: isVeryNarrow || isCompact,
                  enabled: !player.isEliminated,
                  onUncast: onUncastCommander,
                ),
                if (roundNumber != null) ...[
                  SizedBox(height: LayoutTokens.gr0),
                  Text(
                    'Round $roundNumber',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.hudXs,
                    ),
                  ),
                ],
                // Keep ally status in the text column — never beside the
                // commander-damage control (that reads as locking damage).
                if (player.allyPlayerId != null) ...[
                  SizedBox(height: LayoutTokens.gr0),
                  Text(
                    'Ally · ${allyUsername ?? 'secret'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.emphasis,
                      fontSize: FontTokens.hudXs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (statusTrailing != null) ...[
            SizedBox(width: isVeryNarrow ? LayoutTokens.gr0 : LayoutTokens.gr1),
            statusTrailing!,
          ],
        ],
      ),
    );
  }
}

/// Primary commander art: tap to cast (replaces separate Cast control).
class _CastableCommanderAvatar extends StatelessWidget {
  final String playerId;
  final String? commanderName;
  final String? imageUrl;
  final String? selectedDeckId;
  final Color playerColor;
  final double size;
  final bool enabled;
  final VoidCallback onCast;

  const _CastableCommanderAvatar({
    required this.playerId,
    required this.commanderName,
    required this.imageUrl,
    required this.selectedDeckId,
    required this.playerColor,
    required this.size,
    required this.enabled,
    required this.onCast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? 'Cast commander' : 'Eliminated',
      child: Tooltip(
        message: enabled ? 'Cast commander' : 'Eliminated',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onCast : null,
            borderRadius: RadiusTokens.radiusControlMd,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ResolvedCommanderAvatar(
                      playerId: playerId,
                      commanderName: commanderName,
                      imageUrl: imageUrl,
                      selectedDeckId: selectedDeckId,
                      playerColor: playerColor,
                      size: size,
                    ),
                  ),
                  if (enabled)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(LayoutTokens.gr0),
                          decoration: BoxDecoration(
                            color: colors.primaryAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            size: size >= LayoutTokens.minTapTarget
                                ? LayoutTokens.gr2
                                : LayoutTokens.gr0 * 2,
                            color: ColorTokens.onAccent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommanderTaxBadge extends StatelessWidget {
  final int castCount;
  final int tax;
  final bool compact;
  final bool enabled;
  final VoidCallback onUncast;

  const _CommanderTaxBadge({
    required this.castCount,
    required this.tax,
    required this.onUncast,
    this.compact = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final fs = compact ? 11.0 : 12.0;
    if (castCount == 0) {
      return Text(
        'No tax yet',
        style: TextStyle(color: colors.textSecondary, fontSize: fs),
      );
    }

    final canUncast = enabled && castCount > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: canUncast,
          enabled: canUncast,
          label: canUncast ? 'Remove last commander cast' : 'Commander tax',
          child: Tooltip(
            message: canUncast ? 'Tap to remove last cast' : 'Tax +$tax',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canUncast ? onUncast : null,
                borderRadius: RadiusTokens.radiusControlMd,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 8,
                    vertical: compact ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.15),
                    borderRadius: RadiusTokens.radiusControlMd,
                  ),
                  child: Text(
                    'Tax +$tax',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: fs,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: compact ? 3 : 4),
        Flexible(
          child: Text(
            '(cast $castCount×)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: fs),
          ),
        ),
      ],
    );
  }
}
