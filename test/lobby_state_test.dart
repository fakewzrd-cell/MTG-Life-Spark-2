import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/game/game_format.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/game/lobby_state.dart';
import 'package:mgt_life_spark/core/models/app_settings.dart';
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
        turnTimeLimitSeconds: 600,
        trackTurnDuration: true,
      );

      final restored = LobbyConfig.fromJson(config.toJson());

      expect(restored.startingLife, 30);
      expect(restored.alliancesEnabled, false);
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

    test('setReady toggles slot and host rebroadcasts lobby update', () {
      final ble = FakeBleService();
      final container = _lobbyContainer(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(lobbyProvider.notifier);
      notifier.initAsHost();
      notifier.setReady('host', ready: true);

      expect(container.read(lobbyProvider).players.single.isReady, isTrue);
      expect(
        ble.sentMessages.where((m) => m.type == BleMessageType.stateSnapshot),
        isNotEmpty,
      );
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
