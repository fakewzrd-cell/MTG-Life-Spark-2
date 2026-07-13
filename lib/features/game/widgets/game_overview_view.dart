import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/commander_identity_colors.dart';
import '../../../core/game/game_phase.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'alliance_overview_ui.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';
import 'game_timeout_widgets.dart';
import 'overview_commander_art_backdrop.dart';
import 'political_row_widget.dart';
import 'team_colors.dart';
import '../../../shared/utils/game_haptics.dart';
import '../../../shared/widgets/game_icon.dart';

/// Short label for an elimination reason (compact eliminated row).
String? eliminationReasonShortLabel(String? reason) => switch (reason) {
      'life' => 'Life loss',
      'poison' => 'Poison',
      'commanderDamage' => 'Commander dmg',
      'concede' => 'Conceded',
      'disconnect' => 'Disconnected',
      _ => null,
    };

// ── Overview View ─────────────────────────────────────────────────────────

class GameOverviewView extends ConsumerWidget {
  final GameState game;
  final VoidCallback onClose;

  const GameOverviewView({super.key, required this.game, required this.onClose});

  Widget _rowFor(PlayerGameState p, GameState game) {
    return p.isEliminated
        ? _EliminatedPlayerRow(p: p, game: game)
        : _GameOverviewPlayerCard(p: p, game: game);
  }

