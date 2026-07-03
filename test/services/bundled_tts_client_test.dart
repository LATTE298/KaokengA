import 'dart:convert';

import 'package:daily_life/services/bundled_tts_client.dart';
import 'package:daily_life/services/tts_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BundledTtsClient', () {
    test('returns bundled bytes when text is in the manifest', () async {
      final client = BundledTtsClient(
        bundle: _FakeBundle({
          kTtsManifestPath: _utf8Data('{"clips": {"แมว": "word_cat.opus"}}'),
          '$kTtsAssetDir/word_cat.opus': _byteData([1, 2, 3]),
        }),
        network: _FailingNetwork(),
      );

      expect(await client.synthesize('แมว'), [1, 2, 3]);
    });

    test('delegates to network when text is not in the manifest', () async {
      final network = _RecordingNetwork();
      final client = BundledTtsClient(
        bundle: _FakeBundle({kTtsManifestPath: _utf8Data('{"clips": {}}')}),
        network: network,
      );

      expect(await client.synthesize('หมา'), [9]);
      expect(network.requests, ['หมา']);
    });

    test('falls through to network when the audio file is missing', () async {
      // อยู่ใน manifest แล้วแต่ทีมยังไม่ได้วางไฟล์เสียง — ต้องไม่พัง แค่ใช้ทางถัดไป
      final network = _RecordingNetwork();
      final client = BundledTtsClient(
        bundle: _FakeBundle({
          kTtsManifestPath: _utf8Data('{"clips": {"แมว": "word_cat.opus"}}'),
        }),
        network: network,
      );

      expect(await client.synthesize('แมว'), [9]);
      expect(network.requests, ['แมว']);
    });

    test('missing manifest behaves as all-miss without crashing', () async {
      final network = _RecordingNetwork();
      final client = BundledTtsClient(
        bundle: _FakeBundle({}),
        network: network,
      );

      expect(await client.synthesize('นก'), [9]);
      expect(network.requests, ['นก']);
    });

    test('throws a typed error when nothing can provide audio', () async {
      final client = BundledTtsClient(bundle: _FakeBundle({}));

      expect(() => client.synthesize('ปลา'), throwsA(isA<TtsException>()));
    });
  });
}

ByteData _utf8Data(String s) => _byteData(utf8.encode(s));

ByteData _byteData(List<int> bytes) =>
    ByteData.view(Uint8List.fromList(bytes).buffer);

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.assets);

  final Map<String, ByteData> assets;

  @override
  Future<ByteData> load(String key) async {
    final data = assets[key];
    if (data == null) throw StateError('missing asset $key');
    return data;
  }
}

class _RecordingNetwork implements TtsClient {
  final requests = <String>[];

  @override
  Future<Uint8List> synthesize(String text) async {
    requests.add(text);
    return Uint8List.fromList([9]);
  }
}

class _FailingNetwork implements TtsClient {
  @override
  Future<Uint8List> synthesize(String text) async {
    throw StateError('network should not be called when the asset exists');
  }
}
