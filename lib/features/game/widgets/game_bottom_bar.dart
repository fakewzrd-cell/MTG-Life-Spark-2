import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/game/game_providers.dart';
import '../../../core/game/game_state.dart';
import '../../../core/game/game_state_notifier.dart';
import '../../../core/game/player_game_state.dart';
import '../../../core/models/game_feedback.dart';
import '../../../shared/utils/app_router.dart';
import '../../../shared/widgets/home_nav_bar.dart';
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
              if (game.isHost)
                Expanded(
                  child: Center(
                    child: _GameBarButton(
                      icon: Icons.skip_next,
                      label: 'End Turn',
                      iconSize: iconSize,
                      enabled:
                          game.isLocalPlayersTurn && !game.timeoutActive,
                      onTap: () => notifier.endTurn(),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: _GameBarButton(
                    icon: Icons.grid_view,
                    label: 'Overview',
                    iconSize: iconSize,
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
                final after = ref.read(gameProvider);
                final local = after.localPlayer;
                if (local != null &&
                    local.isEliminated &&
                    !after.gameOver) {
                  context.go(AppRoutes.endGame);
                }
              });
            },
          ),
    );
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
    ref.read(pendingFeedbackProvider.notifier).state = PendingFeedbackData(
      likePlayerIds: _likePlayerIds.toList(),
      dislikePlayerIds: _dislikePlayerIds.toList(),
      mvpPlayerId: _mvpPlayerId,
      teamPlayerId: _teamPlayerId,
      underdogPlayerId: _underdogPlayerId,
    );
    Navigator.pop(context);
    widget.onConcede();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final game = widget.game;
    final others = game.players
        .where((p) => p.playerId != game.localPlayerId)
        .toList();

    return Consumer(
      builder:
          (context, ref, _) => AlertDialog(
            backgroundColor: colors.surface,
            contentPadding: EdgeInsets.zero,
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.95,
                maxHeight: MediaQuery.sizeOf(context).height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title + X
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        GameModalChrome.horizontalInset(context),
                        LayoutTokens.gr3,
                        LayoutTokens.gr2,
                        0,
                      ),
                      child: GameDialogTitleRow(
                        title: 'Forfeit?',
                        onClose: () => Navigator.pop(context),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        GameModalChrome.horizontalInset(context),
                        LayoutTokens.gr2,
                        GameModalChrome.horizontalInset(context),
                        0,
                      ),
                      child: Text(
                        'This will remove you from the game. Rate your opponents before leaving.',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontTokens.hudSm,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (others.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: GameModalChrome.horizontalInset(context),
                        ),
                        child: Text(
                          'Rate opponents',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontTokens.hudSm,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...others.map(
                        (p) => _GameConcedePlayerFeedbackRow(
                          player: p,
                          isLiked: _likePlayerIds.contains(p.playerId),
                          isDisliked: _dislikePlayerIds.contains(p.playerId),
                          onLike:
                              () => setState(() {
                                _dislikePlayerIds.remove(p.playerId);
                                _likePlayerIds.add(p.playerId);
                              }),
                          onDislike:
                              () => setState(() {
                                _likePlayerIds.remove(p.playerId);
                                _dislikePlayerIds.add(p.playerId);
                              }),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // MVP
                    _GameConcedeVoteDropdown(
                      label: 'MVP',
                      hint: 'Most Valuable Player',
                      players: others,
                      selectedId: _mvpPlayerId,
                      onChanged: (id) => setState(() => _mvpPlayerId = id),
                    ),
                    const SizedBox(height: 8),
                    // Team Player
                    _GameConcedeVoteDropdown(
                      label: 'Team Player',
                      hint: 'Best teammate',
                      players: others,
                      selectedId: _teamPlayerId,
                      onChanged: (id) => setState(() => _teamPlayerId = id),
                    ),
                    const SizedBox(height: 8),
                    _GameConcedeVoteDropdown(
                      label: 'Underdog',
                      hint: 'Best comeback or underdog performance',
                      players: others,
                      selectedId: _underdogPlayerId,
                      onChanged: (id) => setState(() => _underdogPlayerId = id),
                    ),
                    const SizedBox(height: 20),
                    // Concede button
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        GameModalChrome.horizontalInset(context),
                        0,
                        GameModalChrome.horizontalInset(context),
                        LayoutTokens.gr4,
                      ),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(color: colors.textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _submit(ref),
                        child: Text('Forfeit'),
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

class _GameConcedePlayerFeedbackRow extends StatelessWidget {
  final PlayerGameState player;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const _GameConcedePlayerFeedbackRow({
    required this.player,
    required this.isLiked,
    required this.isDisliked,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GameModalChrome.horizontalInset(context),
        vertical: 2,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: player.playerColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              player.username,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: FontTokens.hudSm,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.thumb_up,
              size: 20,
              color: isLiked ? colors.success : colors.textSecondary,
            ),
            onPressed: onLike,
            style: IconButton.styleFrom(
              backgroundColor:
                  isLiked
                      ? colors.success.withValues(alpha: OpacityTokens.soft)
                      : Colors.transparent,
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.thumb_down,
              size: 20,
              color: isDisliked ? colors.primaryAccent : colors.textSecondary,
            ),
            onPressed: onDislike,
            style: IconButton.styleFrom(
              backgroundColor:
                  isDisliked
                      ? colors.primaryAccent.withValues(alpha: OpacityTokens.soft)
                      : Colors.transparent,
              minimumSize: const Size(44, 44),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameConcedeVoteDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final List<PlayerGameState> players;
  final String? selectedId;
  final void Function(String?) onChanged;

  const _GameConcedeVoteDropdown({
    required this.label,
    required this.hint,
    required this.players,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GameModalChrome.horizontalInset(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: FontTokens.hudXs,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButton<String?>(
            value: selectedId,
            isExpanded: true,
            hint: Text(
              hint,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: FontTokens.hudSm,
              ),
            ),
            dropdownColor: colors.surface,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontTokens.hudSm,
            ),
            underline: const SizedBox.shrink(),
            borderRadius: RadiusTokens.radiusPill,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  '— None —',
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ),
              ...players.map(
                (p) => DropdownMenuItem<String>(
                  value: p.playerId,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: p.playerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          p.username,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontTokens.hudSm,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _GameBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double iconSize;

  const _GameBarButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.iconSize = 24,
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
        onTap: enabled ? onTap : null,
        borderRadius: RadiusTokens.radiusMd,
        child: Tooltip(
          message: label,
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
                padding: const EdgeInsets.all(LayoutTokens.gr2),
                child: Center(
                  child: Icon(icon, size: iconSize, color: c),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
