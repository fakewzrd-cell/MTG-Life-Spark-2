import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_service.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/network/session_link_status.dart';
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

    test('publishes local life announcements for accessibility', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));
      notifier.adjustLife('alice', -3);

      final announcement = container.read(localLifeChangeProvider);
      expect(announcement, isNotNull);
      expect(announcement!.total, 37);
      expect(announcement.delta, -3);
      expect(announcement.source, LifeChangeSource.local);
    });

    test('publishes remote life announcements for the local seat', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: true),
      );
      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.stateDelta,
          payload: {
            'pid': 'alice',
            'field': 'life',
            'val': 35,
            'delta': -5,
            'origin': 'bob',
          },
          seqNum: 1,
        ),
      );

      final announcement = container.read(localLifeChangeProvider);
      expect(announcement, isNotNull);
      expect(announcement!.total, 35);
      expect(announcement.delta, -5);
      expect(announcement.source, LifeChangeSource.remote);
      expect(announcement.actorUsername, 'bob');
    });

    test('hostEndedSession stops client reconnect and raises UI event', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.hostEndedSession,
          payload: const {},
          seqNum: 1,
        ),
      );

      expect(container.read(hostEndedSessionUiEventProvider), isTrue);
      expect(
        container.read(sessionLinkStatusProvider),
        SessionLinkStatus.connected,
      );

      // A later disconnect must not flip into reconnecting forever.
      notifier.handleConnectionEventForTest(
        const BleConnectionEvent(
          playerId: 'host',
          status: BleConnectionStatus.disconnected,
        ),
      );
      expect(
        container.read(sessionLinkStatusProvider),
        SessionLinkStatus.connected,
      );
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

    test('client can record commander damage received from an opponent', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(
          localId: 'alice',
          players: [_player(id: 'alice', life: 40), _player(id: 'bob')],
        ),
      );

      notifier.applyCommanderDamage(
        fromPlayerId: 'bob',
        partnerIndex: 0,
        toPlayerId: 'alice',
        delta: 3,
      );

      final alice = notifier.state.players.first;
      expect(alice.commanderDamageFrom('bob', partnerIndex: 0), 3);
      expect(alice.life, 37);
      expect(
        ble.sentMessages
            .where((m) => m.type == BleMessageType.commanderDamage),
        isNotEmpty,
      );
    });

    test('client can still record commander damage it dealt', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(
          localId: 'alice',
          players: [_player(id: 'alice'), _player(id: 'bob', life: 40)],
        ),
      );

      notifier.applyCommanderDamage(
        fromPlayerId: 'alice',
        partnerIndex: 0,
        toPlayerId: 'bob',
        delta: 2,
      );

      final bob = notifier.state.players.last;
      expect(bob.commanderDamageFrom('alice', partnerIndex: 0), 2);
      expect(bob.life, 38);
    });

    test('client cannot record commander damage between two opponents', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(
          localId: 'alice',
          players: [
            _player(id: 'alice'),
            _player(id: 'bob', life: 40),
            _player(id: 'cara'),
          ],
        ),
      );

      notifier.applyCommanderDamage(
        fromPlayerId: 'cara',
        partnerIndex: 0,
        toPlayerId: 'bob',
        delta: 4,
      );

      final bob = notifier.state.players[1];
      expect(bob.commanderDamageFrom('cara', partnerIndex: 0), 0);
      expect(bob.life, 40);
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

  group('GameStateNotifier concede', () {
    test('solo forfeit ends the game with no winner', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        GameState(
          players: [_player(id: 'solo')],
          turnOrder: const ['solo'],
          localPlayerId: 'solo',
          isHost: true,
          gameStartTime: DateTime(2026, 1, 1),
        ),
      );

      notifier.concede('solo');

      expect(notifier.state.gameOver, isTrue);
      expect(notifier.state.winnerPlayerId, isNull);
      expect(notifier.state.localPlayer!.isEliminated, isTrue);
      expect(notifier.state.localPlayer!.eliminationReason, 'concede');
    });

    test('multiplayer forfeit does not end game while others remain', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(
        localId: 'alice',
        players: [
          _player(id: 'alice'),
          _player(id: 'bob'),
          _player(id: 'carol'),
        ],
      ));

      notifier.concede('alice');

      expect(notifier.state.gameOver, isFalse);
      expect(
        notifier.state.playerById('alice')!.isEliminated,
        isTrue,
      );
    });

    test('heads-up forfeit ends game with opponent as winner', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(localId: 'alice'));

      notifier.concede('alice');

      expect(notifier.state.gameOver, isTrue);
      expect(notifier.state.winnerPlayerId, 'bob');
    });

    test('elimination clears monarch and initiative when holder is out', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(_twoPlayerGame(
        localId: 'alice',
        isHost: true,
        players: [
          _player(id: 'alice'),
          _player(id: 'bob'),
          _player(id: 'carol'),
        ],
      ));

      notifier.setMonarch('bob');
      notifier.setInitiative('carol');
      notifier.concede('bob');

      expect(notifier.state.monarchPlayerId, isNull);
      expect(notifier.state.initiativePlayerId, 'carol');

      notifier.concede('carol');

      expect(notifier.state.initiativePlayerId, isNull);
    });
  });

  group('GameStateNotifier peer reconnect', () {
    test('host soft-drop does not eliminate; grace expiry awaits decision', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: true),
      );

      notifier.handleConnectionEventForTest(const BleConnectionEvent(
        playerId: 'bob',
        status: BleConnectionStatus.reconnecting,
      ));

      expect(notifier.state.playerById('bob')!.isEliminated, isFalse);
      expect(
        container.read(peerLinkIssuesProvider)['bob']?.awaitingHostDecision,
        isFalse,
      );

      final tickBefore = container.read(peerReconnectDecisionTickProvider);
      notifier.handleConnectionEventForTest(const BleConnectionEvent(
        playerId: 'bob',
        status: BleConnectionStatus.disconnected,
      ));

      expect(notifier.state.playerById('bob')!.isEliminated, isFalse);
      expect(
        container.read(peerLinkIssuesProvider)['bob']?.awaitingHostDecision,
        isTrue,
      );
      expect(container.read(peerReconnectDecisionTickProvider), tickBefore + 1);
    });

    test('host remove eliminates and syncs via playerDisconnected only', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: true),
      );

      notifier.handleConnectionEventForTest(const BleConnectionEvent(
        playerId: 'bob',
        status: BleConnectionStatus.disconnected,
      ));
      notifier.removePeerFromTable('bob');

      expect(notifier.state.playerById('bob')!.isEliminated, isTrue);
      expect(container.read(peerLinkIssuesProvider).containsKey('bob'), isFalse);
      expect(
        ble.sentMessages.where((m) => m.type == BleMessageType.playerDisconnected),
        hasLength(1),
      );
      expect(
        ble.sentMessages.any((m) => m.type == BleMessageType.playerEliminated),
        isFalse,
      );
      expect(container.read(playerLeftUiEventProvider)?.username, 'bob');
    });

    test('host remove is a no-op if peer already reconnected', () {
      final ble = FakeBleService()..connectedIds = ['bob'];
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: true),
      );
      container.read(peerLinkIssuesProvider.notifier).state = {
        'bob': const PeerLinkIssue(
          playerId: 'bob',
          username: 'bob',
          awaitingHostDecision: true,
        ),
      };

      notifier.removePeerFromTable('bob');

      expect(notifier.state.playerById('bob')!.isEliminated, isFalse);
      expect(ble.sentMessages, isEmpty);
      expect(container.read(peerLinkIssuesProvider).containsKey('bob'), isFalse);
    });

    test('clients mark peer reconnecting from message and clear on done', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: false),
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.playerReconnecting,
          payload: {'pid': 'bob'},
          seqNum: 1,
        ),
      );
      expect(
        container.read(peerLinkIssuesProvider)['bob']?.awaitingHostDecision,
        isFalse,
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.playerReconnecting,
          payload: {'pid': 'bob', 'done': true},
          seqNum: 2,
        ),
      );
      expect(container.read(peerLinkIssuesProvider).containsKey('bob'), isFalse);
    });

    test('client playerDisconnected eliminates and fires leave UI', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: false),
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.playerDisconnected,
          payload: {'pid': 'bob'},
          seqNum: 1,
        ),
      );

      expect(notifier.state.playerById('bob')!.isEliminated, isTrue);
      expect(container.read(playerLeftUiEventProvider)?.username, 'bob');
    });

    test('reconnectRequest on host pushes targeted snapshot', () {
      final ble = FakeBleService();
      final container = _container(ble: ble);
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.setGameStateForTest(
        _twoPlayerGame(localId: 'alice', isHost: true),
      );

      notifier.handleSessionMessageForTest(
        BleMessage(
          type: BleMessageType.reconnectRequest,
          payload: {'pid': 'bob', 'username': 'bob'},
          seqNum: 1,
        ),
      );

      final snap = ble.sentMessages
          .where((m) => m.type == BleMessageType.stateSnapshot)
          .toList();
      expect(snap, hasLength(1));
      expect(ble.lastTargetPlayerId, 'bob');
    });
  });
}
