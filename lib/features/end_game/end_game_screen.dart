import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/network/session_providers.dart';
import '../../core/game/game_providers.dart';
import '../../core/game/game_state.dart';
import '../../core/game/lobby_state.dart';
import '../../core/game/player_game_state.dart';
import '../../core/game/game_session_events.dart';
import '../../core/game/progression_service.dart';
import '../../core/game/session_exit_helpers.dart';
import '../../shared/widgets/game_icon.dart';
import '../../core/persistence/providers.dart';
import '../../core/debug/app_log.dart';
import '../../core/models/game_feedback.dart';
import '../../shared/utils/achievement_definitions.dart';
import '../../shared/utils/app_router.dart';
import '../../shared/utils/wizard_rank_titles.dart';
import '../../shared/widgets/player_feedback_widgets.dart';
import '../../ui/components/ui_button.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/motion_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';
import '../../ui/tokens/typography_tokens.dart';
import '../../ui/tokens/color_tokens.dart';

class EndGameScreen extends ConsumerStatefulWidget {
  const EndGameScreen({super.key});

  @override
  ConsumerState<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends ConsumerState<EndGameScreen> {
  bool _saved = false;
  bool _saveFailed = false;
  ProgressResult? _result;
  bool _saving = true;
  bool _feedbackSubmitted = false;
  final Set<String> _likePlayerIds = {};
  final Set<String> _dislikePlayerIds = {};
  String? _mvpPlayerId;
  String? _teamPlayerId;
  String? _underdogPlayerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onFirstFrame());
  }

  void _onFirstFrame() {
    final game = ref.read(gameProvider);
    if (!game.gameOver) {
      if (!mounted) return;
      context.go(
        game.localPlayer != null ? AppRoutes.game : AppRoutes.lobby,
      );
      return;
    }
    _saveMatch();
  }

  Future<void> _joinRematchLobby() async {
    final game = ref.read(gameProvider);
    final target = game.isHost ? AppRoutes.lobbyHost : AppRoutes.lobby;
    await quitActiveGame(ref);
    if (!context.mounted) return;
    context.go(target);
  }

  Future<void> _saveMatch() async {
    if (_saved) return;

    final game = ref.read(gameProvider);
    if (!game.gameOver) {
      if (mounted) {
        context.go(
          game.localPlayer != null ? AppRoutes.game : AppRoutes.lobby,
        );
      }
      return;
    }

    setState(() {
      _saving = true;
      _saveFailed = false;
    });

    final pending = ref.read(pendingFeedbackProvider);
    final submittedFromForfeit = pending?.hasContent ?? false;
    if (submittedFromForfeit && mounted) {
      setState(() => _feedbackSubmitted = true);
    }

    try {
      final lobby = ref.read(lobbyProvider);
      final service = ref.read(progressionServiceProvider);

      final stableMatchId = stableMatchIdForGame(game);

      final result = await service.recordMatch(
        finalState: game,
        lobbyState: lobby,
        startTime: game.gameStartTime ?? DateTime.now(),
        matchId: stableMatchId,
      );

      if (submittedFromForfeit && result.matchId.isNotEmpty) {
        await service.saveFeedback(GameFeedback(
          matchId: result.matchId,
          voterPlayerId: game.localPlayerId,
          likePlayerIds: pending!.likePlayerIds,
          dislikePlayerIds: pending.dislikePlayerIds,
          mvpPlayerId: pending.mvpPlayerId,
          teamPlayerId: pending.teamPlayerId,
          underdogPlayerId: pending.underdogPlayerId,
        ));
        ref.read(pendingFeedbackProvider.notifier).state = null;
      }

      bumpProfileRevision(ref);
      bumpDeckListRevision(ref);
      _saved = true;

      if (mounted) {
        setState(() {
          _result = result;
          _saving = false;
          _feedbackSubmitted = submittedFromForfeit;
        });
      }
    } catch (e, st) {
      appLog('EndGameScreen._saveMatch failed', error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _saving = false;
          _saveFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final game = ref.watch(gameProvider);
    ref.listen<int>(rematchProposedProvider, (prev, next) {
      if (next > 0 && next != prev && mounted) {
        _joinRematchLobby();
      }
    });
    final winner = game.winnerPlayerId != null
        ? game.playerById(game.winnerPlayerId!)
        : null;
    final isWinner = winner?.playerId == game.localPlayerId;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: _saving
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colors.primaryAccent),
                    SizedBox(height: LayoutTokens.gr3),
                    Text(
                      'Saving match results…',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ),
              )
            : _saveFailed
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(LayoutTokens.gr4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: colors.primaryAccent, size: 48),
                          SizedBox(height: LayoutTokens.gr3),
                          Text(
                            'Could not save match results.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: LayoutTokens.gr2),
                          Text(
                            'Your stats may not have updated. Try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          SizedBox(height: LayoutTokens.gr4),
                          UiButton(
                            label: 'Retry',
                            onPressed: _saveMatch,
                          ),
                          SizedBox(height: LayoutTokens.gr2),
                          UiButton(
                            label: 'Continue without saving',
                            variant: UiButtonVariant.secondary,
                            onPressed: () => _leaveToHome(context),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: LayoutTokens.gr4),

                    // ── Winner spotlight ──────────────────────────────────
                    _WinnerBanner(
                      winner: winner,
                      isLocalWinner: isWinner,
                      noWinnerHeadline: _noWinnerHeadline(game),
                    ),

                    SizedBox(height: LayoutTokens.gr4),

                    // ── Level-up animation ─────────────────────────────────
                    if (_result != null && _result!.leveledUp)
                      _StaggerReveal(
                        index: 0,
                        child: _LevelUpCard(result: _result!),
                      ),

                    // ── XP earned ─────────────────────────────────────────
                    if (_result != null)
                      _StaggerReveal(
                        index: 1,
                        child: _XpCard(
                          result: _result!,
                          isWinner: isWinner,
                        ),
                      ),

                    // ── New achievements ───────────────────────────────────
                    if (_result != null &&
                        _result!.newAchievementIds.isNotEmpty)
                      _StaggerReveal(
                        index: 2,
                        child: _AchievementsCard(ids: _result!.newAchievementIds),
                      ),

                    SizedBox(height: LayoutTokens.gr2),

                    // ── Post-game feedback (like/dislike, MVP, Team Player) ─
                    if (_result != null && _result!.matchId.isNotEmpty)
                      _FeedbackCard(
                        game: game,
                        feedbackSubmitted: _feedbackSubmitted,
                        likePlayerIds: _likePlayerIds,
                        dislikePlayerIds: _dislikePlayerIds,
                        mvpPlayerId: _mvpPlayerId,
                        teamPlayerId: _teamPlayerId,
                        underdogPlayerId: _underdogPlayerId,
                        onLike: (pid) => setState(() {
                          togglePlayerLike(
                            likeIds: _likePlayerIds,
                            dislikeIds: _dislikePlayerIds,
                            playerId: pid,
                            apply: (likes, dislikes) {
                              _likePlayerIds
                                ..clear()
                                ..addAll(likes);
                              _dislikePlayerIds
                                ..clear()
                                ..addAll(dislikes);
                            },
                          );
                        }),
                        onDislike: (pid) => setState(() {
                          togglePlayerDislike(
                            likeIds: _likePlayerIds,
                            dislikeIds: _dislikePlayerIds,
                            playerId: pid,
                            apply: (likes, dislikes) {
                              _likePlayerIds
                                ..clear()
                                ..addAll(likes);
                              _dislikePlayerIds
                                ..clear()
                                ..addAll(dislikes);
                            },
                          );
                        }),
                        onMvpChanged: (pid) =>
                            setState(() => _mvpPlayerId = pid),
                        onTeamPlayerChanged: (pid) =>
                            setState(() => _teamPlayerId = pid),
                        onUnderdogChanged: (pid) =>
                            setState(() => _underdogPlayerId = pid),
                        onSubmit: () => _submitFeedback(game),
                      ),

                    SizedBox(height: LayoutTokens.gr2),

                    // ── Final standings ────────────────────────────────────
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: LayoutTokens.shellPageInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Standings',
                            style: TypographyTokens.sectionTitle(
                              colors.textSecondary,
                            ).copyWith(
                              fontSize: FontTokens.label,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: LayoutTokens.gr1),
                          ...game.players.map((p) => _FinalPlayerRow(
                                p: p,
                                isWinner: p.playerId == game.winnerPlayerId,
                                isLocal: p.playerId == game.localPlayerId,
                              )),
                        ],
                      ),
                    ),

                    SizedBox(height: LayoutTokens.gr5),

                    // ── Actions ────────────────────────────────────────────
                    _ActionButtons(
                      isHost: game.isHost,
                      onHome: () => _leaveToHome(context),
                      onRematch: () => _doRematch(context, ref, game),
                    ),

                    SizedBox(height: LayoutTokens.gr5),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _leaveToHome(BuildContext context) async {
    await quitActiveGame(ref);
    if (context.mounted) context.go(AppRoutes.home);
  }

  Future<void> _doRematch(
    BuildContext context,
    WidgetRef ref,
    GameState game,
  ) async {
    ref.read(gameProvider.notifier).proposeRematch();
    await quitActiveGame(ref);
    if (!context.mounted) return;
    context.go(game.isHost ? AppRoutes.lobbyHost : AppRoutes.lobby);
  }

  Future<void> _submitFeedback(GameState game) async {
    if (_result == null || _result!.matchId.isEmpty) return;
    final feedback = GameFeedback(
      matchId: _result!.matchId,
      voterPlayerId: game.localPlayerId,
      likePlayerIds: _likePlayerIds.toList(),
      dislikePlayerIds: _dislikePlayerIds.toList(),
      mvpPlayerId: _mvpPlayerId,
      teamPlayerId: _teamPlayerId,
      underdogPlayerId: _underdogPlayerId,
    );
    await ref.read(progressionServiceProvider).saveFeedback(feedback);
    bumpProfileRevision(ref);
    if (mounted) setState(() => _feedbackSubmitted = true);
  }
}

