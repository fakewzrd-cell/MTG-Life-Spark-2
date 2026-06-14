import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/game_phase.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
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
import '../../../shared/widgets/game_icon.dart';

// ── Overview View ─────────────────────────────────────────────────────────

class GameOverviewView extends ConsumerStatefulWidget {
  final GameState game;
  final VoidCallback onClose;

  const GameOverviewView({super.key, required this.game, required this.onClose});

  @override
  ConsumerState<GameOverviewView> createState() => _GameOverviewViewState();
}

class _GameOverviewViewState extends ConsumerState<GameOverviewView> {
  bool _politicsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final onClose = widget.onClose;
    final colors = context.gameColors;
    final notifier = ref.read(gameProvider.notifier);
    final aliveCount = game.activePlayers.length;

    const pageInset = LayoutTokens.shellPageInset;

    return ColoredBox(
      color: colors.backgroundPrimary,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.only(top: pageInset),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: colors.backgroundPrimary,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: LayoutTokens.minTapTarget,
              leadingWidth: pageInset + LayoutTokens.minTapTarget,
              centerTitle: true,
              title: Text(
                'Round ${game.roundNumber}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontTokens.title,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  height: 1,
                ),
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
                      child: TextButton(
                        onPressed: () => notifier.endTurn(),
                        style: TextButton.styleFrom(
                          backgroundColor: colors.primaryAccent.withValues(
                            alpha: OpacityTokens.soft,
                          ),
                          foregroundColor: colors.primaryAccent,
                          padding: EdgeInsets.symmetric(
                            horizontal: LayoutTokens.gr2,
                            vertical: LayoutTokens.gr0 + 2,
                          ),
                          minimumSize: const Size(
                            0,
                            LayoutTokens.minTapTarget - 12,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: RadiusTokens.radiusControlSm,
                          ),
                        ),
                        child: Text(
                          'End turn',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: FontTokens.caption,
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
                  _politicsExpanded ? LayoutTokens.gr2 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PoliticsToggleButton(
                      expanded: _politicsExpanded,
                      onPressed: () =>
                          setState(() => _politicsExpanded = !_politicsExpanded),
                    ),
                    if (_politicsExpanded) ...[
                      SizedBox(height: LayoutTokens.gr2),
                      PoliticalRowWidget(game: game),
                    ],
                  ],
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
                        fontWeight: FontWeight.w800,
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
                delegate: SliverChildListDelegate([
                  ...game.players.map(
                    (p) => _GameOverviewPlayerCard(p: p, game: game),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoliticsToggleButton extends StatelessWidget {
  const _PoliticsToggleButton({
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;

    return Semantics(
      button: true,
      expanded: expanded,
      label: expanded ? 'Hide table politics' : 'Show table politics',
      child: Material(
        color: colors.backgroundSecondary.withValues(alpha: OpacityTokens.soft),
        borderRadius: RadiusTokens.radiusControlSm,
        child: InkWell(
          onTap: onPressed,
          borderRadius: RadiusTokens.radiusControlSm,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr2,
              vertical: LayoutTokens.gr1,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.public,
                  size: LayoutTokens.gr3,
                  color: colors.emphasis,
                ),
                SizedBox(width: LayoutTokens.gr1),
                Expanded(
                  child: Text(
                    'Table politics',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: FontTokens.caption,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
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

  Color get _borderColor {
    if (eliminated) {
      return ColorTokens.textSecondary.withValues(alpha: OpacityTokens.soft);
    }
    if (isActive) return accent.withValues(alpha: OpacityTokens.moderate);
    return ColorTokens.textSecondary.withValues(alpha: OpacityTokens.soft);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 52, minHeight: 36),
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1 + 2,
        vertical: LayoutTokens.gr0 + 2,
      ),
      decoration: BoxDecoration(
        color: isActive && !eliminated
            ? accent.withValues(alpha: OpacityTokens.subtle)
            : ColorTokens.backgroundSecondary.withValues(alpha: OpacityTokens.half),
        borderRadius: RadiusTokens.radiusControlSm,
        border: Border.all(color: _borderColor),
      ),
      alignment: Alignment.center,
      child: eliminated
          ? Text(
            'OUT',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w800,
              fontSize: FontTokens.hudSm,
              height: 1,
            ),
          )
          : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 15,
                color: _textColor.withValues(alpha: 0.9),
              ),
              SizedBox(width: LayoutTokens.gr0),
              Text(
                '$life',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: FontTokens.hudSm,
                  height: 1,
                ),
              ),
            ],
          ),
    );
  }
}

class _GameOverviewStatusChip extends StatelessWidget {
  const _GameOverviewStatusChip({
    required this.label,
    required this.isActive,
    required this.accent,
  });

  final String label;
  final bool isActive;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 36, minWidth: 40),
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr1,
        vertical: LayoutTokens.gr0,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? accent.withValues(alpha: OpacityTokens.soft)
            : colors.backgroundSecondary.withValues(alpha: OpacityTokens.half),
        borderRadius: RadiusTokens.radiusControlSm,
        border: Border.all(
          color: isActive
              ? accent.withValues(alpha: OpacityTokens.half)
              : colors.textSecondary.withValues(alpha: OpacityTokens.soft),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? accent : colors.textSecondary,
          fontSize: FontTokens.caption,
          fontWeight: FontWeight.w700,
          height: 1,
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
        constraints: const BoxConstraints(minHeight: 36, minWidth: 40),
        padding: EdgeInsets.symmetric(
          horizontal: LayoutTokens.gr1,
          vertical: LayoutTokens.gr0,
        ),
        decoration: BoxDecoration(
          color: colors.textSecondary.withValues(alpha: 0.15),
          borderRadius: RadiusTokens.radiusControlSm,
          border: Border.all(
            color: colors.textSecondary.withValues(alpha: 0.6),
          ),
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
    var borderColorResolved =
        isActive ? borderColor : borderColor.withValues(alpha: 0.25);
    if (isMonarch || hasInit) {
      borderColorResolved = colors.emphasis.withValues(
        alpha: isActive ? 0.95 : 0.55,
      );
    }

    final statusLabel = isActive
        ? game.currentPhase.streamlinedShortLabel
        : 'Waiting';
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
        border: Border.all(
          color: borderColorResolved,
          width: isActive || isMonarch || hasInit ? 2 : 1,
        ),
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
                            if (isMonarch) ...[
                              GameIcon.monarch(
                                size: LayoutTokens.gr3,
                                color: politicsIconTone(context),
                              ),
                              SizedBox(width: LayoutTokens.gr0),
                            ],
                            if (hasInit) ...[
                              GameIcon.initiative(
                                size: LayoutTokens.gr3,
                                color: politicsIconTone(context),
                              ),
                              SizedBox(width: LayoutTokens.gr0),
                            ],
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
                      if (!p.isEliminated) ...[
                        _GameOverviewStatusChip(
                          label: statusLabel,
                          isActive: isActive,
                          accent: borderColor,
                        ),
                        SizedBox(width: LayoutTokens.gr1),
                      ],
                      if (p.commanderCastCount > 0) ...[
                        _GameOverviewCommanderTaxChip(tax: p.commanderTax),
                        SizedBox(width: LayoutTokens.gr1),
                      ],
                      _GameOverviewLifeBadge(
                        life: p.life,
                        eliminated: p.isEliminated,
                        isActive: isActive,
                        accent: borderColor,
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
                              fontSize: 14,
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
