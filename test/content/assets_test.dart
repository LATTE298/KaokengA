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

    test('each scenario is well-formed and uses placeholder-safe images', () {
      final index = _readJson('assets/scenarios/index.json');
      final scenarios = index['scenarios'] as List<dynamic>;

      for (final rawScenario in scenarios) {
        final scenario = rawScenario as Map<String, dynamic>;
        final config = _readJson(scenario['config_url'] as String);
        final scenarioId = config['scenario_id'] as String;
        final interactables = config['interactables'] as List<dynamic>;
        final zones = (config['zones'] as List<dynamic>?) ?? const [];

        if (zones.isEmpty) {
          // โหมดโจทย์ชิ้นเดียว: ต้องมี target 1 ชิ้น + target_zone
          final targets = interactables.where(
            (rawItem) => (rawItem as Map<String, dynamic>)['is_target'] == true,
          );
          expect(targets.length, 1, reason: scenarioId);
          expect(config['target_zone'], isNotNull, reason: scenarioId);
        } else {
          // โหมด sort-all: ทุกชิ้นต้องผูก zone_id ที่ประกาศไว้จริง
          final zoneIds = {
            for (final z in zones) (z as Map<String, dynamic>)['id'],
          };
          for (final rawItem in interactables) {
            final item = rawItem as Map<String, dynamic>;
            expect(
              zoneIds.contains(item['zone_id']),
              isTrue,
              reason: '$scenarioId: ${item['id']} มี zone_id ไม่ตรงกับ zones',
            );
          }
          // pick_count (โจทย์สุ่มบางชิ้น) ต้องอยู่ในช่วงที่เล่นได้จริง
          final pickCount = config['pick_count'] as int?;
          if (pickCount != null) {
            expect(
              pickCount >= 2 && pickCount < interactables.length,
              isTrue,
              reason: '$scenarioId: pick_count=$pickCount ไม่สมเหตุสมผล',
            );
          }
          // cover_fit: พิกัด zones/start_pos เป็นสัดส่วน 0..1 ของรูป — ต้องอยู่ในช่วง
          if (config['cover_fit'] == true) {
            for (final z in zones) {
              final zone = z as Map<String, dynamic>;
              for (final k in ['x', 'y', 'width', 'height']) {
                final v = (zone[k] as num).toDouble();
                expect(
                  v >= 0 && v <= 1,
                  isTrue,
                  reason: '$scenarioId zone ${zone['id']}.$k=$v ต้องเป็น 0..1',
                );
              }
            }
            for (final rawItem in interactables) {
              final pos =
                  (rawItem as Map<String, dynamic>)['start_pos']
                      as Map<String, dynamic>;
              for (final k in ['x', 'y']) {
                final v = (pos[k] as num).toDouble();
                expect(
                  v >= 0 && v <= 1,
                  isTrue,
                  reason:
                      '$scenarioId ${rawItem['id']} start_pos.$k=$v ต้อง 0..1',
                );
              }
            }
          }
        }
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
    });

    test('vocabulary has 91 items and declared placeholder-safe images', () {
      final vocabulary = _readJson('assets/vocabulary/vocabulary.json');
      final items = vocabulary['items'] as List<dynamic>;

      // คลังคำจริงของทีม: เดิม 6 หมวด × 15 = 90; หมวดอาหารปรับ (ลบ สุกี้/ส้มตำ/ผัดไทย
      // เพิ่ม ซูชิ/ไข่ต้ม/หมูปิ้ง/บะหมี่) → 16 คำ รวมทั้งหมด 91 (feedback ครู 2026-07-13)
      expect(items.length, 91);
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
