import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/models/app_settings.dart';
import 'package:mgt_life_spark/core/models/commander_stats.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/persistence/backup_codec.dart';

void main() {
  group('LifeSparkBackup codec', () {
    test('round-trips profile, decks, settings, and commander stats', () {
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
      );

      final encoded = const JsonEncoder().convert(original.toJson());
      final restored = LifeSparkBackup.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );

      expect(restored.version, kLifeSparkBackupVersion);
      expect(restored.profile.username, 'Federick');
      expect(restored.profile.playerId, 'pid-123');
      expect(restored.profile.level, 12);
      expect(restored.settings.colorSchemeId, 'fog');
      expect(restored.settings.useDarkTheme, isFalse);
      expect(restored.decks, hasLength(1));
      expect(restored.decks.first.displayName, 'Atraxa Infect');
      expect(restored.decks.first.isPinned, isTrue);
      expect(restored.commanderStats.single.wins, 3);
      expect(original.toJson()['pods'], isEmpty);
    });

    test('ignores legacy pods entries in older backups', () {
      final restored = LifeSparkBackup.fromJson({
        'format': kLifeSparkBackupFormat,
        'version': 1,
        'exportedAt': '2026-07-31T12:00:00.000Z',
        'profile': {
          'username': 'Federick',
          'playerId': 'pid-123',
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
      expect(restored.decks, isEmpty);
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
