import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/game_session_events.dart';
import 'package:mgt_life_spark/core/game/game_state.dart';
import 'package:mgt_life_spark/core/game/player_game_state.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';

import 'support/fake_ble_service.dart';
import 'support/test_profile_repository.dart';

PlayerGameState _player({
  required String id,
  int life = 40,
  int poison = 0,
  Map<String, List<int>> commanderDamage = const {},
}) {
  return PlayerGameState(
    playerId: id,
    username: id,
    playerColor: Colors.blue,
    life: life,
    poison: poison,
    commanderDamage: commanderDamage,
  );
}

GameState _twoPlayerGame({
  required String localId,
  bool isHost = false,
  List<PlayerGameState>? players,
}) {
  final ps = players ??
      [
        _player(id: 'alice'),
        _player(id: 'bob'),
      ];
  return GameState(
    players: ps,
    turnOrder: ps.map((p) => p.playerId).toList(),
    localPlayerId: localId,
    isHost: isHost,
    gameStartTime: DateTime(2026, 1, 1),
    autoKoFromCommanderDamage: true,
    commanderDamageReducesLife: true,
  );
}

ProviderContainer _container({
  required FakeBleService ble,
  TestProfileRepository? profileRepo,
}) {
  return ProviderContainer(
    overrides: [
      sessionServiceProvider.overrideWith((ref) => ble),
      profileRepositoryProvider.overrideWithValue(
        profileRepo ?? TestProfileRepository(),
      ),
    ],
  );
}

void main() {
  group('GameStateNotifier network sync', () {
    test('stamps origin on outbound messages', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));
      notifier.adjustLife('alice', 1);

      expect(ble.sentMessages, isNotEmpty);
      expect(ble.sentMessages.last.originPlayerId, 'alice');
    });

    test('host rebroadcast excludes message originator', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'host', isHost: true),
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.proliferate,
          payload: {'origin': 'bob', 'pid': 'bob'},
          seqNum: 1,
        ),
      );

      expect(ble.sentMessages, isNotEmpty);
      expect(ble.lastExcludePlayerId, 'bob');
    });

    test('client ignores echoed messages from self', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(
          localId: 'alice',
          players: [_player(id: 'alice', poison: 2), _player(id: 'bob')],
        ),
      );

      notifier.proliferate('alice');
      expect(notifier.state.players.first.poison, 3);

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.proliferate,
          payload: {'origin': 'alice', 'pid': 'alice'},
          seqNum: 2,
        ),
      );

      expect(notifier.state.players.first.poison, 3);
    });

    test('commander kill stat only increments for the damage dealer', () {
      final ble = FakeBleService();
      final profileRepo = TestProfileRepository();
      final container = _container(ble: ble, profileRepo: profileRepo);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(
          localId: 'bob',
          isHost: true,
          players: [
            _player(id: 'alice', life: 40),
            _player(id: 'bob'),
          ],
        ).copyWith(
          autoKoFromLife: false,
          commanderDamageReducesLife: false,
        ),
      );

      notifier.applyCommanderDamage(
        fromPlayerId: 'bob',
        partnerIndex: 0,
        toPlayerId: 'alice',
        delta: 21,
      );

      expect(notifier.state.players.first.isEliminated, isTrue);
      expect(profileRepo.commanderKillIncrements, 1);
    });

    test('commander kill stat does not increment for non-dealer clients', () {
      final ble = FakeBleService();
      final profileRepo = TestProfileRepository();
      final container = _container(ble: ble, profileRepo: profileRepo);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(
          localId: 'alice',
          players: [
            _player(id: 'alice', life: 20),
            _player(id: 'bob'),
          ],
        ),
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.playerEliminated,
          payload: {
            'pid': 'alice',
            'reason': 'commanderDamage',
            'killedBy': 'bob',
            'origin': 'bob',
          },
          seqNum: 1,
        ),
      );

      expect(profileRepo.commanderKillIncrements, 0);
    });

    test('stateDelta sync is idempotent on absolute values', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.stateDelta,
          payload: {
            'pid': 'bob',
            'field': 'life',
            'val': 35,
            'delta': -5,
            'origin': 'bob',
          },
          seqNum: 1,
        ),
      );

      expect(notifier.state.players[1].life, 35);

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.stateDelta,
          payload: {
            'pid': 'bob',
            'field': 'life',
            'val': 35,
            'delta': -5,
            'origin': 'bob',
          },
          seqNum: 2,
        ),
      );

      expect(notifier.state.players[1].life, 35);
    });

    test('client cannot mutate another player life', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));
      notifier.adjustLife('bob', -5);

      expect(notifier.state.players[1].life, 40);
      expect(ble.sentMessages, isEmpty);
    });

    test('client does not auto-eliminate on synced life loss', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice').copyWith(autoKoFromLife: true),
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.stateDelta,
          payload: {
            'pid': 'alice',
            'field': 'life',
            'val': 0,
            'delta': -40,
            'origin': 'host',
          },
          seqNum: 1,
        ),
      );

      expect(notifier.state.players.first.life, 0);
      expect(notifier.state.players.first.isEliminated, isFalse);
    });

    test('host auto-eliminates on life loss', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'host', isHost: true)
            .copyWith(autoKoFromLife: true),
      );

      notifier.adjustLife('alice', -40);

      expect(notifier.state.players.first.isEliminated, isTrue);
      expect(
        ble.sentMessages.any((m) => m.type == BleMessageType.playerEliminated),
        isTrue,
      );
    });

    test('rematchPropose bumps rematchProposedProvider', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.rematchPropose,
          payload: {'origin': 'host'},
          seqNum: 1,
        ),
      );

      expect(container.read(rematchProposedProvider), 1);
    });

    test('client cannot end turn when not active player', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        GameState(
          players: [_player(id: 'alice'), _player(id: 'bob')],
          turnOrder: const ['alice', 'bob'],
          activePlayerIndex: 0,
          localPlayerId: 'bob',
          isHost: false,
          gameStartTime: DateTime(2026, 1, 1),
        ),
      );

      notifier.endTurn();

      expect(notifier.state.activePlayerIndex, 0);
      expect(ble.sentMessages, isEmpty);
    });
  });
}
