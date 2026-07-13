import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../shared/utils/game_haptics.dart';
import '../../../shared/widgets/game_icon.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';

/// Matches gameplay dial / counter glyph tint on the strip.
Color politicsIconTone(BuildContext context) =>
    ColorTokens.textSecondary.withValues(alpha: 0.95);

/// Truncates long player names for compact overview chips.
String overviewShortPlayerName(String name, {int maxChars = 9}) {
  final trimmed = name.trim();
  if (trimmed.length <= maxChars) return trimmed;
  return '${trimmed.substring(0, maxChars - 1)}…';
}

/// Opens Monarch / Initiative / Day-Night assignment controls.
Future<void> showTablePoliticsSheet(BuildContext context) {
  return showGameBottomSheet<void>(
    context: context,
    builder: (_) => const _TablePoliticsSheet(),
  );
}

/// One-line politics status under Now Playing — tap to assign.
class TablePoliticsStatusLine extends StatelessWidget {
  const TablePoliticsStatusLine({super.key, required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final segments = _statusSegments(game);
    final hasActive = game.monarchPlayerId != null ||
        game.initiativePlayerId != null ||
        game.dayNight != DayNightState.none;

    return Semantics(
      button: true,
      label: 'Table politics. Tap to assign.',
      child: Material(
        color: colors.backgroundSecondary.withValues(alpha: OpacityTokens.soft),
        borderRadius: RadiusTokens.radiusControlSm,
        child: InkWell(
          onTap: () {
            context.gameHapticSelection();
            showTablePoliticsSheet(context);
          },
          borderRadius: RadiusTokens.radiusControlSm,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr2,
              vertical: LayoutTokens.gr1 + 2,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.public,
                  size: LayoutTokens.gr3,
                  color: hasActive ? colors.emphasis : colors.textSecondary,
                ),
                SizedBox(width: LayoutTokens.gr1),
                Expanded(
                  child: segments.isEmpty
                      ? Text(
                          'No monarch · No initiative · —',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: FontTokens.hudXs,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        )
                      : Wrap(
                          spacing: LayoutTokens.gr1,
                          runSpacing: LayoutTokens.gr0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (var i = 0; i < segments.length; i++) ...[
                              if (i > 0)
                                Text(
                                  '·',
                                  style: TextStyle(
                                    color: colors.textSecondary
                                        .withValues(alpha: 0.55),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              segments[i],
                            ],
                          ],
                        ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: LayoutTokens.gr3,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _statusSegments(GameState game) {
    final segments = <Widget>[];

    final monarch = game.monarchPlayerId != null
        ? game.playerById(game.monarchPlayerId!)
        : null;
    if (monarch != null) {
      segments.add(
        _StatusSegment(
          iconBuilder: (c) => GameIcon.monarch(size: 13, color: c),
          label: overviewShortPlayerName(monarch.username, maxChars: 8),
        ),
      );
    }

    final initiative = game.initiativePlayerId != null
        ? game.playerById(game.initiativePlayerId!)
        : null;
    if (initiative != null) {
      segments.add(
        _StatusSegment(
          iconBuilder: (c) => GameIcon.initiative(size: 13, color: c),
          label: overviewShortPlayerName(initiative.username, maxChars: 8),
        ),
      );
    }

    if (game.dayNight != DayNightState.none) {
      final isDay = game.dayNight == DayNightState.day;
      segments.add(
        _StatusSegment(
          iconBuilder: (c) => isDay
              ? GameIcon.day(size: 13, color: c)
              : GameIcon.night(size: 13, color: c),
          label: isDay ? 'Day' : 'Night',
        ),
      );
    }

    return segments;
  }
}

class _StatusSegment extends StatelessWidget {
  const _StatusSegment({
    required this.iconBuilder,
    required this.label,
  });

  final Widget Function(Color color) iconBuilder;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final tone = colors.emphasis;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconBuilder(tone),
        SizedBox(width: LayoutTokens.gr0 - 1),
        Text(
          label,
          style: TextStyle(
            color: tone,
            fontSize: FontTokens.hudXs,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _TablePoliticsSheet extends ConsumerWidget {
  const _TablePoliticsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GameSheetHeader(title: 'Assign table politics'),
          SizedBox(height: LayoutTokens.gr4),
          PoliticalRowWidget(game: game),
        ],
      ),
    );
  }
}

/// Monarch, Initiative, and Day/Night assign controls (sheet body).
class PoliticalRowWidget extends ConsumerWidget {
  final GameState game;

  const PoliticalRowWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PoliticalBadge(
              label: 'Monarch',
              headerIcon: GameIcon.monarch(
                size: 16,
                color: politicsIconTone(context),
              ),
              holderId: game.monarchPlayerId,
              players: game.players,
              canAssign: true,
              onTap: () => _showAssignPicker(
                context,
                ref,
                'Assign Monarch',
                game.monarchPlayerId,
                (pid) => notifier.setMonarch(pid),
              ),
            ),
          ),
          SizedBox(width: LayoutTokens.gr1),
          Expanded(
            child: _PoliticalBadge(
              label: 'Initiative',
              headerIcon: GameIcon.initiative(
                size: 16,
                color: politicsIconTone(context),
              ),
              holderId: game.initiativePlayerId,
              players: game.players,
              canAssign: true,
              onTap: () => _showAssignPicker(
                context,
                ref,
                'Assign Initiative',
                game.initiativePlayerId,
                (pid) => notifier.setInitiative(pid),
              ),
            ),
          ),
          SizedBox(width: LayoutTokens.gr1),
          Expanded(
            child: _DayNightToggle(
              dayNight: game.dayNight,
              isHost: true,
              onTap: () {
                final next = _nextDayNight(game.dayNight);
                notifier.setDayNight(next);
              },
            ),
          ),
        ],
      ),
    );
  }

  DayNightState _nextDayNight(DayNightState current) {
    switch (current) {
      case DayNightState.none:
        return DayNightState.day;
      case DayNightState.day:
        return DayNightState.night;
      case DayNightState.night:
        return DayNightState.none;
    }
  }

  void _showAssignPicker(
    BuildContext context,
    WidgetRef ref,
    String title,
    String? currentHolderId,
    void Function(String? pid) onAssign,
  ) {
    final game = ref.read(gameProvider);
    showGameBottomSheet<void>(
      context: context,
      builder: (_) => _PlayerPickerSheet(
        title: title,
        players: game.players.where((p) => !p.isEliminated).toList(),
        currentHolderId: currentHolderId,
        onSelected: (pid) {
          Navigator.pop(context);
          onAssign(pid);
        },
      ),
    );
  }
}

class _PoliticalBadge extends StatelessWidget {
  final String label;
  final Widget headerIcon;
  final String? holderId;
  final List<PlayerGameState> players;
  final bool canAssign;
  final VoidCallback? onTap;

