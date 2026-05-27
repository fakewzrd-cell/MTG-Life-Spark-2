import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_providers.dart';
import '../game/lobby_state.dart';
import '../bluetooth/ble_service.dart';
import 'session_join_uri.dart';
import 'ws_client_service.dart';
import 'ws_host_service.dart';
import '../persistence/providers.dart';

/// Which role this device is playing in the current session.
enum SessionRole { none, host, client }

final sessionRoleProvider = StateProvider<SessionRole>((ref) => SessionRole.none);

/// The active network service for the current session (host or client).
/// Null when no game session is active.
final sessionServiceProvider = StateProvider<BleService?>((ref) => null);

/// Creates and starts a host WebSocket server session.
/// Returns false when profile is missing or the socket server could not start.
Future<bool> startHostSession(WidgetRef ref) async {
  final profile = ref.read(profileRepositoryProvider).getProfile();
  if (profile == null) return false;

  final existing = ref.read(sessionServiceProvider);
  if (existing != null) {
    await existing.dispose();
    ref.read(sessionServiceProvider.notifier).state = null;
    ref.read(sessionRoleProvider.notifier).state = SessionRole.none;
  }

  final host = WsHostService(
    hostPlayerId: profile.username,
    hostUsername: profile.username,
    joinToken: SessionJoinUri.generateToken(),
  );
  await host.initialize();
  if (!host.isReady) return false;

  ref.read(sessionServiceProvider.notifier).state = host;
  ref.read(sessionRoleProvider.notifier).state = SessionRole.host;
  return true;
}

/// Creates a WebSocket client session ready to connect.
/// Call [WsClientService.connectToHost] with the URI from the QR code.
Future<void> startClientSession(WidgetRef ref) async {
  if (ref.read(sessionServiceProvider) is WsClientService) return;

  final existing = ref.read(sessionServiceProvider);
  if (existing != null) {
    await existing.dispose();
    ref.read(sessionServiceProvider.notifier).state = null;
    ref.read(sessionRoleProvider.notifier).state = SessionRole.none;
  }

  final profile = ref.read(profileRepositoryProvider).getProfile();
  if (profile == null) return;

  final client = WsClientService(
    localPlayerId: profile.username,
    localUsername: profile.username,
  );
  await client.initialize();

  ref.read(sessionServiceProvider.notifier).state = client;
  ref.read(sessionRoleProvider.notifier).state = SessionRole.client;
}

/// Tears down the network session and clears in-memory game/lobby state.
Future<void> endSession(WidgetRef ref) async {
  final service = ref.read(sessionServiceProvider);
  await service?.dispose();
  ref.read(sessionServiceProvider.notifier).state = null;
  ref.read(sessionRoleProvider.notifier).state = SessionRole.none;
  ref.read(gameProvider.notifier).reset();
  ref.read(lobbyProvider.notifier).reset();
}

/// Alias for leaving an active game or lobby (same as [endSession]).
Future<void> quitActiveGame(WidgetRef ref) => endSession(ref);
