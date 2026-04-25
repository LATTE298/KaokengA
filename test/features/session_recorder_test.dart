import 'package:daily_life/features/sessions/session_recorder.dart';
import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/memory_pack.dart';
import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:daily_life/services/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionRecorder', () {
    test('records daily-life completion with injected values', () async {
      final writer = _FakeSessionWriter();
      final recorder = SessionRecorder(
        repository: writer,
        clock: () => DateTime.utc(2026, 4, 20, 10, 0, 42),
        uuidFactory: _uuidSequence(['interaction-1']),
      );

      await recorder.recordDailyLifeCompleted(
        DailyLifeCompletedEvent(
          session: ActiveSession(
            sessionId: 'session-1',
            uid: 'uid-1',
            module: kModuleDailyLife,
            contentId: '711_milk_001',
            startedAt: DateTime.utc(2026, 4, 20, 10),
          ),
          config: _scenario(),
          dragPath: const [GamePosition(x: 1, y: 2), GamePosition(x: 3, y: 4)],
        ),
      );

      final record = writer.records.single;
      expect(record.sessionId, 'session-1');
      expect(record.uid, 'uid-1');
      expect(record.scenarioId, '711_milk_001');
      expect(record.module, kModuleDailyLife);
      expect(record.startedAt, '2026-04-20T10:00:00.000Z');
      expect(record.endedAt, '2026-04-20T10:00:42.000Z');
      expect(record.durationMs, 42000);
      expect(record.dragInteractions.single.interactionId, 'interaction-1');
      expect(record.dragInteractions.single.objectId, 'milk_carton');
      expect(record.dragInteractions.single.pathPoints, hasLength(2));
    });

    test('records memory completion with match events', () async {
      final writer = _FakeSessionWriter();
      final recorder = SessionRecorder(
        repository: writer,
        clock: () => DateTime.utc(2026, 4, 20, 10, 2, 30),
        uuidFactory: () => 'unused',
      );
      const events = [
        MatchEvent(pairId: 'cat', matched: false, atMs: 1000),
        MatchEvent(pairId: 'cat', matched: true, atMs: 3000),
      ];

      await recorder.recordMemoryCompleted(
        MemoryCompletedEvent(
          session: ActiveSession(
            sessionId: 'session-2',
            uid: 'uid-1',
            module: kModuleMemory,
            contentId: 'thai_animals',
            startedAt: DateTime.utc(2026, 4, 20, 10),
          ),
          pack: _memoryPack(),
          matchEvents: events,
        ),
      );

      final record = writer.records.single;
      expect(record.sessionId, 'session-2');
      expect(record.scenarioId, 'thai_animals');
      expect(record.module, kModuleMemory);
      expect(record.durationMs, 150000);
      expect(record.pairsMatched, 2);
      expect(record.totalPairs, 2);
      expect(record.matchEvents, events);
    });

    test('null uid skips repository writes', () async {
      final writer = _FakeSessionWriter();
      final recorder = SessionRecorder(
        repository: writer,
        clock: DateTime.now,
        uuidFactory: () => 'unused',
      );

      await recorder.recordMemoryCompleted(
        MemoryCompletedEvent(
          session: ActiveSession(
            sessionId: 'session-3',
            uid: null,
            module: kModuleMemory,
            contentId: 'thai_animals',
            startedAt: DateTime.utc(2026, 4, 20),
          ),
          pack: _memoryPack(),
          matchEvents: const [],
        ),
      );

      expect(writer.records, isEmpty);
    });
  });
}

class _FakeSessionWriter implements SessionWriter {
  final records = <SessionRecord>[];

  @override
  Future<void> writeSession(SessionRecord record) async {
    records.add(record);
  }
}

UuidFactory _uuidSequence(List<String> values) {
  var index = 0;
  return () => values[index++];
}

ScenarioConfig _scenario() {
  return const ScenarioConfig(
    scenarioId: '711_milk_001',
    version: 1,
    category: 'daily_life',
    module: 'A',
    titleTh: 'ซื้อนม',
    backgroundImage: 'assets/images/shop.webp',
    ttsInstruction: 'หยิบนม',
    ttsCelebration: 'เก่งมาก',
    ttsHint: 'มองหานม',
    interactables: [
      InteractableConfig(
        id: 'milk_carton',
        image: 'assets/images/milk.webp',
        isTarget: true,
        startPos: GamePosition(x: 10, y: 10),
      ),
      InteractableConfig(
        id: 'bread',
        image: 'assets/images/bread.webp',
        isTarget: false,
        startPos: GamePosition(x: 20, y: 20),
      ),
    ],
    targetZone: TargetZone(x: 1, y: 2, width: 3, height: 4),
  );
}

MemoryPack _memoryPack() {
  return const MemoryPack(
    packId: 'thai_animals',
    titleTh: 'สัตว์',
    pairs: [
      MemoryPair(id: 'cat', image: 'assets/images/cat.webp', ttsName: 'แมว'),
      MemoryPair(id: 'dog', image: 'assets/images/dog.webp', ttsName: 'หมา'),
    ],
  );
}
