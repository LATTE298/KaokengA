# 02 — Information Architecture

> **Version:** 0.1-MVP | **Status:** Planning

---

## Screen Map

```
App Root
├── SplashScreen                    (auto-navigates after 1.5s)
├── ModeSelectScreen                (child-facing home)
│   ├── ModuleAScreen               (Daily Life hub)
│   │   └── ScenarioGameScreen      (the actual Flame game)
│   ├── ModuleBScreen               (Memory hub)
│   │   └── MemoryGameScreen
│   └── ModuleCScreen               (Sound Board)
└── ParentGateScreen                (hidden entry — long-press logo 3s)
    ├── AuthScreen                  (login / register)
    └── DashboardScreen             (post-auth parent view)
        ├── ActivityLogScreen
        ├── ProgressScreen
        └── ScenarioManagerScreen
```

---

## Navigation Model

### Child Side

- Navigation is **full-screen card transitions** — no visible navigation bar.
- Back navigation: **swipe down** or a large `←` icon (top-left, 60×60 dp hitbox).
- No deep links, no URL routing.
- State: ephemeral. Closing app resets to `ModeSelectScreen`.

### Parent Side

- Standard Flutter `Navigator` with bottom nav: **Log | Progress | Scenarios**.
- Auth wall: any parent route redirects to `AuthScreen` if unauthenticated.
- Back from parent side → `ModeSelectScreen` (child mode).

---

## All Routes (Named)

```dart
// Child routes
const kRouteSplash        = '/';
const kRouteModeSelect    = '/mode-select';
const kRouteModuleA       = '/module-a';
const kRouteScenarioGame  = '/module-a/game';   // args: ScenarioConfig
const kRouteModuleB       = '/module-b';
const kRouteMemoryGame    = '/module-b/game';   // args: MemoryPack
const kRouteModuleC       = '/module-c';        // no sub-route; self-contained

// Parent routes
const kRouteParentGate    = '/parent-gate';
const kRouteAuth          = '/parent/auth';
const kRouteDashboard     = '/parent/dashboard';
const kRouteActivityLog   = '/parent/log';
const kRouteProgress      = '/parent/progress';
const kRouteScenarios     = '/parent/scenarios';
```

---

## Screen Specifications

### SplashScreen
- Shows: app logo (animated, 800ms ease-in), yellow gradient background.
- Plays: soft chime TTS "สวัสดีครับ / ค่ะ" (gender configured by parent; default: neutral).
- Navigates to: `ModeSelectScreen` after 1.5s.
- No user input required.

### ModeSelectScreen
- Shows: 3 large illustrated cards in a row (Module A, B, C).
- Each card: icon + Thai label + short description TTS on tap (before entering).
- Hidden interaction: **logo long-press (3 seconds)** → navigate to `ParentGateScreen`.
- No other chrome; full-screen warm yellow canvas.

### ModuleAScreen (Daily Life Hub)
- Shows: horizontal scroll list of scenario cards.
- Each card: background thumbnail + Thai title + enabled/disabled state (synced from Firestore).
- Disabled scenarios: greyed out, not tappable.
- Tap enabled card → navigate to `ScenarioGameScreen` with `ScenarioConfig` as route arg.

### ScenarioGameScreen
- Full-screen Flame game canvas.
- No UI overlay during play except: back arrow (top-left, 60×60 dp).
- Receives `ScenarioConfig` from route args.
- On success: plays success overlay (stays 3s), then returns to `ModuleAScreen`.

### ModuleBScreen (Memory Hub)
- Shows: single pack card (MVP: 1 pack only).
- Tap → `MemoryGameScreen`.
- After future packs added: horizontal scroll, same pattern as Module A.

### MemoryGameScreen
- Full-screen Flame game canvas.
- Back arrow top-left.
- On completion: animated score (pairs found / time taken), then auto-return after 4s.

### ModuleCScreen (Sound Board)
- Full-screen grid of vocabulary cards (no sub-route needed).
- Back arrow top-left.
- Self-contained; no sub-navigation.

### ParentGateScreen
- Shows: simple PIN or biometric prompt ("ส่วนของผู้ปกครอง").
- MVP: no PIN — just a "I am a parent" confirmation button (friction only). Full biometric in v2.
- Success → `AuthScreen` if not logged in; `DashboardScreen` if session active.

### AuthScreen
- Login / Register tabs.
- Firebase Auth: email+password (MVP). Passkey support post-MVP.
- On success → `DashboardScreen`.

### DashboardScreen
- Bottom nav: Log | Progress | Scenarios.
- Default tab: Log.

### ActivityLogScreen
- List of sessions: date, module, scenario name, duration.
- Sorted newest-first.
- Paginated (20 per page).

### ProgressScreen
- Line chart: drag straightness over time (Module A only, MVP).
- Per-scenario selector.

### ScenarioManagerScreen
- List of all scenarios.
- Toggle switch per scenario (writes to Firestore, syncs to child app in real-time).
