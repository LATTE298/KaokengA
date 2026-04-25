# 08 — TTS & Audio Spec

> **Version:** 0.1-MVP | **Status:** Planning

---

## Philosophy

All audio is generated on-demand via Neural TTS. No `.mp3` files are bundled in the app.
This keeps the app small and allows copy to be updated without a release.

---

## TTS Provider

**MVP choice: Google Cloud Text-to-Speech**
- Voice: `th-TH-Neural2-C` (female, warm, clear)
- Alternative: `th-TH-Neural2-B` (male) — configurable per parent account in v2
- Audio encoding: `OGG_OPUS` (smallest, best quality)
- Speaking rate: `0.9` (slightly slower than default; better for children)
- Pitch: `+2.0st` (slightly warmer tone)

```dart
class TtsService {
  // Singleton; injected via Riverpod
  
  Future<void> speak(String text) async { ... }
  Future<void> cancel() async { ... }
  void dispose() { ... }

  // Internal: checks cache first, generates if miss, plays
  Future<Uint8List> _getAudio(String text) async { ... }
}
```

---

## Caching Strategy

- Generated audio is cached locally by text hash (SHA-256 of the Thai string).
- Cache key: `tts_${sha256(text)}.opus`
- Storage: `path_provider` app documents directory.
- TTL: forever (text doesn't change; scenario JSON version bump clears cache).
- Max cache size: 50MB (LRU eviction).

---

## Audio Rules

| Rule | Value | Reason |
|---|---|---|
| Max volume | 80% of device volume | Protect children's hearing |
| Normalisation | EBU R128, -16 LUFS | Consistent perceived loudness |
| Sudden loud sounds | NEVER | Startling = distress for some children |
| Concurrent audio | Cancel previous, play new | No audio overlap |
| TTS during drag | Don't interrupt drag with TTS | Preserve focus during motor task |
| Silence on app background | Pause all TTS | Respect system audio interruption |

---

## All TTS Strings (MVP)

These strings are defined in `lib/l10n/tts_strings_th.dart` (not ARB — kept separate from UI strings for clarity).

### System / Navigation

```dart
const kTtsSplashGreeting    = 'สวัสดีครับ';
const kTtsModuleADesc       = 'มาลองทำกิจกรรมในชีวิตประจำวันกันนะครับ';
const kTtsModuleBDesc       = 'มาเล่นเกมจับคู่ภาพกันนะครับ';
const kTtsModuleCDesc       = 'มาเรียนรู้คำศัพท์ใหม่กันนะครับ';
const kTtsMemoryStart       = 'มาจับคู่รูปภาพกันนะครับ';
const kTtsSoundBoardStart   = 'มาเรียนรู้คำศัพท์กันนะครับ';
```

### Scenario (per-scenario, from JSON `tts_instruction` field)

```
"น้องช่วยหยิบนมกล่องสีน้ำเงินใส่ตะกร้าให้หน่อยนะครับ"
"น้องช่วยแยกขยะใส่ถังที่ถูกต้องให้หน่อยนะครับ"
"น้องช่วยวางผลไม้ลงในจานให้หน่อยนะครับ"
```

### Celebrations

```dart
const kTtsCelebration1 = 'เก่งมากเลยนะครับ! น้องทำได้แล้ว!';
const kTtsCelebration2 = 'ดีมากเลยครับ! เยี่ยมมากเลย!';
const kTtsCelebration3 = 'น้องทำได้ดีมากครับ! เก่งมากๆ!';
// Selected randomly on each success
```

### Memory Game

```dart
const kTtsMemoryMatch    = 'จับคู่ได้แล้ว!';
const kTtsMemoryComplete = 'เก่งมากเลย! จับคู่ได้ครบแล้ว!';
```

### Vocabulary Items (30 items — sample)

```dart
const kVocabItems = {
  'cat':      'แมว',
  'dog':      'หมา',
  'elephant': 'ช้าง',
  'tiger':    'เสือ',
  'fish':     'ปลา',
  'bird':     'นก',
  // ... 24 more
};
```

---

## Haptic Feedback Map

| Event | Pattern | Duration |
|---|---|---|
| Grab interactable | `selectionClick()` | ~10ms |
| Drop in zone (pre-success) | `lightImpact()` | ~20ms |
| SUCCESS | `heavyImpact()` × 2, gap 80ms | ~40ms + 80ms + 40ms |
| Memory tile flip | `selectionClick()` | ~10ms |
| Memory match | `mediumImpact()` | ~30ms |
| Sound board tap | `selectionClick()` | ~10ms |
| Parent gate long-press complete | `mediumImpact()` | ~100ms |

All haptics use Flutter's `HapticFeedback` API. No custom vibration patterns in MVP.

---

## Platform Channel (Double Buzz for Success)

Flutter's `HapticFeedback.heavyImpact()` doesn't support delays. Implement via platform channel:

```dart
// lib/services/haptic_service.dart
class HapticService {
  static const _channel = MethodChannel('dailylife/haptic');

  static Future<void> successBuzz() async {
    await _channel.invokeMethod('doubleBuzz', {'delay': 80});
  }
}
```

Android native (`MainActivity.kt`):
```kotlin
channel.setMethodCallHandler { call, result ->
  if (call.method == "doubleBuzz") {
    val delay = call.argument<Int>("delay") ?: 80
    vibrate(40)
    Handler(Looper.getMainLooper()).postDelayed({ vibrate(40) }, delay.toLong())
    result.success(null)
  }
}
```
