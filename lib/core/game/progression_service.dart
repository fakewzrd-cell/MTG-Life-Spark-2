import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_feedback.dart';
import '../models/match_record.dart';
import '../persistence/achievement_repository.dart';
import '../persistence/feedback_repository.dart';
import '../persistence/deck_repository.dart';
import '../persistence/match_repository.dart';
import '../persistence/profile_repository.dart';
import '../persistence/providers.dart';
import 'game_state.dart';
import 'player_game_state.dart';
import 'game_format.dart';
import 'lobby_state.dart';

/// XP award constants (competitive multiplayer matches only).
const int kXpParticipate = 50;
const int kXpWin = 100;
const int kXpFirstWin = 75;
const int kXpPerLike = 5;

/// True when the session has real opponents (not solo / practice).
bool matchAwardsProgression(GameState state) => state.players.length >= 2;

class ProgressResult {
  final String matchId;
  final int xpGained;
  final int oldLevel;
  final int newLevel;
  final List<String> newAchievementIds;

  /// False for solo/practice — no XP or ranked profile updates.
  final bool awardsProgression;

  const ProgressResult({
    required this.matchId,
    required this.xpGained,
    required this.oldLevel,
    required this.newLevel,
    required this.newAchievementIds,
    this.awardsProgression = true,
  });

  bool get leveledUp => newLevel > oldLevel;
}

class ProgressionService {
  final ProfileRepository _profileRepo;
  final AchievementRepository _achievementRepo;
  final MatchRepository _matchRepo;
  final FeedbackRepository _feedbackRepo;
  final DeckRepository _deckRepo;

  ProgressionService({
    required ProfileRepository profileRepo,
    required AchievementRepository achievementRepo,
    required MatchRepository matchRepo,
    required FeedbackRepository feedbackRepo,
    required DeckRepository deckRepo,
  })  : _profileRepo = profileRepo,
        _achievementRepo = achievementRepo,
        _matchRepo = matchRepo,
        _feedbackRepo = feedbackRepo,
        _deckRepo = deckRepo;

  Future<ProgressResult> recordMatch({
    required GameState finalState,
    required LobbyState lobbyState,
    required DateTime startTime,
    String? matchId,
  }) async {
    final localId = finalState.localPlayerId;
    final local = finalState.playerById(localId);
    final profile = _profileRepo.getProfile();

    if (local == null || profile == null) {
      return const ProgressResult(
          matchId: '',
          xpGained: 0,
          oldLevel: 1,
          newLevel: 1,
          newAchievementIds: [],
          awardsProgression: false);
    }

    final awardsProgression = matchAwardsProgression(finalState);
    if (!awardsProgression) {
      // Solo / practice: no XP, no profile history, no ranked stats.
      final deckId = local.selectedDeckId;
      if (deckId != null && deckId.isNotEmpty) {
        await _backfillDeckCommanderArt(deckId, local);
      }
      return ProgressResult(
        matchId: '',
        xpGained: 0,
        oldLevel: profile.level,
        newLevel: profile.level,
        newAchievementIds: const [],
        awardsProgression: false,
      );
    }

    final resolvedMatchId =
        matchId ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_matchRepo.hasMatch(resolvedMatchId)) {
      return ProgressResult(
        matchId: resolvedMatchId,
        xpGained: 0,
        oldLevel: profile.level,
        newLevel: profile.level,
        newAchievementIds: const [],
      );
    }

    final won = finalState.winnerPlayerId == localId;
    final result = won
        ? 'win'
        : (local.eliminationReason == 'concede' ? 'concede' : 'loss');
    final oldLevel = profile.level;

    // ── Calculate XP ──────────────────────────────────────────────────────
    var xp = kXpParticipate;
    if (won) {
      xp += kXpWin;
      if (profile.totalWins == 0) xp += kXpFirstWin;
    }

    // ── Save match record ─────────────────────────────────────────────────
    final elapsed = DateTime.now().difference(startTime);
    final durationMinutes = elapsed.inMinutes;
    final durationSeconds = elapsed.inSeconds;
    final opponentNames = finalState.players
        .where((p) => p.playerId != localId)
        .map((p) => p.username)
        .toList();

    final winnerId = finalState.winnerPlayerId;
    final ranked = List<PlayerGameState>.from(finalState.players)
      ..sort((a, b) {
        if (a.playerId == winnerId) return -1;
        if (b.playerId == winnerId) return 1;
        if (a.isEliminated != b.isEliminated) {
          return a.isEliminated ? 1 : -1;
        }
        return b.life.compareTo(a.life);
      });
    final placementById = <String, int>{
      for (var i = 0; i < ranked.length; i++) ranked[i].playerId: i + 1,
    };

    final participantsJson = jsonEncode(
      finalState.players.map((p) {
        final team = finalState.teamAssignments[p.playerId] ?? 0;
        return {
          'playerId': p.playerId,
          'username': p.username,
          'commanderName': p.commanderName,
          'commanderImageUrl': p.commanderImageUrl,
          'teamIndex': team,
          'finalLife': p.life,
          'isWinner': p.playerId == winnerId,
          'placementRank': placementById[p.playerId] ?? 0,
        };
      }).toList(),
    );

