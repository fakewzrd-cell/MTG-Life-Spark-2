# Life Spark — Release audit plan

**App version (current):** `1.0.6+6`  
**Audit date:** 2026-05-30  
**Purpose:** Checklist to double-check before pushing the next version to git (and building/shipping APK).  
**Baseline verified:** `flutter analyze` (0 errors, 3 warnings), `flutter test` (89/89 passed).

Each item includes **verification status** from code review (not every item was reproduced on a device in this audit).

| Status | Meaning |
|--------|---------|
| ✅ Confirmed | Logic/path verified in source |
| ⚠️ Partial | Real issue, narrower trigger or lower impact than first stated |
| 📋 Verify on device | Plausible; confirm manually before fixing |

---

## Pre-push checklist (do this last)

- [ ] Run `flutter analyze` — expect 0 errors (warnings OK to triage)
- [ ] Run `flutter test` — all green
- [ ] Smoke test on **phone** (Wi‑Fi web or APK): lobby join → game → end game → rematch
- [ ] Smoke test **Profile** carousels + **My Decks** at default and **large text** (Settings)
- [ ] Smoke test **non-Commander** game: turn label, phase bar, counter scroll
- [ ] Bump `version:` in `pubspec.yaml` if shipping a new build
- [ ] Commit with message focused on **why** (not file list)
- [ ] Push to remote; tag release if you use tags
- [ ] Build APK if distributing: `flutter build apk --release`

---

## Already shipped in current working tree (no audit item — document for release notes)

These were done in recent UI work; include in release notes when you push:

- Profile / My Decks carousel cards: fixed **240×360** (2:3), shared shell, 2×2 stat grid
- Deck format + style line: single `Text.rich` (baseline alignment)
- Commander art: no double frame on deck cards
- Game Play: compact **whose-turn** text only (no pill / no phase on that line)
- More space between phase bar, turn label, and life counter
- Taller counter wheel band for finger scrolling

---

## Phase 1 — High impact (fix before or with next release)

### 1.1 Client lobby: deck / ready lost before first snapshot

| | |
|---|---|
| **Severity** | High |
| **Status** | ✅ Confirmed |
| **Files** | `lib/core/game/lobby_state.dart` (`applyDeck`, `sendReadyToHost`, `_publishLobbyChange` → `_sendClientSlotToHost` ~571–582), `lib/features/lobby/deck_picker_sheet.dart`, `lib/features/lobby/join_scan_screen.dart` |

**Issue:** Joiner calls `_sendClientSlotToHost()` after local changes. If `state.players` does not yet contain the local username, `slot == null` → **no message to host**. UI can still close the deck picker or toggle ready locally.

**Fix options (pick one):**

1. Queue pending slot updates until first `stateSnapshot` includes the player, then flush.
2. On connect, add a local placeholder `PlayerSlot` until snapshot replaces it.
3. Disable deck picker + “Ready” until `mySlot != null` (with loading copy).

**Acceptance criteria:**

- [ ] Join via QR → pick deck → host sees deck on first snapshot or within 2s
- [ ] Toggle ready before snapshot → host sees ready state
- [ ] No silent success (snackbar if send blocked)

**Tests to add:** Unit test on lobby notifier: `applyDeck` with empty `players` queues or no-ops visibly; integration test after mock snapshot.

---

### 1.2 Legacy decks missing `deckStyleId` (hidden in lobby)

| | |
|---|---|
| **Severity** | High |
| **Status** | ✅ Confirmed |
| **Files** | `lib/main.dart` (`_migrateDeckFormats` ~260–267), `lib/features/lobby/deck_picker_sheet.dart` (~25), `lib/core/models/player_deck.dart` |

**Issue:** Startup migration sets empty `format` → Commander, but not `deckStyleId`. `deck_picker_sheet` filters `d.hasDeckStyle` → old decks **missing from lobby picker**.

**Fix options:**

1. One-time migration: assign default style (e.g. `DeckStyle.midrange` or prompt once).
2. Show “needs style” decks in picker with CTA to `showDeckStylePickerSheet`.
3. Extend `_deferredStartupMaintenance` like format migration.

**Acceptance criteria:**

- [ ] Existing Hive decks without style appear in lobby (or user gets one clear prompt)
- [ ] New decks still require style on create

