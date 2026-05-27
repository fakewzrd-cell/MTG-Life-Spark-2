import 'dart:async';

import 'package:mgt_life_spark/core/bluetooth/ble_message.dart';
import 'package:mgt_life_spark/core/bluetooth/ble_service.dart';

/// Records outbound messages for game-state unit tests.
class FakeBleService implements BleService {
  FakeBleService();

  final _messageController = StreamController<BleMessage>.broadcast();
  final _connectionController =
      StreamController<BleConnectionEvent>.broadcast();

  final sentMessages = <BleMessage>[];
  String? lastExcludePlayerId;
  String? lastTargetPlayerId;

  @override
  Stream<BleMessage> get messageStream => _messageController.stream;

  @override
  Stream<BleConnectionEvent> get connectionStream =>
      _connectionController.stream;

  @override
  List<String> get connectedPlayerIds => const [];

  @override
  bool get isReady => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {
    await _messageController.close();
    await _connectionController.close();
  }

  @override
  Future<void> send(
    BleMessage message, {
    String? targetPlayerId,
    String? excludePlayerId,
  }) async {
    sentMessages.add(message);
    lastTargetPlayerId = targetPlayerId;
    lastExcludePlayerId = excludePlayerId;
  }

  void emit(BleMessage message) {
    _messageController.add(message);
  }
}
