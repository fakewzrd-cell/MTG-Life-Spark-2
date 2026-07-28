/// Bumped on any breaking change to the message format.
/// Host rejects clients on a mismatch with a REJECT message.
const kBleProtocolVersion = '1.0';

enum BleMessageType {
  // Handshake
  hello,
  reject,
  sessionPing,

  // Game lifecycle
  gameStart,
  gameEnd,
  stateSnapshot,

  // Game state
  stateDelta,
  commanderDamage,
  commanderCastFromZone,
  undoAction,
  proliferate,

  // Turn & phase
  phaseAdvance,
  turnEnd,
  priorityHold,
  priorityRelease,
  timeoutStart,
  timeoutEnd,

  // Political
  alliancePropose,
  allianceRespond,
  allianceBreak,
  allianceReveal,
  allianceDeclined,
  monarchChange,
  initiativeChange,
  dayNightChange,

  // Lobby
  lobbyRoll,
  lobbyPlayerJoined,
  lobbyPlayerReady,

  // First player roll (at game start)
  firstPlayerRollSubmit,
  firstPlayerTurnOrder,

  /// Host mid-game / table seat turn-order edit (preserves whose turn).
  turnOrderUpdate,

  // Player events
  concede,
  playerEliminated,
  playerDisconnected,

  /// Soft drop / resume signal. Payload: `pid`, optional `done: true` when back.
  playerReconnecting,
  reconnectRequest,

  // Rematch (legacy wire types — unused in app UI; kept for older clients)
  rematchPropose,
  rematchRespond,
  rematchConfirm,

  // Teams
  teamAssign,

  // Variant modes (Planechase, Archenemy, Bounty)
  variantStateUpdate,

  // Stack tracker
  stackUpdate,

  /// End-game likes / Star of the game ballot (LAN sync).
  matchFeedback,
}
