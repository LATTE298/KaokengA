# /specs — Daily Life (ชีวิตประจำวัน) Specification Index

> **How to use this folder:**
> Each file is a self-contained spec document. Read them in the order listed when onboarding.
> During vibe-engineering, jump directly to the file relevant to what you're building.
> Every user action, system response, and edge case is documented — no decisions should be made by inference.

---

## File Map

| File | What it covers |
|---|---|
| `01-product-overview.md` | Vision, philosophy, personas, MVP scope |
| `02-information-architecture.md` | Screen map, navigation model, all routes |
| `03-user-flows.md` | Every user journey, step-by-step with states |
| `04-game-engine-spec.md` | Flame engine, drag-drop, collision, physics |
| `05-modules-spec.md` | Module A (Daily Life), B (Memory), C (Sound Board) detail |
| `06-data-models.md` | All data schemas (JSON, Firestore, local state) |
| `07-parent-dashboard-spec.md` | Auth, logs, progress visualisation, scenario management |
| `08-tts-audio-spec.md` | TTS integration, audio rules, haptic feedback |
| `09-asset-pipeline.md` | Image generation prompts, naming, delivery |
| `10-design-system.md` | Colour tokens, typography, component library, theme |
| `11-accessibility-neurodiversity.md` | All neuro-inclusive rules and implementation guidance |
| `12-firebase-backend.md` | Firestore schema, security rules, Auth config |
| `13-state-management.md` | Riverpod providers, state graph, persistence |
| `14-mvp-scope.md` | Explicit MVP in/out list, phased roadmap |
| `15-testing-strategy.md` | Unit, widget, integration, and QA checklist |

---

## Core Principles (read once, applied everywhere)

1. **No failure states** — items return gently to start; the child always succeeds eventually.
2. **Thai-first** — all copy, TTS, and cultural references are Thai before English.
3. **JSON-driven content** — no new scenario ever requires a code change.
4. **Riverpod strict** — no setState outside of Flame components; every piece of state has one owner.
5. **Scalability > cleverness** — obvious, boring code wins over smart abstractions.

---

## Theme Reference (quick copy)

```dart
// Primary palette — Yellow & Blue, warm + chill
const kYellowPrimary  = Color(0xFFFFC53D); // Golden Thai sun
const kYellowLight    = Color(0xFFFFF3C0); // Soft cream
const kYellowDark     = Color(0xFFB97C00); // Deep amber
const kBluePrimary    = Color(0xFF4A90D9); // Sky blue
const kBlueLight      = Color(0xFFD6EAFF); // Ice blue
const kBlueDark       = Color(0xFF1A4F7A); // Deep ocean
const kWarmNeutral    = Color(0xFFFDF8EE); // Warm white canvas
const kTextPrimary    = Color(0xFF3D2C00); // Warm brown-black
const kTextSecondary  = Color(0xFF7A6235); // Warm muted
```

---

*Last updated: MVP planning phase. Increment version in each file header on every change.*
