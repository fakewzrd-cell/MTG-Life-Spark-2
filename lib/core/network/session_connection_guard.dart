import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../game/game_providers.dart';
import 'session_providers.dart';
import 'ws_client_service.dart';

/// Keeps multiplayer sessions alive across brief app backgrounding.
///
/// - Enables wake lock while a session is active (reduces aggressive suspend).
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
    unawaited(WakelockPlus.disable());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onResumed());
    }
  }

  Future<void> _onResumed() async {
    final service = ref.read(sessionServiceProvider);
    if (service is WsClientService) {
      await service.reconnectIfDisconnected();
    }
    // Host HTTP server may have been suspended; clients will reconnect above.
    if (ref.read(gameProvider).players.isNotEmpty) {
      // Game state remains in memory; network layer restores the socket.
    }
  }

  void _syncWakeLock() {
    final active = ref.read(sessionRoleProvider) != SessionRole.none;
    if (active) {
      unawaited(WakelockPlus.enable());
    } else {
      unawaited(WakelockPlus.disable());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
