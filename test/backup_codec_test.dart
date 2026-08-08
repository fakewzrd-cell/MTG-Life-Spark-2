import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/app_settings.dart';
import 'package:mgt_life_spark/core/models/commander_stats.dart';
import 'package:mgt_life_spark/core/models/match_record.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/persistence/backup_codec.dart';

void main() {
  group('LifeSparkBackup codec', () {
    test('round-trips profile, decks, settings, history, and feedback', () {
      final original = LifeSparkBackup(
        version: kLifeSparkBackupVersion,
        exportedAt: DateTime.utc(2026, 7, 31, 12),
        profile: PlayerProfile(
          username: 'Federick',
          playerId: 'pid-123',
          level: 12,
          xp: 6200,
          tier: 'Silver',
          totalWins: 4,
          totalLosses: 2,
          selectedCommanderName: 'Atraxa',
          totalGamesPlayed: 6,
          currentWinStreak: 2,
          likesReceived: 3,
          dislikesReceived: 1,
          honorsStarReceived: 2,
        ),
        settings: AppSettings(
          useDarkTheme: false,
          colorSchemeId: 'fog',
          onboardingCompleted: true,
          defaultStartingLife: 40,
        ),
        decks: [
          PlayerDeck(
            id: 'deck-1',
            displayName: 'Atraxa Infect',
            commanderName: 'Atraxa',
            wins: 3,
            losses: 1,
            gamesPlayed: 4,
            commanderColorIdentity: const ['W', 'U', 'B', 'G'],
            format: 'commander',
            isPinned: true,
          ),
        ],
        commanderStats: [
          CommanderStats(
            commanderName: 'Atraxa',
            wins: 3,
            losses: 1,
            gamesPlayed: 4,
          ),
        ],
        matches: [
          MatchRecord(
            matchId: 'm-1',
            date: DateTime.utc(2026, 7, 30, 18),
            commanderName: 'Atraxa',
            opponentNames: const ['Bob', 'Cara'],
            result: 'win',
            eliminationReason: 'survived',
            format: 'Commander',
            durationMinutes: 45,
            startingLifeTotal: 40,
            playerCount: 3,
            durationSeconds: 2700,
            localDeckIdSnapshot: 'deck-1',
          ),
        ],
        feedbackByKey: {
          'm-1::pid-456': jsonEncode({
            'matchId': 'm-1',
            'voterPlayerId': 'pid-456',
            'likePlayerIds': ['pid-123'],
            'dislikePlayerIds': <String>[],
            'starPlayerId': 'pid-123',
          }),
        },
        profileAvatarImageBase64: 'aGVsbG8=', // "hello"
        profileAvatarImageMime: 'image/jpeg',
      );

      final encoded = const JsonEncoder().convert(original.toJson());
      final restored = LifeSparkBackup.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );

      expect(restored.version, kLifeSparkBackupVersion);
      expect(restored.profile.username, 'Federick');
      expect(restored.profile.playerId, 'pid-123');
      expect(restored.profile.level, 12);
      expect(restored.profile.likesReceived, 3);
      expect(restored.profile.honorsStarReceived, 2);
      expect(restored.settings.colorSchemeId, 'fog');
      expect(restored.settings.useDarkTheme, isFalse);
      expect(restored.decks, hasLength(1));
      expect(restored.decks.first.displayName, 'Atraxa Infect');
      expect(restored.decks.first.isPinned, isTrue);
      expect(restored.commanderStats.single.wins, 3);
      expect(restored.matches, hasLength(1));
      expect(restored.matches.single.matchId, 'm-1');
      expect(restored.matches.single.result, 'win');
      expect(restored.matches.single.localDeckIdSnapshot, 'deck-1');
      expect(restored.feedbackByKey, hasLength(1));
      expect(restored.feedbackByKey.containsKey('m-1::pid-456'), isTrue);
      expect(restored.profileAvatarImageBase64, 'aGVsbG8=');
      expect(restored.profileAvatarImageMime, 'image/jpeg');
      expect(original.toJson()['pods'], isEmpty);
    });

    test('v1 backups restore without matches/feedback keys', () {
      final restored = LifeSparkBackup.fromJson({
        'format': kLifeSparkBackupFormat,
        'version': 1,
        'exportedAt': '2026-07-31T12:00:00.000Z',
        'profile': {
          'username': 'Federick',
          'playerId': 'pid-123',
          'honorsStarReceived': 5,
          'likesReceived': 2,
        },
        'settings': {
          'onboardingCompleted': true,
        },
        'decks': <Map<String, dynamic>>[],
        'pods': [
          {
            'id': 'pod-1',
            'name': 'Friday Night',
            'memberPlayerIds': ['pid-123'],
          },
        ],
        'commanderStats': <Map<String, dynamic>>[],
      });

      expect(restored.profile.username, 'Federick');
      expect(restored.profile.honorsStarReceived, 5);
      expect(restored.profile.likesReceived, 2);
      expect(restored.decks, isEmpty);
      expect(restored.matches, isEmpty);
      expect(restored.feedbackByKey, isEmpty);
    });

    test('rejects unknown format marker', () {
      expect(
        () => LifeSparkBackup.fromJson({
          'format': 'something-else',
          'version': 1,
          'profile': {'username': 'x'},
          'settings': {},
        }),
        throwsFormatException,
      );
    });

    test('rejects unsupported version', () {
      expect(
        () => LifeSparkBackup.fromJson({
          'format': kLifeSparkBackupFormat,
          'version': 99,
          'profile': {'username': 'x'},
          'settings': {},
        }),
        throwsFormatException,
      );
    });
  });
}
