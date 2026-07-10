import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/game_state_notifier.dart';
import '../../../core/game/player_game_state.dart';
import '../../../core/models/game_feedback.dart';
import '../../../core/game/session_exit_helpers.dart';
import '../../../core/network/session_providers.dart';
import '../../../shared/utils/app_router.dart';
import '../../../shared/widgets/home_nav_bar.dart';
import '../../../shared/widgets/player_feedback_widgets.dart';
import '../../../shared/utils/game_haptics.dart';
import '../../../ui/tokens/color_tokens.dart';
import '../../../ui/tokens/font_tokens.dart';
import '../../../ui/tokens/layout_tokens.dart';
import '../../../ui/tokens/opacity_tokens.dart';
import '../../../ui/tokens/radius_tokens.dart';
import 'game_colors.dart';
import 'game_modal_chrome.dart';
import 'game_timeout_widgets.dart';

// ── Bottom action bar ──────────────────────────────────────────────────────

class GameBottomBar extends ConsumerWidget {
  final GameState game;
  final PlayerGameState local;
  final VoidCallback onToggleOverview;
  final bool compact;

  const GameBottomBar({
    required this.game,
    required this.local,
    required this.onToggleOverview,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.gameColors;
    final notifier = ref.read(gameProvider.notifier);
    final compact = this.compact;
    final iconSize = compact ? 22.0 : 24.0;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          LayoutTokens.gr3,
          compact ? LayoutTokens.gr1 : LayoutTokens.gr2,
          LayoutTokens.gr3,
          LayoutTokens.gr3,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.gr2,
            vertical: compact ? LayoutTokens.gr2 : LayoutTokens.gr3,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: RadiusTokens.radiusMd,
            border: Border.all(color: colors.backgroundSecondary),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: OpacityTokens.faint),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: _GameBarButton(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    iconSize: iconSize,
                    compact: compact,
                    enabled: true,
                    onTap: () => HomeNavBar.promptQuitAndGoHome(context, ref),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _GameBarButton(
                    icon: Icons.undo,
                    label: 'Undo',
                    iconSize: iconSize,
                    compact: compact,
                    enabled: !local.isEliminated,
                    onTap: () => notifier.undo(local.playerId),
                  ),
                ),
              ),
              if (game.isHost)
                Expanded(
                  child: Center(
                    child: _GameBarButton(
                      icon:
                          game.timeoutActive ? Icons.play_arrow : Icons.timer,
                      label: game.timeoutActive ? 'Resume' : 'Timeout',
                      iconSize: iconSize,
                      compact: compact,
                      onTap: () {
                        if (game.timeoutActive) {
                          notifier.endTimeout();
                        } else {
                          _showTimeoutPicker(context, notifier);
                        }
                      },
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: _GameBarButton(
                    icon: Icons.grid_view,
                    label: 'Overview',
                    iconSize: iconSize,
                    compact: compact,
                    enabled: true,
                    onTap: onToggleOverview,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _GameBarButton(
                    icon: Icons.flag_outlined,
                    label: 'Forfeit',
                    iconSize: iconSize,
                    compact: compact,
                    enabled: !local.isEliminated && !game.gameOver,
                    onTap:
                        () => _showConcedeDialog(context, ref, local.playerId),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeoutPicker(BuildContext context, GameStateNotifier notifier) {
    showGameTimeoutPicker(context, notifier);
  }

  void _showConcedeDialog(
    BuildContext context,
    WidgetRef ref,
    String playerId,
  ) {
    final game = ref.read(gameProvider);
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => _GameConcedeDialog(
            game: game,
            playerId: playerId,
            onConcede: () {
              ref.read(gameProvider.notifier).concede(playerId);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                _showPostForfeitFollowUp(context, ref);
              });
            },
          ),
    );
  }
}

/// After a forfeit in a continuing multiplayer pod: stay to spectate or leave.
Future<void> _showPostForfeitFollowUp(
  BuildContext context,
  WidgetRef ref,
) async {
  final game = ref.read(gameProvider);
  if (game.gameOver) return;

  final othersStillPlaying = game.players.any(
    (p) => p.playerId != game.localPlayerId && !p.isEliminated,
  );
  if (!othersStillPlaying) return;

  final colors = context.gameColors;
  final inset = GameModalChrome.horizontalInset(context);
  final titleStyle = TextStyle(
    color: colors.textPrimary,
    fontSize: FontTokens.title,
    fontWeight: FontWeight.w700,
  );
  final bodyStyle = TextStyle(
    color: colors.textSecondary,
    fontSize: FontTokens.hudSm,
    height: 1.4,
  );

  final leave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: RadiusTokens.radiusMd,
        side: BorderSide(color: colors.backgroundSecondary),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: LayoutTokens.gr3,
        vertical: LayoutTokens.gr4,
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: Padding(
        padding: EdgeInsets.fromLTRB(inset, LayoutTokens.gr3, inset, 0),
        child: GameDialogTitleRow(
          titleWidget: Text('You forfeited', style: titleStyle),
          onClose: () => Navigator.pop(dialogContext, false),
        ),
      ),
      content: Padding(
        padding: EdgeInsets.fromLTRB(inset, LayoutTokens.gr2, inset, 0),
        child: Text(
          'Other players can keep playing. Stay on this device to spectate '
          'until the table finishes. Returning to your profile hub now saves '
          'your concede result and disconnects from the live game.',
          style: bodyStyle,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            inset,
            LayoutTokens.gr2,
            inset,
            LayoutTokens.gr3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: LayoutTokens.minTapTarget,
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primaryAccent,
                    foregroundColor: ColorTokens.onAccent,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Stay & spectate'),
                ),
              ),
              SizedBox(height: LayoutTokens.gr2),
              SizedBox(
                height: LayoutTokens.minTapTarget,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.borderSubtle),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Return to profile'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  if (leave != true || !context.mounted) return;
  await recordLocalConcedeBeforeExit(ref);
  await quitActiveGame(ref);
  if (context.mounted) {
    context.go(AppRoutes.home);
  }
}

// ── Concede Dialog (with feedback) ───────────────────────────────────────────

class _GameConcedeDialog extends StatefulWidget {
  final GameState game;
  final String playerId;
  final VoidCallback onConcede;

  const _GameConcedeDialog({
    required this.game,
    required this.playerId,
    required this.onConcede,
  });

  @override
  State<_GameConcedeDialog> createState() => _GameConcedeDialogState();
}

class _GameConcedeDialogState extends State<_GameConcedeDialog> {
  final Set<String> _likePlayerIds = {};
  final Set<String> _dislikePlayerIds = {};
  String? _mvpPlayerId;
  String? _teamPlayerId;
  String? _underdogPlayerId;

  void _submit(WidgetRef ref) {
    final pending = PendingFeedbackData(
      likePlayerIds: _likePlayerIds.toList(),
      dislikePlayerIds: _dislikePlayerIds.toList(),
      mvpPlayerId: _mvpPlayerId,
      teamPlayerId: _teamPlayerId,
      underdogPlayerId: _underdogPlayerId,
    );
    ref.read(pendingFeedbackProvider.notifier).state =
        pending.hasContent ? pending : null;
    Navigator.pop(context);
    widget.onConcede();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final game = widget.game;
    final inset = GameModalChrome.horizontalInset(context);
    final others = game.players
        .where((p) => p.playerId != game.localPlayerId)
        .toList();

    return Consumer(
      builder: (context, ref, _) {
        final titleStyle = TextStyle(
          color: colors.textPrimary,
          fontSize: FontTokens.title,
          fontWeight: FontWeight.w700,
        );
        final bodyStyle = TextStyle(
          color: colors.textSecondary,
          fontSize: FontTokens.hudSm,
          height: 1.4,
        );

        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: RadiusTokens.radiusMd,
            side: BorderSide(color: colors.backgroundSecondary),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.gr3,
            vertical: LayoutTokens.gr4,
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          title: Padding(
            padding: EdgeInsets.fromLTRB(inset, LayoutTokens.gr3, inset, 0),
            child: GameDialogTitleRow(
              titleWidget: Text('Forfeit?', style: titleStyle),
              onClose: () => Navigator.pop(context),
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(inset, LayoutTokens.gr2, inset, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    others.isEmpty
                        ? 'Your practice game will end. Optionally note how it went.'
                        : 'You will leave the game. Optionally rate opponents before you go.',
                    style: bodyStyle,
                  ),
                  if (others.isNotEmpty) ...[
                    SizedBox(height: LayoutTokens.gr3),
                    PlayerFeedbackFields(
                      opponents: others,
                      likePlayerIds: _likePlayerIds,
                      dislikePlayerIds: _dislikePlayerIds,
                      rateOpponentsTitle: 'Rate opponents',
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
                      mvpPlayerId: _mvpPlayerId,
                      teamPlayerId: _teamPlayerId,
                      underdogPlayerId: _underdogPlayerId,
                      onMvpChanged: (id) => setState(() => _mvpPlayerId = id),
                      onTeamPlayerChanged: (id) =>
                          setState(() => _teamPlayerId = id),
                      onUnderdogChanged: (id) =>
                          setState(() => _underdogPlayerId = id),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                inset,
                LayoutTokens.gr2,
                inset,
                LayoutTokens.gr3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: LayoutTokens.minTapTarget,
                    child: FilledButton(
                      onPressed: () => _submit(ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorTokens.danger,
                        foregroundColor: ColorTokens.onAccent,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Forfeit'),
                    ),
                  ),
                  SizedBox(height: LayoutTokens.gr2),
                  SizedBox(
                    height: LayoutTokens.minTapTarget,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.borderSubtle),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GameBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double iconSize;
  final bool compact;

  const _GameBarButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.iconSize = 24,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final c =
        enabled
            ? colors.textSecondary
            : colors.textSecondary.withValues(alpha: 0.4);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                context.gameHapticLight();
                onTap?.call();
              }
            : null,
        borderRadius: RadiusTokens.radiusMd,
        child: Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: LayoutTokens.gr6,
              minHeight: LayoutTokens.gr6,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LayoutTokens.gr1,
                vertical: compact ? LayoutTokens.gr1 : LayoutTokens.gr2,
              ),
              // Icon + label are decorative here — the explicit Semantics
              // above is the single source of truth for the a11y label, so
              // the Text below must not contribute its own competing node.
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: iconSize, color: c),
                    SizedBox(height: LayoutTokens.gr0),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FontTokens.hudXs - (compact ? 2 : 0),
                        fontWeight: FontWeight.w600,
                        color: c,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
