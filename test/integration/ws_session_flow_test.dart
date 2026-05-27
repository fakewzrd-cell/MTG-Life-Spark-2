import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_protocol.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_service.dart';
import 'package:mgt_life_spark/core/network/session_join_uri.dart';
import 'package:mgt_life_spark/core/network/ws_client_service.dart';
import 'package:mgt_life_spark/core/network/ws_host_service.dart';

void main() {
  group('WebSocket session flow', () {
    late WsHostService host;

    setUp(() async {
      host = WsHostService(
        hostPlayerId: 'host',
        hostUsername: 'Host',
        joinToken: SessionJoinUri.generateToken(),
      );
      await host.initialize();
      expect(host.isReady, isTrue);
      expect(host.port, greaterThan(0));
    });

    tearDown(() async {
      await host.dispose();
    });

    test('client connects with QR token and announces lobby join', () async {
      final client = WsClientService(
        localPlayerId: 'guest',
        localUsername: 'Guest',
      );
      addTearDown(client.dispose);
      await client.initialize();

      final connected = Completer<void>();
      final connectionSub = client.connectionStream.listen((event) {
        if (event.status == BleConnectionStatus.connected) {
          if (!connected.isCompleted) connected.complete();
        }
      });

      final hostJoin = host.messageStream.firstWhere(
        (message) => message.type == BleMessageType.lobbyPlayerJoined,
      );

      final qrPayload = SessionJoinUri.buildQrPayload(
        hostIp: '127.0.0.1',
        port: host.port,
        token: host.joinToken,
      );
      final parsed = SessionJoinUri.parse(qrPayload);
      expect(parsed.token, host.joinToken);

      await client.connectToHost(parsed.wsUri, joinToken: parsed.token!);

      await connected.future.timeout(const Duration(seconds: 5));
      expect(client.isReady, isTrue);

      final joinMessage = await hostJoin.timeout(const Duration(seconds: 5));
      expect(joinMessage.payload['pid'], 'guest');
      expect(joinMessage.payload['username'], 'Guest');

      await connectionSub.cancel();
    });

    test('host rejects client with invalid join token', () async {
      final client = WsClientService(
        localPlayerId: 'guest',
        localUsername: 'Guest',
      );
      addTearDown(client.dispose);
      await client.initialize();

      final rejected = Completer<void>();
      final connectionSub = client.connectionStream.listen((event) {
        if (event.status == BleConnectionStatus.rejected) {
          if (!rejected.isCompleted) rejected.complete();
        }
      });

      await client.connectToHost(
        'ws://127.0.0.1:${host.port}',
        joinToken: 'not-the-host-token',
      );

      await rejected.future.timeout(const Duration(seconds: 5));
      expect(client.isReady, isFalse);

      await connectionSub.cancel();
    });
  });
}
