import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../shared/utils/game_haptics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_constants.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_format.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/theme/app_color_tokens.dart';
import 'game_colors.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import '../../../shared/widgets/game_icon.dart';
import 'game_modal_chrome.dart';

/// Highest commander damage on any single track (primary or partner).
int maxCommanderDamageTrack(
  PlayerGameState local,
  List<PlayerGameState> opponents,
) {
  var max = 0;
  for (final opp in opponents) {
    max = math.max(
      max,
      local.commanderDamageFrom(opp.playerId, partnerIndex: 0),
    );
    if (opp.hasPartner) {
      max = math.max(
        max,
        local.commanderDamageFrom(opp.playerId, partnerIndex: 1),
      );
    }
  }
  return max;
}

/// Total commander damage the local player has dealt across all opponents.
int totalCommanderDamageDealt(
  PlayerGameState local,
  List<PlayerGameState> opponents,
) {
  var total = 0;
  for (final opp in opponents) {
    total += opp.commanderDamageFrom(local.playerId, partnerIndex: 0);
    if (local.hasPartner) {
      total += opp.commanderDamageFrom(local.playerId, partnerIndex: 1);
    }
  }
  return total;
}

/// Highest single track of commander damage the local player has dealt.
int maxCommanderDamageDealtTrack(
  PlayerGameState local,
  List<PlayerGameState> opponents,
) {
  var max = 0;
  for (final opp in opponents) {
    max = math.max(
      max,
      opp.commanderDamageFrom(local.playerId, partnerIndex: 0),
    );
    if (local.hasPartner) {
      max = math.max(
        max,
        opp.commanderDamageFrom(local.playerId, partnerIndex: 1),
      );
    }
  }
  return max;
}

Color commanderDamageColor(AppColorTokens colors, int damage) {
  final ko = GameConstants.commanderDamageKo;
  if (damage >= ko) return colors.error;
  if (damage >= ko - 3) return colors.warning;
  if (damage >= 10) return colors.primaryAccent.withValues(alpha: 0.95);
  return colors.textPrimary;
}

/// True when this session uses Commander rules.
bool isCommanderGameSession({
  required PlayerGameState local,
  required List<PlayerGameState> allPlayers,
  GameFormat? gameFormat,
  int? startingLife,
}) {
  if (local.commanderName != null || local.hasPartner) return true;
  if (allPlayers.any((p) => p.commanderName != null || p.hasPartner)) {
    return true;
  }
  // Solo Commander pod — use lobby format / starting life, not current life.
  if (allPlayers.length <= 1) {
    if (gameFormat?.isCommanderStyle == true) return true;
    if (startingLife == GameFormat.commander.defaultStartingLife) return true;
  }
  return false;
}

