/// Official constructed / multiplayer formats for lobby and match configuration.
enum GameFormat {
  standard,
  pioneer,
  modern,
  legacy,
  vintage,
  commander,
}

extension GameFormatDetails on GameFormat {
  String get displayName => switch (this) {
    GameFormat.standard => 'Standard',
    GameFormat.pioneer => 'Pioneer',
    GameFormat.modern => 'Modern',
    GameFormat.legacy => 'Legacy',
    GameFormat.vintage => 'Vintage',
    GameFormat.commander => 'Commander',
  };

  int get defaultStartingLife => switch (this) {
    GameFormat.commander => 40,
    _ => 20,
  };

  bool get isCommanderStyle => this == GameFormat.commander;

  static const List<GameFormat> lobbyPickerOrder = [
    GameFormat.standard,
    GameFormat.pioneer,
    GameFormat.modern,
    GameFormat.legacy,
    GameFormat.vintage,
    GameFormat.commander,
  ];

  /// Hive / lobby JSON key, e.g. `standard`, `commander`.
  static GameFormat? fromName(String? name) {
    if (name == null || name.isEmpty) return null;
    for (final f in GameFormat.values) {
      if (f.name == name) return f;
    }
    return null;
  }

  /// Settings UI and legacy strings, e.g. `Standard`, `Commander`.
  static GameFormat? fromDisplayName(String? displayName) {
    if (displayName == null || displayName.isEmpty) return null;
    for (final f in GameFormat.values) {
      if (f.displayName == displayName) return f;
    }
    return fromName(displayName);
  }
}
