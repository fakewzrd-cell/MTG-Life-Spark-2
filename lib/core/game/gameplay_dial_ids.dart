/// Preset modular dial keys (blueprint). Values live in [PlayerGameState.extraDials].
abstract final class GameplayDialIds {
  static const blood = 'blood';
  static const clue = 'clue';
  static const map = 'map';
  static const treasure = 'treasure';
  static const devotion = 'devotion';
  static const creatures = 'creatures';
  static const enchantments = 'enchantments';
  static const artifacts = 'artifacts';
  static const graveyardCreatures = 'gy_creatures';
  static const exile = 'exile';

  static const List<String> presets = [
    blood,
    clue,
    map,
    treasure,
    devotion,
    creatures,
    enchantments,
    artifacts,
    graveyardCreatures,
    exile,
  ];
}
