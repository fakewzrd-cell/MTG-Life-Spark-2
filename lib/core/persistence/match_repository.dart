import 'package:hive_flutter/hive_flutter.dart';

import '../../shared/utils/commander_image_resolver.dart';
import '../models/match_record.dart';

class MatchRepository {
  static const _boxName = 'matchHistory';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<MatchRecord>(_boxName);
    }
  }

  Box<MatchRecord> get _box => Hive.box<MatchRecord>(_boxName);

  bool hasMatch(String matchId) => _box.containsKey(matchId);

  Future<void> saveMatch(MatchRecord record) async {
    await _box.put(record.matchId, record);
  }

  List<MatchRecord> getRecentMatches() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return _box.values
        .where(
          (m) =>
              !isPreviewPlaceholderMatchId(m.matchId) &&
              m.date.isAfter(cutoff),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<MatchRecord> getAllMatches() {
    return _box.values
        .where((m) => !isPreviewPlaceholderMatchId(m.matchId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Call on app startup — removes detailed entries older than 30 days.
  /// Stats should already be rolled into PlayerProfile lifetime totals.
  Future<void> purgeOldMatches() async {
    if (!Hive.isBoxOpen(_boxName)) return;
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final oldKeys = <dynamic>[];
    for (final record in _box.values) {
      if (isPreviewPlaceholderMatchId(record.matchId)) continue;
      if (record.date.isBefore(cutoff)) {
        oldKeys.add(record.matchId);
      }
    }
    if (oldKeys.isEmpty) return;
    await _box.deleteAll(oldKeys);
  }

  Future<void> deleteMatch(String matchId) async {
    await _box.delete(matchId);
  }

  /// Wipe all match history (used by backup restore).
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Snapshot every row for restore rollback (includes placeholders).
  List<MatchRecord> snapshotAll() =>
      _box.values.map(_cloneRecord).toList(growable: false);

  /// Replace every row (used by backup restore rollback).
  Future<void> replaceAll(List<MatchRecord> records) async {
    await _box.clear();
    for (final record in records) {
      await _box.put(record.matchId, record);
    }
  }
}

MatchRecord _cloneRecord(MatchRecord m) => MatchRecord(
      matchId: m.matchId,
      date: m.date,
      commanderName: m.commanderName,
      partnerCommanderName: m.partnerCommanderName,
      opponentNames: List<String>.from(m.opponentNames),
      result: m.result,
      eliminationReason: m.eliminationReason,
      format: m.format,
      durationMinutes: m.durationMinutes,
      startingLifeTotal: m.startingLifeTotal,
      playerCount: m.playerCount,
      durationSeconds: m.durationSeconds,
      participantsJson: m.participantsJson,
      podNameSnapshot: m.podNameSnapshot,
      locationSnapshot: m.locationSnapshot,
      localDeckIdSnapshot: m.localDeckIdSnapshot,
    );