String _noWinnerHeadline(GameState game) {
  if (game.winnerPlayerId != null) return 'Game Over — No Winner';
  final local = game.localPlayer;
  if (game.players.length == 1 &&
      local?.eliminationReason == 'concede') {
    return 'Practice ended';
  }
  return 'Game Over — No Winner';
}

// ── Winner Banner ────────────────────────────────────────────────────────────

class _WinnerBanner extends StatelessWidget {
  final PlayerGameState? winner;
  final bool isLocalWinner;
  final String noWinnerHeadline;

  const _WinnerBanner({
    required this.winner,
    required this.isLocalWinner,
    required this.noWinnerHeadline,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    if (winner == null) {
      return Padding(
        padding: EdgeInsets.all(LayoutTokens.shellPageInset),
        child: Text(
          noWinnerHeadline,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: FontTokens.headline,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: LayoutTokens.shellPageInset),
      child: Column(
        children: [
          Text(
            isLocalWinner ? 'You Win!' : 'Winner',
            style: TypographyTokens.headline(context).copyWith(
              color: colors.emphasis,
            ),
          ),
          SizedBox(height: LayoutTokens.gr3),

          // Commander art
          if (winner!.commanderImageUrl != null)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: winner!.playerColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: winner!.playerColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: winner!.commanderImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => CircleAvatar(
                    backgroundColor: winner!.playerColor,
                    child: Text(
                      winner!.username.isNotEmpty
                          ? winner!.username[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: ColorTokens.onAccent,
                          fontSize: FontTokens.displayCommander,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          else
            CircleAvatar(
              radius: 50,
              backgroundColor: winner!.playerColor,
              child: Text(
                winner!.username.isNotEmpty
                    ? winner!.username[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: ColorTokens.onAccent,
                    fontSize: FontTokens.displayCommander,
                    fontWeight: FontWeight.bold),
              ),
            ),

          SizedBox(height: LayoutTokens.gr2),
          Text(
            winner!.username,
            style: TextStyle(
              color: winner!.playerColor,
              fontSize: FontTokens.headline,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (winner!.commanderName != null)
            Text(
              winner!.commanderName!,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontTokens.hudSm,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Level Up Card ─────────────────────────────────────────────────────────────

class _LevelUpCard extends StatelessWidget {
  final ProgressResult result;

  const _LevelUpCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Card(
      margin: EdgeInsets.fromLTRB(
        LayoutTokens.shellPageInset,
        LayoutTokens.gr1,
        LayoutTokens.shellPageInset,
        0,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.radiusSm,
        side: BorderSide(
          color: colors.emphasis.withValues(alpha: 0.5),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.emphasis.withValues(alpha: 0.15),
              colors.primaryAccent.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(LayoutTokens.gr3),
          child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Lottie.asset(
              'assets/animations/level_up.json',
              repeat: true,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.arrow_upward,
                      size: 48, color: colors.emphasis),
            ),
          ),
          SizedBox(width: LayoutTokens.gr3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RANK UP!',
                style: TextStyle(
                  color: colors.emphasis,
                  fontSize: FontTokens.bodyLg,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'Rank ${result.oldLevel} → ${result.newLevel}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontTokens.sm,
                ),
              ),
              if (wizardRankTitle(result.oldLevel) !=
                  wizardRankTitle(result.newLevel))
                Text(
                  '${wizardRankTitle(result.oldLevel)} → ${wizardRankTitle(result.newLevel)}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.sm,
                  ),
                ),
            ],
          ),
        ],
          ),
        ),
      ),
    );
  }
}

// ── XP Card ──────────────────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  final ProgressResult result;
  final bool isWinner;

  const _XpCard({required this.result, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      margin: EdgeInsets.fromLTRB(
        LayoutTokens.shellPageInset,
        LayoutTokens.gr1,
        LayoutTokens.shellPageInset,
        0,
      ),
      padding: EdgeInsets.all(LayoutTokens.gr3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusSm,
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: colors.emphasis, size: 24),
          SizedBox(width: LayoutTokens.gr2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '+${result.xpGained} XP',
                style: TextStyle(
                  color: colors.emphasis,
                  fontSize: FontTokens.bodyLg,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                isWinner ? 'Win bonus included' : 'Participation XP',
                style: TextStyle(
                    color: colors.textSecondary, fontSize: FontTokens.hudXs),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rank ${result.newLevel}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontTokens.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                wizardRankTitle(result.newLevel),
                style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontTokens.hudXs,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Feedback Card ─────────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final GameState game;
  final bool feedbackSubmitted;
  final Set<String> likePlayerIds;
  final Set<String> dislikePlayerIds;
  final String? mvpPlayerId;
  final String? teamPlayerId;
  final String? underdogPlayerId;
  final void Function(String) onLike;
  final void Function(String) onDislike;
  final void Function(String?) onMvpChanged;
  final void Function(String?) onTeamPlayerChanged;
  final void Function(String?) onUnderdogChanged;
  final VoidCallback onSubmit;

  const _FeedbackCard({
    required this.game,
    required this.feedbackSubmitted,
    required this.likePlayerIds,
    required this.dislikePlayerIds,
    required this.mvpPlayerId,
    required this.teamPlayerId,
    required this.underdogPlayerId,
    required this.onLike,
    required this.onDislike,
    required this.onMvpChanged,
    required this.onTeamPlayerChanged,
    required this.onUnderdogChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final others = game.players
        .where((p) => p.playerId != game.localPlayerId)
        .toList();

    if (feedbackSubmitted) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: LayoutTokens.shellPageInset),
        padding: EdgeInsets.all(LayoutTokens.gr3),
        decoration: BoxDecoration(
          color: colors.success.withValues(alpha: 0.15),
          borderRadius: RadiusTokens.radiusMd,
          border: Border.all(
              color: colors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: colors.success, size: 28),
            SizedBox(width: LayoutTokens.gr2),
            Expanded(
              child: Text(
                'Thanks! Your feedback has been recorded.',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontTokens.hudSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: LayoutTokens.shellPageInset),
      padding: EdgeInsets.all(LayoutTokens.gr3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusMd,
        border: Border.all(color: colors.backgroundSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Your Opponents',
            style: TypographyTokens.sectionTitle(colors.textPrimary),
          ),
          PlayerFeedbackFields(
            opponents: others,
            likePlayerIds: likePlayerIds,
            dislikePlayerIds: dislikePlayerIds,
            onLike: onLike,
            onDislike: onDislike,
            mvpPlayerId: mvpPlayerId,
            teamPlayerId: teamPlayerId,
            underdogPlayerId: underdogPlayerId,
            onMvpChanged: onMvpChanged,
            onTeamPlayerChanged: onTeamPlayerChanged,
            onUnderdogChanged: onUnderdogChanged,
            voteSpacing: LayoutTokens.gr1,
          ),
          SizedBox(height: LayoutTokens.gr3),
          UiButton(
            label: 'Submit Feedback',
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

// ── Achievements Card ─────────────────────────────────────────────────────────

class _AchievementsCard extends StatelessWidget {
  final List<String> ids;

  const _AchievementsCard({required this.ids});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    final defs = ids
        .map((id) => AchievementDefinitions.byId(id))
        .whereType<AchievementDef>()
        .toList();

    if (defs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(
        LayoutTokens.shellPageInset,
        LayoutTokens.gr1,
        LayoutTokens.shellPageInset,
        0,
      ),
      padding: EdgeInsets.all(LayoutTokens.gr2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: RadiusTokens.radiusChip,
        border: Border.all(
            color: colors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏅 New Achievements',
            style: TextStyle(
              color: colors.success,
              fontSize: FontTokens.hudSm,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: LayoutTokens.gr1),
          ...defs.map((def) => Padding(
                padding: EdgeInsets.only(bottom: LayoutTokens.gr0),
                child: Row(
                  children: [
                    Text(def.icon,
                        style: TextStyle(fontSize: FontTokens.bodyLg)),
                    SizedBox(width: LayoutTokens.gr1),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(def.title,
                            style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: FontTokens.hudSm,
                                fontWeight: FontWeight.w600)),
                        Text(def.description,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: FontTokens.xs,
                            )),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Final Player Row ──────────────────────────────────────────────────────────

class _FinalPlayerRow extends StatelessWidget {
  final PlayerGameState p;
  final bool isWinner;
  final bool isLocal;

  const _FinalPlayerRow({
    required this.p,
    required this.isWinner,
    required this.isLocal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: LayoutTokens.gr1),
      padding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr2,
        vertical: LayoutTokens.gr2,
      ),
      decoration: BoxDecoration(
        color: isWinner
            ? colors.emphasis.withValues(alpha: 0.1)
            : colors.surface,
        borderRadius: RadiusTokens.radiusControlSm,
        border: Border.all(
          color: isWinner
              ? colors.emphasis.withValues(alpha: 0.4)
              : colors.backgroundSecondary,
        ),
      ),
      child: Row(
        children: [
          if (isWinner)
            Padding(
              padding: EdgeInsets.only(right: LayoutTokens.gr1),
              child: GameIcon.monarch(
                size: FontTokens.sm,
                color: colors.emphasis,
              ),
            ),
          Container(
            width: LayoutTokens.gr1,
            height: LayoutTokens.gr1,
            decoration: BoxDecoration(
              color: p.playerColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: LayoutTokens.gr1),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    p.username,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight:
                          isLocal ? FontWeight.bold : FontWeight.normal,
                      fontSize: FontTokens.hudSm,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLocal)
                  Text(
                    ' (you)',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontTokens.xs,
                    ),
                  ),
              ],
            ),
          ),
          if (p.commanderName != null)
            Flexible(
              child: Text(
                p.commanderName!,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontTokens.xs,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          SizedBox(width: LayoutTokens.gr1),
          Text(
            p.isEliminated
                ? _reasonLabel(p.eliminationReason)
                : '${p.life} ❤',
            style: TextStyle(
              color: p.isEliminated ? colors.primaryAccent : colors.textPrimary,
              fontSize: FontTokens.sm,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _reasonLabel(String? r) {
    switch (r) {
      case 'life':
        return 'Life depleted';
      case 'poison':
        return '10 poison';
      case 'commanderDamage':
        return 'Commander dmg';
      case 'concede':
        return 'Conceded';
      default:
        return 'Eliminated';
    }
  }
}

// ── Action Buttons ────────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final bool isHost;
  final VoidCallback onHome;
  final VoidCallback onRematch;

  const _ActionButtons({
    required this.isHost,
    required this.onHome,
    required this.onRematch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: LayoutTokens.ctaHorizontal),
      child: Column(
        children: [
          if (isHost) ...[
            UiButton(
              label: 'Rematch',
              icon: const Icon(Icons.replay_rounded, size: 20),
              onPressed: onRematch,
            ),
            SizedBox(height: LayoutTokens.gr2),
          ],
          UiButton(
            label: 'Back to Home',
            variant: UiButtonVariant.secondary,
            icon: const Icon(Icons.home_outlined, size: 20),
            onPressed: onHome,
          ),
        ],
      ),
    );
  }
}

/// Fade-in reveal for end-game result sections.
class _StaggerReveal extends StatefulWidget {
  const _StaggerReveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<_StaggerReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.standard,
    );
    Future<void>.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: widget.child,
    );
  }
}
