# 06 — Data Models

> **Version:** 0.1-MVP | **Status:** Planning
> Single source of truth for all data shapes. If a field appears in code that's not here, it's a bug.

---

## 1. ScenarioConfig (JSON — content layer)

Loaded from Firebase Storage or bundled in assets. Never mutated at runtime.

```json
{
  "scenario_id": "711_milk_001",
  "version": 1,
  "category": "daily_life",
  "module": "A",
  "title_th": "ช่วยหยิบของที่เซเว่น",
  "background_image": "https://storage.googleapis.com/.../711_interior.webp",
  "tts_instruction": "น้องช่วยหยิบนมกล่องสีน้ำเงินใส่ตะกร้าให้หน่อยนะครับ",
  "tts_celebration": "เก่งมากเลยนะครับ! น้องทำได้แล้ว!",
  "tts_hint": "ลองหยิบนมกล่องสีน้ำเงินนะครับ",
  "interactables": [
    {
      "id": "milk_carton_blue",
      "image": "https://storage.googleapis.com/.../milk_blue.webp",
      "is_target": true,
      "start_pos": { "x": 200, "y": 400 }
    },
    {
      "id": "bread_loaf",
      "image": "https://storage.googleapis.com/.../bread.webp",
      "is_target": false,
      "start_pos": { "x": 400, "y": 400 }
    },
    {
      "id": "potato_chips",
      "image": "https://storage.googleapis.com/.../chips.webp",
      "is_target": false,
      "start_pos": { "x": 600, "y": 400 }
    }
  ],
  "target_zone": {
    "x": 800, "y": 700,
    "width": 200, "height": 150
  }
}
```

### Field Rules

| Field | Type | Required | Notes |
|---|---|---|---|
| `scenario_id` | string | ✅ | Snake case, globally unique |
| `version` | int | ✅ | Increment on any field change |
| `category` | enum | ✅ | `daily_life` / `memory` / `sound_board` |
| `module` | enum | ✅ | `A` / `B` / `C` |
| `title_th` | string | ✅ | Thai only for MVP |
| `background_image` | URL | ✅ | `.webp`, max 500KB |
| `tts_instruction` | string | ✅ | Full sentence, polite Thai |
| `tts_celebration` | string | ✅ | Enthusiastic, max 2 sentences |
| `tts_hint` | string | ✅ | Gentle nudge, used after 8s idle |
| `interactables` | array | ✅ | Min 1 target, max 5 total |
| `interactables[].is_target` | bool | ✅ | Exactly 1 must be `true` |
| `interactables[].start_pos` | {x, y} | ✅ | In 1920×1080 space |
| `target_zone` | {x,y,w,h} | ✅ | In 1920×1080 space |

---

## 2. MemoryPack (JSON — content layer)

```json
{
  "pack_id": "thai_animals_001",
  "title_th": "สัตว์ไทย",
  "pairs": [
    {
      "id": "elephant",
      "image": "https://storage.googleapis.com/.../elephant.webp",
      "tts_name": "ช้าง"
    },
    {
      "id": "tiger",
      "image": "https://storage.googleapis.com/.../tiger.webp",
      "tts_name": "เสือ"
    }
  ]
}
```

- `pairs` array: exactly 8 items for MVP (produces 4×4 grid).
- Each item appears twice on the board (16 tiles total).

---

## 3. VocabularyItem (JSON — content layer)

```json
{
  "item_id": "cat_001",
  "image": "https://storage.googleapis.com/.../cat.webp",
  "tts_word": "แมว",
  "category": "animals"
}
```

- Sound Board loads all items at once (no pagination in MVP).
- MVP: 30 items total, 5 categories of 6.

---

## 4. Firestore Schema

### `/users/{uid}`

```json
{
  "uid": "firebase_auth_uid",
  "email": "parent@example.com",
  "created_at": "2026-01-01T00:00:00Z",
  "display_name": "คุณแม่น้องมิน"
}
```

### `/sessions/{uid}/records/{session_id}`

Written by the child-side app after each scenario/module completion.
`module` is `daily_life` for Module A or `memory` for Module B.

**Module A (Daily Life):** populates `drag_interactions`. Memory fields omitted.

