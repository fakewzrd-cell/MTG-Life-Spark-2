import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/game/game_format.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/game/lobby_state.dart';
import 'package:mgt_life_spark/core/models/app_settings.dart';
import 'package:mgt_life_spark/core/models/player_deck.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/models/player_slot.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';

import 'support/fake_ble_service.dart';
import 'support/test_profile_repository.dart';
import 'support/test_settings_repository.dart';

ProviderContainer _lobbyContainer({
  required FakeBleService ble,
  TestProfileRepository? profileRepo,
  TestSettingsRepository? settingsRepo,
}) {
  return ProviderContainer(
    overrides: [
      sessionServiceProvider.overrideWith((ref) => ble),
      profileRepositoryProvider.overrideWithValue(
        profileRepo ??
            TestProfileRepository(
              profile: PlayerProfile(username: 'host'),
            ),
      ),
      settingsRepositoryProvider.overrideWithValue(
        settingsRepo ?? TestSettingsRepository(),
      ),
    ],
  );
}
void main() {
  group('LobbyConfig', () {
    test('round-trips through JSON', () {
      const config = LobbyConfig(
        startingLife: 30,
        alliancesEnabled: false,
        teamsEnabled: true,
        turnTimeLimitSeconds: 600,
        trackTurnDuration: true,
      );

      final restored = LobbyConfig.fromJson(config.toJson());

      expect(restored.startingLife, 30);
      expect(restored.alliancesEnabled, false);
      expect(restored.teamsEnabled, isTrue);
      expect(restored.turnTimeLimitSeconds, 600);
      expect(restored.trackTurnDuration, isTrue);
    });
  });

  group('LobbyState.canStart', () {
    test('requires every player to be ready', () {
      const waiting = LobbyState(
        players: [
          PlayerSlot(
            playerId: 'a',
            username: 'a',
            playerColor: Colors.red,
            isHost: true,
            isReady: true,
          ),
          PlayerSlot(
            playerId: 'b',
            username: 'b',
            playerColor: Colors.green,
            isReady: false,
          ),
        ],
        isHost: true,
      );

      expect(waiting.canStart, isFalse);

      const ready = LobbyState(
        players: [
          PlayerSlot(
            playerId: 'a',
            username: 'a',
            playerColor: Colors.red,
            isHost: true,
            isReady: true,
          ),
          PlayerSlot(
            playerId: 'b',
            username: 'b',
            playerColor: Colors.green,
            isReady: true,
          ),
        ],
        isHost: true,
      );

      expect(ready.canStart, isTrue);
    });
  });

  group('LobbyNotifier', () {
    test('initAsHost seeds host slot from profile', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      container.read(lobbyProvider.notifier).initAsHost();
      final lobby = container.read(lobbyProvider);

      expect(lobby.isHost, isTrue);
      expect(lobby.players, hasLength(1));
      expect(lobby.players.single.username, 'host');
      expect(lobby.players.single.playerId, isNotEmpty);
      expect(lobby.players.single.playerId, isNot('host'));
      expect(lobby.players.single.isHost, isTrue);
    });

    test('initAsHost seeds format and life from app settings', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(
        ble: ble,
        settingsRepo: TestSettingsRepository(
          AppSettings(
            defaultFormat: 'Standard',
            defaultStartingLife: 20,
          ),
        ),
      );
      addTearDown(container.dispose);

      container.read(lobbyProvider.notifier).initAsHost();
      final lobby = container.read(lobbyProvider);

      expect(lobby.config.format, GameFormat.standard);
      expect(lobby.config.startingLife, 20);
    });

    test('initAsHost keeps config on re-init when players already present', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(
        ble: ble,
        settingsRepo: TestSettingsRepository(
          AppSettings(
            defaultFormat: 'Standard',
            defaultStartingLife: 20,
          ),
        ),
      );
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      notifier.updateConfig(
        const LobbyConfig(
          format: GameFormat.modern,
          startingLife: 25,
        ),
      );
      notifier.initAsHost();

      final lobby = container.read(lobbyProvider);
      expect(lobby.config.format, GameFormat.modern);
      expect(lobby.config.startingLife, 25);
    });

    test('initAsHost keeps matchLabel on re-init when players already present',
        () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      notifier.setMatchLabel('Friday EDH');
      expect(container.read(lobbyProvider).matchLabel, 'Friday EDH');

      notifier.initAsHost();
      expect(container.read(lobbyProvider).matchLabel, 'Friday EDH');
    });

    test('setReady toggles slot and host rebroadcasts lobby update', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      final hostId = container.read(lobbyProvider).players.single.playerId;
      notifier.setReady(hostId, ready: true);

      expect(container.read(lobbyProvider).players.single.isReady, isTrue);
      expect(
        ble.sentMessages.where((m) => m.type == BleMessageType.stateSnapshot),
        isNotEmpty,
      );
    });

    test('setCommander preserves selected deck until explicitly cleared', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      final hostId = container.read(lobbyProvider).players.single.playerId;
      final deck = PlayerDeck(
        id: 'tracked-deck',
        displayName: 'Tracked deck',
        commanderName: 'Original commander',
        commanderColorIdentity: const ['W'],
      );

      notifier.applyDeck(playerId: hostId, deck: deck);
      notifier.setCommander(
        playerId: hostId,
        commanderName: 'Replacement commander',
        commanderImageUrl: 'https://example.com/replacement.jpg',
        commanderColorIdentity: const ['U', 'B'],
      );

      var slot = container.read(lobbyProvider).players.single;
      expect(slot.commanderName, 'Replacement commander');
      expect(slot.commanderColorIdentity, ['U', 'B']);
      expect(slot.selectedDeckId, 'tracked-deck');
      expect(
        ble.sentMessages.where((m) => m.type == BleMessageType.stateSnapshot),
        isNotEmpty,
      );

      notifier.clearSelectedDeck(hostId);
      slot = container.read(lobbyProvider).players.single;
      expect(slot.selectedDeckId, isNull);
      expect(slot.commanderName, 'Replacement commander');
    });

    test('setCommander does not create deck attribution', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      final hostId = container.read(lobbyProvider).players.single.playerId;

      notifier.setCommander(
        playerId: hostId,
        commanderName: 'Manual commander',
        commanderImageUrl: '',
      );

      expect(
        container.read(lobbyProvider).players.single.selectedDeckId,
        isNull,
      );
    });

    test('host accepts duplicate display names with distinct seat ids', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(
        ble: ble,
        profileRepo: TestProfileRepository(
          profile: PlayerProfile(
            username: 'Planeswalker',
            playerId: 'host-uuid',
          ),
        ),
      );
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();

      ble.emit(
        BleMessage(
          type: BleMessageType.lobbyPlayerJoined,
          payload: {'pid': 'guest-uuid-1', 'username': 'Planeswalker'},
          seqNum: 1,
        ),
      );
      ble.emit(
        BleMessage(
          type: BleMessageType.lobbyPlayerJoined,
          payload: {'pid': 'guest-uuid-2', 'username': 'Planeswalker'},
          seqNum: 2,
        ),
      );

      // Allow stream handlers to run.
      return Future<void>.delayed(Duration.zero).then((_) {
        final lobby = container.read(lobbyProvider);
        expect(lobby.players, hasLength(3));
        expect(
          lobby.players.map((p) => p.username).toList(),
          everyElement('Planeswalker'),
        );
        expect(
          lobby.players.map((p) => p.playerId).toSet(),
          {'host-uuid', 'guest-uuid-1', 'guest-uuid-2'},
        );
      });
    });

    test('setMatchLabel normalizes and broadcasts', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      ble.sentMessages.clear();

      notifier.setMatchLabel('  Friday EDH  ');
      expect(container.read(lobbyProvider).matchLabel, 'Friday EDH');
      expect(
        ble.sentMessages.where((m) => m.type == BleMessageType.stateSnapshot),
        isNotEmpty,
      );
      expect(
        ble.sentMessages.last.payload['matchLabel'],
        'Friday EDH',
      );

      notifier.setMatchLabel('   ');
      expect(container.read(lobbyProvider).matchLabel, isNull);
    });

    test('reset clears players and stops listening', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      notifier.reset();

      final lobby = container.read(lobbyProvider);
      expect(lobby.players, isEmpty);
      expect(lobby.isHost, isFalse);
    });
  });
}
