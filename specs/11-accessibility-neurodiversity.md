# 11 — Accessibility & Neurodiversity Spec

> **Version:** 0.1-MVP | **Status:** Planning
> These are non-negotiable constraints, not nice-to-haves.
> Every new component must be checked against this list before PR.

---

## Core Principle

> The app must work for the child on their worst day — when their sensory tolerance is low, their fine motor control is reduced, and their attention is limited. Design for that child, and all children benefit.

---

## Visual Rules

### No high-contrast harsh patterns
- Background images must be reviewed for: busy patterns, sharp edge density, flickering visual content.
- AI generation prompt must include: `soft edges, muted saturation, no stripes, no checkerboard, no high-frequency visual noise`.
- Minimum contrast for text: 4.5:1 (WCAG AA) — but use warm brown on warm yellow, not black on white (too stark).

### Consistent visual language
- All AI-generated images: same style reference prompt + same `--seed` or `style_id`.
- Target aesthetic: soft 3D cartoon, warm-toned, Thai setting, simplified shapes.
- Objects must be recognisable at 120×120dp (no fine detail that disappears at small size).

### No unexpected visual changes
- No auto-playing animations on idle screens (only on success, which is expected).
- No animated ads, banners, or anything that moves without child interaction.
- Module card pulse animation: max 1.04 scale, slow (2s), opt-outable in v2.

### Drop zone must be clearly visible
- Dashed yellow border at rest.
- Solid blue border when dragging near.
- Must not blend with background — design backgrounds to leave a neutral landing area.

---

## Audio Rules

### No sudden loud sounds
- All TTS audio normalised to -16 LUFS (EBU R128).
- Volume at 80% of device volume maximum.
- Celebration TTS: upbeat but not shouting. Brief test with headphones at max volume before shipping.

### Predictable audio
- TTS plays at: screen load, idle (8s), success. No other spontaneous audio.
- Sound Board: audio only on deliberate tap. Never auto-plays.

### Cancellable
- Any TTS cancels immediately when child navigates away.
- Two taps on Sound Board card: second tap cancels first and replays (no double-audio).

---

## Motor Accessibility Rules

### Hitbox sizes

| Element | Minimum visual size | Minimum hitbox |
|---|---|---|
| Back arrow | 40×40dp | 60×60dp (extended tap area) |
| Module card | 120×120dp | full card |
| Scenario card | 160×200dp | full card |
| Vocabulary card | (screen_width/5 - 12dp) | full card |
| Toggle switch | 32×20dp | 60×40dp |
| Interactable (Flame) | 120×120dp | 96×96dp (80%) |

All Flutter tap areas extended via `GestureDetector` with `HitTestBehavior.opaque` on a minimum 60dp container.

### Drag sensitivity
- Drag starts after 4dp movement (not immediate) to avoid accidental drags from taps.
- Object follows finger without acceleration — 1:1 movement.
- No velocity-based throwing — object goes exactly where released.
- Return animation is gentle (400ms ease-in-out), not instant snap.

### Retry is always possible
- Dropped in wrong place: silent return to start. Child can try again immediately.
- No locked states, no wait timers before retry.
- Dropped correctly but celebration still playing: child can't accidentally "undo" — zone is locked.

---

## Cognitive Load Rules

### One task at a time
- One TTS instruction plays before interaction begins. Not repeated mid-task.
- Hint (after 8s idle) is the same instruction + animated arrow. Not new information.
- No text on screen during drag (only background scene and objects).

### No timers visible to child
- No countdown, no timer bar, no pressure.
- Sessions are logged with timestamps internally but never shown to child.

### No failure states
- Wrong object in zone: ignored. No red flash, no error sound, no "try again" prompt.
- Object misses zone: returns to start silently.
- The child experiences only: neutral (nothing happened) or success (celebration).

### Predictable outcomes
- Same action → same result, every time.
- No randomised negative feedback.
- Celebration randomisation (3 variations) is acceptable — all are positive.

---

## Sensory Considerations

### Haptic levels
- Every haptic is short (<100ms) and mild-to-medium intensity.
- No long buzzes or strong vibrations.
- Double-buzz on success: intentional, celebratory — 40ms each.
- Future: parent can disable haptics in settings (v2).

### Motion
- No spinning, rotating, or shaking animations.
- Particle burst (success): radial outward, no inward/spinning. 800ms duration.
- Tile flip (Memory): 3D Y-axis rotation, 250ms. Not faster.
- All transitions: fade or slide. No zoom-out or dramatic scale.

### Reduce Motion support
- Check `MediaQuery.of(context).disableAnimations`.
- If true: skip animations entirely, snap to states directly. TTS and haptics still play.

```dart
// Usage pattern:
final reduceMotion = MediaQuery.of(context).disableAnimations;
reduceMotion
  ? child.setPosition(target)
  : child.add(MoveEffect.to(target, EffectController(duration: 0.4)));
```

---

## Parent Dashboard Accessibility

- Standard WCAG AA compliance for all parent-facing UI (parent may have visual impairments).
- Screen reader support (Semantics widgets on all interactive elements).
- Tab order logical (top-to-bottom, left-to-right).
- Form errors announced via `Semantics(liveRegion: true)`.

---

## Review Checklist (per PR)

Before merging any UI component, verify:

- [ ] Hitbox ≥ 60dp for all interactive elements
- [ ] No hard-coded black on white text (use warm token colours)
- [ ] No animation faster than 150ms (child-facing)
- [ ] No sounds play without user intent (except TTS instruction on load + idle)
- [ ] New images reviewed for visual busyness
- [ ] Reduce Motion path tested
- [ ] Works with TTS disabled (no audio-only information)
- [ ] No failure state introduced
