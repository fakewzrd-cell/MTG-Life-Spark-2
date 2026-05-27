# MTG Life Spark

Commander-focused multiplayer life tracker for Magic: The Gathering pods. Host a LAN session from your phone, share a QR code, and keep life totals, counters, stack order, alliances, and match history in sync across the table.

## Features

- **Multiplayer sync** — QR join over local WebSocket (`ws://` on the host device)
- **Commander tooling** — commander damage, cast-from-zone, Scryfall card search on the stack
- **Table politics** — monarch, initiative, day/night, secret alliances, team colors
- **Profile & history** — XP progression, match stats, deck slots
- **Platform support** — iOS, Android, macOS, and web (web hosting has networking limits; see below)

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.7+ (stable channel recommended)
- Xcode (iOS/macOS), Android Studio / SDK (Android), or Chrome (web)

## Setup

```bash
git clone <repo-url>
cd MTG-Life-Spark
flutter pub get
```

### Run locally

```bash
# Pick a device from `flutter devices`
flutter run

# Web (development)
flutter run -d chrome
```

### Android release signing (optional)

Copy the template and fill in your keystore paths:

```bash
cp android/keystore.properties.example android/keystore.properties
```

Release builds read `android/keystore.properties`; the file is gitignored.

### Web / Vercel

The repo includes `vercel.json` and `scripts/build_web_vercel.sh` for static web builds. LAN WebSocket hosting from a browser tab is limited by browser security — use mobile/desktop apps for hosting a session when possible.

## Tests & analysis

```bash
flutter test
flutter analyze lib/ test/
```

CI runs tests, analysis, and a web build (see `.github/workflows/flutter_ci.yml`).

`test/integration/` adds smoke coverage for the WebSocket join handshake (token validation) and the game lobby entry screen — no physical device required.

## Project layout

| Path | Purpose |
|------|---------|
| `lib/core/game/` | Game state, networking messages, stack logic |
| `lib/core/network/` | WebSocket host/client services |
| `lib/features/game/` | In-game UI (life counter, stack, overview) |
| `lib/features/lobby/` | Host/join lobby and QR flow |
| `lib/features/profile/` | Player profile, decks, match history |
| `test/` | Unit tests (game sync, lobby, XP, stack) |
| `test/integration/` | WebSocket join flow and game lobby entry smoke tests |

## Multiplayer notes

- The **host** runs a WebSocket server on the local network and displays a QR payload clients scan to join.
- QR codes include a short-lived **join token** (`?token=...`); clients must scan the current code (legacy codes without a token are rejected).
- Clients apply state from the host; life-loss elimination and several table actions are **host-authoritative**.
- **Solo games** start with only the players in your lobby (no auto-filled demo pod). Use **Load example stack** on the Stack tab when you want a four-player practice pod.
- **Table politics** (Monarch, Initiative, Day/Night) are on the in-game **Overview** screen; the lobby host can assign them even in a solo practice session on web.

## License

Private / unpublished (`publish_to: none` in `pubspec.yaml`).
