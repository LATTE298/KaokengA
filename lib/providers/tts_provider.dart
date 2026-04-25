import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/tts_service.dart';

final googleTtsApiKeyProvider = Provider<String>((ref) {
  return const String.fromEnvironment('GOOGLE_TTS_API_KEY');
});

final ttsHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final ttsClientProvider = Provider<TtsClient>((ref) {
  final apiKey = ref.watch(googleTtsApiKeyProvider);
  if (apiKey.isEmpty) return const NoOpTtsClient();
  return GoogleTtsClient(
    httpClient: ref.watch(ttsHttpClientProvider),
    apiKey: apiKey,
  );
});

final ttsAudioCacheProvider = Provider<TtsAudioCache>((ref) {
  return LocalTtsAudioCache();
});

final ttsAudioPlayerProvider = Provider<TtsAudioPlayer>((ref) {
  return JustAudioTtsPlayer();
});

// Singleton TTS service (spec 13 §TTS Provider).
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(
    client: ref.watch(ttsClientProvider),
    cache: ref.watch(ttsAudioCacheProvider),
    player: ref.watch(ttsAudioPlayerProvider),
  );
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
