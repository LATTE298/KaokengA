# MVP Progress Tracker

> Single source of truth for MVP build progress.
> Aligned with `specs/14-mvp-scope.md`. Update as items ship.
> **Legend:** [x] done · [~] partial · [ ] not started

**Last audited:** 2026-04-25 · **Overall:** ~85%

---

## Module A — Daily Life
- [x] Scenario `711_milk_001` JSON (`assets/scenarios/711_milk_001.json`)
- [x] Scenario `trash_sort_001` JSON
- [x] Scenario `food_prep_001` JSON
- [x] Flame drag & drop engine (`lib/game/daily_life_game.dart`)
- [x] Success animation + TTS celebration
- [x] Idle re-prompt after 8s
- [ ] Animated hint arrow after 15s  ← only TTS exists today
- [x] Return tween on missed drop
- [x] Session data logging to Firestore
- [x] Sprite-backed background/interactables with explicit placeholder fallback
- [x] Bundled scenario Flame render smoke tests

## Module B — Memory
- [x] Thai animals pack (8 pairs / 16 tiles)
- [x] Tile flip animation
- [x] Match detection + celebration TTS
- [x] No-match silent return
- [x] Completion screen (pair count, no timer)
- [x] Session data logging to Firestore

## Module C — Sound Board
- [x] 30 vocabulary items across 5 categories
- [x] Tap-to-hear TTS wiring (placeholder service)
- [x] Active highlight state (1s)
- [x] Categories: animals, food, colours, body parts, household items

## Parent Dashboard
- [x] Firebase Auth (email + password, anonymous child account linking)
- [x] Activity log — 20 most recent sessions, with load-more pagination
- [x] Scenario toggle (Module A only)
- [x] Logout flow
- [x] Progress summary tab

## Infrastructure
- [x] Firestore configured, writes wired end-to-end (anonymous auth; `/sessions/{uid}/records`)
- [x] Neural TTS API integration (`GoogleTtsClient` behind `GOOGLE_TTS_API_KEY`)
- [x] Local SHA-256 TTS audio cache + cancellable playback
- [~] Firebase Storage (Blaze required; bundled assets used)
- [~] `flutter_cache_manager` used for optional remote JSON cache, not yet image caching
- [x] Riverpod state management
- [x] Flame engine
- [x] Typed content repository errors for missing/malformed/unpublished content

## Design
- [x] Yellow + Blue theme (`lib/theme/colors.dart`)
- [x] Sarabun Thai font via google_fonts
- [x] Thai-only child-facing copy
- [x] Haptic feedback (grab / tap / success / match)
- [x] Hitboxes ≥60dp (120dp interactables, 80% hit area)

---

## Priority Queue (Next Up)
1. Add animated hint arrow to Module A (15s)
2. Add real `.webp` artwork for scenario backgrounds/interactables, memory cards, vocabulary, and thumbnails
3. Use image caching/preloading for scenario/memory/vocab images
4. Harden Firestore rules with validation and emulator-backed tests
5. Replace string module/category/timestamps with typed values/converters

---

## How to Use
- Tick a box the moment a feature lands on `main`.
- If a box flips from [x] back to [ ], add a one-line note under it with the date + reason.
- Keep this file in sync with `specs/14-mvp-scope.md`; that doc defines *what*, this doc tracks *where we are*.
