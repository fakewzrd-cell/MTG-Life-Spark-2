import 'dart:async';

import '../bluetooth/ble_message.dart';
import '../bluetooth/ble_service.dart';

/// Web stub — hosting requires a native device with [dart:io] HttpServer.
class WsHostService implements BleService {
  WsHostService({required this.hostPlayerId, required this.hostUsername});

  final String hostPlayerId;
  final String hostUsername;

  final _messageController = StreamController<BleMessage>.broadcast();
  final _connectionController = StreamController<BleConnectionEvent>.broadcast();

  int get port => 0;

  @override
  Stream<BleMessage> get messageStream => _messageController.stream;

  @override
  Stream<BleConnectionEvent> get connectionStream =>
      _connectionController.stream;

  @override
  List<String> get connectedPlayerIds => const [];

  @override
  bool get isReady => false;

  @override
  Future<void> initialize() async {
    _connectionController.add(const BleConnectionEvent(
      playerId: '',
      status: BleConnectionStatus.error,
      errorMessage:
          'Hosting is not available in the browser. Use the mobile app or '
          'run the app locally on your computer to host and show a QR code.',
    ));
  }

  @override
  Future<void> dispose() async {
    await _messageController.close();
    await _connectionController.close();
  }

  @override
  Future<void> send(BleMessage message, {String? targetPlayerId}) async {}
}
