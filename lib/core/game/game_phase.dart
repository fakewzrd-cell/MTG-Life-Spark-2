/// Player-facing turn steps for the Play tab (simplified from full MTG rules).
enum GamePhase {
  untap,
  draw,
  preCombatMain,
  combat,
  postCombatMain;

  /// Phases shown in the picker and stepped with Next / Back.
  static const List<GamePhase> navigationOrder = [
    GamePhase.untap,
    GamePhase.draw,
    GamePhase.preCombatMain,
    GamePhase.combat,
    GamePhase.postCombatMain,
  ];

  /// Maps legacy 12-step phase names from older clients / saved state.
  static GamePhase normalize(String? name) {
    if (name == null || name.isEmpty) return GamePhase.untap;
    for (final phase in GamePhase.values) {
      if (phase.name == name) return phase;
    }
    return switch (name) {
      'upkeep' => GamePhase.draw,
      'beginningOfCombat' ||
      'declareAttackers' ||
      'declareBlockers' ||
      'combatDamage' ||
      'endOfCombat' =>
        GamePhase.combat,
      'endStep' || 'cleanup' => GamePhase.postCombatMain,
      _ => GamePhase.untap,
    };
  }
}

extension GamePhaseX on GamePhase {
  String get displayName => switch (this) {
        GamePhase.untap => 'Untap',
        GamePhase.draw => 'Draw',
        GamePhase.preCombatMain => 'Main 1',
        GamePhase.combat => 'Combat',
        GamePhase.postCombatMain => 'Main 2',
      };

  String get shortName => switch (this) {
        GamePhase.untap => 'Untap',
        GamePhase.draw => 'Draw',
        GamePhase.preCombatMain => 'M1',
        GamePhase.combat => 'Combat',
        GamePhase.postCombatMain => 'M2',
      };

  String get streamlinedDisplayName => displayName;

  String get streamlinedShortLabel => switch (this) {
        GamePhase.untap => 'Untap',
        GamePhase.draw => 'Draw',
        GamePhase.preCombatMain => 'Main',
        GamePhase.combat => 'Combat',
        GamePhase.postCombatMain => 'Main 2',
      };

  bool get isCombatPhase => this == GamePhase.combat;

  bool get isMainPhase =>
      this == GamePhase.preCombatMain || this == GamePhase.postCombatMain;

  bool get isFinalPhase => this == GamePhase.postCombatMain;

  GamePhase get next {
    final i = GamePhase.navigationOrder.indexOf(this);
    if (i < 0 || i >= GamePhase.navigationOrder.length - 1) {
      return GamePhase.navigationOrder.last;
    }
    return GamePhase.navigationOrder[i + 1];
  }

  GamePhase get previous {
    final i = GamePhase.navigationOrder.indexOf(this);
    if (i <= 0) return GamePhase.navigationOrder.first;
    return GamePhase.navigationOrder[i - 1];
  }

  int get stepNumber => GamePhase.navigationOrder.indexOf(this) + 1;
}
