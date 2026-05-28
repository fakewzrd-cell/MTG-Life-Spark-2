/// Shared gameplay limits used across [GameStateNotifier] and UI.
abstract final class GameConstants {
  /// Maximum players allowed in a lobby or game session.
  static const maxLobbyPlayers = 6;

  static const sessionLogCap = 400;
  static const lifeChangeLogCap = 10;
  static const counterMax = 9999;
  static const commanderDamageKo = 21;
  static const poisonKo = 10;
}
