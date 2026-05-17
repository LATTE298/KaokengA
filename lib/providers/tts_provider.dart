import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
// TtsService singleton (spec 13 §TTS Provider)
// ---------------------------------------------------------------------------

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(
    client: ref.watch(ttsClientProvider),
    cache: ref.watch(ttsAudioCacheProvider),
    player: ref.watch(ttsAudioPlayerProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
