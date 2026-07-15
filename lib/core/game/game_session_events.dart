import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped when the host proposes a rematch so clients on the end-game screen
/// can navigate back to the lobby.
final rematchProposedProvider = StateProvider<int>((ref) => 0);

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
