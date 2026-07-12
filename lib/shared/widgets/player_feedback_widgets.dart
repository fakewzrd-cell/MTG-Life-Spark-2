import 'package:flutter/material.dart';

import '../../core/game/player_game_state.dart';
import '../../ui/theme/app_color_tokens.dart';
import '../../ui/tokens/font_tokens.dart';
import '../../ui/tokens/layout_tokens.dart';
import '../../ui/tokens/opacity_tokens.dart';
import '../../ui/tokens/radius_tokens.dart';

/// Like / dislike row for post-game and forfeit feedback.
class PlayerFeedbackRow extends StatelessWidget {
  const PlayerFeedbackRow({
    super.key,
    required this.player,
    required this.isLiked,
    required this.isDisliked,
    required this.onLike,
    required this.onDislike,
  });

  final PlayerGameState player;
  final bool isLiked;
  final bool isDisliked;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: LayoutTokens.gr1),
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
          SizedBox(width: LayoutTokens.gr1),
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
            tooltip: isLiked ? 'Clear like' : 'Like',
            onPressed: onLike,
            style: IconButton.styleFrom(
              backgroundColor: isLiked
                  ? colors.success.withValues(alpha: OpacityTokens.soft)
                  : Colors.transparent,
              minimumSize: const Size(
                LayoutTokens.minTapTarget,
                LayoutTokens.minTapTarget,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.thumb_down,
              size: 20,
              color: isDisliked ? colors.primaryAccent : colors.textSecondary,
            ),
            tooltip: isDisliked ? 'Clear dislike' : 'Dislike',
            onPressed: onDislike,
            style: IconButton.styleFrom(
              backgroundColor: isDisliked
                  ? colors.primaryAccent.withValues(alpha: OpacityTokens.soft)
                  : Colors.transparent,
              minimumSize: const Size(
                LayoutTokens.minTapTarget,
                LayoutTokens.minTapTarget,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// MVP / Team / Underdog picker shared across end-game and forfeit flows.
class PlayerFeedbackVoteDropdown extends StatelessWidget {
  const PlayerFeedbackVoteDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.players,
    required this.selectedId,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final List<PlayerGameState> players;
  final String? selectedId;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: FontTokens.hudXs,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: LayoutTokens.gr0),
        DropdownButtonFormField<String?>(
          key: ValueKey<String?>(selectedId),
          initialValue: selectedId,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colors.textSecondary,
              fontSize: FontTokens.hudSm,
            ),
            filled: true,
            fillColor: colors.backgroundSecondary,
            border: OutlineInputBorder(
              borderRadius: RadiusTokens.radiusLg,
              borderSide: BorderSide(color: colors.backgroundSecondary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.radiusLg,
              borderSide: BorderSide(color: colors.backgroundSecondary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: RadiusTokens.radiusLg,
              borderSide: BorderSide(color: colors.primaryAccent),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.gr2,
              vertical: LayoutTokens.gr2,
            ),
          ),
          dropdownColor: colors.surface,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: FontTokens.hudSm,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                '— None —',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontTokens.hudSm,
                ),
              ),
            ),
            ...players.map(
              (p) => DropdownMenuItem<String?>(
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
                    SizedBox(width: LayoutTokens.gr1),
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
    );
  }
}

/// Opponent thumbs + vote dropdowns (no card chrome — wrap as needed).
class PlayerFeedbackFields extends StatelessWidget {
  const PlayerFeedbackFields({
    super.key,
    required this.opponents,
    required this.likePlayerIds,
    required this.dislikePlayerIds,
    required this.onLike,
    required this.onDislike,
    required this.mvpPlayerId,
    required this.teamPlayerId,
    required this.underdogPlayerId,
    required this.onMvpChanged,
    required this.onTeamPlayerChanged,
    required this.onUnderdogChanged,
    this.rateOpponentsTitle,
    this.voteSpacing = LayoutTokens.gr2,
  });

  final List<PlayerGameState> opponents;
  final Set<String> likePlayerIds;
  final Set<String> dislikePlayerIds;
  final void Function(String playerId) onLike;
  final void Function(String playerId) onDislike;
  final String? mvpPlayerId;
  final String? teamPlayerId;
  final String? underdogPlayerId;
  final void Function(String?) onMvpChanged;
  final void Function(String?) onTeamPlayerChanged;
  final void Function(String?) onUnderdogChanged;
  final String? rateOpponentsTitle;
  final double voteSpacing;

  @override
  Widget build(BuildContext context) {
    if (opponents.isEmpty) return const SizedBox.shrink();

    final colors = AppColorTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (rateOpponentsTitle != null) ...[
          Text(
            rateOpponentsTitle!,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontTokens.hudSm,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: LayoutTokens.gr1),
        ],
        ...opponents.map(
          (p) => PlayerFeedbackRow(
            player: p,
            isLiked: likePlayerIds.contains(p.playerId),
            isDisliked: dislikePlayerIds.contains(p.playerId),
            onLike: () => onLike(p.playerId),
            onDislike: () => onDislike(p.playerId),
          ),
        ),
        SizedBox(height: LayoutTokens.gr2),
        PlayerFeedbackVoteDropdown(
          label: 'MVP',
          hint: 'Most Valuable Player',
          players: opponents,
          selectedId: mvpPlayerId,
          onChanged: onMvpChanged,
        ),
        SizedBox(height: voteSpacing),
        PlayerFeedbackVoteDropdown(
          label: 'Team Player',
          hint: 'Best teammate',
          players: opponents,
          selectedId: teamPlayerId,
          onChanged: onTeamPlayerChanged,
        ),
        SizedBox(height: voteSpacing),
        PlayerFeedbackVoteDropdown(
          label: 'Underdog',
          hint: 'Best comeback or underdog performance',
          players: opponents,
          selectedId: underdogPlayerId,
          onChanged: onUnderdogChanged,
        ),
      ],
    );
  }
}

/// Toggle like/dislike with mutual exclusion; tap again clears that vote.
void togglePlayerLike({
  required Set<String> likeIds,
  required Set<String> dislikeIds,
  required String playerId,
  required void Function(Set<String> likes, Set<String> dislikes) apply,
}) {
  final likes = Set<String>.from(likeIds);
  final dislikes = Set<String>.from(dislikeIds);
  if (likes.contains(playerId)) {
    likes.remove(playerId);
  } else {
    dislikes.remove(playerId);
    likes.add(playerId);
  }
  apply(likes, dislikes);
}

void togglePlayerDislike({
  required Set<String> likeIds,
  required Set<String> dislikeIds,
  required String playerId,
  required void Function(Set<String> likes, Set<String> dislikes) apply,
}) {
  final likes = Set<String>.from(likeIds);
  final dislikes = Set<String>.from(dislikeIds);
  if (dislikes.contains(playerId)) {
    dislikes.remove(playerId);
  } else {
    likes.remove(playerId);
    dislikes.add(playerId);
  }
  apply(likes, dislikes);
}
