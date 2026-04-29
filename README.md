# Kaokeng — Daily Life

_Last checked: 2026-04-29_

A neuro-inclusive sandbox app for Thai children, built with Flutter and the Flame game engine.  
The app primarily targets Android tablets in landscape orientation.

## Features

- **Module A — Daily Life:** Drag-and-drop scenario gameplay, such as buying milk at 7-Eleven, with Thai TTS celebration and encouragement audio
- **Module B — Memory Game:** Tile-matching card game with Thai animal vocabulary
- **Module C — Sound Board:** 30 vocabulary items across 5 categories with TTS playback
- **Parent Dashboard:** Email/password registration and login, activity log, and per-scenario access controls
- **Anonymous child sessions** through Firebase Auth — no child account required
- **JSON-driven content:** New scenarios can be added without changing app code

## Tech Stack

| Layer | Library |
|---|---|
| UI framework | Flutter |
| Game engine | Flame 1.22 |
| State management | Riverpod 2 |
| Data models | Freezed + json_serializable |
| Routing | go_router |
| Backend | Firebase Auth + Cloud Firestore |
| Audio | just_audio |
| Fonts | Google Fonts |
| Icons | Phosphor Flutter |

## Quick Start

Clone the project:

```bash
git clone https://github.com/Kenjeaw/Kaokeng.git
cd Kaokeng
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

> Full prerequisites, Firebase setup, and build commands are available in [BUILD.md](BUILD.md).

## Project Structure

```text
lib/
├── main.dart                  # App entry point
├── firebase_options.dart      # Firebase SDK config (generated)
├── features/                  # Feature-level controllers
├── game/                      # Flame game components
├── l10n/                      # Thai TTS strings
├── models/                    # Freezed data models
├── providers/                 # Riverpod providers
├── routes/                    # go_router configuration
├── screens/
│   ├── child/                 # Child-facing screens
│   └── parent/                # Parent dashboard screens
├── services/                  # Business logic and repositories
├── theme/                     # Design tokens: colors, typography, spacing
└── widgets/                   # Shared UI components

assets/
├── scenarios/                 # Scenario JSON definitions
├── images/                    # Scene and item images
├── memory_packs/              # Memory game card sets
└── vocabulary/                # Sound board vocabulary

specs/                         # Product and design specification documents
test/                          # Unit, widget, and game tests
```

## Testing

```bash
flutter test
```

## License

Not specified.