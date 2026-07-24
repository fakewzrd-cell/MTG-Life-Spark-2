import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../debug/app_log.dart';
import '../bluetooth/ble_message.dart';
import '../bluetooth/ble_protocol.dart';
import '../bluetooth/ble_service.dart';
import 'session_link_status.dart';

/// WebSocket-based host service.
///
/// Runs a plain [HttpServer] on a random port and upgrades incoming HTTP
/// connections to WebSocket. Each connected socket maps to one game client.
///
/// Message format: UTF-8 JSON strings (BleMessage.toJson / fromJson).
/// No chunking needed — WiFi MTU is far larger than any game message.
class WsHostService implements BleService {
  final _messageController = StreamController<BleMessage>.broadcast();
  final _connectionController = StreamController<BleConnectionEvent>.broadcast();

  /// clientKey (remote address string) → verified playerId (after handshake)
  final Map<String, String> _verified = {};

  /// clientKey → open WebSocket
  final Map<String, WebSocket> _sockets = {};

  /// playerId → grace timer before announcing a real disconnect.
  final Map<String, Timer> _reconnectGrace = {};

  HttpServer? _server;
  int _seqNum = 0;
  int _nextClientId = 0;
  bool _ready = false;

  final String hostPlayerId;
  final String hostUsername;
  final String joinToken;

  WsHostService({
    required this.hostPlayerId,
    required this.hostUsername,
    required this.joinToken,
  });

  /// Port the server is bound to; available after [initialize].
  int get port => _server?.port ?? 0;

  @override
  Stream<BleMessage> get messageStream => _messageController.stream;

  @override
  Stream<BleConnectionEvent> get connectionStream =>
      _connectionController.stream;

  @override
  List<String> get connectedPlayerIds => _verified.values.toList();

