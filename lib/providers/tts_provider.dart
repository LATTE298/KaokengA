import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/bundled_tts_client.dart';
import '../services/device_tts_service.dart';
import '../services/tts_service.dart';
// Picks tts_io.dart on native, tts_web.dart on web.
// The stub is never actually resolved at runtime; it satisfies the analyser.
import '../services/tts_platform_impl_stub.dart'
    if (dart.library.io) '../services/tts_io.dart'
    if (dart.library.html) '../services/tts_web.dart';

// ---------------------------------------------------------------------------
// API key
// ---------------------------------------------------------------------------

final googleTtsApiKeyProvider = Provider<String>((ref) {
  return const String.fromEnvironment('GOOGLE_TTS_API_KEY');
});

// ---------------------------------------------------------------------------
// HTTP client (shared)
// ---------------------------------------------------------------------------

final ttsHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

// ---------------------------------------------------------------------------
// TtsClient — falls back to NoOp when no API key is configured
// ---------------------------------------------------------------------------

final ttsClientProvider = Provider<TtsClient>((ref) {
  final apiKey = ref.watch(googleTtsApiKeyProvider);
  if (apiKey.isEmpty) return const NoOpTtsClient();
  return GoogleTtsClient(
    httpClient: ref.watch(ttsHttpClientProvider),
    apiKey: apiKey,
  );
});

// ---------------------------------------------------------------------------
// Cache — in-memory on web, file-based on native
// ---------------------------------------------------------------------------

final ttsAudioCacheProvider = Provider<TtsAudioCache>((ref) {
  return makeTtsCache();
});

// ---------------------------------------------------------------------------
// Player — Blob URL on web, just_audio stream on native
// ---------------------------------------------------------------------------

final ttsAudioPlayerProvider = Provider<TtsAudioPlayer>((ref) {
  return makeTtsPlayer();
});

// ---------------------------------------------------------------------------
// Device TTS — เครื่องเสียงสำรองในเครื่อง (flutter_tts)
// ---------------------------------------------------------------------------

final deviceTtsProvider = Provider<TtsSpeaker>((ref) {
  final service = DeviceTtsService();
  ref.onDispose(service.dispose);
  return service;
});

// ---------------------------------------------------------------------------
// Bundled clips — เสียงไทยอัดล่วงหน้าใน assets/tts (ดู docs/TTS_CLIPS.md)
// ---------------------------------------------------------------------------

final bundledTtsClientProvider = Provider<TtsClient>((ref) {
  return BundledTtsClient(network: ref.watch(ttsClientProvider));
});

// ---------------------------------------------------------------------------
// TtsSpeaker singleton (spec 13 §TTS Provider)
// ---------------------------------------------------------------------------

// ลำดับการหาเสียงต่อประโยค: cache → ไฟล์อัดล่วงหน้าใน assets/tts → Cloud TTS
// (เฉพาะเมื่อมีคีย์) → เสียง engine ในเครื่อง (fallback สุดท้าย) — แอปไม่มีทางเงียบ
// และประโยคที่อัดไว้แล้วเล่นทันทีไม่ต้องต่อเน็ต/ไม่เสียค่า API
final ttsServiceProvider = Provider<TtsSpeaker>((ref) {
  final service = TtsService(
    client: ref.watch(bundledTtsClientProvider),
    cache: ref.watch(ttsAudioCacheProvider),
    player: ref.watch(ttsAudioPlayerProvider),
    fallback: ref.watch(deviceTtsProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
