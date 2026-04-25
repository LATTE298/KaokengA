# 03 — User Flows

> **Version:** 0.1-MVP | **Status:** Planning
> Every user action (tap, drag, swipe, long-press) is listed. Every system response is listed.
> If it's not here, it's not implemented.

---

## Flow 1 — Child: App Launch → Play Scenario

```
1. Child picks up tablet.
2. App opens. SplashScreen shows.
   → System: logo animates in (800ms ease-in-out scale 0.8→1.0).
   → System: plays TTS greeting "สวัสดีครับ" (soft, warm tone).
   → System: waits 1.5s.
   → System: navigates to ModeSelectScreen.

3. Child sees 3 module cards.
   → System: no auto-play TTS here (too overwhelming on repeat visits).

4. Child taps Module A card ("ชีวิตประจำวัน").
   → System: card scale animation (1.0 → 1.04 → 1.0, 200ms).
   → System: plays TTS card description: "มาลองทำกิจกรรมในชีวิตประจำวันกันนะครับ".
   → System: navigates to ModuleAScreen after 600ms (letting TTS start).

5. Child sees scenario card grid.
   → System: shows only enabled scenarios (from Firestore).
   → System: first scenario card is slightly highlighted (pulse animation, 2s loop).

6. Child taps a scenario card (e.g. "ช่วยหยิบของที่เซเว่น").
   → System: card ripple animation.
   → System: plays TTS scenario intro: "น้องช่วยหยิบนมกล่องสีน้ำเงินใส่ตะกร้าให้หน่อยนะครับ".
   → System: navigates to ScenarioGameScreen (cross-fade 300ms).
   → System: fetches ScenarioConfig JSON (cached locally; no loading spinner for <200ms).
   → System: Flame canvas loads background image, places interactables at start_pos.

7. Child sees the scene. TTS instruction plays automatically (1s after screen load).
   → System: instruction plays once. Repeats if no interaction for 8 seconds.
   → System: target object has a gentle pulse glow (yellow outline, 1.5s loop).

8. Child touches and drags the target object (blue milk carton).
   → System: object attaches to finger (z-lifted, slight scale up 1.05).
   → System: haptic pulse (short, 40ms, medium intensity) on grab.
   → System: pulse glow on drop zone activates.

   EDGE CASE A — Child drags but lifts finger outside drop zone:
   → System: object smoothly tweens back to start_pos (400ms ease-in-out).
   → System: no negative feedback, no sound, no visual failure state.

   EDGE CASE B — Child drags a distractor into the drop zone:
   → System: distractor enters drop zone visual boundary.
   → System: nothing happens (collision is type-checked; distractors are ignored).
   → System: distractor tweens back to start_pos on release (400ms).

   EDGE CASE C — Child drags nothing for 15s total (after 8s re-prompt):
   → System: plays TTS again + points animated arrow toward target object.
   → System: arrow pulses 3× then disappears. Repeats at 15s intervals.

9. Child drops target into drop zone.
   → System: collision detected (Flame hitbox overlap).
   → System: SUCCESS sequence fires:
      a. Object snaps to centre of drop zone (200ms).
      b. Particle burst (yellow + blue stars, 60 particles, 800ms).
      c. Drop zone glows gold (500ms ease-out).
      d. Haptic: double buzz (40ms, pause 80ms, 40ms).
      e. TTS plays: "เก่งมากเลยนะครับ! 🌟" (celebration voice).
      f. Screen holds for 2.5s (child enjoys the moment).
      g. Fade to ModuleAScreen (500ms).

   → System: logs session data to Firestore:
      { scenario_id, timestamp, duration_ms, drag_path_points[] }
```

---

## Flow 2 — Child: Memory Game (Module B)

```
1. Child taps Module B card on ModeSelectScreen.
   → System: navigates to ModuleBScreen.
   → System: shows single pack card (MVP).

2. Child taps the pack card.
   → System: navigates to MemoryGameScreen.
   → System: TTS: "มาจับคู่รูปภาพกันนะครับ".
   → System: 16 face-down tiles arranged in 4×4 grid.
   → System: tiles animate in (stagger, 30ms per tile, flip up then down).

3. Child taps a tile.
   → System: tile flips face-up (3D flip animation, 250ms).
   → System: haptic pulse (short, 30ms).
   → System: image + TTS name plays (e.g. "ช้าง").

4. Child taps a second tile.
   → System: second tile flips face-up.
   → System: TTS name plays.

   MATCH:
   → System: both tiles glow gold (400ms).
   → System: haptic double buzz.
   → System: TTS: "จับคู่ได้แล้ว!".
   → System: tiles stay face-up (non-interactive, dimmed).

   NO MATCH:
   → System: both tiles held face-up for 1.2s (child sees both).
   → System: both flip face-down (250ms).
   → System: no failure sound; no negative feedback.

5. All 8 pairs found.
   → System: completion animation (confetti, 2s).
   → System: TTS: "เก่งมากเลย! จับคู่ได้ครบแล้ว!".
   → System: score card shows (pairs: 8/8, no timer shown in MVP).
   → System: auto-return to ModuleBScreen after 4s.

   → System: logs { pack_id, timestamp, duration_ms, flip_count } to Firestore.
```

---

## Flow 3 — Child: Sound Board (Module C)

