import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_service.dart';
import 'package:mgt_life_spark/core/game/game_providers.dart';
import 'package:mgt_life_spark/core/game/lobby_state.dart';
import 'package:mgt_life_spark/core/models/player_profile.dart';
import 'package:mgt_life_spark/core/network/session_join_uri.dart';
import 'package:mgt_life_spark/core/network/session_providers.dart';
import 'package:mgt_life_spark/core/network/ws_client_service.dart';
import 'package:mgt_life_spark/core/network/ws_host_service.dart';
import 'package:mgt_life_spark/core/persistence/providers.dart';

import '../support/test_profile_repository.dart';

void main() {
  group('Multi-client session sync', () {
    late WsHostService host;

    setUp(() async {
      host = WsHostService(
        hostPlayerId: 'host',
        hostUsername: 'Host',
        joinToken: SessionJoinUri.generateToken(),
      );
      await host.initialize();
    });

    tearDown(() async {
      await host.dispose();
    });

    test('two clients join with valid tokens', () async {
      final joins = <String>[];
      final sub = host.messageStream.listen((message) {
        if (message.type == BleMessageType.lobbyPlayerJoined) {
          final pid = message.payload['pid'] as String?;
          if (pid != null) joins.add(pid);
        }
      });

      Future<void> connectClient(String id, String name) async {
        final client = WsClientService(
          localPlayerId: id,
          localUsername: name,
        );
        addTearDown(client.dispose);
        await client.initialize();

        final connected = Completer<void>();
        final connectionSub = client.connectionStream.listen((event) {
          if (event.status == BleConnectionStatus.connected &&
              !connected.isCompleted) {
            connected.complete();
          }
        });

        await client.connectToHost(
          'ws://127.0.0.1:${host.port}',
          joinToken: host.joinToken,
        );
        await connected.future.timeout(const Duration(seconds: 5));
        await connectionSub.cancel();
      }

      await connectClient('alice', 'Alice');
      await connectClient('bob', 'Bob');

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(joins, containsAll(['alice', 'bob']));
      expect(host.connectedPlayerIds, containsAll(['alice', 'bob']));

      await sub.cancel();
    });
  });

  test('lobby host keeps game authority without active session role', () {
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          TestProfileRepository(profile: PlayerProfile(username: 'host')),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(sessionRoleProvider), SessionRole.none);

    final lobbyNotifier = container.read(lobbyProvider.notifier);
    lobbyNotifier.initAsHost();
    lobbyNotifier.setReady('host', ready: true);

    final lobby = container.read(lobbyProvider);
    expect(lobby.isHost, isTrue);

    container.read(gameProvider.notifier).initFromLobby(lobby);
    final game = container.read(gameProvider);

    expect(game.isHost, isTrue);
    expect(game.players.length, 1);
    expect(game.players.single.playerId, 'host');
  });
}
