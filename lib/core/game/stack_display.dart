import 'game_state.dart';
import 'stack_item.dart';

/// One row or group in the stack UI.
class StackDisplayNode {
  final StackItem item;
  final List<StackDisplayNode> responses;
  final int depth;

  const StackDisplayNode({
    required this.item,
    this.responses = const [],
    this.depth = 0,
  });
}

/// APNAP bucket: all active items from one player in creation order.
class StackApnapGroup {
  final String playerId;
  final String username;
  final bool isActivePlayer;
  final int turnOrderPosition;
  final List<StackItem> items;

  const StackApnapGroup({
    required this.playerId,
    required this.username,
    required this.isActivePlayer,
    required this.turnOrderPosition,
    required this.items,
  });
}

abstract final class StackDisplay {
  /// Clockwise turn order starting at the stack APNAP anchor (or active player).
  static List<String> apnapPlayerOrder(GameState game) {
    if (game.turnOrder.isEmpty) return [];
    final n = game.turnOrder.length;
    final anchorId =
        game.stackApnapAnchorPlayerId ?? game.activePlayerId;
    var start = game.turnOrder.indexOf(anchorId);
    if (start < 0) start = game.activePlayerIndex % n;
    return List.generate(n, (i) => game.turnOrder[(start + i) % n]);
  }

  static int turnOrderPosition(GameState game, String playerId) {
    final i = game.turnOrder.indexOf(playerId);
    return i < 0 ? 0 : i + 1;
  }

  /// LIFO resolve order: 1 = resolves next (newest active), 2 = next, etc.
  static Map<String, int> resolveOrderNumbers(List<StackItem> items) {
    final active = items.where((i) => i.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final map = <String, int>{};
    for (var i = 0; i < active.length; i++) {
      map[active[i].id] = i + 1;
    }
    return map;
  }

  /// Newest active item — resolves first (LIFO).
  static StackItem? resolvesNextItem(List<StackItem> items) {
    final active = items.where((i) => i.isActive).toList();
    if (active.isEmpty) return null;
    return active.reduce(
      (a, b) => a.createdAt > b.createdAt ? a : b,
    );
  }

  static StackItem? parentOf(StackItem item, List<StackItem> items) {
    final pid = item.parentId;
    if (pid == null) return null;
    for (final i in items) {
      if (i.id == pid) return i;
    }
    return null;
  }

  /// True when this item targets another stack entry that is no longer active.
  static bool hasInvalidStackTarget(StackItem item, List<StackItem> items) {
    final parent = parentOf(item, items);
    if (parent == null) return item.parentId != null;
    return !parent.isActive;
  }

  /// Parent spell name for nested "in response to" subtitle.
  static String? parentNameFor(StackItem item, List<StackItem> items) {
    final pid = item.parentId;
    if (pid == null) return null;
    for (final i in items) {
      if (i.id == pid) return i.name;
    }
    return null;
  }

  /// Root items in stack order (newest first), active only.
  static List<StackItem> activeRootsNewestFirst(List<StackItem> items) {
    return items
        .where((i) => i.isActive && i.parentId == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// LIFO tree: roots in stack order; each item lists direct responses (oldest first).
  static List<StackDisplayNode> stackOrderTree(
    List<StackItem> items, {
    bool includeInactive = true,
  }) {
    final visible = includeInactive
        ? items
        : items.where((i) => i.showsOnStack).toList();
    final byId = {for (final i in visible) i.id: i};
    final roots = visible
        .where((i) => i.parentId == null || !byId.containsKey(i.parentId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    StackDisplayNode build(StackItem item, int depth) {
      final children = visible
          .where((i) => i.parentId == item.id)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return StackDisplayNode(
        item: item,
        depth: depth,
        responses: [for (final c in children) build(c, depth + 1)],
      );
    }

    return [for (final r in roots) build(r, 0)];
  }

  /// Groups active items by controller in APNAP order.
  static List<StackApnapGroup> apnapGroups(GameState game) {
    final order = apnapPlayerOrder(game);
    final activeItems =
        game.stackItems.where((i) => i.showsOnStack).toList();
    final groups = <StackApnapGroup>[];

    for (final pid in order) {
      final player = game.playerById(pid);
      if (player == null) continue;
      final mine = activeItems
          .where((i) => i.playerId == pid)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      if (mine.isEmpty) continue;
      groups.add(
        StackApnapGroup(
          playerId: pid,
          username: player.username,
          isActivePlayer: pid == game.activePlayerId,
          turnOrderPosition: turnOrderPosition(game, pid),
          items: mine,
        ),
      );
    }

    // Players not in turn order (edge case)
    final known = order.toSet();
    for (final item in activeItems) {
      if (known.contains(item.playerId)) continue;
      final player = game.playerById(item.playerId);
      groups.add(
        StackApnapGroup(
          playerId: item.playerId,
          username: player?.username ?? item.playerId,
          isActivePlayer: false,
          turnOrderPosition: 0,
          items: [item],
        ),
      );
    }
    return groups;
  }
}
