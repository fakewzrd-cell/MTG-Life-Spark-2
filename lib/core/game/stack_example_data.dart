import 'stack_item.dart';
import 'player_game_state.dart';
import '../../shared/theme/app_theme.dart';

/// Demo pod IDs when the lobby has fewer than four players.
const examplePlayer2Id = 'example-p2';
const examplePlayer3Id = 'example-p3';
const examplePlayer4Id = 'example-p4';

/// Ensures four [PlayerGameState] entries for the example pod (keeps existing players).
List<PlayerGameState> mergeExamplePodPlayers({
  required List<PlayerGameState> current,
  required String localPlayerId,
  required int startingLife,
}) {
  final result = List<PlayerGameState>.from(current);

  void addDemo(String id, String username, int colorIndex) {
    if (result.any((p) => p.playerId == id)) return;
    result.add(
      PlayerGameState(
        playerId: id,
        username: username,
        playerColor: AppTheme.playerColor(colorIndex),
        life: startingLife,
        commanderName: 'Demo deck',
      ),
    );
  }

  addDemo(examplePlayer2Id, 'Jordan', 1);
  addDemo(examplePlayer3Id, 'Sam', 2);
  addDemo(examplePlayer4Id, 'Riley', 3);

  return result;
}

/// Turn order for the demo: you (local) are active player, then clockwise.
List<String> exampleTurnOrder(String localPlayerId) => [
      localPlayerId,
      examplePlayer2Id,
      examplePlayer3Id,
      examplePlayer4Id,
    ];

/// Simulated four-player stack (LIFO + nested responses + Scryfall fields).
///
/// Story: Riley casts [Cyclonic Rift]. You [Swan Song], Jordan [Force of Negation],
/// Sam [Dispel] — Dispel resolves first.
List<StackItem> buildExampleStackItems({
  required List<String> playerIds,
  required String localPlayerId,
}) {
  assert(playerIds.length >= 4);
  final pYou = localPlayerId;
  final p2 = playerIds[1];
  final p3 = playerIds[2];
  final p4 = playerIds[3];

  final base = DateTime.now().millisecondsSinceEpoch;

  return [
    StackItem(
      id: 'example-4p-rift',
      playerId: p4,
      name: 'Cyclonic Rift',
      createdAt: base,
      manaCost: '{3}{U}',
      typeLine: 'Instant',
      oracleText:
          'Return all nonland permanents you don\'t control to their owners\' hands. '
          'Overload {6}{U}{U}',
    ),
    StackItem(
      id: 'example-4p-swan',
      playerId: pYou,
      name: 'Swan Song',
      parentId: 'example-4p-rift',
      createdAt: base + 1,
      manaCost: '{U}',
      typeLine: 'Instant',
      oracleText: 'Counter target enchantment, instant, or sorcery spell. '
          'Its controller creates a 2/2 blue Bird creature token with flying.',
    ),
    StackItem(
      id: 'example-4p-fon',
      playerId: p2,
      name: 'Force of Negation',
      parentId: 'example-4p-swan',
      createdAt: base + 2,
      manaCost: '{1}{U}{U}',
      typeLine: 'Instant',
      oracleText:
          'Counter target noncreature spell. If its converted mana cost is 4 or greater, '
          'counter that spell instead.',
    ),
    StackItem(
      id: 'example-4p-dispel',
      playerId: p3,
      name: 'Dispel',
      parentId: 'example-4p-fon',
      createdAt: base + 3,
      manaCost: '{U}',
      typeLine: 'Instant',
      oracleText: 'Counter target instant spell.',
    ),
    StackItem(
      id: 'example-4p-tutor',
      playerId: p2,
      name: 'Demonic Tutor',
      createdAt: base - 2,
      manaCost: '{1}{B}',
      typeLine: 'Sorcery',
      oracleText:
          'Search your library for a card, put that card into your hand, '
          'then shuffle.',
    ),
    StackItem(
      id: 'example-4p-ring',
      playerId: p4,
      name: 'Sol Ring',
      createdAt: base - 3,
      manaCost: '{1}',
      typeLine: 'Artifact',
      oracleText: '{T}: Add {C}{C}.',
      status: StackItemStatus.resolved,
    ),
  ];
}
