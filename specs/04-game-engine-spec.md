# 04 — Game Engine Spec (Flame)

> **Version:** 0.1-MVP | **Status:** Planning

---

## Architecture Overview

```
ScenarioGameScreen (Flutter Widget)
└── GameWidget<DailyLifeGame>
    └── DailyLifeGame (FlameGame + HasCollisionDetection)
        ├── BackgroundComponent       (SpriteComponent, z=0)
        ├── DropZoneComponent         (RectangleHitbox, z=1)
        ├── InteractableComponent[]   (SpriteComponent + DragCallbacks, z=2)
        └── SuccessOverlayComponent   (added on success, z=10)
```

---

## DailyLifeGame

```dart
class DailyLifeGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  final ScenarioConfig config;
  // Injected via constructor from route args
}
```

### Lifecycle

| Method | Responsibility |
|---|---|
| `onLoad()` | Load all sprites from config URLs; add all components; start idle timer |
| `onRemove()` | Cancel idle timer; cancel TTS; log session to Firestore |

---

## BackgroundComponent

- `SpriteComponent` filling 100% of game size.
- Image: `config.background_image` URL.
- Loaded with `Flame.images.fetchOrGenerate()` (cached by URL).
- No interactivity.

---

## InteractableComponent

### Properties

```dart
class InteractableComponent extends SpriteComponent
    with DragCallbacks, CollisionCallbacks {
  final InteractableConfig config;  // from scenario JSON
  bool isBeingDragged = false;
  Vector2 startPosition = Vector2.zero();
}
```

### Sizing

- All interactables: **120×120 logical pixels** (MVP, uniform for simplicity).
- Post-MVP: `config.width` / `config.height` per item.

### Hitbox

- `RectangleHitbox` sized to 80% of sprite (avoids edge-tap issues).
- `isSolid = false` (no physics blocking, only collision detection).

### Drag Behaviour

```
onDragStart(event):
  isBeingDragged = true
  priority = 100  // lift above siblings
  scale = Vector2.all(1.05)  // visual lift
  HapticFeedback.selectionClick()  // light haptic

onDragUpdate(event):
  position += event.localDelta  // follow finger exactly

onDragEnd(event):
  isBeingDragged = false
  priority = config.zIndex  // restore
  scale = Vector2.all(1.0)
  // collision result handled by onCollisionStart
  // if no collision registered: tween back to startPosition
```

### Return Tween (no collision)

```dart
// After 50ms grace period post drag-end, if not in drop zone:
add(MoveEffect.to(
  startPosition,
  EffectController(duration: 0.4, curve: Curves.easeInOut),
));
```

### Target Identification

- `config.is_target == true` → this is the winning object.
- Collision with DropZoneComponent: only process if `is_target == true`.
- Distractors: `onCollisionStart` fires but is immediately ignored.

---

## DropZoneComponent

```dart
class DropZoneComponent extends PositionComponent with CollisionCallbacks {
  // Defined by config.target_zone: { x, y, width, height }
  bool isActivated = false;
}
```

### Visual States

| State | Visual |
|---|---|
| Idle | Dashed yellow border, 30% opacity |
| Drag near (within 150px) | Solid yellow border, 80% opacity, gentle pulse |
| Collision (target overlapping) | Gold fill, full opacity |

### Collision Logic

```
onCollisionStart(other):
  if other is InteractableComponent && other.config.is_target:
    triggerSuccess(other)

triggerSuccess(target):
  isActivated = true
  target.position = center of drop zone
  target.priority = 5 (below overlay)
  add(SuccessOverlayComponent())
  HapticFeedback.heavyImpact()  // double buzz via platform channel
  TtsService.play(config.tts_celebration)
  SessionLogger.log(...)
  Future.delayed(2.5s): game.router.popRoute()
```

---

## SuccessOverlayComponent

- `PositionComponent` at (0, 0), size = game.size.
- Renders: particle burst (yellow + blue, 60 particles).
- Particle system: built with `ParticleSystemComponent` from Flame.
- Auto-removes after 2.5s.

### Particle Config

```dart
ParticleSystemComponent(
  particle: Particle.generate(
    count: 60,
    lifespan: 1.2,
    generator: (i) => AcceleratedParticle(
      acceleration: Vector2(0, 200),  // gravity
      speed: Vector2(
        Random().nextDouble() * 400 - 200,
        Random().nextDouble() * -500 - 100,
      ),
      child: CircleParticle(
        radius: Random().nextDouble() * 6 + 2,
        paint: Paint()..color = (i % 2 == 0) ? kYellowPrimary : kBluePrimary,
      ),
    ),
  ),
)
```

---

## Idle Timer & Re-prompt System

```
Timer starts at: scenario load complete
8s of no interaction:
  → TTS re-plays config.tts_instruction
  → Animated arrow appears, pointing at target object
    (PositionComponent with arrow sprite, bounce animation)
15s more of no interaction:
  → Arrow re-pulses 3×
  → TTS plays again
  → Repeats indefinitely at 15s intervals
Any drag event:
  → Timer resets
  → Arrow hides immediately
```

---

## Motor Skill Data Collection

Every drag interaction logs a path for parent dashboard.

```dart
// Collected during onDragUpdate:
List<Vector2> dragPath = [];

// Logged to Firestore on drag end:
{
  "interaction_id": uuid,
  "scenario_id": config.scenario_id,
  "timestamp": DateTime.now().toIso8601String(),
  "was_successful": bool,
  "path_points": [{"x": 120.5, "y": 340.2}, ...],  // sampled every 50ms
  "duration_ms": int,
}
```

### Straightness Score

Calculated on the backend (Cloud Function, post-MVP) or client-side:

```dart
double straightnessScore(List<Vector2> path) {
  if (path.length < 2) return 1.0;
  final directDistance = path.first.distanceTo(path.last);
  final pathLength = _totalLength(path);
  return directDistance / pathLength.clamp(0.0001, double.infinity);
}
// 1.0 = perfectly straight. Lower = more curved/shaky.
```

---

## Performance Targets

| Metric | Target |
|---|---|
| First frame rendered | < 100ms after navigation |
| Sprite load (from cache) | < 16ms per sprite |
| Drag responsiveness | 60fps sustained during drag |
| Collision detection | < 1ms per frame |
| Memory (all sprites loaded) | < 80MB |

---

## Device Adaptation

```dart
// Game size follows FlameGame.size (matches GameWidget size)
// All positions in config are defined as percentages of 1920×1080 reference:
Vector2 resolvePosition(Map<String, double> rawPos, Vector2 gameSize) {
  return Vector2(
    rawPos['x']! / 1920 * gameSize.x,
    rawPos['y']! / 1080 * gameSize.y,
  );
}
```

> All `start_pos` and `target_zone` values in scenario JSONs are authored at 1920×1080. The engine scales automatically.
