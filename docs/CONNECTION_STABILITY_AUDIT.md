# Connection stability audit (post-fix)

**Date:** 2026-07-28  
**Package:** `app.lifespark.mtg`

## Root cause (confirmed)

Leaving Life Spark for Texts/another app often kills the local `ws://` socket. Previously:

1. **Host** treated any client socket close as a permanent leave → eliminated the player / removed from lobby.
2. **Client** treated its own socket close as “host lost” → ended the match immediately (`_handleHostSessionLost`).

That matched the report: switching apps looked like the table connection “turned off.”

## Current behavior (2026-07-28)

| Layer | Behavior |
|-------|----------|
| `WsHostService` | Soft-drop: emit `reconnecting` + `playerReconnecting` immediately; **120s grace**; on expiry emit `disconnected` only (no auto `playerDisconnected`). `extendReconnectGrace` / `cancelReconnectGrace` for host choice. Resume rebinds + clears banners (`done: true`). `reconnectRequest` forwarded so game can push snapshot. |
| `WsClientService` | After first handshake, resume uses `reconnectRequest`. Disconnect events suppressed while `_reconnecting`. |
| `GameStateNotifier` | Client: persistent 3s retry + grace → `lost` UI **without ending match**; `retryHostLink()`. Host: track `peerLinkIssues`; grace expiry bumps decision tick; `keepWaitingForPeer` / `removePeerFromTable` (eliminate only on remove). |
| `SessionConnectionGuard` | Wake lock + resume reconnect retries until session ends. |
| UI | Own link: banner + **Try again**. Peers: “X is reconnecting…”. Host after grace: **Keep waiting** / **Remove from table** (title X = keep waiting). |

## Audit checklist (code)

- [x] Host no longer broadcasts leave on the first socket close
- [x] Host no longer auto-eliminates when grace expires
- [x] Client no longer ends the match when grace expires
- [x] Mid-match resume does not require QR again (`lastHostUri` + token retained)
- [x] Reconnect path does not spam false disconnects during socket recycle
- [x] Intentional leave / dispose still clears session (`intentional` disconnect)
- [x] Remove sync uses `playerDisconnected` only (clients get leave UI)
- [x] Stale host dialog cannot remove a peer who already reconnected
- [x] Title close on decision dialog does not remove the player
- [x] Unit coverage: soft-drop, remove, reconnect guard, client message, snapshot on `reconnectRequest`

## Device table test (required before trusting in a real pod)

1. Host starts a 2+ player game on Wi‑Fi.
2. Joiner opens **Texts** for ~30–60s, returns to Life Spark.
3. Expect: brief “Reconnecting…”, then same match — **not** eliminated, **no** QR rescan.
4. Host opens Texts ~30–60s, returns.
5. Expect: joiners reconnect within grace; match continues.
6. Stay away **>120s**: host sees Keep waiting / Remove — not auto-KO.
7. Offline joiner taps **Try again** after a long drop — recovers without leaving the match.

## Limits (honest)

- Extreme battery savers / OEM killers can still suspend the host server; grace + resume covers normal texting/app switch, not “kill app forever.”
- No persistent cloud relay — LAN only.
- If the host never answers Keep waiting / Remove after grace, the seat stays soft-dropped until reconnect or remove.

## Verdict

**Code path for soft reconnect + host decision is implemented, bugfixed, and unit-tested.**  
**100% table confidence still requires the device checklist above on real phones** (host + joiner).
