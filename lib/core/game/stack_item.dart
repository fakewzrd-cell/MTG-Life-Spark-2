/// Lifecycle of an entry on the stack tracker.
enum StackItemStatus {
  active,
  resolved,
  countered,
  /// Rules counter — spell/ability leaves the stack (illegal or missing target).
  fizzled,
}

/// One spell or ability on the stack (optionally nested via [parentId]).
class StackItem {
  final String id;
  final String playerId;
  /// Canonical card name from Scryfall when picked via search.
  final String name;
  final String? parentId;
  final StackItemStatus status;
  final int createdAt;
  /// Scryfall oracle text (rules) when the card was added.
  final String? oracleText;
  final String? manaCost;
  final String? imageUrl;
  /// Scryfall type line, e.g. `Instant` or `Artifact — Equipment`.
  final String? typeLine;

  const StackItem({
    required this.id,
    required this.playerId,
    required this.name,
    this.parentId,
    this.status = StackItemStatus.active,
    required this.createdAt,
    this.oracleText,
    this.manaCost,
    this.imageUrl,
    this.typeLine,
  });

  bool get hasScryfallData =>
      (oracleText != null && oracleText!.isNotEmpty) ||
      (manaCost != null && manaCost!.isNotEmpty) ||
      (typeLine != null && typeLine!.isNotEmpty);

  /// Primary type for compact UI (segment before `—`).
  String? get typeLabel {
    final line = typeLine?.trim();
    if (line == null || line.isEmpty) return null;
    final dash = line.indexOf('—');
    if (dash < 0) return line;
    return line.substring(0, dash).trim();
  }

  bool get isActive => status == StackItemStatus.active;

  /// Stays visible on the stack tab (green when resolved, amber when fizzled).
  bool get showsOnStack =>
      status == StackItemStatus.active ||
      status == StackItemStatus.fizzled ||
      status == StackItemStatus.resolved;

  StackItem copyWith({
    String? name,
    StackItemStatus? status,
    String? oracleText,
    String? manaCost,
    String? imageUrl,
    String? typeLine,
  }) {
    return StackItem(
      id: id,
      playerId: playerId,
      name: name ?? this.name,
      parentId: parentId,
      status: status ?? this.status,
      createdAt: createdAt,
      oracleText: oracleText ?? this.oracleText,
      manaCost: manaCost ?? this.manaCost,
      imageUrl: imageUrl ?? this.imageUrl,
      typeLine: typeLine ?? this.typeLine,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'name': name,
        'parentId': parentId,
        'status': status.name,
        'createdAt': createdAt,
        if (oracleText != null) 'oracleText': oracleText,
        if (manaCost != null) 'manaCost': manaCost,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (typeLine != null) 'typeLine': typeLine,
      };

  factory StackItem.fromJson(Map<String, dynamic> json) => StackItem(
        id: json['id'] as String,
        playerId: json['playerId'] as String,
        name: json['name'] as String,
        parentId: json['parentId'] as String?,
        status: StackItemStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => StackItemStatus.active,
        ),
        createdAt: (json['createdAt'] as num).toInt(),
        oracleText: json['oracleText'] as String?,
        manaCost: json['manaCost'] as String?,
        imageUrl: json['imageUrl'] as String?,
        typeLine: json['typeLine'] as String?,
      );
}

/// How the stack tab orders / groups visible items.
enum StackSortMode {
  /// Last in, first out — classic stack (newest on top).
  stackOrder,

  /// Group by controller in Active Player, then Non-Active Player turn order.
  apnap,
}