    await _matchRepo.saveMatch(MatchRecord(
      matchId: resolvedMatchId,
      date: DateTime.now(),
      commanderName: local.commanderName ?? 'Unknown',
      partnerCommanderName: local.partnerCommanderName,
      opponentNames: opponentNames,
      result: result,
      eliminationReason: local.eliminationReason ?? 'survived',
      format: lobbyState.config.format.displayName,
      durationMinutes: durationMinutes,
      startingLifeTotal: lobbyState.config.startingLife,
      playerCount: finalState.players.length,
      durationSeconds: durationSeconds,
      participantsJson: participantsJson,
      podNameSnapshot: lobbyState.podNameSnapshot,
      locationSnapshot: lobbyState.locationLabelSnapshot,
      localDeckIdSnapshot: local.selectedDeckId,
    ));

    // ── Update profile / deck / achievements ──────────────────────────────
    await _profileRepo.recordMatchResult(
      commanderName: local.commanderName ?? 'Unknown',
      won: won,
      xpGained: xp,
    );
    final deckId = local.selectedDeckId;
    if (deckId != null && deckId.isNotEmpty) {
      final deck = _deckRepo.getById(deckId);
      final lobbyFormat = lobbyState.config.format;
      if (deck != null && deck.matchesLobbyFormat(lobbyFormat)) {
        await _deckRepo.recordMatchResult(deckId, won);
        await _backfillDeckCommanderArt(deckId, local);
      }
    }

    final updatedProfile = _profileRepo.getProfile()!;
    final newAchievements = await _checkAchievements(updatedProfile, won);
    final newLevel = updatedProfile.level;

    return ProgressResult(
      matchId: resolvedMatchId,
      xpGained: xp,
      oldLevel: oldLevel,
      newLevel: newLevel,
      newAchievementIds: newAchievements,
    );
  }

  /// Saves feedback for a match. Call after recordMatch.
  ///
  /// [awardGiverXp] is true for the local voter; remote ballots only update
  /// received likes/honors via recompute.
  Future<void> saveFeedback(
    GameFeedback feedback, {
    bool awardGiverXp = true,
  }) async {
    await _feedbackRepo.saveFeedback(feedback);
    if (awardGiverXp) {
      final likesCount = feedback.likePlayerIds.length;
      if (likesCount > 0) {
        await _profileRepo.addXp(likesCount * kXpPerLike);
      }
    }
    final profile = _profileRepo.getProfile();
    if (profile != null) {
      await _profileRepo.recomputeSocialStatsFromFeedback(
        _feedbackRepo,
        profile.username,
      );
    }
  }

  Future<void> _backfillDeckCommanderArt(
    String deckId,
    PlayerGameState local,
  ) async {
    final deck = _deckRepo.getById(deckId);
    if (deck == null) return;
    var changed = false;
    final cmdUrl = local.commanderImageUrl;
    if (cmdUrl != null &&
        cmdUrl.trim().isNotEmpty &&
        (deck.commanderImageUrl == null || deck.commanderImageUrl!.isEmpty)) {
      deck.commanderImageUrl = cmdUrl.trim();
      changed = true;
    }
    final partnerUrl = local.partnerCommanderImageUrl;
    if (partnerUrl != null &&
        partnerUrl.trim().isNotEmpty &&
        (deck.partnerCommanderImageUrl == null ||
            deck.partnerCommanderImageUrl!.isEmpty)) {
      deck.partnerCommanderImageUrl = partnerUrl.trim();
      changed = true;
    }
    if (changed) await _deckRepo.save(deck);
  }

  Future<List<String>> _checkAchievements(
    dynamic profile,
    bool won,
  ) async {
    final newlyUnlocked = <String>[];
    final unlockedIds = _achievementRepo.getUnlockedIds();

    Future<void> tryUnlock(String id) async {
      if (!unlockedIds.contains(id)) {
        await _achievementRepo.unlock(id);
        newlyUnlocked.add(id);
        unlockedIds.add(id); // update local set
      }
    }

    if (won) {
      await tryUnlock('first_win');
    }

    if (profile.totalGamesPlayed >= 10) await tryUnlock('games_10');
    if (profile.totalGamesPlayed >= 50) await tryUnlock('games_50');
    if (profile.totalGamesPlayed >= 100) await tryUnlock('games_100');

    if (profile.lifetimePoisonDealt >= 50) await tryUnlock('poison_50');
    if (profile.lifetimePoisonDealt >= 100) await tryUnlock('poison_100');

    if (profile.lifetimeCommanderKills >= 1) await tryUnlock('commander_kill_1');
    if (profile.lifetimeCommanderKills >= 5) await tryUnlock('commander_kill_5');

    if (profile.level >= 11) await tryUnlock('reach_silver');
    if (profile.level >= 26) await tryUnlock('reach_gold');
    if (profile.level >= 76) await tryUnlock('reach_diamond');

    final cmdStats = _profileRepo
        .getCommanderStats(profile.selectedCommanderName ?? '');
    if (cmdStats != null && cmdStats.wins >= 5) {
      await tryUnlock('same_commander_5');
    }

    return newlyUnlocked;
  }
}

final progressionServiceProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(
    profileRepo: ref.read(profileRepositoryProvider),
    achievementRepo: ref.read(achievementRepositoryProvider),
    matchRepo: ref.read(matchRepositoryProvider),
    feedbackRepo: ref.read(feedbackRepositoryProvider),
    deckRepo: ref.read(deckRepositoryProvider),
  );
});
