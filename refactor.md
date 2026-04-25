# Refactor Audit

## Audit Table

| Issue | Complexity 1-10 | Risk | Suggested Fix |
|---|---:|---|---|
| `lib/services/tts_service.dart` is a no-op with `UnimplementedError`, while child flows depend on spoken feedback. | 8 | H | Introduce a `TtsClient` interface, local SHA-256 cache, cancellable playback, and one fake implementation for tests before wiring Google TTS. |
| `android/app/src/main/kotlin/com/kaokeng/daily_life/MainActivity.kt` does not implement the `dailylife/haptic` method channel used by `HapticService.success()`. | 4 | M | Add Android channel implementation or simplify `HapticService` to supported Flutter haptics until native code exists. |
| `assets/images/` contains only `.gitkeep`, but scenario, memory, and vocabulary JSONs reference many `.webp` assets. | 5 | H | Add an asset validator test and either ship placeholder image assets or change JSON/UI to an explicit placeholder contract. |
| `lib/screens/child/scenario_game_screen.dart` creates `startedAt` and `DailyLifeGame` inside `build`, so rebuilds can reset session timing/game state. | 6 | H | Move game/session construction into a stateful controller or `ActiveSession` provider initialized once per scenario entry. |
| Session logging is duplicated across Module A and Module B screens and uses fire-and-forget writes without observable state. | 6 | M | Extract `SessionController`/`SessionRecorder` around `SessionRecord` creation, duration calculation, UUIDs, and write outcome logging. |
| `lib/screens/child/memory_game_screen.dart` owns shuffle, match rules, timers, TTS, haptics, and Firestore persistence in one widget. | 7 | M | Split pure memory-game state machine from Flutter rendering and side effects. |
| Press/tap card behavior is duplicated in `mode_select_screen.dart`, `module_a_screen.dart`, `module_b_screen.dart`, and `module_c_screen.dart`. | 5 | M | Extract shared child UI components: `PressableChildCard`, `ModuleCard`, `ScenarioCard`, `VocabCard`, and loading/error wrappers. |
| `lib/providers/content_providers.dart` uses `firstWhere` for scenario lookup and ignores `published` filtering. | 3 | M | Add safe lookup with domain errors and filter unpublished scenarios in repository/provider layer. |
| Content loading is hardcoded to bundled assets despite repository comments referencing remote/cache behavior. | 6 | M | Define `ContentSource` abstraction and keep asset-backed implementation as MVP default; add remote/cache implementation later. |
| `lib/models/scenario_config.dart` and `session_record.dart` model categories/modules/timestamps as plain strings. | 5 | M | Add enums/value objects for module/category/session type and use `DateTime` converters or Firestore timestamp adapters. |
| `lib/l10n/tts_strings_th.dart` mixes TTS copy, UI labels, and parent UI strings. | 4 | L | Split into `tts_copy_th.dart` and `ui_strings_th.dart`, then prepare ARB/localization only after copy boundaries are clean. |
| Parent auth and dashboard screens are placeholders while Firebase services/rules are already present. | 7 | H | Implement parent auth, activity log stream, and scenario toggles behind providers before broad UI polish. |
| Firestore rules allow owner writes but do not validate session shape, scenario settings shape, or immutable fields. | 5 | M | Add rules validation plus emulator tests for sessions, users, and scenario overrides. |
| Root `tenacious-veld-453115-u8-d0fcb66d2549.json` appears to be a service-account credential and is not ignored by `.gitignore`. | 2 | H | Remove from project tree, rotate if ever committed/shared, and add `*-firebase-adminsdk*.json`/service-account patterns to `.gitignore`. |
| Tests are too thin for the behavioral surface: only serialization and a sanity test pass. | 6 | H | Add repository fixture tests, provider tests, memory reducer tests, asset schema validation, and widget smoke tests for child flows. |

## Execution Graph

1. P1 analyzer/test baseline must stay green before any extraction.
2. Remove/ignore credential files before touching Firebase or CI.
3. Add asset/content validation before replacing placeholder renderers or loading real sprites.
4. Standardize `types.dart`/enums and timestamp converters before P2 session/controller extraction.
5. Extract shared child UI cards before changing Module A/B/C layouts.
6. Extract pure memory-game logic before moving persistence out of `MemoryGameScreen`.
7. Extract `SessionRecorder` before changing `DailyLifeGame` completion or dashboard reads.
8. Define `TtsClient` interface before implementing Google TTS/cache/audio playback.
9. Implement parent auth provider before dashboard activity log and scenario toggles.
10. Add provider/repository tests before remote content or Firestore stream migration.

