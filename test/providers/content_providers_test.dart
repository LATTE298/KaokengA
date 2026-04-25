import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/services/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('findScenarioSummary', () {
    const summaries = [
      ScenarioSummary(
        scenarioId: 'known_scenario',
        titleTh: 'สถานการณ์ทดสอบ',
        category: 'daily_life',
        module: 'A',
        configUrl: 'assets/scenarios/known_scenario.json',
        thumbnailUrl: 'assets/images/known_scenario.webp',
        version: 1,
        published: true,
      ),
    ];

    test('returns the matching scenario summary', () {
      final summary = findScenarioSummary(summaries, 'known_scenario');

      expect(summary.scenarioId, 'known_scenario');
    });

    test('throws a typed exception for an unknown scenario id', () {
      expect(
        () => findScenarioSummary(summaries, 'missing_scenario'),
        throwsA(isA<ContentNotFoundException>()),
      );
    });
  });
}