  @override
  bool get isReady => _ready;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> initialize() async {
    try {
      // Bind to any available port on all IPv4 interfaces
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      _ready = true;
      _server!.transform(WebSocketTransformer()).listen(
        _onNewSocket,
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (e) {
      _connectionController.add(BleConnectionEvent(
        playerId: '',
        status: BleConnectionStatus.error,
        errorMessage: 'Failed to start WebSocket server: $e',
      ));
    }
  }

  @override
  Future<void> dispose() async {
    for (final t in _reconnectGrace.values) {
      t.cancel();
    }
    _reconnectGrace.clear();
    await _server?.close(force: true);
    _server = null;
    final openSockets = List<WebSocket>.from(_sockets.values);
    _sockets.clear();
    _verified.clear();
    for (final ws in openSockets) {
      await ws.close();
    }
    await _messageController.close();
    await _connectionController.close();
    _ready = false;
  }

  // ── Incoming connections ──────────────────────────────────────────────────

  void _onNewSocket(WebSocket ws) {
    final key = '${_nextClientId++}';
    _sockets[key] = ws;

    ws.listen(
      (data) => _onData(data, key),
      onDone: () => _onDisconnect(key),
      onError: (_) => _onDisconnect(key),
      cancelOnError: false,
    );
  }

  void _onData(dynamic data, String key) {
    if (data is! String) return;
    BleMessage message;
    try {
      message = BleMessage.fromJson(
        jsonDecode(data) as Map<String, dynamic>,
      );
    } catch (e, st) {
      appLog('WsHostService: invalid message JSON', error: e, stackTrace: st);
      return;
    }
    _handleClientMessage(message, key);
  }

  void _handleClientMessage(BleMessage message, String clientKey) {
    if (message.type == BleMessageType.sessionPing) {
      _sendToKey(
        BleMessage(
          type: BleMessageType.sessionPing,
          payload: const {},
          seqNum: _nextSeq(),
        ),
        clientKey,
      );
      return;
    }

    if (message.type == BleMessageType.hello) {
      final version = message.payload['version'] as String?;
      if (version != kBleProtocolVersion) {
        _sendToKey(
          BleMessage.reject(_nextSeq(), reason: 'versionMismatch'),
          clientKey,
        );
        _sockets[clientKey]?.close();
        _sockets.remove(clientKey);
        return;
      }
      final token = message.payload['token'] as String?;
      if (token == null || token != joinToken) {
        _sendToKey(
          BleMessage.reject(_nextSeq(), reason: 'invalidJoinToken'),
          clientKey,
        );
        _sockets[clientKey]?.close();
        _sockets.remove(clientKey);
        return;
      }
      _sendToKey(BleMessage.hello(_nextSeq()), clientKey);
      return;
    }

    if (message.type == BleMessageType.lobbyPlayerJoined) {
      final playerId =
          message.payload['pid'] as String? ?? clientKey;
      _bindVerifiedClient(clientKey, playerId);
      _messageController.add(message);
      return;
    }

    if (message.type == BleMessageType.reconnectRequest) {
      final playerId = message.payload['pid'] as String? ?? '';
      if (playerId.isEmpty) return;
      _bindVerifiedClient(clientKey, playerId);
      // Do not forward as lobby join — game/lobby layers just need the socket.
      return;
    }

    if (message.type == BleMessageType.lobbyPlayerReady) {
      final playerId = message.payload['pid'] as String? ?? '';
      final verifiedId = _verified[clientKey];
      if (verifiedId != null && verifiedId != playerId) {
        return;
      }
      _messageController.add(message);
      return;
    }

    final verifiedId = _verified[clientKey];
    if (verifiedId == null) {
      return;
    }
    if (!_actorMatchesVerifiedPlayer(message, verifiedId)) {
      return;
    }

    _messageController.add(message);
  }

  bool _actorMatchesVerifiedPlayer(BleMessage message, String verifiedId) {
    final origin = message.originPlayerId;
    if (origin != null) return origin == verifiedId;

    final pid = message.payload['pid'] as String?;
    if (pid != null &&
        (message.type == BleMessageType.stateDelta ||
            message.type == BleMessageType.undoAction ||
            message.type == BleMessageType.playerEliminated ||
            message.type == BleMessageType.commanderCastFromZone ||
            message.type == BleMessageType.priorityHold ||
            message.type == BleMessageType.firstPlayerRollSubmit)) {
      return pid == verifiedId;
    }

    final from = message.payload['from'] as String?;
    if (from != null &&
        (message.type == BleMessageType.commanderDamage ||
            message.type == BleMessageType.allianceDeclined)) {
      return from == verifiedId;
    }

    // Messages without an actor field must include origin (e.g. proliferate).
    return false;
  }

  void _bindVerifiedClient(String clientKey, String playerId) {
    // Drop any older socket still mapped to this player (stale after resume).
    final staleKeys = _verified.entries
        .where((e) => e.value == playerId && e.key != clientKey)
        .map((e) => e.key)
        .toList();
    for (final key in staleKeys) {
      _verified.remove(key);
      final stale = _sockets.remove(key);
      try {
        stale?.close();
      } catch (e) {
        appLog('WsHostService stale socket close failed', error: e);
      }
    }

    _reconnectGrace.remove(playerId)?.cancel();
    _verified[clientKey] = playerId;
    _connectionController.add(BleConnectionEvent(
      playerId: playerId,
      status: BleConnectionStatus.connected,
    ));
  }

  void _onDisconnect(String clientKey) {
    _sockets.remove(clientKey);
    final playerId = _verified.remove(clientKey);
    if (playerId == null) return;

    // Already waiting on this player — keep the existing grace window.
    if (_reconnectGrace.containsKey(playerId)) return;

    // Soft drop: wait for Texts/app-switch resume before announcing leave.
    _reconnectGrace[playerId] = Timer(kSessionReconnectGrace, () {
      _reconnectGrace.remove(playerId);
      // Player already re-bound on another socket.
      if (_verified.containsValue(playerId)) return;
      _connectionController.add(BleConnectionEvent(
        playerId: playerId,
        status: BleConnectionStatus.disconnected,
      ));
      _broadcastExcept(
        BleMessage(
          type: BleMessageType.playerDisconnected,
          payload: {'pid': playerId},
          seqNum: _nextSeq(),
        ),
        excludeKey: clientKey,
      );
    });
  }

  // ── Sending ───────────────────────────────────────────────────────────────

  @override
  Future<void> send(
    BleMessage message, {
    String? targetPlayerId,
    String? excludePlayerId,
  }) async {
    final encoded = jsonEncode(message.toJson());
    if (targetPlayerId != null) {
      final key = _keyFor(targetPlayerId);
      if (key != null) _trySend(_sockets[key]!, encoded);
      return;
    }
    for (final entry in _sockets.entries) {
      if (excludePlayerId != null &&
          _verified[entry.key] == excludePlayerId) {
        continue;
      }
      _trySend(entry.value, encoded);
    }
  }

  void _sendToKey(BleMessage message, String clientKey) {
    final ws = _sockets[clientKey];
    if (ws != null) _trySend(ws, jsonEncode(message.toJson()));
  }

  void _broadcastExcept(BleMessage message,
      {required String excludeKey}) {
    final encoded = jsonEncode(message.toJson());
    for (final entry in _sockets.entries) {
      if (entry.key != excludeKey) _trySend(entry.value, encoded);
    }
  }

  void _trySend(WebSocket ws, String data) {
    try {
      if (ws.readyState == WebSocket.open) ws.add(data);
    } catch (e) {
      appLog('WsHostService._trySend failed', error: e);
    }
  }

  String? _keyFor(String playerId) {
    for (final entry in _verified.entries) {
      if (entry.value == playerId) return entry.key;
    }
    return null;
  }

  int _nextSeq() => _seqNum++;
}