**Tests to add:** Migration test: deck with `deckStyleId: ''` → after startup, pickable or flagged.

---

### 1.3 Profile carousel overflow at large text scale

| | |
|---|---|
| **Severity** | High (layout) |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/profile/profile_carousel_sections.dart` (`ProfileDeckCard`, `profileDeckCardArtHeight`, `profileDeckCardFooterReserveHeight`), `test/profile_carousel_card_layout_test.dart` |

**Issue:** Footer reserve math accepts `textScale` in tests, but **`ProfileDeckCard` build does not pass `MediaQuery.textScalerOf(context)`** into art height. System **large text** can overflow fixed 360dp card.

**Fix:** Clamp text scale (e.g. 1.0–1.35) in widget; pass into `profileDeckCardArtHeight` / footer reserve; or wrap footer in `Flexible` + clip.

**Acceptance criteria:**

- [ ] iOS/Android: Settings → largest text → Profile + My Decks carousels: **no yellow/black overflow stripes**
- [ ] Default text: layout unchanged

**Tests to add:** Widget test `ProfileDeckCard` at `textScaler: 1.35`, `expect(takeException())` null.

---

## Phase 2 — Medium (next sprint or patch)

### 2.1 `gameOver` blocks re-init if session not cleared

| | |
|---|---|
| **Severity** | Medium |
| **Status** | ⚠️ Partial |
| **Files** | `lib/core/game/game_state_notifier.dart` (`shouldInitializeGameFromLobby` ~166–168), `lib/shared/utils/app_router.dart` (~226–230), `lib/core/network/session_providers.dart` (`endSession` / `quitActiveGame`) |

**Issue:** `shouldInitializeGameFromLobby` returns false when `gameOver`. Normal leave paths call `quitActiveGame` / `endSession` (end game, lobby leave, home nav, session dialog). **Edge case:** deep link or back stack to `/game` or `/lobby` without reset → stuck redirect.

**Fix:** Reset game in `broadcastGameStart` / lobby entry when starting a new match; or clear `gameOver` when entering lobby host screen.

**Acceptance criteria:**

- [ ] End game → Home → Host new game → Play tab loads
- [ ] Rematch flow still works (`end_game_screen` already calls `quitActiveGame`)

**📋 Verify on device:** Back gesture from end game without tapping “Leave”.

---

### 2.2 WebSocket reconnect invisible to user

| | |
|---|---|
| **Severity** | Medium |
| **Status** | ✅ Confirmed |
| **Files** | `lib/core/network/ws_client_service.dart`, `lib/core/network/session_connection_guard.dart` |

**Issue:** Reconnect failures only `debugPrint`. User may think actions synced.

**Fix:** Emit connection state; banner on `SessionConnectionGuard`; disable send-heavy actions until `_ready`.

**Acceptance criteria:**

- [ ] Background app 30s → return → banner or auto-reconnect feedback
- [ ] Failed reconnect: visible message, retry affordance

---

### 2.3 Duplicate “whose turn” on non-Commander games

| | |
|---|---|
| **Severity** | Medium (UX) |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/game/screens/game_screen.dart` (~369–389 HUD `statusStrip`, ~433–434 Play tab) |

**Issue:** Without commander HUD: `ActiveTurnBanner` in **header** and again **under phase bar**.

**Fix:** Show in one place only when `!showCommanderHud` or when `tightVertical`.

**Acceptance criteria:**

- [ ] Standard/pod game: single turn label on Play tab
- [ ] Commander game: unchanged (commander bar + optional line under phases if desired)

---

### 2.4 Counter pills: wrong wheel after reorder

| | |
|---|---|
| **Severity** | Medium |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/game/widgets/gameplay_dials_strip_widget.dart` (`_GameplayDialPill` ~410–478, ~1059–1086) |

**Fix:** `key: ValueKey(field)` on pill wrapper.

**Acceptance criteria:**

- [ ] Add/remove/reorder strip dials → each shows correct value without scrolling

---

### 2.5 Web join: QR-only

| | |
|---|---|
| **Severity** | Medium |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/lobby/join_scan_screen.dart` |

**Fix:** “Paste join link” field using existing `SessionJoinUri` parser (especially for desktop web).

**Acceptance criteria:**

