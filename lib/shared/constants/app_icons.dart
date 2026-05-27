/// Central reference for game-related icon assets.
class AppIcons {
  AppIcons._();

  // ── Game counters (SVG — tint via [GameIcon] color) ─────────────────────
  static const String poison = 'assets/icons/Poison.svg';
  static const String energy = 'assets/icons/Energy.svg';
  static const String experience = 'assets/icons/Experience.svg';
  static const String radiation = 'assets/icons/Radiation.svg';
  /// Treasure: raster only until a Treasure.svg is added to assets/icons.
  static const String treasure = 'assets/icons/Treasure.png';

  // ── Variant modes ────────────────────────────────────────────────────────
  /// Bounty variant mode
  static const String bounty = 'assets/icons/Bounty.svg';

  /// Fanned cards — Play tab (in-game) and Decks tab (shell nav).
  static const String playTabCards = 'assets/icons/game_play_tab.png';

  /// Profile hero banner when no custom banner is chosen.
  static const String defaultProfileBanner =
      'assets/images/default_profile_banner.png';

  // ── Mana symbols (WUBRG) ────────────────────────────────────────────────
  static const String manaW = 'assets/icons/W.svg';
  static const String manaU = 'assets/icons/U.svg';
  static const String manaB = 'assets/icons/B.svg';
  static const String manaR = 'assets/icons/R.svg';
  static const String manaG = 'assets/icons/G.svg';

  /// Returns mana icon path for a single character (W, U, B, R, G).
  static String? manaFor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'W':
        return manaW;
      case 'U':
        return manaU;
      case 'B':
        return manaB;
      case 'R':
        return manaR;
      case 'G':
        return manaG;
      default:
        return null;
    }
  }
}
