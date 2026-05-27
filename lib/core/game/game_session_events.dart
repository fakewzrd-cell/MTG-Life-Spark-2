import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped when the host proposes a rematch so clients on the end-game screen
/// can navigate back to the lobby.
final rematchProposedProvider = StateProvider<int>((ref) => 0);
