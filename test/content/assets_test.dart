import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled content assets', () {
    late final Set<String> placeholderPaths;

    setUpAll(() {
      final manifest = _readJson('assets/images/placeholder_manifest.json');
      placeholderPaths = {
        for (final path in manifest['placeholder_images'] as List<dynamic>)
          path as String,
      };
    });

    test('scenario index config URLs point to existing bundled JSON files', () {
      final index = _readJson('assets/scenarios/index.json');
      final scenarios = index['scenarios'] as List<dynamic>;

      expect(scenarios, isNotEmpty);
      for (final rawScenario in scenarios) {
        final scenario = rawScenario as Map<String, dynamic>;
        final configUrl = scenario['config_url'] as String;

        expect(configUrl.startsWith('assets/scenarios/'), isTrue);
        expect(File(configUrl).existsSync(), isTrue, reason: configUrl);
        _expectImageAvailableOrPlaceholder(
          scenario['thumbnail_url'] as String,
          placeholderPaths,
        );
      }
    });

    test(
      'each scenario has one target and declared placeholder-safe images',
      () {
        final index = _readJson('assets/scenarios/index.json');
        final scenarios = index['scenarios'] as List<dynamic>;

        for (final rawScenario in scenarios) {
          final scenario = rawScenario as Map<String, dynamic>;
          final config = _readJson(scenario['config_url'] as String);
          final interactables = config['interactables'] as List<dynamic>;
          final targets = interactables.where(
            (rawItem) => (rawItem as Map<String, dynamic>)['is_target'] == true,
          );

          expect(targets.length, 1, reason: config['scenario_id'] as String);
          _expectImageAvailableOrPlaceholder(
            config['background_image'] as String,
            placeholderPaths,
          );
          for (final rawItem in interactables) {
            final item = rawItem as Map<String, dynamic>;
            _expectImageAvailableOrPlaceholder(
              item['image'] as String,
              placeholderPaths,
            );
          }
        }
      },
    );

    test('vocabulary has 90 items and declared placeholder-safe images', () {
      final vocabulary = _readJson('assets/vocabulary/vocabulary.json');
      final items = vocabulary['items'] as List<dynamic>;

      // คลังคำจริงของทีม: 6 หมวด × 15 คำ (จาก zip "NSC คำศัพท์ + ภาพ")
      expect(items.length, 90);
      for (final rawItem in items) {
        final item = rawItem as Map<String, dynamic>;
        _expectImageAvailableOrPlaceholder(
          item['image'] as String,
          placeholderPaths,
        );
      }
    });

    test('placeholder manifest does not contain stale real files', () {
      for (final path in placeholderPaths) {
        expect(File(path).existsSync(), isFalse, reason: path);
      }
    });
  });
}

Map<String, dynamic> _readJson(String path) {
  return jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
}

void _expectImageAvailableOrPlaceholder(
  String path,
  Set<String> placeholderPaths,
) {
  final exists = File(path).existsSync();
  final explicitlyPlaceholder = placeholderPaths.contains(path);

  expect(
    exists || explicitlyPlaceholder,
    isTrue,
    reason: '$path must exist or be declared in placeholder_manifest.json',
  );
}
