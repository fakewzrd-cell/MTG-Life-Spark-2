import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/game/commander_identity_colors.dart';
import '../../../core/game/game_phase.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/player_game_state.dart';
import '../../../ui/theme/app_color_tokens.dart';
import '../../../ui/theme/app_system_ui.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/motion_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'alliance_overview_ui.dart';
import 'end_turn_bar.dart';
import 'game_bottom_bar.dart';
import 'game_colors.dart';
import 'game_history_tab.dart';
import 'game_modal_chrome.dart';
import 'game_timeout_widgets.dart';
import 'overview_commander_art_backdrop.dart';
import 'player_whisper_sheet.dart';
import 'political_row_widget.dart';
import 'table_tools_sheet.dart';
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

class GameOverviewView extends ConsumerStatefulWidget {
  final GameState game;
  final VoidCallback onClose;

  const GameOverviewView({super.key, required this.game, required this.onClose});

  @override
  ConsumerState<GameOverviewView> createState() => _GameOverviewViewState();
}

class _GameOverviewViewState extends ConsumerState<GameOverviewView> {
  final GlobalKey _activeCardKey = GlobalKey();

  GameState get game => widget.game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollActiveIntoView());
  }

  @override
  void didUpdateWidget(covariant GameOverviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game.activePlayerId != game.activePlayerId) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollActiveIntoView());
    }
  }

  void _scrollActiveIntoView({int attempt = 0}) {
    final ctx = _activeCardKey.currentContext;
    if (ctx != null && mounted) {
      Scrollable.ensureVisible(
        ctx,
        duration: MotionTokens.slow,
        curve: Curves.easeOutCubic,
        alignment: 0.12,
      );
      return;
    }
    // Reorderable/sliver lists may not have built the active row yet.
    if (attempt < 6 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollActiveIntoView(attempt: attempt + 1),
      );
    }
  }

  Widget _rowFor(PlayerGameState p) {
    return p.isEliminated
        ? _EliminatedPlayerRow(p: p, game: game)
        : _GameOverviewPlayerCard(p: p, game: game);
  }

  Widget _keyedRow(PlayerGameState p) {
    final row = _rowFor(p);
    if (p.playerId == game.activePlayerId && !p.isEliminated) {
      return KeyedSubtree(key: _activeCardKey, child: row);
    }
    return row;
  }

  bool _canHostReorder(GameState game) =>
      game.isHost &&
      !game.gameOver &&
      !game.timeoutActive &&
      !game.awaitingFirstPlayerRoll &&
      game.players.length > 1;

  List<Widget> _buildPlayerListChildren() =>
      game.playersInTurnOrder.map(_keyedRow).toList();

  void _onHostReorder(int oldIndex, int newIndex) {
    final order =
        game.playersInTurnOrder.map((p) => p.playerId).toList(growable: true);
    if (oldIndex < 0 || oldIndex >= order.length) return;
    if (newIndex < 0 || newIndex >= order.length) return;
    final id = order.removeAt(oldIndex);
    order.insert(newIndex, id);
    ref.read(gameProvider.notifier).hostSetTurnOrder(order);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final notifier = ref.read(gameProvider.notifier);
    final aliveCount = game.activePlayers.length;
    final activePlayer = game.playerById(game.activePlayerId);

    const pageInset = LayoutTokens.shellPageInset;
    final identity = game.localPlayer?.commanderColorIdentity ?? const [];
    final gradientColors = CommanderIdentityColors.gameplayGradient(
      colors,
      identity,
    );
    final endTurnEnabled =
        !game.timeoutActive && (game.isLocalPlayersTurn || game.isHost);
    final waitingForName = endTurnEnabled
        ? null
        : (activePlayer?.username);

    // Keep status / nav bar styling aligned with the rest of the app so Table
    // does not flash a white system bar (SliverAppBar default overlay).
    final overlay = AppSystemUi.overlayStyle(context).copyWith(
      statusBarColor: Colors.transparent,
    );

    // Transparent top chrome so the identity gradient reads edge-to-edge;
    // [SliverAppBar] (primary) still owns status-bar inset without a dark band.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomScrollView(
              // Keep pod-sized rosters built so the active card key exists for
              // ensureVisible (especially with host reorder / long lists).
              cacheExtent: 2400,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  primary: true,
                  systemOverlayStyle: overlay,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  forceMaterialTransparency: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  foregroundColor: colors.textPrimary,
                  toolbarHeight: LayoutTokens.minTapTarget,
                  leadingWidth: pageInset + LayoutTokens.minTapTarget,
                  centerTitle: true,
                  title: Text(
                    'Round ${game.roundNumber}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: FontTokens.title,
                      fontWeight: FontWeight.w700,
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
                        child: Semantics(
                          button: true,
                          label: 'Close overview',
                          child: IconButton(
                            tooltip: 'Close overview',
                            onPressed: widget.onClose,
                            icon: Icon(
                              Icons.close_rounded,
                              color: colors.textPrimary,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: LayoutTokens.minTapTarget,
                              minHeight: LayoutTokens.minTapTarget,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Align(
                      alignment: Alignment.center,
                      child: Semantics(
                        button: true,
                        label: 'Tools',
                        child: IconButton(
                          tooltip: 'Tools',
                          onPressed: () => showTableToolsSheet(context),
                          icon: Icon(
                            Icons.casino_outlined,
                            color: colors.textPrimary,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: LayoutTokens.minTapTarget,
                            minHeight: LayoutTokens.minTapTarget,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: pageInset),
                      child: Align(
                        alignment: Alignment.center,
                        child: Semantics(
                          button: true,
                          label: 'History',
                          child: IconButton(
                            tooltip: 'History',
                            onPressed: () => showGameHistorySheet(context),
                            icon: Icon(
                              Icons.history_rounded,
                              color: colors.textPrimary,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: LayoutTokens.minTapTarget,
                              minHeight: LayoutTokens.minTapTarget,
                            ),
                          ),
                        ),
                      ),
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
                        if (_canHostReorder(game)) ...[
                          SizedBox(width: LayoutTokens.gr2),
                          Expanded(
                            child: Text(
                              'Hold & drag to reorder turns',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: FontTokens.hudXs,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    pageInset,
                    0,
                    pageInset,
                    LayoutTokens.gr3,
                  ),
                  sliver: _canHostReorder(game)
                      ? SliverReorderableList(
                          itemCount: game.playersInTurnOrder.length,
                          onReorder: _onHostReorder,
                          itemBuilder: (context, index) {
                            final p = game.playersInTurnOrder[index];
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(p.playerId),
                              index: index,
                              child: _keyedRow(p),
                            );
                          },
                        )
                      : SliverList(
                          delegate: SliverChildListDelegate(
                            _buildPlayerListChildren(),
                          ),
                        ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pageInset,
                LayoutTokens.gr2,
                pageInset,
                LayoutTokens.gr2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EndTurnBar(
                    accentColor: colors.primaryAccent,
                    enabled: endTurnEnabled,
                    onEndTurn: () => notifier.endTurn(),
                    waitingForName: waitingForName,
                  ),
                  if (game.localPlayer != null &&
                      !game.localPlayer!.isEliminated &&
                      !game.gameOver) ...[
                    SizedBox(height: LayoutTokens.gr1),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.94),
                        borderRadius: RadiusTokens.radiusControlSm,
                      ),
                      child: ClipRRect(
                        borderRadius: RadiusTokens.radiusControlSm,
                        child: SizedBox(
                          height: EndTurnBar.barHeight,
                          child: Material(
                            color: colors.error.withValues(
                              alpha: OpacityTokens.soft,
                            ),
                            child: InkWell(
                              onTap: () {
                                context.gameHapticLight();
                                showGameForfeitFlow(
                                  context,
                                  ref,
                                  game.localPlayerId,
                                );
                              },
                              child: Center(
                                child: Text(
                                  'Forfeit',
                                  style: TextStyle(
                                    fontSize: FontTokens.title,
                                    fontWeight: FontWeight.w700,
                                    color: colors.error,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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
    this.showHeart = false,
  });

  final int life;
  final bool eliminated;
  final bool isActive;
  final Color accent;
  final bool showHeart;

  Color _textColor(AppColorTokens colors) {
    if (eliminated) return colors.textSecondary;
    if (life <= 5) return colors.error;
    if (life <= 10) return colors.emphasis;
    return colors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      constraints: BoxConstraints(
        minWidth: showHeart ? 56 : 40,
        minHeight: LayoutTokens.minTapTarget,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: showHeart ? LayoutTokens.gr1 + 2 : LayoutTokens.gr1,
        vertical: LayoutTokens.gr0 + 2,
      ),
      decoration: BoxDecoration(
        color: isActive && !eliminated
            ? accent.withValues(alpha: OpacityTokens.subtle)
            : colors.backgroundSecondary.withValues(alpha: OpacityTokens.half),
        borderRadius: RadiusTokens.radiusControlSm,
      ),
      alignment: Alignment.center,
      child: eliminated
          ? Text(
              'OUT',
              style: TextStyle(
                color: _textColor(colors),
                fontWeight: FontWeight.w700,
                fontSize: FontTokens.hudSm,
                height: 1,
              ),
            )
          : showHeart
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: _textColor(colors).withValues(
                        alpha: OpacityTokens.nearOpaque,
                      ),
                    ),
                    SizedBox(width: LayoutTokens.gr0),
                    Text(
                      '$life',
                      style: TextStyle(
                        color: _textColor(colors),
                        fontWeight: FontWeight.w700,
                        fontSize: FontTokens.body,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                )
              : Text(
                  '$life',
                  style: TextStyle(
                    color: _textColor(colors),
                    fontWeight: FontWeight.w700,
                    fontSize: FontTokens.body,
                    height: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
    );
  }
}

/// Compact − / life / + for Table roster — host only.
class _GameOverviewLifeStepper extends StatelessWidget {
  const _GameOverviewLifeStepper({
    required this.life,
    required this.isActive,
    required this.accent,
    required this.enabled,
    required this.onDelta,
    this.showHeart = false,
  });

  final int life;
  final bool isActive;
  final Color accent;
  final bool enabled;
  final void Function(int delta) onDelta;
  final bool showHeart;

  Color _textColor(AppColorTokens colors) {
    if (life <= 5) return colors.error;
    if (life <= 10) return colors.emphasis;
    return colors.textPrimary;
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
            onHoldStep: enabled
                ? () {
                    context.gameHapticLight();
                    onDelta(-5);
                  }
                : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: LayoutTokens.gr0),
            child: showHeart
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: _textColor(colors).withValues(
                          alpha: OpacityTokens.nearOpaque,
                        ),
                      ),
                      SizedBox(width: LayoutTokens.gr0),
                      Text(
                        '$life',
                        style: TextStyle(
                          color: _textColor(colors),
                          fontWeight: FontWeight.w700,
                          fontSize: FontTokens.body,
                          height: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  )
                : Text(
                    '$life',
                    style: TextStyle(
                      color: _textColor(colors),
                      fontWeight: FontWeight.w700,
                      fontSize: FontTokens.body,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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
            onHoldStep: enabled
                ? () {
                    context.gameHapticLight();
                    onDelta(5);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _LifeStepButton extends StatefulWidget {
  const _LifeStepButton({
    required this.icon,
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
    required this.onHoldStep,
  });

  final IconData icon;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback? onTap;
  /// Fired after hold threshold, then repeatedly — typically ±5.
  final VoidCallback? onHoldStep;

  @override
  State<_LifeStepButton> createState() => _LifeStepButtonState();
}

class _LifeStepButtonState extends State<_LifeStepButton> {
  Timer? _holdTimer;
  bool _holding = false;

  @override
  void dispose() {
    _stopHold();
    super.dispose();
  }

  void _startHold() {
    if (!widget.enabled || widget.onHoldStep == null) return;
    _holding = true;
    _holdTimer = Timer(MotionTokens.hero, () {
      if (!_holding || !mounted) return;
      widget.onHoldStep!();
      _holdTimer = Timer.periodic(MotionTokens.fast, (_) {
        if (!_holding || !mounted) {
          _holdTimer?.cancel();
          return;
        }
        widget.onHoldStep!();
      });
    });
  }

  void _stopHold() {
    _holding = false;
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onLongPressStart: widget.enabled && widget.onHoldStep != null
            ? (_) => _startHold()
            : null,
        onLongPressEnd: widget.enabled && widget.onHoldStep != null
            ? (_) => _stopHold()
            : null,
        onLongPressCancel:
            widget.enabled && widget.onHoldStep != null ? _stopHold : null,
        child: SizedBox(
          width: LayoutTokens.minTapTarget,
          height: LayoutTokens.minTapTarget,
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.enabled
                ? colors.textPrimary
                : colors.textSecondary.withValues(alpha: 0.4),
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
    final teamIdx = game.teamsEnabled
        ? (game.teamAssignments[p.playerId] ?? 0)
        : 0;
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
    final canAssignTeam =
        game.teamsEnabled && (isLocal || game.isHost);
    final canWhisper = !isLocal &&
        !game.gameOver &&
        game.players.where((pl) => !pl.isEliminated).length >= 2;
    final showMenu =
        !p.isEliminated &&
        local != null &&
        (isLocal || hasAllianceMenu || canAssignTeam || canWhisper);
    final canEditLife = !p.isEliminated && game.isHost;
    final showAsActive = isActive && !p.isEliminated;

    Widget card = AnimatedContainer(
      duration: MotionTokens.slow,
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: LayoutTokens.gr2),
      decoration: BoxDecoration(
        gradient: showAsActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  borderColor.withValues(alpha: 0.24),
                  colors.surface,
                ],
              )
            : null,
        color: p.isEliminated
            ? colors.backgroundSecondary.withValues(alpha: OpacityTokens.half)
            : showAsActive
                ? null
                : isLocal
                    ? colors.surface.withValues(alpha: OpacityTokens.nearOpaque)
                    : colors.surface,
        borderRadius:
            showAsActive ? RadiusTokens.radiusMd : RadiusTokens.radiusSm,
      ),
      child: ClipRRect(
        borderRadius:
            showAsActive ? RadiusTokens.radiusMd : RadiusTokens.radiusSm,
        child: Stack(
          children: [
            OverviewCommanderArtBackdrop(player: p),
            if (showAsActive)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: borderColor,
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                LayoutTokens.gr2,
                showAsActive ? LayoutTokens.gr3 : LayoutTokens.gr2,
                LayoutTokens.gr2,
                showAsActive ? LayoutTokens.gr3 : LayoutTokens.gr2,
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
                        if (showAsActive) ...[
                          Row(
                            children: [
                              Text(
                                'NOW PLAYING',
                                style: TextStyle(
                                  color: borderColor,
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
                          SizedBox(height: LayoutTokens.gr0),
                        ],
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
                                        fontSize: showAsActive
                                            ? FontTokens.title
                                            : FontTokens.hudSm,
                                        height: 1.2,
                                      ),
                                    ),
                                    if (isLocal)
                                      TextSpan(
                                        text: ' · you',
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: FontTokens.hudXs,
                                          height: 1.2,
                                        ),
                                      ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!showAsActive && (isMonarch || hasInit)) ...[
                              SizedBox(width: LayoutTokens.gr1),
                              _PlayerPoliticsBadges(
                                isMonarch: isMonarch,
                                hasInitiative: hasInit,
                              ),
                            ],
                          ],
                        ),
                        if (showAsActive && game.phasesEnabled) ...[
                          SizedBox(height: 2),
                          Text(
                            game.currentPhase.streamlinedShortLabel,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: FontTokens.hudSm,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                      if (p.isEliminated || !canEditLife)
                        _GameOverviewLifeBadge(
                          life: p.life,
                          eliminated: p.isEliminated,
                          isActive: showAsActive,
                          accent: borderColor,
                          showHeart: showAsActive,
                        )
                      else
                        _GameOverviewLifeStepper(
                          life: p.life,
                          isActive: showAsActive,
                          accent: borderColor,
                          enabled: true,
                          showHeart: showAsActive,
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
                              case 'whisper':
                                showPlayerWhisperSheet(
                                  context: context,
                                  ref: ref,
                                  target: p,
                                );
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
                            if (canWhisper) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'whisper',
                                  child: Text('Send whisper'),
                                ),
                              );
                            }
                            if (canAssignTeam) {
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

    return Semantics(
      container: true,
      label: showAsActive ? 'Now playing: ${p.username}' : null,
      child: card,
    );
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