  const _PoliticalBadge({
    required this.label,
    required this.headerIcon,
    required this.holderId,
    required this.players,
    required this.canAssign,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final holder = holderId != null
        ? players.where((p) => p.playerId == holderId).firstOrNull
        : null;
    final hasHolder = holder != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PoliticsColumnHeader(icon: headerIcon, label: label),
        SizedBox(height: LayoutTokens.gr1),
        Expanded(
          child: _OverviewFilledMarkerButton(
            enabled: canAssign,
            onPressed: canAssign ? onTap : null,
            filled: hasHolder,
            fillColor: hasHolder
                ? colors.emphasis.withValues(alpha: 0.88)
                : colors.backgroundSecondary.withValues(alpha: 0.9),
            foregroundColor:
                hasHolder ? colors.backgroundPrimary : colors.textSecondary,
            value: holder != null
                ? overviewShortPlayerName(holder.username)
                : 'None',
          ),
        ),
      ],
    );
  }
}

class _DayNightToggle extends StatelessWidget {
  final DayNightState dayNight;
  final bool isHost;
  final VoidCallback? onTap;

  const _DayNightToggle({
    required this.dayNight,
    required this.isHost,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final (valueLabel, color) = switch (dayNight) {
      DayNightState.none => ('None', colors.textSecondary),
      DayNightState.day => ('Day', colors.emphasis),
      DayNightState.night => ('Night', colors.primaryAccent),
    };
    final isActive = dayNight != DayNightState.none;

    final iconTone = politicsIconTone(context);
    final headerIcon = switch (dayNight) {
      DayNightState.day => GameIcon.day(size: 16, color: iconTone),
      DayNightState.night => GameIcon.night(size: 16, color: iconTone),
      DayNightState.none => GameIcon.day(
          size: 16,
          color: iconTone.withValues(alpha: 0.45),
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PoliticsColumnHeader(icon: headerIcon, label: 'Day/Night'),
        SizedBox(height: LayoutTokens.gr1),
        Expanded(
          child: _OverviewFilledMarkerButton(
            enabled: isHost,
            onPressed: isHost ? onTap : null,
            filled: isActive,
            fillColor: isActive
                ? color.withValues(alpha: 0.88)
                : colors.backgroundSecondary.withValues(alpha: 0.9),
            foregroundColor:
                isActive ? colors.backgroundPrimary : colors.textSecondary,
            value: valueLabel,
          ),
        ),
      ],
    );
  }
}

class _PoliticsColumnHeader extends StatelessWidget {
  final Widget icon;
  final String label;

