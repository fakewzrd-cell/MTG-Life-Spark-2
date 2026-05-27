/// Bumped on any breaking change to the message format.
/// Host rejects clients on a mismatch with a REJECT message.
const kBleProtocolVersion = '1.0';

enum BleMessageType {
  // Handshake
  hello,
  reject,

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

  // Player events
  concede,
  playerEliminated,
  playerDisconnected,
  reconnectRequest,

  // Rematch
  rematchPropose,
  rematchRespond,
  rematchConfirm,

  // Teams
  teamAssign,

  // Variant modes (Planechase, Archenemy, Bounty)
  variantStateUpdate,

  // Stack tracker
  stackUpdate,
}
