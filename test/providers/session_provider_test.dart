import 'package:daily_life/features/sessions/session_recorder.dart';
import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/memory_pack.dart';
import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:daily_life/providers/auth_provider.dart';
import 'package:daily_life/providers/session_provider.dart';
import 'package:daily_life/services/session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('session providers', () {
    test(
      'records Module A completion with deterministic active session',
      () async {
        final writer = _FakeSessionWriter();
        final container = _container(
          writer: writer,
          uid: 'uid-1',
          clock: _clockSequence([
            DateTime.utc(2026, 4, 20, 10),
            DateTime.utc(2026, 4, 20, 10, 0, 42),
          ]),
          uuidFactory: _uuidSequence(['session-1', 'interaction-1']),
        );
        addTearDown(container.dispose);

        final session = container.read(
          activeSessionProvider(
            const ActiveSessionKey(
              module: kModuleDailyLife,
              contentId: '711_milk_001',
            ),
          ),
        );
        await container
            .read(sessionRecorderProvider)
            .recordDailyLifeCompleted(
              DailyLifeCompletedEvent(
                session: session,
                config: _scenario(),
                dragPath: const [
                  GamePosition(x: 1, y: 2),
                  GamePosition(x: 3, y: 4),
                ],
                score: 10,
                stars: 3,
              ),
            );

        final record = writer.records.single;
        expect(record.sessionId, 'session-1');
        expect(record.uid, 'uid-1');
        expect(record.score, 10);
        expect(record.stars, 3);
        expect(record.scenarioId, '711_milk_001');
        expect(record.module, kModuleDailyLife);
        expect(record.startedAt, '2026-04-20T10:00:00.000Z');
        expect(record.endedAt, '2026-04-20T10:00:42.000Z');
        expect(record.durationMs, 42000);
        expect(record.dragInteractions.single.interactionId, 'interaction-1');
        expect(record.dragInteractions.single.objectId, 'milk_carton');
        expect(record.dragInteractions.single.pathPoints, const [
          GamePosition(x: 1, y: 2),
          GamePosition(x: 3, y: 4),
        ]);
      },
    );

    test(
      'records Module B completion with deterministic active session',
      () async {
        final writer = _FakeSessionWriter();
        final container = _container(
          writer: writer,
          uid: 'uid-1',
          clock: _clockSequence([
            DateTime.utc(2026, 4, 20, 10),
            DateTime.utc(2026, 4, 20, 10, 2, 30),
          ]),
          uuidFactory: _uuidSequence(['session-2']),
        );
        addTearDown(container.dispose);
        const events = [
          MatchEvent(pairId: 'cat', matched: false, atMs: 1000),
          MatchEvent(pairId: 'cat', matched: true, atMs: 3000),
        ];

        final session = container.read(
          activeSessionProvider(
            const ActiveSessionKey(
              module: kModuleMemory,
              contentId: 'thai_animals',
            ),
          ),
        );
        await container
            .read(sessionRecorderProvider)
            .recordMemoryCompleted(
              MemoryCompletedEvent(
                session: session,
                pack: _memoryPack(),
                matchEvents: events,
              ),
            );

        final record = writer.records.single;
        expect(record.sessionId, 'session-2');
        expect(record.uid, 'uid-1');
        expect(record.scenarioId, 'thai_animals');
        expect(record.module, kModuleMemory);
        expect(record.startedAt, '2026-04-20T10:00:00.000Z');
        expect(record.endedAt, '2026-04-20T10:02:30.000Z');
        expect(record.durationMs, 150000);
        expect(record.pairsMatched, 2);
        expect(record.totalPairs, 2);
        expect(record.matchEvents, events);
      },
    );

    test('replaying the same content creates a fresh session', () async {
      final container = _container(
        writer: _FakeSessionWriter(),
        uid: 'uid-1',
        clock: _clockSequence([
          DateTime.utc(2026, 4, 20, 10),
          DateTime.utc(2026, 4, 20, 10, 5),
        ]),
        uuidFactory: _uuidSequence(['session-first', 'session-second']),
      );
      addTearDown(container.dispose);
      const key = ActiveSessionKey(
        module: kModuleMemory,
        contentId: 'thai_animals',
      );

      // รอบแรก: จำลองหน้าจอเกม watch ระหว่างเล่น แล้วปิดหน้าจอ (subscription ปิด)
      final subscription = container.listen(
        activeSessionProvider(key),
        (_, __) {},
      );
      final first = subscription.read();
      subscription.close();
      await container.pump(); // ให้ autoDispose เก็บ state ของรอบแรกก่อน

      // รอบสอง: เข้าเล่นเนื้อหาเดิมอีกครั้ง ต้องไม่ได้ session เดิม (bug 4.2)
      final second = container.read(activeSessionProvider(key));

      expect(first.sessionId, 'session-first');
      expect(second.sessionId, 'session-second');
      expect(second.startedAt, DateTime.utc(2026, 4, 20, 10, 5));
    });

    test('does not write records without an authenticated uid', () async {
      final writer = _FakeSessionWriter();
      final container = _container(
        writer: writer,
        uid: null,
        clock: _clockSequence([
          DateTime.utc(2026, 4, 20, 10),
          DateTime.utc(2026, 4, 20, 10, 1),
        ]),
        uuidFactory: _uuidSequence(['session-3']),
      );
      addTearDown(container.dispose);

      final session = container.read(
        activeSessionProvider(
          const ActiveSessionKey(
            module: kModuleMemory,
            contentId: 'thai_animals',
          ),
        ),
      );
      await container
          .read(sessionRecorderProvider)
          .recordMemoryCompleted(
            MemoryCompletedEvent(
              session: session,
              pack: _memoryPack(),
              matchEvents: const [],
            ),
          );

      expect(writer.records, isEmpty);
    });
  });
}

ProviderContainer _container({
  required SessionWriter writer,
  required String? uid,
  required Clock clock,
  required UuidFactory uuidFactory,
}) {
  return ProviderContainer(
    overrides: [
      sessionRepositoryProvider.overrideWithValue(writer),
      uidProvider.overrideWithValue(uid),
      clockProvider.overrideWithValue(clock),
      uuidFactoryProvider.overrideWithValue(uuidFactory),
    ],
  );
}

class _FakeSessionWriter implements SessionWriter {
  final records = <SessionRecord>[];

  @override
  Future<void> writeSession(SessionRecord record) async {
    records.add(record);
  }
}

Clock _clockSequence(List<DateTime> values) {
  var index = 0;
  return () => values[index++];
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
