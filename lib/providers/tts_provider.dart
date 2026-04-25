import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/tts_service.dart';

// Singleton TTS service (spec 13 §TTS Provider).
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});