/// Opens commander damage tracking in a bottom sheet (does not shift Play UI).
///
/// Handle + title sit outside the scroll list so swipe-down dismisses the sheet
/// (same pattern as card lookup). Only the threat list scrolls when tall.
Future<void> showCommanderDamageSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showGameBottomSheet<void>(
    context: context,
    builder: (ctx) {
      final maxH = MediaQuery.sizeOf(ctx).height * 0.92;
      // Handle, title, subtitle, gaps — keep out of the ListView.
      const chromeReserve = 140.0;
      final maxListH = (maxH - chromeReserve).clamp(160.0, maxH);
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: GameSheetBody(
          child: Consumer(
            builder: (context, ref, _) {
              final game = ref.watch(gameProvider);
              final local = game.localPlayer;
              if (local == null) return const SizedBox.shrink();

              final opponents = game.players
                  .where((p) => p.playerId != local.playerId)
                  .toList();
              final notifier = ref.read(gameProvider.notifier);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GameSheetHandle(),
                  SizedBox(height: LayoutTokens.gr2),
                  const GameSheetHeader(
                    title: 'Commander damage',
                    subtitle:
                        'Threats to you first. Open Dealt to log damage you dealt.',
                    showHandle: false,
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  LimitedBox(
                    maxHeight: maxListH,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CommanderDamagePanel(
                          localPlayer: local,
                          opponents: opponents,
                          onDamageChange: ({
                            required String fromPlayerId,
                            required int partnerIndex,
                            required String toPlayerId,
                            required int delta,
                          }) =>
                              notifier.applyCommanderDamage(
                            fromPlayerId: fromPlayerId,
                            partnerIndex: partnerIndex,
                            toPlayerId: toPlayerId,
                            delta: delta,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

/// Compact status control for the commander bar (right side).
class CommanderDamageBarButton extends StatelessWidget {
  final int totalDamage;
  final int maxTrackDamage;
  final bool enabled;
  final VoidCallback onTap;

  const CommanderDamageBarButton({
    super.key,
    required this.totalDamage,
    required this.maxTrackDamage,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final ko = GameConstants.commanderDamageKo;
    final remaining =
        (ko - maxTrackDamage).clamp(0, ko);
    final urgent = remaining <= 3;
    final lethal = remaining == 0 && maxTrackDamage >= ko;
    final accent = commanderDamageColor(colors, maxTrackDamage);

    return Semantics(
      button: true,
      enabled: enabled,
      label:
          'Commander damage life $remaining of $ko remaining, '
          '$maxTrackDamage taken on worst track, tap to manage',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: RadiusTokens.radiusControlSm,
          child: AnimatedContainer(
            duration: MotionTokens.standard,
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(
              minHeight: LayoutTokens.minTapTarget,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr2,
              vertical: LayoutTokens.gr1,
            ),
            decoration: BoxDecoration(
              color: urgent
                  ? accent.withValues(alpha: OpacityTokens.subtle)
                  : colors.primaryAccent.withValues(alpha: OpacityTokens.subtle),
              borderRadius: RadiusTokens.radiusControlSm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (lethal)
                  Icon(
                    Icons.warning_amber_rounded,
                    size: LayoutTokens.gr3 + 2,
                    color: enabled ? accent : colors.textSecondary,
                  )
                else
                  GameIcon.commanderDamage(
                    size: LayoutTokens.gr3 + 2,
                    color: enabled ? accent : colors.textSecondary,
                  ),
                SizedBox(height: LayoutTokens.gr0),
                Text(
                  '$remaining',
                  style: TextStyle(
                    color: enabled ? accent : colors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: remaining >= ko ? 18 : 16,
                    height: 1,
                  ),
                ),
                Text(
                  'left',
                  style: TextStyle(
                    color: enabled
                        ? accent.withValues(alpha: 0.9)
                        : colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Commander damage listing for the commander-damage bottom sheet.
class CommanderDamagePanel extends StatefulWidget {
  final PlayerGameState localPlayer;
  final List<PlayerGameState> opponents;
  final void Function({
    required String fromPlayerId,
    required int partnerIndex,
    required String toPlayerId,
    required int delta,
  }) onDamageChange;

  const CommanderDamagePanel({
    super.key,
    required this.localPlayer,
    required this.opponents,
    required this.onDamageChange,
  });

  @override
  State<CommanderDamagePanel> createState() => _CommanderDamagePanelState();
}

class _CommanderDamagePanelState extends State<CommanderDamagePanel> {
  String? _dealtExpandedId;

  List<PlayerGameState> get _trackableOpponents {
    final list = widget.opponents.where((o) {
      if (!o.isEliminated) return true;
      return _maxIncomingTrack(o) > 0 || _dealtTotal(o) > 0;
    }).toList();
    list.sort((a, b) => _maxIncomingTrack(b).compareTo(_maxIncomingTrack(a)));
    return list;
  }

  int _maxIncomingTrack(PlayerGameState opponent) {
    var max = widget.localPlayer.commanderDamageFrom(
      opponent.playerId,
      partnerIndex: 0,
    );
    if (opponent.hasPartner) {
      final p = widget.localPlayer.commanderDamageFrom(
        opponent.playerId,
        partnerIndex: 1,
      );
      if (p > max) max = p;
    }
    return max;
  }

  int _dealtTotal(PlayerGameState opponent) {
    var total = opponent.commanderDamageFrom(
      widget.localPlayer.playerId,
      partnerIndex: 0,
    );
    if (widget.localPlayer.hasPartner) {
      total += opponent.commanderDamageFrom(
        widget.localPlayer.playerId,
        partnerIndex: 1,
      );
    }
    return total;
  }

  String _shortName(String name) {
    if (name.length <= 14) return name;
    return '${name.substring(0, 13)}…';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final opponents = _trackableOpponents;
    final ko = GameConstants.commanderDamageKo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Damage each commander has dealt you — $ko eliminates.',
          style: TextStyle(
            fontSize: FontTokens.caption,
            color: colors.textSecondary,
            height: 1.35,
          ),
        ),
        SizedBox(height: LayoutTokens.gr3),
        if (opponents.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
            child: Text(
              'Opponents will appear here when others join the pod.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: FontTokens.caption,
                color: colors.textSecondary.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
          )
        else
          for (final opp in opponents) ...[
            _ThreatOpponentRow(
              opponent: opp,
              localPlayer: widget.localPlayer,
              shortName: _shortName(opp.username),
              dealtTotal: _dealtTotal(opp),
              dealtExpanded: _dealtExpandedId == opp.playerId,
              onToggleDealt: () => setState(() {
                _dealtExpandedId =
                    _dealtExpandedId == opp.playerId ? null : opp.playerId;
              }),
              onDamageChange: widget.onDamageChange,
            ),
            SizedBox(height: LayoutTokens.gr2),
          ],
      ],
    );
  }
}

class _ThreatOpponentRow extends StatelessWidget {
  const _ThreatOpponentRow({
    required this.opponent,
    required this.localPlayer,
    required this.shortName,
    required this.dealtTotal,
    required this.dealtExpanded,
    required this.onToggleDealt,
    required this.onDamageChange,
  });

  final PlayerGameState opponent;
  final PlayerGameState localPlayer;
  final String shortName;
  final int dealtTotal;
  final bool dealtExpanded;
  final VoidCallback onToggleDealt;
  final void Function({
    required String fromPlayerId,
    required int partnerIndex,
    required String toPlayerId,
    required int delta,
  }) onDamageChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final canEditReceived = !localPlayer.isEliminated;
    final canEditDealt = !opponent.isEliminated;
    final primaryDmg = localPlayer.commanderDamageFrom(
      opponent.playerId,
      partnerIndex: 0,
    );
    final partnerDmg = opponent.hasPartner
        ? localPlayer.commanderDamageFrom(
            opponent.playerId,
            partnerIndex: 1,
          )
        : 0;
    final accent = commanderDamageColor(colors, primaryDmg > partnerDmg
        ? primaryDmg
        : partnerDmg);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSecondary.withValues(alpha: 0.45),
        borderRadius: RadiusTokens.radiusMd,
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: EdgeInsets.all(LayoutTokens.gr2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _OpponentAvatar(opponent: opponent, size: 36),
                SizedBox(width: LayoutTokens.gr2),
                Expanded(
                  child: Text(
                    '$shortName → You',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: FontTokens.hudSm,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onToggleDealt,
                  child: Text(
                    dealtExpanded ? 'Hide dealt' : 'Dealt $dealtTotal',
                    style: TextStyle(
                      fontSize: FontTokens.hudXs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: LayoutTokens.gr2),
            _DamageTrack(
              label: opponent.commanderName ?? 'Commander',
              damage: primaryDmg,
              showTakenOfKo: true,
              onAdd: canEditReceived
                  ? () => onDamageChange(
                        fromPlayerId: opponent.playerId,
                        partnerIndex: 0,
                        toPlayerId: localPlayer.playerId,
                        delta: 1,
                      )
                  : null,
              onRemove: primaryDmg > 0 && canEditReceived
                  ? () => onDamageChange(
                        fromPlayerId: opponent.playerId,
                        partnerIndex: 0,
                        toPlayerId: localPlayer.playerId,
                        delta: -1,
                      )
                  : null,
            ),
            if (opponent.hasPartner) ...[
              SizedBox(height: LayoutTokens.gr2),
              _DamageTrack(
                label: opponent.partnerCommanderName ?? 'Partner',
                damage: partnerDmg,
                showTakenOfKo: true,
                onAdd: canEditReceived
                    ? () => onDamageChange(
                          fromPlayerId: opponent.playerId,
                          partnerIndex: 1,
                          toPlayerId: localPlayer.playerId,
                          delta: 1,
                        )
                    : null,
                onRemove: partnerDmg > 0 && canEditReceived
                    ? () => onDamageChange(
                          fromPlayerId: opponent.playerId,
                          partnerIndex: 1,
                          toPlayerId: localPlayer.playerId,
                          delta: -1,
                        )
                    : null,
              ),
            ],
            if (dealtExpanded) ...[
              SizedBox(height: LayoutTokens.gr3),
              _DirectionSection(
                title: 'You → $shortName',
                subtitle: 'Damage you dealt',
                sourcePlayer: localPlayer,
                targetPlayer: opponent,
                canEdit: canEditDealt,
                onDamageChange: onDamageChange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DirectionSection extends StatelessWidget {
  const _DirectionSection({
    required this.title,
    required this.subtitle,
    required this.sourcePlayer,
    required this.targetPlayer,
    required this.canEdit,
    required this.onDamageChange,
  });

  final String title;
  final String subtitle;
  final PlayerGameState sourcePlayer;
  final PlayerGameState targetPlayer;
  final bool canEdit;
  final void Function({
    required String fromPlayerId,
    required int partnerIndex,
    required String toPlayerId,
    required int delta,
  }) onDamageChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final primaryDmg = targetPlayer.commanderDamageFrom(
      sourcePlayer.playerId,
      partnerIndex: 0,
    );
    final partnerDmg = sourcePlayer.hasPartner
        ? targetPlayer.commanderDamageFrom(
            sourcePlayer.playerId,
            partnerIndex: 1,
          )
        : 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundSecondary.withValues(alpha: 0.4),
        borderRadius: RadiusTokens.radiusMd,
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(LayoutTokens.gr2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: FontTokens.hudSm,
              ),
            ),
            SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: FontTokens.hudXs,
              ),
            ),
            SizedBox(height: LayoutTokens.gr2),
            _DamageTrack(
              label: sourcePlayer.commanderName ?? 'Commander',
              damage: primaryDmg,
              onAdd: canEdit
                  ? () => onDamageChange(
                        fromPlayerId: sourcePlayer.playerId,
                        partnerIndex: 0,
                        toPlayerId: targetPlayer.playerId,
                        delta: 1,
                      )
                  : null,
              onRemove: primaryDmg > 0 && canEdit
                  ? () => onDamageChange(
                        fromPlayerId: sourcePlayer.playerId,
                        partnerIndex: 0,
                        toPlayerId: targetPlayer.playerId,
                        delta: -1,
                      )
                  : null,
            ),
            if (sourcePlayer.hasPartner) ...[
              SizedBox(height: LayoutTokens.gr2),
              _DamageTrack(
                label: sourcePlayer.partnerCommanderName ?? 'Partner commander',
                damage: partnerDmg,
                onAdd: canEdit
                    ? () => onDamageChange(
                          fromPlayerId: sourcePlayer.playerId,
                          partnerIndex: 1,
                          toPlayerId: targetPlayer.playerId,
                          delta: 1,
                        )
                    : null,
                onRemove: partnerDmg > 0 && canEdit
                    ? () => onDamageChange(
                          fromPlayerId: sourcePlayer.playerId,
                          partnerIndex: 1,
                          toPlayerId: targetPlayer.playerId,
                          delta: -1,
                        )
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpponentAvatar extends StatelessWidget {
  final PlayerGameState opponent;
  final double size;

  const _OpponentAvatar({required this.opponent, this.size = 44});

  @override
  Widget build(BuildContext context) {
    if (opponent.commanderImageUrl != null &&
        opponent.commanderImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: RadiusTokens.radiusControlMd,
        child: CachedNetworkImage(
          imageUrl: opponent.commanderImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _colorDot(size),
        ),
      );
    }
    return _colorDot(size);
  }

  Widget _colorDot(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: opponent.playerColor.withValues(alpha: OpacityTokens.soft),
          borderRadius: RadiusTokens.radiusControlMd,
          border: Border.all(color: opponent.playerColor),
        ),
        child: Icon(
          Icons.person,
          color: opponent.playerColor,
          size: LayoutTokens.gr3,
        ),
      );
}

class _DamageTrack extends StatelessWidget {
  final String label;
  final int damage;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool showTakenOfKo;

  const _DamageTrack({
    required this.label,
    required this.damage,
    this.onAdd,
    this.onRemove,
    this.showTakenOfKo = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final ko = GameConstants.commanderDamageKo;
    final color = commanderDamageColor(colors, damage);
    final progress = (damage / ko).clamp(0.0, 1.0);
    final title = showTakenOfKo ? '$label · $damage / $ko' : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontTokens.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (damage >= ko)
              Tooltip(
                message: 'Lethal commander damage!',
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: LayoutTokens.gr2,
                  color: colors.error,
                ),
              ),
          ],
        ),
        SizedBox(height: LayoutTokens.gr0),
        ClipRRect(
          borderRadius: BorderRadius.circular(LayoutTokens.gr0),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: colors.textSecondary.withValues(alpha: 0.1),
            color: color.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: LayoutTokens.gr1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DmgStepButton(
              icon: Icons.remove_rounded,
              isAdd: false,
              onTap: onRemove,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr3),
              child: AnimatedDefaultTextStyle(
                duration: MotionTokens.standard,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                child: Text('$damage'),
              ),
            ),
            _DmgStepButton(
              icon: Icons.add_rounded,
              isAdd: true,
              onTap: onAdd,
            ),
          ],
        ),
      ],
    );
  }
}

class _DmgStepButton extends StatelessWidget {
  final IconData icon;
  final bool isAdd;
  final VoidCallback? onTap;

  const _DmgStepButton({
    required this.icon,
    required this.isAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final enabled = onTap != null;
    final fill = isAdd
        ? colors.primaryAccent.withValues(alpha: enabled ? 0.22 : 0.08)
        : colors.success.withValues(alpha: enabled ? 0.2 : 0.08);
    final iconColor = enabled
        ? (isAdd ? colors.primaryAccent : colors.success)
        : colors.textSecondary.withValues(alpha: 0.45);

    return Semantics(
      button: true,
      enabled: enabled,
      label: isAdd ? 'Increase commander damage' : 'Decrease commander damage',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  context.gameHapticLight();
                  onTap!();
                }
              : null,
          borderRadius: RadiusTokens.radiusPill,
          child: AnimatedContainer(
            duration: MotionTokens.standard,
            width: LayoutTokens.thumbTapTarget,
            height: LayoutTokens.thumbTapTarget,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: iconColor),
          ),
        ),
      ),
    );
  }
}
