import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../debug/app_log.dart';
import '../models/game_feedback.dart';

class FeedbackRepository {
  static const _boxName = 'matchFeedback';
  static const _keySep = '::';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  static String _storageKey(String matchId, String voterPlayerId) =>
      '$matchId$_keySep$voterPlayerId';

  /// All stored feedback entries (legacy single-key + composite keys).
  Iterable<GameFeedback> allFeedback() sync* {
    for (final e in _box.toMap().entries) {
      final f = _parseValue(e.key.toString(), e.value);
      if (f != null) yield f;
    }
  }

  GameFeedback? _parseValue(String key, String json) {
    try {
      return GameFeedback.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e, st) {
      appLog('FeedbackRepository: invalid feedback JSON for key $key',
          error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> saveFeedback(GameFeedback feedback) async {
    final newKey = _storageKey(feedback.matchId, feedback.voterPlayerId);
    await _box.put(newKey, jsonEncode(feedback.toJson()));
    // Migrate away from legacy key (matchId only) for this match.
    if (_box.containsKey(feedback.matchId)) {
      await _box.delete(feedback.matchId);
    }
  }

  GameFeedback? getFeedback(String matchId) {
    // Legacy: single key per match (local voter only).
    final legacy = _box.get(matchId);
    if (legacy != null) {
      return _parseValue(matchId, legacy);
    }
    return null;
  }

  /// Feedback for a match from a specific voter (composite key).
  GameFeedback? getFeedbackForVoter(String matchId, String voterPlayerId) {
    final v = _box.get(_storageKey(matchId, voterPlayerId));
    if (v == null) return null;
    return _parseValue(_storageKey(matchId, voterPlayerId), v);
  }

  /// Total likes given across all matches (for profile stats).
  int get totalLikesGiven =>
      allFeedback().fold<int>(0, (sum, f) => sum + f.likePlayerIds.length);

  /// Total dislikes given across all matches.
  int get totalDislikesGiven =>
      allFeedback().fold<int>(0, (sum, f) => sum + f.dislikePlayerIds.length);

  /// Count of feedback entries where MVP was chosen.
  int get totalMvpVotesGiven => allFeedback()
      .fold<int>(0, (sum, f) => sum + (f.mvpPlayerId != null ? 1 : 0));

  /// Count of feedback entries where Team Player was chosen.
  int get totalTeamPlayerVotesGiven => allFeedback()
      .fold<int>(0, (sum, f) => sum + (f.teamPlayerId != null ? 1 : 0));

  /// Count of feedback entries where Underdog was chosen.
  int get totalUnderdogVotesGiven => allFeedback()
      .fold<int>(0, (sum, f) => sum + (f.underdogPlayerId != null ? 1 : 0));
}
