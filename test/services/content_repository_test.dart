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
        repo.fetchVocabulary(),
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

    test('loaded scenario accepts images declared as placeholders', () async {
      final repo = AssetContentRepository(
        bundle: _FakeAssetBundle({
          'assets/scenarios/known_scenario.json': jsonEncode(
            _scenarioConfigJson(imagePath: 'assets/images/missing.webp'),
          ),
          'assets/images/placeholder_manifest.json': jsonEncode({
            'placeholder_images': ['assets/images/missing.webp'],
          }),
        }),
      );

      final loaded = await repo.fetchLoadedScenarioConfig(
        'assets/scenarios/known_scenario.json',
      );

      expect(loaded.usesPlaceholder('assets/images/missing.webp'), isTrue);
    });

    test(
      'loaded scenario rejects missing images outside the placeholder manifest',
      () async {
        final repo = AssetContentRepository(
          bundle: _FakeAssetBundle({
            'assets/scenarios/known_scenario.json': jsonEncode(
              _scenarioConfigJson(imagePath: 'assets/images/missing.webp'),
            ),
            'assets/images/placeholder_manifest.json': jsonEncode({
              'placeholder_images': <String>[],
            }),
          }),
        );

        await expectLater(
          repo.fetchLoadedScenarioConfig(
            'assets/scenarios/known_scenario.json',
          ),
          throwsA(isA<ContentAssetLoadException>()),
        );
      },
    );
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

Map<String, Object?> _scenarioConfigJson({required String imagePath}) {
  return {
    'scenario_id': 'known_scenario',
    'version': 1,
    'category': 'daily_life',
    'module': 'A',
    'title_th': 'สถานการณ์ทดสอบ',
    'background_image': imagePath,
    'tts_instruction': 'หยิบของ',
    'tts_celebration': 'เก่งมาก',
    'tts_hint': 'ลองหยิบของ',
    'interactables': [
      {
        'id': 'item',
        'image': imagePath,
        'is_target': true,
        'start_pos': {'x': 100, 'y': 100},
      },
    ],
    'target_zone': {'x': 500, 'y': 500, 'width': 100, 'height': 100},
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
