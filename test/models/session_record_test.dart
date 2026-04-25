import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionRecord JSON round-trip', () {
    test('Module A with drag interactions', () {
      final record = SessionRecord(
        sessionId: 'sess-a',
        uid: 'uid-1',
        scenarioId: '711_milk_001',
        module: 'daily_life',
        startedAt: '2026-04-20T10:00:00.000Z',
        endedAt: '2026-04-20T10:00:42.000Z',
        durationMs: 42000,
        completed: true,
        dragInteractions: const [
          DragInteraction(
            interactionId: 'int-1',
            objectId: 'milk_carton',
            wasTarget: true,
            wasSuccessful: true,
            durationMs: 3200,
            straightnessScore: 0.87,
            pathPoints: [
              GamePosition(x: 10, y: 20),
              GamePosition(x: 400, y: 300),
            ],
          ),
        ],
      );
      final json = record.toJson();
      expect(json['session_id'], 'sess-a');
      expect(json['drag_interactions'], isA<List>());
      expect(json.containsKey('match_events'), isFalse);
      final decoded = SessionRecord.fromJson(json);
      expect(decoded, record);
    });

    test('Module B with match events', () {
      final record = SessionRecord(
        sessionId: 'sess-b',
        uid: 'uid-1',
        scenarioId: 'thai_animals',
        module: 'memory',
        startedAt: '2026-04-20T10:00:00.000Z',
        endedAt: '2026-04-20T10:02:30.000Z',
        durationMs: 150000,
        completed: true,
        pairsMatched: 8,
        totalPairs: 8,
        matchEvents: const [
          MatchEvent(pairId: 'p1', matched: false, atMs: 1200),
          MatchEvent(pairId: 'p1', matched: true, atMs: 5800),
        ],
      );
      final json = record.toJson();
      expect(json['pairs_matched'], 8);
      expect(json['total_pairs'], 8);
      expect(json['match_events'], isA<List>());
      final decoded = SessionRecord.fromJson(json);
      expect(decoded, record);
    });
  });
}
