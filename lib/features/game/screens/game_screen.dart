import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/game/alliance_ui_events.dart';
import '../../../core/game/commander_identity_colors.dart';
import '../../../core/game/game_format.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/lobby_state.dart';
import '../../../core/persistence/providers.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/shake_detector.dart';
import '../../../shared/utils/app_router.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../widgets/active_turn_banner.dart';
import '../widgets/alliance_overview_ui.dart';
import '../widgets/commander_damage_panel.dart';
import '../widgets/commander_info_bar.dart';
import '../widgets/game_bottom_bar.dart';
import '../widgets/game_colors.dart';
import '../widgets/game_first_player_roll_overlay.dart';
import '../widgets/game_history_tab.dart';
import '../widgets/game_hud_header.dart';
import '../widgets/game_overview_view.dart';
import '../widgets/game_performance_widgets.dart';
import '../widgets/game_timeout_widgets.dart';
import '../widgets/gameplay_dials_strip_widget.dart';
import '../widgets/phase_nav_cluster.dart';
import '../widgets/stack_tracker_tab.dart';
import '../widgets/variant_card_panel.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showOverview = false;
  StreamSubscription<Object?>? _gameOverSub;
  ShakeDetector? _shakeDetector;
  final DateTime _localInitStarted = DateTime.now();

  /// Cached so [dispose] never uses `ref` after Riverpod tears down this widget.
  bool _enteredWithHiddenSystemBars = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsRepositoryProvider).settings;
    _enteredWithHiddenSystemBars = settings.hideSystemBars;
    if (settings.keepDisplayAwake) {
      WakelockPlus.enable();
    }
    if (_enteredWithHiddenSystemBars) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForGameOver();
      _startShakeDetector();
      final lobby = ref.read(lobbyProvider);
      ref.read(gameProvider.notifier).initFromLobbyIfNeeded(lobby);
    });
  }

  void _startShakeDetector() {
    _shakeDetector?.stop();
    _shakeDetector = ShakeDetector(
      onShake: () {
        if (!mounted) return;
        if (!ref.read(settingsRepositoryProvider).settings.shakeToUndoEnabled) {
          return;
        }
        final localId = ref.read(gameProvider).localPlayerId;
        ref.read(gameProvider.notifier).undo(localId);
        ref.read(hapticServiceProvider).medium();
      },
    );
    _shakeDetector!.start();
  }

  @override
  void dispose() {
    _shakeDetector?.stop();
    WakelockPlus.disable();
    if (_enteredWithHiddenSystemBars) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _gameOverSub?.cancel();
    super.dispose();
  }

  void _listenForGameOver() {
    _gameOverSub = ref.read(gameProvider.notifier).stream.listen((state) {
      if (state.gameOver && mounted) {
        context.go(AppRoutes.endGame);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final localPresent = ref.watch(
      gameProvider.select((g) => g.localPlayer != null),
    );
    if (!localPresent) {
      final elapsed = DateTime.now().difference(_localInitStarted);
      if (elapsed < const Duration(seconds: 15)) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        backgroundColor: colors.backgroundPrimary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(LayoutTokens.gr6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: LayoutTokens.gr4),
                Text(
                  'Could not load your player slot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontTokens.headline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: LayoutTokens.gr2),
                Text(
                  'The game may be out of sync. Return to the lobby and rejoin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.body,
                  ),
                ),
                const SizedBox(height: LayoutTokens.gr6),
                FilledButton(
                  onPressed: () => context.go(AppRoutes.lobby),
                  child: const Text('Return to lobby'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final showTurnOrderReveal = ref.watch(
      gameProvider.select((g) => g.showTurnOrderReveal),
    );
    if (showTurnOrderReveal) {
      final game = ref.watch(gameProvider);
      return Scaffold(
        backgroundColor: colors.backgroundPrimary,
        body: SafeArea(
          child: TurnOrderRevealOverlay(
            game: game,
            onContinue: ref.read(gameProvider.notifier).dismissTurnOrderReveal,
          ),
        ),
      );
    }

    final awaitingFirstPlayerRoll = ref.watch(
      gameProvider.select((g) => g.awaitingFirstPlayerRoll),
    );
    if (awaitingFirstPlayerRoll) {
      final game = ref.watch(gameProvider);
      final local = game.localPlayer!;
      return Scaffold(
        backgroundColor: colors.backgroundPrimary,
        body: SafeArea(
          child: GameFirstPlayerRollOverlay(
            game: game,
            local: local,
            onRoll:
                (roll) =>
                    ref.read(gameProvider.notifier).submitFirstPlayerRoll(roll),
          ),
        ),
      );
    }

    final gradientChrome = ref.watch(
      gameProvider.select((g) => g.localPlayer!.commanderColorIdentity),
    );
    final gradientColors =
        CommanderIdentityColors.gameplayGradient(gradientChrome);
    final localPlayerId = ref.read(gameProvider).localPlayerId;
    final timeoutActive = ref.watch(
      gameProvider.select((g) => g.timeoutActive),
    );
    final timeoutStartTime = ref.watch(
      gameProvider.select((g) => g.timeoutStartTime),
    );
    final timeoutDurationSeconds = ref.watch(
      gameProvider.select((g) => g.timeoutDurationSeconds),
    );
    ref.listen<AllianceUiEvent?>(allianceUiEventProvider, (prev, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          handleAllianceUiEvent(context, ref, next);
        });
      }
    });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            if (_showOverview)
              PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) setState(() => _showOverview = false);
                },
                child: Consumer(
                  builder: (context, ref, _) => GameOverviewView(
                    game: ref.watch(gameProvider),
                    onClose: () => setState(() => _showOverview = false),
                  ),
                ),
              )
            else
              SafeArea(
                child: _PersonalView(
                  localPlayerId: localPlayerId,
                  onToggleOverview: () => setState(() => _showOverview = true),
                ),
              ),
            if (timeoutActive)
              GameTimeoutOverlay(
                startTime: timeoutStartTime,
                durationSeconds: timeoutDurationSeconds,
              ),
          ],
        ),
      ),
    );
  }
}

