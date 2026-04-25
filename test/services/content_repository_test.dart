import 'dart:convert';

import 'package:daily_life/services/content_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetContentRepository', () {
    test('loads scenario index from bundled assets', () async {
      final repo = AssetContentRepository(
        bundle: _FakeAssetBundle({
          'assets/scenarios/index.json': jsonEncode({
            'scenarios': [_scenarioSummaryJson()],
          }),
        }),
      );

      final scenarios = await repo.fetchScenarioIndex();

      expect(scenarios.single.scenarioId, 'known_scenario');
    });

    test('throws typed not-found error for missing assets', () async {
      final repo = AssetContentRepository(bundle: _FakeAssetBundle({}));

      await expectLater(
        repo.fetchDefaultMemoryPack(),
        throwsA(isA<ContentNotFoundException>()),
      );
    });

    test('throws typed malformed-json error for invalid JSON', () async {
      final repo = AssetContentRepository(
        bundle: _FakeAssetBundle({'assets/scenarios/index.json': '{invalid'}),
      );

      await expectLater(
        repo.fetchScenarioIndex(),
        throwsA(isA<ContentMalformedJsonException>()),
      );
    });

    test(
      'throws typed malformed-json error for invalid content shape',
      () async {
        final repo = AssetContentRepository(
          bundle: _FakeAssetBundle({
            'assets/scenarios/index.json': jsonEncode({'scenarios': {}}),
          }),
        );

        await expectLater(
          repo.fetchScenarioIndex(),
          throwsA(isA<ContentMalformedJsonException>()),
        );
      },
    );

    test('throws typed remote-url error for remote config URLs', () async {
      final repo = AssetContentRepository(bundle: _FakeAssetBundle({}));

      await expectLater(
        repo.fetchScenarioConfig('https://example.com/scenario.json'),
        throwsA(isA<ContentRemoteUrlNotSupportedException>()),
      );
    });
  });
}

Map<String, Object?> _scenarioSummaryJson() {
  return {
    'scenario_id': 'known_scenario',
    'title_th': 'สถานการณ์ทดสอบ',
    'category': 'daily_life',
    'module': 'A',
    'config_url': 'assets/scenarios/known_scenario.json',
    'thumbnail_url': 'assets/images/known_scenario.webp',
    'version': 1,
    'published': true,
  };
}

class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    final bytes = utf8.encode(value);
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}
