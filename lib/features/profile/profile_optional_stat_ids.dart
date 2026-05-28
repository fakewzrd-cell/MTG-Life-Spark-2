/// Optional player-stats carousel cards the user can add via the "+" tile.
abstract final class ProfileOptionalStatIds {
  ProfileOptionalStatIds._();

  static const mostPlayed = 'mostPlayed';
  static const toughRecord = 'toughRecord';

  /// All optional stat cards available today (extend for future types).
  static const List<String> catalog = [mostPlayed, toughRecord];

  static String title(String id) {
    switch (id) {
      case mostPlayed:
        return 'Most played';
      case toughRecord:
        return 'Tough record';
      default:
        return 'Stat';
    }
  }

  static String description(String id) {
    switch (id) {
      case mostPlayed:
        return 'Commander you have played the most across recorded matches.';
      case toughRecord:
        return 'Deck with the lowest win rate among decks with at least one game.';
      default:
        return '';
    }
  }

  static bool isKnown(String id) => catalog.contains(id);
}
