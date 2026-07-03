import 'dart:typed_data';

import 'package:daily_life/providers/tts_provider.dart';
import 'package:daily_life/services/tts_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ต้องมี binding ก่อน: DeviceTtsService สร้าง MethodChannel และ chain นี้อ่าน
  // manifest จริงจาก rootBundle
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ttsServiceProvider', () {
    test(
      'no API key: text without a bundled clip flows to the device speaker',
      () async {
        // ใน test ไม่มี dart-define → คีย์ว่าง เหมือน build ที่ลืมใส่คีย์จริง
        final fallback = _FakeSpeaker();
        final container = ProviderContainer(
          overrides: [
            ttsAudioCacheProvider.overrideWithValue(_FakeCache()),
            ttsAudioPlayerProvider.overrideWithValue(_FakePlayer()),
            deviceTtsProvider.overrideWithValue(fallback),
          ],
        );
        addTearDown(container.dispose);
        expect(container.read(googleTtsApiKeyProvider), isEmpty);

        // เดินครบ chain จริง: manifest (ไม่มีประโยคนี้) → NoOp client (คีย์ว่าง)
        // → bytes ว่าง → ต้องตกมาที่เสียงในเครื่อง ไม่ใช่เงียบ
        await container
            .read(ttsServiceProvider)
            .speak('ประโยคทดสอบที่ไม่ได้อัดไว้');

        expect(fallback.spoken, ['ประโยคทดสอบที่ไม่ได้อัดไว้']);
      },
    );

    test('with API key uses the cloud TTS pipeline', () {
      final container = ProviderContainer(
        overrides: [
          googleTtsApiKeyProvider.overrideWithValue('test-key'),
          ttsAudioCacheProvider.overrideWithValue(_FakeCache()),
          ttsAudioPlayerProvider.overrideWithValue(_FakePlayer()),
          deviceTtsProvider.overrideWithValue(_FakeSpeaker()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(ttsServiceProvider), isA<TtsService>());
      expect(container.read(ttsClientProvider), isA<GoogleTtsClient>());
    });
  });
}

class _FakeSpeaker implements TtsSpeaker {
  final spoken = <String>[];

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}
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
