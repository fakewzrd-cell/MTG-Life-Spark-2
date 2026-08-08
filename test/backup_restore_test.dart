import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mgt_life_spark/core/models/app_settings.dart';
import 'package:mgt_life_spark/core/models/commander_stats.dart';
import 'package:mgt_life_spark/core/models/game_feedback.dart';
import 'package:mgt_life_spark/core/models/match_record.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/persistence/backup_codec.dart';
import 'package:mgt_life_spark/core/persistence/backup_service.dart';
import 'package:mgt_life_spark/core/persistence/deck_repository.dart';
import 'package:mgt_life_spark/core/persistence/feedback_repository.dart';
import 'package:mgt_life_spark/core/persistence/match_repository.dart';
import 'package:mgt_life_spark/core/persistence/profile_repository.dart';
import 'package:mgt_life_spark/core/persistence/settings_repository.dart';

void main() {
  late Directory tempDir;
  late ProfileRepository profileRepo;
  late SettingsRepository settingsRepo;
  late DeckRepository deckRepo;
  late MatchRepository matchRepo;
  late FeedbackRepository feedbackRepo;
  late BackupService backupService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('life_spark_backup_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PlayerProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MatchRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CommanderStatsAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PlayerDeckAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    profileRepo = ProfileRepository();
    settingsRepo = SettingsRepository();
    deckRepo = DeckRepository();
    matchRepo = MatchRepository();
    feedbackRepo = FeedbackRepository();

    await profileRepo.init();
    await settingsRepo.init();
    await deckRepo.init();
    await matchRepo.init();
    await feedbackRepo.init();

    await Hive.box<PlayerProfile>('playerProfile').clear();
    await Hive.box<CommanderStats>('commanderStats').clear();
    await Hive.box<AppSettings>('appSettings').clear();
    await Hive.box<PlayerDeck>('playerDecks').clear();
    await Hive.box<MatchRecord>('matchHistory').clear();
    await Hive.box<String>('matchFeedback').clear();
    // Settings repo expects a row after clear.
    await settingsRepo.update(AppSettings(onboardingCompleted: true));

    backupService = BackupService(
      profileRepo: profileRepo,
      settingsRepo: settingsRepo,
      deckRepo: deckRepo,
      matchRepo: matchRepo,
      feedbackRepo: feedbackRepo,
    );
  });

  Future<void> seedFullProfile() async {
    await profileRepo.saveProfile(
      PlayerProfile(
        username: 'Federick',
        playerId: 'pid-local',
        level: 8,
        xp: 3200,
        totalWins: 5,
        totalLosses: 2,
        totalGamesPlayed: 7,
        likesReceived: 4,
        dislikesReceived: 1,
        honorsStarReceived: 3,
      ),
    );
    await deckRepo.save(
      PlayerDeck(
        id: 'deck-1',
        displayName: 'Atraxa',
        commanderName: 'Atraxa, Praetors\' Voice',
        wins: 3,
        losses: 1,
        gamesPlayed: 4,
      ),
    );
    await profileRepo.replaceAllCommanderStats([
      CommanderStats(
        commanderName: 'Atraxa, Praetors\' Voice',
        wins: 3,
        losses: 1,
        gamesPlayed: 4,
      ),
    ]);
    await matchRepo.saveMatch(
      MatchRecord(
        matchId: 'match-keep',
        date: DateTime.now().toUtc(),
        commanderName: 'Atraxa, Praetors\' Voice',
        opponentNames: const ['Bob', 'Cara'],
        result: 'win',
        eliminationReason: 'survived',
        format: 'Commander',
        durationMinutes: 40,
        startingLifeTotal: 40,
        playerCount: 3,
        durationSeconds: 2400,
        localDeckIdSnapshot: 'deck-1',
      ),
    );
    await feedbackRepo.saveFeedback(
      const GameFeedback(
        matchId: 'match-keep',
        voterPlayerId: 'pid-voter',
        likePlayerIds: ['pid-local'],
        dislikePlayerIds: [],
        starPlayerId: 'pid-local',
      ),
    );
  }

  test('export then restore retains games, sparks, and behaviour source',
      () async {
    await seedFullProfile();

    final exported = await backupService.buildBackup();
    expect(exported.version, kLifeSparkBackupVersion);
    expect(exported.matches, hasLength(1));
    expect(exported.feedbackByKey, isNotEmpty);
    expect(exported.profile.honorsStarReceived, 3);
    expect(exported.profile.likesReceived, 4);

    // Simulate a different phone state before restore.
    await matchRepo.clearAll();
    await feedbackRepo.clearAll();
    await profileRepo.saveProfile(
      PlayerProfile(
        username: 'Other',
        playerId: 'pid-other',
        likesReceived: 0,
        dislikesReceived: 0,
        honorsStarReceived: 0,
      ),
    );
    await deckRepo.replaceAll(const []);
    expect(matchRepo.getAllMatches(), isEmpty);
    expect(feedbackRepo.allFeedback(), isEmpty);

    final restored = await backupService.restoreBackup(exported);

    expect(restored.profile.username, 'Federick');
    expect(restored.profile.playerId, 'pid-local');
    expect(profileRepo.getProfile()!.honorsStarReceived, 3);
    expect(profileRepo.getProfile()!.likesReceived, 4);
    expect(profileRepo.getProfile()!.dislikesReceived, 1);
    expect(matchRepo.getAllMatches().map((m) => m.matchId), ['match-keep']);
    expect(deckRepo.getAll().single.id, 'deck-1');

    final ballots = feedbackRepo.allFeedback().toList();
    expect(ballots, hasLength(1));
    expect(ballots.single.starPlayerId, 'pid-local');
    expect(ballots.single.likePlayerIds, contains('pid-local'));

    // Startup-style recompute with playerId should keep / sync social totals.
    await profileRepo.recomputeSocialStatsFromFeedback(
      feedbackRepo,
      profileRepo.getProfile()!.playerId,
    );
    final after = profileRepo.getProfile()!;
    expect(after.likesReceived, 1);
    expect(after.honorsStarReceived, 1);
    expect(after.dislikesReceived, 0);
  });

  test('empty feedback recompute does not wipe restored sparks/behaviour',
      () async {
    await profileRepo.saveProfile(
      PlayerProfile(
        username: 'Federick',
        playerId: 'pid-local',
        likesReceived: 9,
        dislikesReceived: 2,
        honorsStarReceived: 5,
      ),
    );
    expect(feedbackRepo.allFeedback(), isEmpty);

    await profileRepo.recomputeSocialStatsFromFeedback(
      feedbackRepo,
      'pid-local',
    );

    final p = profileRepo.getProfile()!;
    expect(p.likesReceived, 9);
    expect(p.dislikesReceived, 2);
    expect(p.honorsStarReceived, 5);
  });

  test('recompute matches ballots by playerId, not username', () async {
    await profileRepo.saveProfile(
      PlayerProfile(
        username: 'Federick',
        playerId: 'pid-local',
        likesReceived: 0,
        honorsStarReceived: 0,
      ),
    );
    await feedbackRepo.saveFeedback(
      const GameFeedback(
        matchId: 'm1',
        voterPlayerId: 'pid-voter',
        likePlayerIds: ['pid-local'],
        starPlayerId: 'pid-local',
      ),
    );

    // Bug path: username never appears in ballot id lists.
    await profileRepo.recomputeSocialStatsFromFeedback(
      feedbackRepo,
      'Federick',
    );
    expect(profileRepo.getProfile()!.likesReceived, 0);
    expect(profileRepo.getProfile()!.honorsStarReceived, 0);

    await profileRepo.recomputeSocialStatsFromFeedback(
      feedbackRepo,
      'pid-local',
    );
    expect(profileRepo.getProfile()!.likesReceived, 1);
    expect(profileRepo.getProfile()!.honorsStarReceived, 1);
  });

  test('v1 backups still decode; restore leaves history empty', () async {
    await seedFullProfile();
    // Dirty local history that must not linger after a v1 restore.
    expect(matchRepo.getAllMatches(), isNotEmpty);

    final v1 = LifeSparkBackup.fromJson({
      'format': kLifeSparkBackupFormat,
      'version': 1,
      'exportedAt': '2026-08-01T12:00:00.000Z',
      'profile': {
        'username': 'Legacy',
        'playerId': 'pid-legacy',
        'likesReceived': 7,
        'dislikesReceived': 0,
        'honorsStarReceived': 4,
      },
      'settings': {'onboardingCompleted': true},
      'decks': <Map<String, dynamic>>[],
      'commanderStats': <Map<String, dynamic>>[],
    });

    await backupService.restoreBackup(v1);

    expect(profileRepo.getProfile()!.username, 'Legacy');
    expect(profileRepo.getProfile()!.honorsStarReceived, 4);
    expect(matchRepo.getAllMatches(), isEmpty);
    expect(feedbackRepo.allFeedback(), isEmpty);

    // And empty-feedback recompute must not zero the restored sparks.
    await profileRepo.recomputeSocialStatsFromFeedback(
      feedbackRepo,
      profileRepo.getProfile()!.playerId,
    );
    expect(profileRepo.getProfile()!.honorsStarReceived, 4);
    expect(profileRepo.getProfile()!.likesReceived, 7);
  });

  test('encode/decode round-trip keeps feedback raw keys', () {
    final backup = LifeSparkBackup(
      version: kLifeSparkBackupVersion,
      exportedAt: DateTime.utc(2026, 8, 8),
      profile: PlayerProfile(username: 'A', playerId: 'p1'),
      settings: AppSettings(),
      decks: const [],
      commanderStats: const [],
      matches: [
        MatchRecord(
          matchId: 'm1',
          date: DateTime.utc(2026, 8, 7),
          commanderName: 'X',
          opponentNames: const [],
          result: 'win',
          eliminationReason: 'survived',
          format: 'Commander',
          durationMinutes: 1,
          startingLifeTotal: 40,
          playerCount: 2,
        ),
      ],
      feedbackByKey: {
        'm1::voter': jsonEncode({
          'matchId': 'm1',
          'voterPlayerId': 'voter',
          'likePlayerIds': ['p1'],
          'dislikePlayerIds': <String>[],
          'starPlayerId': 'p1',
        }),
      },
    );

    final again = backupService.decodeBackup(backupService.encodeBackup(backup));
    expect(again.matches.single.matchId, 'm1');
    expect(again.feedbackByKey['m1::voter'], isNotNull);
    expect(again.version, 2);
  });
}
