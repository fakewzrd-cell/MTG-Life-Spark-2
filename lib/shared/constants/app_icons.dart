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

  /// Default profile picture when the player has not chosen card art.
  static const String defaultProfileAvatar =
      'assets/images/default_profile_avatar.png';

  /// Launch / bootstrap splash — Life Spark mark (white on transparent).
  static const String splashLogo = 'assets/images/splash_logo.png';

  /// Brand mark only (white on transparent) — same art as splash.
  static const String lifeSparkLogo = 'assets/images/life_spark_logo.png';

  /// Horizontal wordmark (mark + LIFE SPARK) for app bars / headers.
  static const String logoHorizontal = 'assets/images/logo_horizontal.png';

  /// Vertical wordmark (mark above LIFE SPARK) for splash reveal / setup.
  static const String logoVertical = 'assets/images/logo_vertical.png';
}