class _PersonalView extends ConsumerStatefulWidget {
  final String localPlayerId;
  final VoidCallback onToggleOverview;

  const _PersonalView({
    required this.localPlayerId,
    required this.onToggleOverview,
  });

  @override
  ConsumerState<_PersonalView> createState() => _PersonalViewState();
}

class _PersonalViewState extends ConsumerState<_PersonalView> {
  /// 0 = Play, 1 = Stack, 2 = History
  int _mainTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    ref.watch(gameProvider.select(gameHudHeaderRebuildFingerprint));
    if (_mainTabIndex == 0) {
      ref.watch(gameProvider.select(playTabRebuildFingerprint));
    } else if (_mainTabIndex == 1) {
      ref.watch(gameProvider.select(stackTabRebuildFingerprint));
    } else {
      ref.watch(gameProvider.select((g) => g.sessionActionLog));
    }

    final game = ref.read(gameProvider);
    final local = game.playerById(widget.localPlayerId);
    if (local == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.gr4),
          child: Text(
            'Player data unavailable',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    final notifier = ref.read(gameProvider.notifier);
    final opponents =
        game.players.where((p) => p.playerId != local.playerId).toList();

    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact =
        screenHeight < 704 || screenWidth < GameLayoutBreakpoints.compact;
    final tightVertical =
        screenHeight < GameLayoutBreakpoints.shortViewport;
    final horizontalInset = LayoutTokens.gr3;
    final rawMaxW = min(screenWidth - horizontalInset * 2, 400.0);
    final lifeBandMaxW = rawMaxW - (rawMaxW % 4);
    final lifeBandH = tightVertical
        ? (isCompact ? 128.0 : 148.0)
        : (isCompact ? 160.0 : 192.0);
    final playGapSm =
        tightVertical ? LayoutTokens.gr1 : LayoutTokens.gr2;
    final playGapMd =
        tightVertical ? LayoutTokens.gr2 : LayoutTokens.gr3;

    void adjustLife(int delta) {
      if (delta == 0) return;
      notifier.adjustLife(local.playerId, delta);
    }

    final opponentsWithCommanders = opponents
        .where((o) => !o.isEliminated || o.commanderName != null)
        .toList();
    final lobbyConfig = ref.read(lobbyProvider).config;
    final showCommanderHud = lobbyConfig.format.isCommanderStyle;
    final showCommanderDamage = showCommanderHud &&
        isCommanderGameSession(
          local: local,
          allPlayers: game.players,
          gameFormat: lobbyConfig.format,
          startingLife: lobbyConfig.startingLife,
        );
    final maxCmdDamage = maxCommanderDamageTrack(
      local,
      opponentsWithCommanders,
    );

    final chromeAccent = CommanderIdentityColors.gameChromeAccent(
      local.commanderColorIdentity,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalInset,
            LayoutTokens.gr3,
            horizontalInset,
            tightVertical ? LayoutTokens.gr1 : LayoutTokens.gr2,
          ),
          child: GameHudHeader(
            tightVertical: tightVertical,
            accentColor: chromeAccent,
            isLocalPlayersTurn: showCommanderHud &&
                game.isLocalPlayersTurn &&
                !local.isEliminated,
            selectedTabIndex: _mainTabIndex,
            onTabSelected: (index) => setState(() => _mainTabIndex = index),
            statusStrip: showCommanderHud
                ? CommanderInfoBar(
                    player: local,
                    onCastCommander: () =>
                        notifier.castCommanderFromZone(local.playerId),
                    onUncastCommander: () =>
                        notifier.uncastCommanderFromZone(local.playerId),
                    embeddedInCard: true,
                    roundNumber: game.roundNumber,
                    allyUsername: local.allyPlayerId == null
                        ? null
                        : game.playerById(local.allyPlayerId!)?.username,
                    statusTrailing: showCommanderDamage
                        ? CommanderDamageBarButton(
                            totalDamage: local.totalCommanderDamageReceived,
                            maxTrackDamage: maxCmdDamage,
                            enabled: !local.isEliminated,
                            onTap: () =>
                                showCommanderDamageSheet(context, ref),
                          )
                        : null,
                  )
                : ActiveTurnBanner(game: game),
          ),
        ),
        Expanded(
          child: switch (_mainTabIndex) {
            1 => StackTrackerTab(game: ref.read(gameProvider)),
            2 => GameHistoryTab(
              entries: ref.watch(
                gameProvider.select((g) => g.sessionActionLog),
              ),
              localPlayerId: widget.localPlayerId,
            ),
            _ => Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalInset),
              child: LayoutBuilder(
                builder: (context, playConstraints) {
                  final variantsEnabled = game.planechaseEnabled ||
                      game.archenemyEnabled ||
                      game.bountyEnabled;
                  final showTurnTimer =
                      (game.trackTurnDuration ||
                          game.turnTimeLimitSeconds != null) &&
                      game.turnStartTime != null;
                  final hasExtraRows = variantsEnabled || showTurnTimer;
                  final dialCompact =
                      tightVertical ||
                      playConstraints.maxHeight < 520 ||
                      (hasExtraRows &&
                          playConstraints.maxHeight <
                              GameLayoutBreakpoints.shortViewport);

                  final phaseBar = Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: lifeBandMaxW),
                      child: PhaseNavCluster(
                        game: game,
                        accentColor: chromeAccent,
                        onBack: !game.timeoutActive
                            ? notifier.previousPhase
                            : null,
                        onNext: !game.timeoutActive
                            ? notifier.advancePhase
                            : null,
                        onPickPhase: game.timeoutActive
                            ? null
                            : notifier.setPhase,
                        onEndTurn: notifier.endTurn,
                        endTurnEnabled: !game.timeoutActive &&
                            (game.isLocalPlayersTurn || game.isHost),
                      ),
                    ),
                  );
                  final lifeCounter = Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: lifeBandMaxW,
                        maxHeight: lifeBandH,
                      ),
                      child: ScopedLifeCounter(
                        playerId: local.playerId,
                        onLifeChange: adjustLife,
                      ),
                    ),
                  );
                  final dialStrip = Padding(
                    padding: EdgeInsets.only(bottom: playGapSm),
                    child: ScopedGameplayDials(
                      playerId: local.playerId,
                      compactVertical: dialCompact,
                      onAdjustCounter: (field, delta) =>
                          notifier.adjustCounter(local.playerId, field, delta),
                      onSetCounterAbsolute: (field, v) => notifier
                          .setGameplayDialAbsolute(local.playerId, field, v),
                      onRegisterCustomDial: (key, label) => notifier
                          .registerCustomGameplayDial(
                              local.playerId, key, label),
                      onAddDialToStrip: (field) =>
                          notifier.addGameplayDialToStrip(
                              local.playerId, field),
                      onRemoveDialFromStrip: (field) => notifier
                          .removeGameplayDialFromStrip(local.playerId, field),
                    ),
                  );

                  // Small pinned rows above the life counter: a variant
                  // quick-access chip (opens full deck content in a bottom
                  // sheet, off the Play tab's layout budget) and/or the turn
                  // timer. Both are compact/fixed-height, so — unlike the
                  // old inline variant card list — they never need a
                  // flexible or scrollable region of their own.
                  final extraRows = <Widget>[
                    if (variantsEnabled) ...[
                      const VariantQuickAccessChip(),
                      SizedBox(height: playGapSm),
                    ],
                    if (showTurnTimer) ...[
                      Center(
                        child: GameTurnDurationBanner(
                          turnStartTime: game.turnStartTime!,
                          limitSeconds: game.turnTimeLimitSeconds,
                          isActiveTurn: game.isLocalPlayersTurn,
                          activePlayerName:
                              game
                                  .playerById(game.activePlayerId)
                                  ?.username ??
                              'Player',
                        ),
                      ),
                      SizedBox(height: playGapSm),
                    ],
                  ];

                  // Comfortable minimum: pinned zones at their intrinsic
                  // size, plus the life counter's legibility floor.
                  const lifeMinFloor = 96.0;
                  const extraRowEstimate = 44.0;
                  final dialStripH =
                      GameplayDialsStripWidget.estimatedStripHeight(
                    context,
                    compactVertical: dialCompact,
                  );
                  final comfortableMin = PhaseNavCluster.barHeight +
                      playGapMd +
                      (variantsEnabled ? extraRowEstimate : 0.0) +
                      (showTurnTimer ? extraRowEstimate : 0.0) +
                      lifeMinFloor +
                      playGapSm +
                      dialStripH;

                  if (playConstraints.maxHeight >= comfortableMin) {
                    // Normal case (virtually all portrait phones/tablets):
                    // the life counter simply fills whatever space remains
                    // via Expanded — no manual pixel math, and structurally
                    // impossible to overflow here.
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        phaseBar,
                        SizedBox(height: playGapMd),
                        ...extraRows,
                        Expanded(child: lifeCounter),
                        SizedBox(height: playGapSm),
                        dialStrip,
                      ],
                    );
                  }

                  // Safety net for viewports shorter than the comfortable
                  // minimum (landscape phones, tightly split-screened
                  // tablets/foldables): scroll the whole Play tab instead
                  // of letting it overflow.
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: playConstraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          phaseBar,
                          SizedBox(height: playGapMd),
                          ...extraRows,
                          SizedBox(height: lifeMinFloor, child: lifeCounter),
                          SizedBox(height: playGapSm),
                          dialStrip,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          },
        ),
        GameBottomBar(
          game: game,
          local: local,
          onToggleOverview: widget.onToggleOverview,
          compact: tightVertical,
        ),
      ],
    );
  }
}
