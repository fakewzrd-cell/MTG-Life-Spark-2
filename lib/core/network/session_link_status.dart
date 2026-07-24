import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local multiplayer link health (Wi‑Fi WebSocket).
enum SessionLinkStatus {
  /// Socket ready (or no active session).
  connected,

  /// Brief drop / app resume — auto-reconnect in progress.
  reconnecting,

  /// Grace period expired; table cannot continue on this device.
  lost,
}

/// How long we wait for a peer (or the host) to come back before treating
/// the drop as a real leave. Covers Texts / app-switch on modern Android.
const Duration kSessionReconnectGrace = Duration(seconds: 120);

final sessionLinkStatusProvider =
    StateProvider<SessionLinkStatus>((ref) => SessionLinkStatus.connected);
