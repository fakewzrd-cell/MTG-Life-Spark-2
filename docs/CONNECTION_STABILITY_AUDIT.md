# Connection stability audit (post-fix)

**Date:** 2026-07-23  
**Package:** `app.lifespark.mtg`

## Root cause (confirmed)

Leaving Life Spark for Texts/another app often kills the local `ws://` socket. Previously:

1. **Host** treated any client socket close as a permanent leave → eliminated the player / removed from lobby.
2. **Client** treated its own socket close as “host lost” → ended the match immediately (`_handleHostSessionLost`).

That matched the report: switching apps looked like the table connection “turned off.”

## Fix implemented

| Layer | Behavior |
|-------|----------|
| `WsHostService` | Soft-drop: **120s reconnect grace** before `disconnected` / `playerDisconnected`. `reconnectRequest` rebinds the player without lobby re-join. |
| `WsClientService` | After first handshake, resume uses `reconnectRequest`. Disconnect events suppressed while `_reconnecting`. |
| `GameStateNotifier` | Client enters **reconnecting** for 120s and retries; only then ends the match. |
| `SessionConnectionGuard` | Wake lock + resume reconnect with retries. |
| UI | Banner: **Reconnecting to table…** |

## Audit checklist

### Code review

- [x] Host no longer broadcasts leave on the first socket close
- [x] Client no longer calls `_handleHostSessionLost` on the first drop
- [x] Mid-match resume does not require QR again (`lastHostUri` + token retained)
- [x] Reconnect path does not spam false disconnects during socket recycle
- [x] Intentional leave / dispose still clears session (`intentional` disconnect)

### Device table test (required before trusting in a real pod)

1. Host starts a 2+ player game on Wi‑Fi.
2. Joiner opens **Texts** for ~30–60s, returns to Life Spark.
3. Expect: brief “Reconnecting…”, then same match — **not** eliminated, **no** QR rescan.
4. Host opens Texts ~30–60s, returns.
5. Expect: joiners reconnect within grace; match continues.
6. Stay away **>120s** without returning: leave/end behavior is allowed (grace expired).

### Limits (honest)

- Extreme battery savers / OEM killers can still suspend the host server; grace + resume covers normal texting/app switch, not “kill app forever.”
- No persistent cloud relay — LAN only.

## Verdict

**Code path for the reported bug is fixed and reviewed.**  
**100% table confidence requires the device checklist above on real phones** (host + joiner). Run that once before the next Play upload.