  /// Groups by team when any team is assigned; otherwise a flat roster.
  /// Unassigned players (team 0) render as their own trailing group.
  List<Widget> _buildPlayerListChildren(BuildContext context, GameState game) {
    final colors = context.gameColors;
    final assignments = game.teamAssignments;
    final hasTeams = assignments.values.any((t) => t > 0);

    if (!hasTeams) {
      return game.players.map((p) => _rowFor(p, game)).toList();
    }

    final byTeam = <int, List<PlayerGameState>>{};
    for (final p in game.players) {
      final t = assignments[p.playerId] ?? 0;
      byTeam.putIfAbsent(t, () => []).add(p);
    }
    final teamIds = byTeam.keys.where((t) => t > 0).toList()..sort();

    final children = <Widget>[];
    for (final t in teamIds) {
      children.add(_TeamGroupHeader(teamIndex: t, colors: colors));
      children.addAll(byTeam[t]!.map((p) => _rowFor(p, game)));
    }
    final unassigned = byTeam[0];
    if (unassigned != null && unassigned.isNotEmpty) {
      children.add(_TeamGroupHeader(teamIndex: 0, colors: colors));
      children.addAll(unassigned.map((p) => _rowFor(p, game)));
    }
    return children;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.gameColors;
    final notifier = ref.read(gameProvider.notifier);
    final aliveCount = game.activePlayers.length;
    final activePlayer = game.playerById(game.activePlayerId);
    final turnSubtitle = activePlayer == null
        ? null
        : activePlayer.playerId == game.localPlayerId
            ? 'Your turn'
            : '${overviewShortPlayerName(activePlayer.username, maxChars: 16)}\'s turn';

    const pageInset = LayoutTokens.shellPageInset;
    final gradientColors = CommanderIdentityColors.gameplayGradient(
      game.localPlayer?.commanderColorIdentity ?? const [],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: colors.backgroundPrimary.withValues(alpha: 0.82),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: turnSubtitle == null
                  ? LayoutTokens.minTapTarget
                  : LayoutTokens.minTapTarget + LayoutTokens.gr2,
              leadingWidth: pageInset + LayoutTokens.minTapTarget,
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Round ${game.roundNumber}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: FontTokens.title,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      height: 1,
                    ),
                  ),
                  if (turnSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      turnSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontTokens.hudXs,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ],
              ),
              leading: SizedBox(
                width: pageInset + LayoutTokens.minTapTarget,
                child: Padding(
                  padding: EdgeInsets.only(left: pageInset),
                  child: Align(
                    alignment: Alignment.center,
                    child: Tooltip(
                      message: 'Close overview',
                      child: GameDialogCloseButton(onPressed: onClose),
                    ),
                  ),
                ),
              ),
              actions: [
                if (game.isHost &&
                    game.isLocalPlayersTurn &&
                    !game.timeoutActive)
                  Padding(
                    padding: EdgeInsets.only(right: pageInset),
                    child: Align(
                      alignment: Alignment.center,
                      child: FilledButton.tonal(
                        onPressed: () => notifier.endTurn(),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primaryAccent.withValues(
                            alpha: OpacityTokens.soft,
                          ),
                          foregroundColor: colors.primaryAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: LayoutTokens.gr2,
                          ),
                          minimumSize: const Size(
                            0,
                            LayoutTokens.minTapTarget,
                          ),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          shape: RoundedRectangleBorder(
                            borderRadius: RadiusTokens.radiusControlSm,
                          ),
                        ),
                        child: Text(
                          'End turn',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: FontTokens.body,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: pageInset + LayoutTokens.minTapTarget,
                    height: LayoutTokens.minTapTarget,
                  ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pageInset,
                  LayoutTokens.gr2,
                  pageInset,
                  0,
                ),
                child: TablePoliticsStatusLine(game: game),
              ),
            ),

            if (activePlayer != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pageInset,
                    LayoutTokens.gr2,
                    pageInset,
                    0,
                  ),
                  child: _ActivePlayerSpotlight(
                    game: game,
                    player: activePlayer,
                  ),
                ),
              ),

            if (game.timeoutActive)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pageInset,
                    0,
                    pageInset,
                    LayoutTokens.gr2,
                  ),
                  child: GameTimeoutBanner(
                    startTime: game.timeoutStartTime,
                    durationSeconds: game.timeoutDurationSeconds,
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pageInset,
                  LayoutTokens.gr2,
                  pageInset,
                  LayoutTokens.gr1,
                ),
                child: Row(
                  children: [
                    Text(
                      'Players',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontTokens.caption,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(width: LayoutTokens.gr1),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: LayoutTokens.gr1,
                        vertical: LayoutTokens.gr0 - 1,
                      ),
                      decoration: BoxDecoration(
                        color: colors.backgroundSecondary.withValues(
                          alpha: OpacityTokens.soft,
                        ),
                        borderRadius: RadiusTokens.radiusControlSm,
                      ),
                      child: Text(
                        '$aliveCount',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontTokens.hudXs,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                pageInset,
                0,
                pageInset,
                LayoutTokens.gr4,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildPlayerListChildren(context, game),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero band for the current turn holder — answers "whose turn?" at a glance
/// without scrolling the roster below.
class _ActivePlayerSpotlight extends StatelessWidget {
  const _ActivePlayerSpotlight({required this.game, required this.player});

  final GameState game;
  final PlayerGameState player;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final isLocal = player.playerId == game.localPlayerId;
    final teamIdx = game.teamAssignments[player.playerId] ?? 0;
    final accent = teamIdx > 0 ? teamColor(teamIdx) : player.playerColor;
    final isMonarch = game.isMonarch(player.playerId);
    final hasInit = game.hasInitiative(player.playerId);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.22),
            colors.surface,
          ],
        ),
        borderRadius: RadiusTokens.radiusMd,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr2,
          vertical: LayoutTokens.gr2,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: accent,
              child: Text(
                player.username.isNotEmpty
                    ? player.username[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: ColorTokens.onAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: FontTokens.body,
                ),
              ),
            ),
            SizedBox(width: LayoutTokens.gr2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'NOW PLAYING',
                        style: TextStyle(
                          color: accent,
                          fontSize: FontTokens.hudXs,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      if (isMonarch) ...[
                        SizedBox(width: LayoutTokens.gr1),
                        GameIcon.monarch(
                          size: 14,
                          color: politicsIconTone(context),
                        ),
                      ],
                      if (hasInit) ...[
                        SizedBox(width: LayoutTokens.gr0),
                        GameIcon.initiative(
                          size: 14,
                          color: politicsIconTone(context),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: player.username,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: FontTokens.title,
                            height: 1.1,
                          ),
                        ),
                        if (isLocal)
                          TextSpan(
                            text: ' · you',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: FontTokens.hudXs,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    game.currentPhase.streamlinedShortLabel,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.hudSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: LayoutTokens.gr2),
            _GameOverviewLifeBadge(
              life: player.life,
              eliminated: false,
              isActive: true,
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header for a team cluster in the roster ("Team 1", "Unassigned").
class _TeamGroupHeader extends StatelessWidget {
  const _TeamGroupHeader({required this.teamIndex, required this.colors});

  final int teamIndex;
  final AppColorTokens colors;

  @override
  Widget build(BuildContext context) {
    final color = teamIndex == 0 ? colors.textSecondary : teamColor(teamIndex);
    final label = teamIndex == 0 ? 'Unassigned' : 'Team $teamIndex';
    return Padding(
      padding: EdgeInsets.fromLTRB(
        LayoutTokens.gr0,
        LayoutTokens.gr2,
        LayoutTokens.gr0,
        LayoutTokens.gr1,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: LayoutTokens.gr1),
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: FontTokens.hudXs,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(width: LayoutTokens.gr1),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: colors.textSecondary.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact single-line row for eliminated players — keeps focus on the
/// table that's still playing instead of matching the full card height.
class _EliminatedPlayerRow extends StatelessWidget {
  const _EliminatedPlayerRow({required this.p, required this.game});

  final PlayerGameState p;
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final isLocal = p.playerId == game.localPlayerId;
    final reasonLabel = eliminationReasonShortLabel(p.eliminationReason);

    return Container(
      margin: EdgeInsets.only(bottom: LayoutTokens.gr1),
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr2,
        vertical: LayoutTokens.gr1,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary.withValues(alpha: OpacityTokens.half),
        borderRadius: RadiusTokens.radiusSm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: p.playerColor.withValues(alpha: 0.25),
            child: Text(
              p.username.isNotEmpty ? p.username[0].toUpperCase() : '?',
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: FontTokens.hudXs,
              ),
            ),
          ),
          SizedBox(width: LayoutTokens.gr1 + 2),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: p.username,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: FontTokens.hudSm,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: colors.textSecondary.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  if (isLocal)
                    TextSpan(
                      text: ' · you',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: FontTokens.hudXs,
                      ),
                    ),
                  if (reasonLabel != null)
                    TextSpan(
                      text: '  ·  $reasonLabel',
                      style: TextStyle(
                        color: colors.textSecondary.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                        fontSize: FontTokens.hudXs,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: LayoutTokens.gr1),
          Text(
            'OUT',
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: FontTokens.hudXs,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverviewLifeBadge extends StatelessWidget {
  const _GameOverviewLifeBadge({
    required this.life,
    required this.eliminated,
    required this.isActive,
    required this.accent,
  });

  final int life;
  final bool eliminated;
  final bool isActive;
  final Color accent;

  Color get _textColor {
    if (eliminated) return ColorTokens.textSecondary;
    if (life <= 5) return ColorTokens.danger;
    if (life <= 10) return ColorTokens.emphasis;
    return ColorTokens.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 56,
        minHeight: LayoutTokens.minTapTarget,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1 + 2,
        vertical: LayoutTokens.gr0 + 2,
      ),
      decoration: BoxDecoration(
        color: isActive && !eliminated
            ? accent.withValues(alpha: OpacityTokens.subtle)
            : ColorTokens.backgroundSecondary.withValues(alpha: OpacityTokens.half),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      alignment: Alignment.center,
      child: eliminated
          ? Text(
            'OUT',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w700,
              fontSize: FontTokens.hudSm,
              height: 1,
            ),
          )
          : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 18,
                color: _textColor.withValues(alpha: OpacityTokens.nearOpaque),
              ),
              SizedBox(width: LayoutTokens.gr0),
              Text(
                '$life',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: FontTokens.body,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
    );
  }
}

/// Compact − / life / + for Table roster — host can edit anyone; others only self.
class _GameOverviewLifeStepper extends StatelessWidget {
  const _GameOverviewLifeStepper({
    required this.life,
    required this.isActive,
    required this.accent,
    required this.enabled,
    required this.onDelta,
  });

  final int life;
  final bool isActive;
  final Color accent;
  final bool enabled;
  final void Function(int delta) onDelta;

  Color get _textColor {
    if (life <= 5) return ColorTokens.danger;
    if (life <= 10) return ColorTokens.emphasis;
    return ColorTokens.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive
            ? accent.withValues(alpha: OpacityTokens.subtle)
            : colors.backgroundSecondary.withValues(alpha: OpacityTokens.half),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LifeStepButton(
            icon: Icons.remove_rounded,
            enabled: enabled,
            semanticLabel: 'Decrease life',
            onTap: enabled
                ? () {
                    context.gameHapticLight();
                    onDelta(-1);
                  }
                : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: _textColor.withValues(alpha: OpacityTokens.nearOpaque),
                ),
                SizedBox(width: LayoutTokens.gr0 - 1),
                Text(
                  '$life',
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: FontTokens.body,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          _LifeStepButton(
            icon: Icons.add_rounded,
            enabled: enabled,
            semanticLabel: 'Increase life',
            onTap: enabled
                ? () {
                    context.gameHapticLight();
                    onDelta(1);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _LifeStepButton extends StatelessWidget {
  const _LifeStepButton({
    required this.icon,
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: RadiusTokens.radiusControlSm,
          child: SizedBox(
            width: LayoutTokens.minTapTarget,
            height: LayoutTokens.minTapTarget,
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? colors.textPrimary
                  : colors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameOverviewCommanderTaxChip extends StatelessWidget {
  const _GameOverviewCommanderTaxChip({required this.tax});

  final int tax;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Semantics(
      label: 'Commander tax plus $tax',
      child: Container(
        constraints: const BoxConstraints(
        minHeight: LayoutTokens.minTapTarget,
        minWidth: LayoutTokens.minTapTarget,
      ),
        padding: EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr1,
          vertical: LayoutTokens.gr0,
        ),
        decoration: BoxDecoration(
          color: colors.textSecondary.withValues(alpha: 0.15),
          borderRadius: RadiusTokens.radiusControlSm,
        ),
        alignment: Alignment.center,
        child: Text(
          'Tax +$tax',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: FontTokens.caption,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Compact monarch / initiative markers on a player card.
class _PlayerPoliticsBadges extends StatelessWidget {
  const _PlayerPoliticsBadges({
    required this.isMonarch,
    required this.hasInitiative,
  });

  final bool isMonarch;
  final bool hasInitiative;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final tone = politicsIconTone(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMonarch)
          _badge(
            colors: colors,
            child: GameIcon.monarch(size: 14, color: tone),
            semanticsLabel: 'Monarch',
          ),
        if (isMonarch && hasInitiative) SizedBox(width: LayoutTokens.gr0),
        if (hasInitiative)
          _badge(
            colors: colors,
            child: GameIcon.initiative(size: 14, color: tone),
            semanticsLabel: 'Initiative',
          ),
      ],
    );
  }

  Widget _badge({
    required AppColorTokens colors,
    required Widget child,
    required String semanticsLabel,
  }) {
    return Semantics(
      label: semanticsLabel,
      child: Container(
        padding: EdgeInsets.all(LayoutTokens.gr0),
        decoration: BoxDecoration(
          color: colors.emphasis.withValues(alpha: OpacityTokens.soft),
          borderRadius: RadiusTokens.radiusControlSm,
        ),
        child: child,
      ),
    );
  }
}

class _GameOverviewPlayerCard extends ConsumerWidget {
  final PlayerGameState p;
  final GameState game;

  const _GameOverviewPlayerCard({required this.p, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.gameColors;
    final isActive = p.playerId == game.activePlayerId;
    final isLocal = p.playerId == game.localPlayerId;
    final teamIdx = game.teamAssignments[p.playerId] ?? 0;
    final local = game.localPlayer;
    final notifier = ref.read(gameProvider.notifier);
    final pendingLabel = pendingAllianceLabel(game, p.playerId);
    final isMonarch = game.isMonarch(p.playerId);
    final hasInit = game.hasInitiative(p.playerId);

    final borderColor = teamIdx > 0 ? teamColor(teamIdx) : p.playerColor;

    final myAlliance =
        local != null ? game.allianceFor(local.playerId) : null;
    final hasAllianceMenu = game.alliancesEnabled &&
        ((!isLocal &&
                myAlliance == null &&
                game.allianceFor(p.playerId) == null) ||
            (myAlliance != null &&
                (isLocal || myAlliance.involves(p.playerId))));
    final showMenu =
        !p.isEliminated && local != null && (isLocal || hasAllianceMenu);
    final canEditLife = !p.isEliminated &&
        (game.isHost || p.playerId == game.localPlayerId);

    Widget card = AnimatedContainer(
      duration: MotionTokens.slow,
      margin: EdgeInsets.only(bottom: LayoutTokens.gr2),
      decoration: BoxDecoration(
        color: p.isEliminated
            ? colors.backgroundSecondary.withValues(alpha: OpacityTokens.half)
            : isActive
                ? borderColor.withValues(alpha: OpacityTokens.faint)
                : isLocal
                    ? colors.surface.withValues(alpha: OpacityTokens.nearOpaque)
                    : colors.surface,
        borderRadius: RadiusTokens.radiusSm,
      ),
      child: ClipRRect(
        borderRadius: RadiusTokens.radiusSm,
        child: Stack(
          children: [
            OverviewCommanderArtBackdrop(player: p),
            if (isActive && !p.isEliminated)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: borderColor,
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isActive && !p.isEliminated
                    ? LayoutTokens.gr1
                    : LayoutTokens.gr2,
                LayoutTokens.gr2,
                LayoutTokens.gr2,
                LayoutTokens.gr2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: p.username,
                                      style: TextStyle(
                                        color: p.isEliminated
                                            ? colors.textSecondary
                                            : colors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: FontTokens.hudSm,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (isLocal)
                                      TextSpan(
                                        text: ' · you',
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: FontTokens.hudXs,
                                          height: 1.3,
                                        ),
                                      ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isMonarch || hasInit) ...[
                              SizedBox(width: LayoutTokens.gr1),
                              _PlayerPoliticsBadges(
                                isMonarch: isMonarch,
                                hasInitiative: hasInit,
                              ),
                            ],
                          ],
                        ),
                        OverviewPlayerMarkerBadges(
                          game: game,
                          playerId: p.playerId,
                        ),
                        if (pendingLabel != null) ...[
                          SizedBox(height: LayoutTokens.gr0 + 1),
                          Text(
                            pendingLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.emphasis,
                              fontSize: FontTokens.hudXs,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: LayoutTokens.gr2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (p.commanderCastCount > 0) ...[
                        _GameOverviewCommanderTaxChip(tax: p.commanderTax),
                        SizedBox(width: LayoutTokens.gr1),
                      ],
                      if (p.isEliminated)
                        _GameOverviewLifeBadge(
                          life: p.life,
                          eliminated: true,
                          isActive: false,
                          accent: borderColor,
                        )
                      else
                        _GameOverviewLifeStepper(
                          life: p.life,
                          isActive: isActive,
                          accent: borderColor,
                          enabled: canEditLife,
                          onDelta: (delta) =>
                              notifier.adjustLife(p.playerId, delta),
                        ),
                      if (showMenu) ...[
                        SizedBox(width: LayoutTokens.gr0),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: colors.textSecondary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: LayoutTokens.minTapTarget,
                            minHeight: LayoutTokens.minTapTarget,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'propose':
                                showProposeAllianceSheet(
                                  context: context,
                                  ref: ref,
                                  target: p,
                                );
                              case 'reveal':
                                notifier.revealAlliance(local.playerId);
                              case 'break':
                                notifier.breakAlliance(local.playerId);
                              case 'team':
                                _showTeamSelectorSheet(
                                  context,
                                  ref,
                                  p.playerId,
                                  teamIdx,
                                );
                            }
                          },
                          itemBuilder: (context) {
                            final items = <PopupMenuEntry<String>>[];
                            if (isLocal) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'team',
                                  child: Text('Assign team color'),
                                ),
                              );
                            }
                            if (game.alliancesEnabled &&
                                !isLocal &&
                                game.allianceFor(local.playerId) == null &&
                                game.allianceFor(p.playerId) == null) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'propose',
                                  child: Text('Propose secret alliance'),
                                ),
                              );
                            }
                            final menuAlliance =
                                game.allianceFor(local.playerId);
                            if (game.alliancesEnabled &&
                                menuAlliance != null &&
                                (isLocal ||
                                    menuAlliance.involves(p.playerId)) &&
                                !menuAlliance.isRevealed) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'reveal',
                                  child: Text('Reveal alliance to table'),
                                ),
                              );
                            }
                            if (game.alliancesEnabled &&
                                menuAlliance != null &&
                                (isLocal ||
                                    menuAlliance.involves(p.playerId))) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'break',
                                  child: Text('Break secret alliance'),
                                ),
                              );
                            }
                            return items;
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return card;
  }

  static void _showTeamSelectorSheet(
    BuildContext context,
    WidgetRef ref,
    String playerId,
    int currentTeam,
  ) {
    final notifier = ref.read(gameProvider.notifier);
    showGameBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final colors = ctx.gameColors;
        return GameSheetBody(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GameSheetHeader(title: 'Assign team'),
            SizedBox(height: LayoutTokens.gr2),
            ...[0, 1, 2, 3, 4].map((idx) {
              final label = idx == 0 ? 'None' : 'Team $idx';
              final color =
                  idx == 0 ? colors.textSecondary : teamColor(idx);
              final isSelected = currentTeam == idx;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: isSelected
                      ? (idx == 0
                          ? colors.textSecondary.withValues(alpha: 0.15)
                          : color.withValues(alpha: 0.15))
                      : Colors.transparent,
                  borderRadius: RadiusTokens.radiusControlSm,
                  child: InkWell(
                    onTap: () {
                      notifier.assignTeam(playerId, idx);
                      Navigator.of(ctx).pop();
                    },
                    borderRadius: RadiusTokens.radiusControlSm,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          if (idx > 0)
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(width: 12),
                          if (idx > 0) const SizedBox(width: 10),
                          Text(
                            label,
                            style: TextStyle(
                              color: idx == 0
                                  ? colors.textSecondary
                                  : colors.textPrimary,
                              fontSize: FontTokens.hudSm,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
          ),
        );
      },
    );
  }
}
