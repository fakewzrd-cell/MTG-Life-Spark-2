import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../bluetooth/ble_message.dart';
import '../bluetooth/ble_protocol.dart';
import '../bluetooth/ble_service.dart';
import 'ws_client_connect_stub.dart'
    if (dart.library.io) 'ws_client_connect_io.dart';

/// WebSocket-based client service.
///
/// Connects to the host's WebSocket server at the URI encoded in the QR code
/// (`ws://<host-ip>:<port>`), performs the same version handshake as before,
/// then sends / receives [BleMessage] JSON frames.
class WsClientService implements BleService {
  final _messageController = StreamController<BleMessage>.broadcast();
  final _connectionController = StreamController<BleConnectionEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;

  String? _hostUri;
  String? _joinToken;
  int _seqNum = 0;
  bool _ready = false;
  bool _intentionalDisconnect = false;
  Timer? _keepAliveTimer;
  bool _reconnecting = false;

  /// Last successful host URI (for resume-after-background reconnect).
  String? get lastHostUri => _hostUri;

  String? get lastJoinToken => _joinToken;

  final String localPlayerId;
  final String localUsername;

  WsClientService({required this.localPlayerId, required this.localUsername});

  @override
  Stream<BleMessage> get messageStream => _messageController.stream;

  @override
  Stream<BleConnectionEvent> get connectionStream =>
      _connectionController.stream;

  /// Clients only connect to the host; peer player IDs are not tracked here.
  @override
  List<String> get connectedPlayerIds => const [];

  @override
  bool get isReady => _ready;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    // Nothing to do until connectToHost is called.
  }

  @override
  Future<void> dispose() async {
    _intentionalDisconnect = true;
    _stopKeepAlive();
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _ready = false;
    await _messageController.close();
    await _connectionController.close();
  }

  // ── Connection ────────────────────────────────────────────────────────────

  static const _connectTimeout = Duration(seconds: 12);

  /// Connects to the WebSocket server at [wsUri] (e.g. `ws://192.168.1.5:27315`).
  /// [joinToken] must match the token embedded in the host QR code.
  Future<void> connectToHost(String wsUri, {required String joinToken}) async {
    _intentionalDisconnect = false;
    _hostUri = wsUri;
    _joinToken = joinToken;
    await disconnect();
    try {
      await _openChannel(wsUri);
    } catch (e) {
      await disconnect();
      _connectionController.add(BleConnectionEvent(
        playerId: wsUri,
        status: BleConnectionStatus.error,
        errorMessage: e is TimeoutException
            ? e.message
            : 'Cannot reach host: $e',
      ));
    }
  }

  Future<void> _openChannel(String wsUri) async {
    _channel = connectClientChannel(
      Uri.parse(wsUri),
      connectTimeout: _connectTimeout,
    );
    await _channel!.ready;

    _sub = _channel!.stream.listen(
      _onData,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: false,
    );

    // Kick off handshake
    _sendRaw(BleMessage.hello(_nextSeq(), joinToken: _joinToken));
  }

  /// Closes any open socket without tearing down stream controllers.
  Future<void> disconnect({bool intentional = false}) async {
    if (intentional) _intentionalDisconnect = true;
    _stopKeepAlive();
    await _sub?.cancel();
    _sub = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _ready = false;
  }

  /// Re-opens the last host connection after the OS drops the socket in background.
  Future<void> reconnectIfDisconnected() async {
    if (_intentionalDisconnect || _reconnecting) return;
    final uri = _hostUri;
    final token = _joinToken;
    if (uri == null || token == null) return;
    if (_ready && _channel != null) return;

    _reconnecting = true;
    try {
      await disconnect();
      await connectToHost(uri, joinToken: token);
    } catch (e, st) {
      debugPrint('WsClientService reconnect failed: $e\n$st');
    } finally {
      _reconnecting = false;
    }
  }

  void _startKeepAlive() {
    _stopKeepAlive();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 18), (_) {
      if (!_ready) return;
      _sendRaw(BleMessage(
        type: BleMessageType.sessionPing,
        payload: const {},
        seqNum: _nextSeq(),
      ));
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  // ── Incoming data ─────────────────────────────────────────────────────────

  void _onData(dynamic data) {
    if (data is! String) return;
    BleMessage message;
    try {
      message = BleMessage.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (_) {
      return;
    }

    if (message.type == BleMessageType.reject) {
      _ready = false;
      final reason = message.payload['reason'] as String? ?? 'versionMismatch';
      final messageText = switch (reason) {
        'invalidJoinToken' =>
          'Invalid or expired join code. Scan the host QR again.',
        'lobbyFull' =>
          'This lobby is full (6 players max). Wait for a slot or start a new game.',
        _ =>
          'Protocol version mismatch. Required: ${message.payload['requiredVersion']}',
      };
      _connectionController.add(BleConnectionEvent(
        playerId: _hostUri ?? '',
        status: BleConnectionStatus.rejected,
        errorMessage: messageText,
      ));
      return;
    }

    if (message.type == BleMessageType.sessionPing) return;

    if (message.type == BleMessageType.hello) {
      // Host acknowledged → mark ready, notify UI, then announce lobby join.
      _ready = true;
      _startKeepAlive();
      _connectionController.add(BleConnectionEvent(
        playerId: _hostUri ?? '',
        status: BleConnectionStatus.connected,
      ));
      _sendRaw(BleMessage(
        type: BleMessageType.lobbyPlayerJoined,
        payload: {
          'pid': localPlayerId,
          'username': localUsername,
        },
        seqNum: _nextSeq(),
      ));
      return;
    }

    _messageController.add(message);
  }

  void _onDone() {
    _ready = false;
    _connectionController.add(BleConnectionEvent(
      playerId: _hostUri ?? '',
      status: BleConnectionStatus.disconnected,
    ));
  }

  void _onError(Object error) {
    _ready = false;
    _connectionController.add(BleConnectionEvent(
      playerId: _hostUri ?? '',
      status: BleConnectionStatus.error,
      errorMessage: error.toString(),
    ));
  }

  // ── Sending ───────────────────────────────────────────────────────────────

  @override
  Future<void> send(
    BleMessage message, {
    String? targetPlayerId,
    String? excludePlayerId,
  }) async {
    _sendRaw(message);
  }

  void _sendRaw(BleMessage message) {
    try {
      _channel?.sink.add(jsonEncode(message.toJson()));
    } catch (_) {}
  }

  int _nextSeq() => _seqNum++;
}