```json
{
  "session_id": "uuid_v4",
  "uid": "firebase_auth_uid",
  "scenario_id": "711_milk_001",
  "module": "daily_life",
  "started_at": "2026-01-15T14:23:00Z",
  "ended_at": "2026-01-15T14:25:30Z",
  "duration_ms": 150000,
  "completed": true,
  "drag_interactions": [
    {
      "interaction_id": "uuid_v4",
      "object_id": "milk_carton_blue",
      "was_target": true,
      "was_successful": true,
      "duration_ms": 4200,
      "straightness_score": 0.87,
      "path_points": [
        { "x": 200.0, "y": 400.0 },
        { "x": 350.0, "y": 500.0 },
        { "x": 850.0, "y": 750.0 }
      ]
    }
  ]
}
```

**Module B (Memory):** populates `pairs_matched`, `total_pairs`, and
`match_events` (every tap-pair, matched or not, with elapsed ms from session
start). `drag_interactions` is an empty list.

```json
{
  "session_id": "uuid_v4",
  "uid": "firebase_auth_uid",
  "scenario_id": "thai_animals",
  "module": "memory",
  "started_at": "2026-01-15T14:23:00Z",
  "ended_at": "2026-01-15T14:25:30Z",
  "duration_ms": 150000,
  "completed": true,
  "drag_interactions": [],
  "pairs_matched": 8,
  "total_pairs": 8,
  "match_events": [
    { "pair_id": "elephant", "matched": false, "at_ms": 1800 },
    { "pair_id": "elephant", "matched": true,  "at_ms": 6400 }
  ]
}
```

### `/scenario_settings/{uid}/overrides/{scenario_id}`

Written by parent dashboard when toggling a scenario.

```json
{
  "scenario_id": "711_milk_001",
  "enabled": true,
  "updated_at": "2026-01-15T10:00:00Z"
}
```

Default (no doc): all scenarios are enabled.

### `/content/scenarios/{scenario_id}`

Master list of all available scenarios. Read-only for child app.

```json
{
  "scenario_id": "711_milk_001",
  "title_th": "ช่วยหยิบของที่เซเว่น",
  "category": "daily_life",
  "module": "A",
  "config_url": "https://storage.googleapis.com/.../711_milk_001.json",
  "thumbnail_url": "https://storage.googleapis.com/.../711_milk_001_thumb.webp",
  "version": 1,
  "published": true
}
```

---

## 5. Dart Models (generated from JSON)

Use `freezed` + `json_serializable` for all models.

```dart
@freezed
class ScenarioConfig with _$ScenarioConfig {
  const factory ScenarioConfig({
    required String scenarioId,
    required int version,
    required String category,
    required String module,
    required String titleTh,
    required String backgroundImage,
    required String ttsInstruction,
    required String ttsCelebration,
    required String ttsHint,
    required List<InteractableConfig> interactables,
    required TargetZone targetZone,
  }) = _ScenarioConfig;

  factory ScenarioConfig.fromJson(Map<String, dynamic> json) =>
      _$ScenarioConfigFromJson(json);
}

@freezed
class InteractableConfig with _$InteractableConfig {
  const factory InteractableConfig({
    required String id,
    required String image,
    required bool isTarget,
    required GamePosition startPos,
  }) = _InteractableConfig;

  factory InteractableConfig.fromJson(Map<String, dynamic> json) =>
      _$InteractableConfigFromJson(json);
}

@freezed
class TargetZone with _$TargetZone {
  const factory TargetZone({
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _TargetZone;

  factory TargetZone.fromJson(Map<String, dynamic> json) =>
      _$TargetZoneFromJson(json);
}
```

---

## 6. Local Cache Strategy

| Data | Storage | TTL |
|---|---|---|
| Scenario JSON configs | `flutter_cache_manager` | 24h |
| Scenario images | `flutter_cache_manager` | 7d |
| Vocabulary items | `flutter_cache_manager` | 7d |
| Firestore scenario list | Firestore offline persistence | indefinite |
| Firestore session records | Write-through; no local read needed | — |
| Auth session | Firebase Auth persistence | indefinite |