```
1. Child taps Module C card on ModeSelectScreen.
   → System: navigates to ModuleCScreen.
   → System: TTS: "มาเรียนรู้คำศัพท์กันนะครับ".

2. Child sees grid of vocabulary cards (5 columns × 6 rows = 30 items).
   → System: no auto-play; child is in full control.

3. Child taps any vocabulary card.
   → System: card scale animation (1.0 → 1.08 → 1.0, 150ms).
   → System: haptic pulse (short, 30ms).
   → System: TTS plays the word clearly (e.g. "แมว" with natural prosody).
   → System: card temporarily highlighted (blue outline, fades in 1s).

4. Child taps same card again.
   → System: repeats TTS. No limit on replays.

5. Child taps back arrow.
   → System: navigates to ModeSelectScreen.
   → System: any playing TTS is cancelled.
```

---

## Flow 4 — Parent: First-Time Setup

```
1. Parent long-presses app logo on ModeSelectScreen for 3s.
   → System: progress ring animates around logo (3s, blue).
   → System: at 3s completion: vibration (medium, 100ms).
   → System: navigates to ParentGateScreen.

2. ParentGateScreen shows: "ส่วนนี้สำหรับผู้ปกครอง" + large "เข้าสู่ส่วนผู้ปกครอง" button.
   → System: no biometric in MVP (see roadmap).

3. Parent taps "เข้าสู่ส่วนผู้ปกครอง".
   → System: navigates to AuthScreen (register tab default for new user).

4. Parent fills in: email + password.
   → System: real-time validation (email format, password ≥8 chars).
   → System: "สร้างบัญชี" button active only when both valid.

5. Parent taps "สร้างบัญชี".
   → System: loading spinner on button.
   → System: Firebase Auth createUserWithEmailAndPassword().

   SUCCESS:
   → System: creates Firestore user doc at /users/{uid}.
   → System: navigates to DashboardScreen (Log tab).
   → System: shows empty state: "ยังไม่มีข้อมูลการเล่น เริ่มเล่นกับน้องเลยนะครับ".

   ERROR (email already used):
   → System: shows inline error "อีเมลนี้มีบัญชีแล้ว กรุณาเข้าสู่ระบบ".
   → System: switches to Login tab.

   ERROR (network):
   → System: shows inline error "ไม่มีการเชื่อมต่ออินเทอร์เน็ต".
```

---

## Flow 5 — Parent: Login (Return Visit)

```
1. Parent long-presses logo → ParentGateScreen → taps entry button.
   → System: navigates to AuthScreen.
   → System: if previous session active (Firebase Auth persistence): skip directly to DashboardScreen.

2. Parent sees Login tab (default if previously registered).

3. Parent fills email + password.

4. Parent taps "เข้าสู่ระบบ".
   → System: Firebase signInWithEmailAndPassword().

   SUCCESS → DashboardScreen (Log tab, newest sessions first).

   ERROR (wrong password):
   → System: inline error "รหัสผ่านไม่ถูกต้อง".
   → System: password field clears, retains focus.

   ERROR (no account):
   → System: inline error "ไม่พบบัญชีนี้ กรุณาสร้างบัญชีใหม่".
```

---

## Flow 6 — Parent: Review Activity Log

```
1. Parent is on DashboardScreen, Log tab (default).

2. Sees list: each row = scenario name (Thai) + date + duration.
   → System: data from Firestore /sessions/{uid}/... ordered by timestamp desc.
   → System: shows 20 rows; "โหลดเพิ่มเติม" button at bottom (pagination).

3. Parent taps a row.
   → System: MVP: no drill-down detail view. Row is not tappable. (Post-MVP: session replay).

4. Parent taps "โหลดเพิ่มเติม".
   → System: fetches next 20 records.
   → System: appends to list (no page reload).
```

---

## Flow 7 — Parent: Toggle Scenario On/Off

```
1. Parent navigates to Scenarios tab.
   → System: loads list of all scenarios from Firestore (ordered by category, then scenario_id).

2. Parent sees: scenario name + toggle switch + category badge.
   → System: toggle reflects current enabled state from Firestore.

3. Parent taps a toggle.
   → System: optimistic UI update (toggle flips immediately).
   → System: writes { enabled: bool } to Firestore /scenarios/{scenario_id}/userSettings/{uid}.

   SUCCESS: persisted. Child app receives real-time update via Firestore listener.

   ERROR (network): toggle reverts to previous state. Snackbar: "ไม่สามารถบันทึกได้ กรุณาลองใหม่".
```

---

## Flow 8 — Parent: Logout

```
1. Parent taps profile icon (top-right on Dashboard).
   → System: bottom sheet appears: "ออกจากระบบ" button + cancel.

2. Parent taps "ออกจากระบบ".
   → System: Firebase Auth signOut().
   → System: clears local Riverpod auth state.
   → System: navigates to ModeSelectScreen (child mode).
```

---

## Edge Case Catalogue

| ID | Scenario | System Response |
|---|---|---|
| E-01 | App backgrounded mid-drag | Object resets to start_pos on resume |
| E-02 | Firestore unavailable on scenario load | Shows cached scenario (last fetched); falls back to bundled defaults if never fetched |
| E-03 | TTS API timeout | Silent failure; no audio plays; game continues |
| E-04 | Child rotates device mid-game | Flame canvas redraws; object positions recalculated by percentage of canvas |
| E-05 | Two fingers on screen simultaneously | First touch wins; second finger ignored during drag |
| E-06 | Parent session expires mid-dashboard | Soft redirect to AuthScreen with message "กรุณาเข้าสู่ระบบใหม่" |
| E-07 | Scenario image fails to load | Shows yellow placeholder with Thai name text |
| E-08 | Child rapidly taps all Sound Board items | TTS queue: cancel current, play new immediately (no queue buildup) |
