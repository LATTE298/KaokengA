import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/loaded_scenario_config.dart';
import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:daily_life/providers/auth_provider.dart';
import 'package:daily_life/providers/content_providers.dart';
import 'package:daily_life/providers/parent_dashboard_providers.dart';
import 'package:daily_life/screens/parent/progress_dashboard.dart';
import 'package:daily_life/services/activity_log_repository.dart';
import 'package:daily_life/services/content_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders overall percent, skills, and recent games', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _wrap([
        _record('s1', kModuleMemory, 'memory_animals', 9, '2026-06-16T10:00:00'),
        _record('s2', kModuleDailyLife, '711_milk_001', 6, '2026-06-16T11:00:00'),
        _record('s3', kModuleVocab, 'quiz_food', 8, '2026-06-16T12:00:00'),
      ]),
    );
    await tester.pump(); // activity log stream
    await tester.pump(); // scenario list future

    // overall = (9+6+8)/3*10 = 76.67 → 77
    expect(find.text('77%'), findsOneWidget);
    expect(find.text('ภาพรวมพัฒนาการ'), findsOneWidget);
    // 4 ด้านครบ พร้อมเปอร์เซ็นต์รายด้าน
    expect(find.text('ความจำ'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget); // memory
    expect(find.text('การใช้ชีวิตประจำวัน'), findsWidgets);
    expect(find.text('60%'), findsOneWidget); // daily_life
    // vocab → ทั้งการสังเกตและการสื่อสาร = 80%
    expect(find.text('การสังเกต'), findsOneWidget);
    expect(find.text('การสื่อสาร'), findsOneWidget);
    expect(find.text('80%'), findsNWidgets(2));
    // เกมที่เล่นล่าสุด: daily_life ใช้ชื่อ scenario จริง
    expect(find.text('ซื้อนม'), findsOneWidget);
    expect(find.textContaining('ตอบคำถาม'), findsWidgets);
    // ข้อแนะนำ
    expect(find.text('ข้อแนะนำ'), findsOneWidget);
  });

  testWidgets('dense landscape fits a phone screen without overflow', (
    tester,
  ) async {
    // มือถือแนวนอน (อุปกรณ์หลัก) — ต้องเห็นครบไม่ overflow/ไม่ scroll
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // จำลอง chrome จริงของ DashboardScreen (AppBar + แถบเมนูล่าง) ที่กินความสูง
    // เพื่อให้ dense layout ต้อง fit body area จริง (เตี้ยกว่าทั้งจอ ~136px)
    await tester.pumpWidget(
      _wrapInApp([
        _record('s1', kModuleMemory, 'memory_animals', 9, '2026-06-16T10:00:00'),
        _record('s2', kModuleDailyLife, '711_milk_001', 6, '2026-06-16T11:00:00'),
        _record('s3', kModuleVocab, 'quiz_food', 8, '2026-06-16T12:00:00'),
      ]),
    );
    await tester.pump();
    await tester.pump();

    // ไม่มี RenderFlex overflow / exception ใดๆ
    expect(tester.takeException(), isNull);
    // องค์ประกอบหลักครบในจอเดียว
    expect(find.text('พัฒนาการของเด็ก'), findsOneWidget);
    expect(find.text('ความจำ'), findsOneWidget);
    expect(find.text('การสื่อสาร'), findsOneWidget);
    expect(find.text('เกมที่เล่นล่าสุด'), findsOneWidget);
    expect(find.text('ข้อแนะนำ'), findsOneWidget);
    // dense = ไม่มี vertical scroll ของหน้าเลย (ข้อแนะนำเป็น carousel แนวนอน)
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('shows empty state when there is no data', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_wrap(const []));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('ยังไม่มีข้อมูลการเล่น'), findsOneWidget);
  });
}

Widget _wrap(List<SessionRecord> records) {
  return _wrapWith(
    records,
    Scaffold(body: ProgressDashboard(now: DateTime(2026, 6, 16, 18))),
  );
}

// จำลอง chrome ของ DashboardScreen จริงตอนแนวนอน (AppBar อย่างเดียว — แถบเมนูล่าง
// ถูกซ่อนเมื่อ landscape) เพื่อทดสอบว่า dense layout fit ใน body area จริง
Widget _wrapInApp(List<SessionRecord> records) {
  return _wrapWith(
    records,
    Scaffold(
      appBar: AppBar(title: const Text('ความก้าวหน้า')),
      body: ProgressDashboard(now: DateTime(2026, 6, 16, 18)),
    ),
  );
}

Widget _wrapWith(List<SessionRecord> records, Widget home) {
  return ProviderScope(
    overrides: [
      uidProvider.overrideWithValue('uid-1'),
      activityLogRepositoryProvider.overrideWithValue(
        _FakeActivityLogReader(records),
      ),
      contentRepositoryProvider.overrideWithValue(
        _FakeContentRepository([_scenario('711_milk_001', 'ซื้อนม')]),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

class _FakeActivityLogReader implements ActivityLogReader {
  _FakeActivityLogReader(this.records);
  final List<SessionRecord> records;

  @override
  Stream<List<SessionRecord>> watchRecentSessions(
    String uid, {
    required int limit,
  }) => Stream.value(records);
}

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository(this.scenarios);
  final List<ScenarioSummary> scenarios;

  @override
  Future<List<ScenarioSummary>> fetchScenarioIndex() async => scenarios;

  @override
  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl) =>
      throw UnimplementedError();

  @override
  Future<LoadedScenarioConfig> fetchLoadedScenarioConfig(String assetOrUrl) =>
      throw UnimplementedError();

  @override
  Future<List<VocabularyItem>> fetchVocabulary() => throw UnimplementedError();
}

ScenarioSummary _scenario(String id, String title) {
  return ScenarioSummary(
    scenarioId: id,
    titleTh: title,
    category: 'daily_life',
    module: 'A',
    configUrl: 'assets/scenarios/$id.json',
    thumbnailUrl: 'assets/images/$id.webp',
    version: 1,
    published: true,
  );
}

SessionRecord _record(
  String sessionId,
  String module,
  String scenarioId,
  int score,
  String endedAt,
) {
  return SessionRecord(
    sessionId: sessionId,
    uid: 'uid-1',
    scenarioId: scenarioId,
    module: module,
    startedAt: endedAt,
    endedAt: endedAt,
    durationMs: 60000,
    completed: true,
    score: score,
  );
}
