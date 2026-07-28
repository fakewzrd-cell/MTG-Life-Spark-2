import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fired when a remote player leaves/disconnects mid-match so the UI can toast
/// and (when the table ends) land on the feedback screen.
class PlayerLeftUiEvent {
  const PlayerLeftUiEvent({
    required this.username,
    required this.gameEnded,
  });

  final String username;
  final bool gameEnded;
}

final playerLeftUiEventProvider =
    StateProvider<PlayerLeftUiEvent?>((ref) => null);

/// A seat whose socket dropped; host may wait or remove after grace.
class PeerLinkIssue {
  const PeerLinkIssue({
    required this.playerId,
    required this.username,
    required this.awaitingHostDecision,
  });

  final String playerId;
  final String username;

  /// True after reconnect grace — host should Keep waiting / Remove.
  final bool awaitingHostDecision;
}

/// playerId → soft-drop status (cleared when they reconnect or are removed).
final peerLinkIssuesProvider =
    StateProvider<Map<String, PeerLinkIssue>>((ref) => {});

/// Bumped when a peer's grace expires so the host UI can prompt once.
final peerReconnectDecisionTickProvider = StateProvider<int>((ref) => 0);
