/// Central reference for game-related icon assets.
class AppIcons {
  AppIcons._();

  // ── Game counters (raster silhouettes — tint via [GameIcon] color) ──────
  static const String poison = 'assets/icons/Poison.png';
  static const String energy = 'assets/icons/Energy.png';
  static const String experience = 'assets/icons/Experience.png';
  static const String radiation = 'assets/icons/Radiation.svg';
  /// Treasure: raster only until a Treasure.svg is added to assets/icons.
  static const String treasure = 'assets/icons/Treasure.png';

  // ── Table politics (overview) — raster silhouettes, tint via [GameIcon] ───
  static const String monarch = 'assets/icons/Monarch.png';
  static const String initiative = 'assets/icons/Initiative.png';
  static const String day = 'assets/icons/Day.png';
  static const String night = 'assets/icons/Night.png';

  // ── Variant modes ────────────────────────────────────────────────────────
  /// Commander damage (status bar — damage taken toward 21).
  static const String commanderDamage = 'assets/icons/CommanderDamage.svg';

  /// Bounty variant mode
  static const String bounty = 'assets/icons/Bounty.svg';

  /// Fanned cards — Play tab (in-game) and Decks tab (shell nav).
  static const String playTabCards = 'assets/icons/game_play_tab.png';

  /// Profile hero banner when no custom banner is chosen.
  static const String defaultProfileBanner =
      'assets/images/default_profile_banner.png';

  /// Default profile picture silhouette (tinted with the active accent colour).
  static const String defaultProfileAvatar =
      'assets/images/default_profile_avatar.png';

  /// Launch / bootstrap splash (lightning + speed lines).
  static const String splashLogo = 'assets/images/splash_logo.svg';

  /// Game lobby — host card background (dungeon party silhouettes).
  static const String lobbyHostParty = 'assets/images/lobby_host_party.png';

  /// Game lobby — join card background (arcane portal).
  static const String lobbyJoinPortal = 'assets/images/lobby_join_portal.png';

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