## 4-Phase Action Plan

### P1 (Warmup): Scriptable/Automated Fixes

| Task | Files |
|---|---|
| Run formatter, Dart fixes, analyzer, and tests; commit only mechanical deltas. | `lib/**`, `test/**` |
| Remove placeholder `test/widget_test.dart` or replace with a real app smoke test. | `test/widget_test.dart` |
| Add service-account ignore pattern and remove local credential from app tree. | `.gitignore`, `tenacious-veld-453115-u8-d0fcb66d2549.json` |
| Add asset/schema validation test for scenario, memory, vocabulary JSON references. | `test/content/assets_test.dart`, `assets/**` |
| Add safe scenario lookup test covering unknown scenario IDs. | `test/providers/content_providers_test.dart` |

Verification: `dart format --set-exit-if-changed lib test && flutter analyze && flutter test`

### P2 (Unification): Component/Logic Extraction

| Merge/Extract | Source Files | Target |
|---|---|---|
| Pressable child card behavior and fixed child hit states. | `lib/screens/child/mode_select_screen.dart`, `module_a_screen.dart`, `module_b_screen.dart`, `module_c_screen.dart` | `lib/widgets/child/pressable_child_card.dart` |
| Module/scenario/vocabulary cards. | `_ModuleCard`, `_ScenarioCard`, `_VocabCard` | `lib/widgets/child/module_card.dart`, `scenario_card.dart`, `vocab_card.dart` |
| Async loading/error wrappers for child screens. | Module A/B/C and memory screens | `lib/widgets/child/child_async_view.dart` |
| Memory game rules. | `lib/screens/child/memory_game_screen.dart` | `lib/features/memory/memory_game_controller.dart` |
| Session record construction and writes. | `memory_game_screen.dart`, `scenario_game_screen.dart` | `lib/features/sessions/session_recorder.dart` |
| App domain constants/enums. | `scenario_config.dart`, `session_record.dart`, string callsites | `lib/models/app_types.dart` |

Verification: `flutter test test/models test/features test/widgets`

### P3 (Core): Architectural Shifts

| Shift | Step-by-Step |
|---|---|
| Session lifecycle provider | 1. Add `ActiveSession`/`SessionRecorder` provider with injectable clock and UUID factory. 2. Move Module A and Module B record creation out of screens into recorder methods. 3. Update screens/game callbacks to emit domain events and verify records with provider tests. |
| Content repository boundary | 1. Split `ContentRepository` into `ContentRepository` interface plus `AssetContentRepository`. 2. Add typed domain errors for missing scenario, malformed JSON, unpublished content, and remote URL not supported. 3. Add optional `CachedRemoteContentRepository` behind the same interface after asset tests pass. |
| TTS/audio implementation | 1. Define `TtsClient` plus fake/no-op test implementation and make `TtsService` cancellable. 2. Add hash-keyed local cache with max-size eviction and lifecycle cancellation. 3. Wire Google TTS HTTP client and audio playback behind runtime configuration. |
| Parent-side architecture | 1. Implement email/password auth and account linking in `AuthService`/providers. 2. Add activity-log and scenario-settings repositories with Firestore stream providers. 3. Replace dashboard placeholders with log/progress/settings views using tested providers. |
| Flame asset rendering | 1. Add `BackgroundComponent` and sprite-backed interactables while keeping placeholder fallback explicit. 2. Preload assets during scenario load and surface load errors in `ScenarioGameScreen`. 3. Add a smoke test or golden-compatible render check for each bundled scenario. |

Verification: `flutter test test/features test/providers test/services`

### P4 (Polish): Type Hardening and Performance Bottlenecks

| Task | Files |
|---|---|
| Replace string modules/categories with enums and JSON converters. | `lib/models/scenario_config.dart`, `lib/models/session_record.dart` |
| Replace ISO string timestamps with `DateTime`/Firestore converters. | `lib/models/session_record.dart`, `lib/services/session_repository.dart` |
| Add Firestore rules validation and emulator-backed tests. | `firestore.rules`, `test/rules/**` |
| Throttle drag-path sampling to spec cadence instead of recording every drag update. | `lib/game/daily_life_game.dart`, `lib/game/interactable_component.dart` |
| Avoid rebuilding/recreating `DailyLifeGame` on unrelated provider changes. | `lib/screens/child/scenario_game_screen.dart` |
| Add image/cache preloading and measure frame timing on target tablet size. | `lib/game/**`, `lib/services/content_repository.dart` |

Verification: `flutter test --coverage && flutter analyze`