  const _PoliticsColumnHeader({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: LayoutTokens.gr0),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: FontTokens.hudXs,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewFilledMarkerButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final bool filled;
  final Color fillColor;
  final Color foregroundColor;
  final String value;

  const _OverviewFilledMarkerButton({
    required this.enabled,
    required this.onPressed,
    required this.filled,
    required this.fillColor,
    required this.foregroundColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, LayoutTokens.minTapTarget),
        padding: EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr1,
          vertical: LayoutTokens.gr2,
        ),
        backgroundColor: fillColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor:
            colors.backgroundSecondary.withValues(alpha: 0.6),
        disabledForegroundColor: colors.textSecondary.withValues(alpha: 0.5),
        elevation: filled ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.radiusControlMd,
          side: BorderSide(
            color: filled
                ? colors.emphasis.withValues(alpha: 0.35)
                : colors.textSecondary.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Center(
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontTokens.hudXs,
            fontWeight: FontWeight.w700,
            color: foregroundColor,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}

class _PlayerPickerSheet extends StatelessWidget {
  final String title;
  final List<PlayerGameState> players;
  final String? currentHolderId;
  final void Function(String? pid) onSelected;

  const _PlayerPickerSheet({
    required this.title,
    required this.players,
    required this.currentHolderId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return GameSheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSheetHeader(title: title),
          ListTile(
            tileColor: currentHolderId == null
                ? colors.primaryAccent.withValues(alpha: 0.1)
                : colors.backgroundSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RadiusTokens.sm),
            ),
            title: Text(
              'None',
              style: TextStyle(color: colors.textSecondary),
            ),
            onTap: () => onSelected(null),
          ),
          SizedBox(height: LayoutTokens.gr1),
          ...players.map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
              child: ListTile(
                tileColor: p.playerId == currentHolderId
                    ? p.playerColor.withValues(alpha: 0.15)
                    : colors.backgroundSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                ),
                leading: CircleAvatar(
                  backgroundColor: p.playerColor,
                  radius: 14,
                  child: Text(
                    p.username.isNotEmpty ? p.username[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: ColorTokens.onAccent,
                      fontSize: FontTokens.caption,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  p.username,
                  style: TextStyle(color: colors.textPrimary),
                ),
                trailing: p.playerId == currentHolderId
                    ? Icon(
                        Icons.check_circle,
                        color: colors.success,
                        size: 18,
                      )
                    : null,
                onTap: () => onSelected(p.playerId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
