import 'dart:typed_data';

// Placeholder TTS service (spec 08).
//
// The MVP target is Google Cloud Text-to-Speech (th-TH-Neural2-C, 0.9 rate,
// +2.0st pitch, OGG_OPUS). A full implementation needs:
//   * an HTTP client to call the TTS REST API (API key injected at runtime),
//   * SHA-256 cache keys over the Thai string (spec 08 §Caching Strategy),
//   * an audio player for OPUS output,
//   * cancel-on-navigate semantics (spec 08 §Audio Rules).
//
// This scaffold gives every callsite a stable shape; replacing the body is a
// single-file swap once the TTS API key is configured.
class TtsService {
  Future<void> speak(String text) async {
    // TODO(tts): fetch OPUS bytes from cache or Cloud TTS, then play.
    // For now: no-op so the UI can wire up without audio.
  }

  Future<void> cancel() async {
    // TODO(tts): stop any in-flight playback.
  }

  Future<Uint8List> synth(String text) async {
    // TODO(tts): return cached or freshly-generated OGG_OPUS bytes.
    throw UnimplementedError('TtsService.synth pending Google TTS wiring');
  }

  void dispose() {}
}
