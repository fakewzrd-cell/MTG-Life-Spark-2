import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'session_link_status.dart';
import 'session_providers.dart';
import 'ws_client_service.dart';

/// Keeps multiplayer sessions alive across brief app backgrounding.
///
/// - Enables wake lock while a session is active (reduces aggressive suspend).
/// - Marks [sessionLinkStatusProvider] reconnecting while recovering.
/// - Reconnects WebSocket clients when the OS drops the socket on resume.
class SessionConnectionGuard extends ConsumerStatefulWidget {
  const SessionConnectionGuard({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SessionConnectionGuard> createState() =>
      _SessionConnectionGuardState();
}

class _SessionConnectionGuardState extends ConsumerState<SessionConnectionGuard>
    with WidgetsBindingObserver {
  Timer? _resumeRetryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(sessionRoleProvider, (_, _) => _syncWakeLock());
    ref.listenManual(sessionServiceProvider, (_, _) => _syncWakeLock());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWakeLock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeRetryTimer?.cancel();
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_onResumed());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        // Keep wake lock; socket may still drop — resume path recovers.
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _onResumed() async {
    _syncWakeLock();
    final role = ref.read(sessionRoleProvider);
    if (role == SessionRole.none) return;

    final service = ref.read(sessionServiceProvider);
    if (service is! WsClientService) {
      // Host: server stays in-process; clients reconnect to us.
      ref.read(sessionLinkStatusProvider.notifier).state =
          SessionLinkStatus.connected;
      return;
    }

    if (service.isReady) {
      ref.read(sessionLinkStatusProvider.notifier).state =
          SessionLinkStatus.connected;
      return;
    }

    ref.read(sessionLinkStatusProvider.notifier).state =
        SessionLinkStatus.reconnecting;

    final ok = await service.reconnectIfDisconnected();
    if (!mounted) return;
    if (ok) {
      _resumeRetryTimer?.cancel();
      ref.read(sessionLinkStatusProvider.notifier).state =
          SessionLinkStatus.connected;
      return;
    }

    // Retry a few times after resume (Wi‑Fi / host may need a moment).
    _resumeRetryTimer?.cancel();
    var attempts = 0;
    _resumeRetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      attempts++;
      unawaited(() async {
        final again = await service.reconnectIfDisconnected();
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (again || service.isReady) {
          timer.cancel();
          ref.read(sessionLinkStatusProvider.notifier).state =
              SessionLinkStatus.connected;
          return;
        }
        if (attempts >= 10) {
          timer.cancel();
        }
      }());
    });
  }

  void _syncWakeLock() {
    final active = ref.read(sessionRoleProvider) != SessionRole.none;
    if (active) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
      ref.read(sessionLinkStatusProvider.notifier).state =
          SessionLinkStatus.connected;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