- [ ] Join without camera on Chrome desktop
- [ ] Invalid URL shows error

---

### 2.6 Join scan: empty catch blocks

| | |
|---|---|
| **Severity** | Medium |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/lobby/join_scan_screen.dart` (~96–131) |

**Fix:** Log + user-visible retry (mirror permission-denied UX).

---

### 2.7 Host WS server errors swallowed

| | |
|---|---|
| **Severity** | Medium |
| **Status** | 📋 Verify on device |
| **Files** | `lib/core/network/ws_host_service_io.dart` |

**Fix:** `onError` → `appLog` + host-facing event/snackbar.

---

### 2.8 Game history list keys

| | |
|---|---|
| **Severity** | Low–Medium |
| **Status** | 📋 Verify on device |
| **Files** | `lib/features/game/widgets/game_history_tab.dart` |

**Fix:** Stable `Key`s on log rows for long sessions.

---

### 2.9 Game screen overlay rebuild scope

| | |
|---|---|
| **Severity** | Low–Medium (performance) |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/game/screens/game_screen.dart` |

**Fix:** Narrow `ref.watch(gameProvider.select(...))` on overlays (match `_PersonalView` pattern).

---

### 2.10 Counter wheel: 1000 items per dial

| | |
|---|---|
| **Severity** | Low–Medium (performance) |
| **Status** | ✅ Confirmed |
| **Files** | `lib/features/game/widgets/gameplay_dials_strip_widget.dart` (`_kDialWheelMax`, `ListWheelScrollView`) |

**Fix:** Smaller virtual range + index mapping, or stepper-only on compact height.

**📋 Verify on device:** 4 dials, scroll each — frame drops on mid-tier Android?

---

## Phase 3 — Low / polish

| ID | Item | Status | Files |
|----|------|--------|-------|
| 3.1 | Dial +/- accessibility labels | ✅ | `gameplay_dials_strip_widget.dart` |
| 3.2 | Carousel `ValueKey(deck.id)` | 📋 | `profile_carousel_sections.dart`, `decks_manage_screen.dart` |
| 3.3 | Variant panel generic error | ✅ | `variant_card_panel.dart` |
| 3.4 | Wake lock on web / lobby | 📋 | `session_connection_guard.dart` |
| 3.5 | Unused imports (analyzer warnings) | ✅ | `ws_host_service_io.dart`, test files |
| 3.6 | `use_key_in_widget_constructors` infos | Optional | Profile carousel widgets |

---

## Audit items reviewed — not actionable bugs

| Original claim | Verdict |
|----------------|---------|
| `shrinkWrap` ListView overflow chains | **Not found** in `lib/` |
| `shared_preferences` misconfiguration | **N/A** — persistence is Hive |
| Analyzer errors blocking release | **None** — only 3 warnings |
| Play tab missing scroll on short viewport | **False** — `SingleChildScrollView` present |
| Format/style `Text.rich` misalignment | **Addressed** in current tree |

---

## Suggested git workflow when ready

```bash
# 1. Confirm clean baseline
flutter analyze
flutter test

# 2. Stage intentional files only (exclude dist/, coverage/ unless you want them)
git status
git add lib/ test/ docs/RELEASE_AUDIT_PLAN.md pubspec.yaml  # adjust list

# 3. Commit (example — edit to match your changes)
git commit -m "$(cat <<'EOF'
Polish profile carousels and Play tab UX; document release audit plan.

EOF
)"

# 4. Push
git push origin main   # or your branch name
```

If you maintain **two remotes** (e.g. `origin` + backup), push both after review:

```bash
git push origin HEAD
git push <second-remote> HEAD
```

---

## Priority order for implementation (recommended)

1. **1.1** Lobby client snapshot race  
2. **1.2** Deck style migration  
3. **1.3** Profile card text-scale overflow  
4. **2.3** Dedupe turn banner  
5. **2.4** Dial `ValueKey`  
6. **2.2** Connection UI  
7. **2.5** Web paste join URL  
8. Everything else in Phase 2–3 as time allows  

---

## Sign-off (fill when you review)

| Reviewer | Date | Notes |
|----------|------|-------|
| | | |
| | | |

**Release approved for git push:** ☐ Yes ☐ No — issues deferred: _______________
