import 'dart:typed_data';

import 'package:daily_life/providers/tts_provider.dart';
import 'package:daily_life/services/device_tts_service.dart';
import 'package:daily_life/services/tts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // DeviceTtsService สร้าง MethodChannel ตอน construct — ต้องมี binding ก่อน
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ttsServiceProvider', () {
    test('no API key falls back to the on-device speaker, not silence', () {
      // ใน test ไม่มี dart-define → คีย์ว่าง เหมือน build ที่ลืมใส่คีย์จริง
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(googleTtsApiKeyProvider), isEmpty);
      final speaker = container.read(ttsServiceProvider);
      expect(speaker, isA<DeviceTtsService>());
      // ต้องเป็นตัวเดียวกับ deviceTtsProvider (แชร์ instance ไม่สร้างซ้อน)
      expect(speaker, same(container.read(deviceTtsProvider)));
    });

    test('with API key uses the cloud TTS pipeline', () {
      final container = ProviderContainer(
        overrides: [
          googleTtsApiKeyProvider.overrideWithValue('test-key'),
          ttsAudioCacheProvider.overrideWithValue(_FakeCache()),
          ttsAudioPlayerProvider.overrideWithValue(_FakePlayer()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(ttsServiceProvider), isA<TtsService>());
    });
  });
}

class _FakeCache implements TtsAudioCache {
  @override
  Future<void> enforceMaxSize() async {}

  @override
  Future<Uint8List?> get(String key) async => null;

  @override
  Future<void> put(String key, Uint8List bytes) async {}
}

class _FakePlayer implements TtsAudioPlayer {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> playBytes(Uint8List bytes) async {}

  @override
  Future<void> stop() async {}
}
