import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/loaded_scenario_config.dart';
import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:daily_life/providers/auth_provider.dart';
import 'package:daily_life/providers/content_providers.dart';
import 'package:daily_life/providers/parent_dashboard_providers.dart';
import 'package:daily_life/screens/parent/auth_screen.dart';
import 'package:daily_life/screens/parent/dashboard_screen.dart';
import 'package:daily_life/services/activity_log_repository.dart';
import 'package:daily_life/services/auth_service.dart';
import 'package:daily_life/services/content_repository.dart';
import 'package:daily_life/services/scenario_settings_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('AuthScreen validates email and password', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AuthScreen(),
        overrides: [authServiceProvider.overrideWithValue(_FakeAuthService())],
      ),
    );
    await tester.pumpAndSettle();

    final submit = find.byKey(const Key('parent-auth-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pump();

    expect(find.text('รูปแบบอีเมลไม่ถูกต้อง'), findsOneWidget);
  });

  testWidgets('AuthScreen has Google button and toggles register/login', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AuthScreen(),
        overrides: [authServiceProvider.overrideWithValue(_FakeAuthService())],
      ),
    );
    await tester.pumpAndSettle();

    // เริ่มโหมดเข้าสู่ระบบ + มีปุ่ม Google
    expect(find.text('ยินดีต้อนรับกลับ!'), findsOneWidget);
    expect(find.byKey(const Key('parent-google-signin')), findsOneWidget);

    // สลับเป็นสมัครสมาชิก (การ์ดยาวกว่าจอ test — เลื่อนหาปุ่มก่อนกด)
    final toggle = find.byKey(const Key('parent-toggle-mode'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text('สร้างบัญชีใหม่'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders activity log data', (tester) async {
    await tester.pumpWidget(_dashboardWrap());
    await tester.pump();

    expect(find.text('ซื้อนม'), findsOneWidget);
    expect(find.textContaining('ชีวิตประจำวัน'), findsOneWidget);
  });

  testWidgets('DashboardScreen scenario switch writes override', (
    tester,
  ) async {
    final settings = _FakeScenarioSettingsStore();
    await tester.pumpWidget(_dashboardWrap(settings: settings));
    await tester.pump();

    await tester.tap(find.text('ตั้งค่าสถานการณ์'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(settings.writes.single, ('uid-1', '711_milk_001', false));
  });

  testWidgets('DashboardScreen opens logout sheet', (tester) async {
    await tester.pumpWidget(_dashboardWrap());
    await tester.pump();

    await tester.tap(find.byTooltip('ออกจากระบบ'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('parent-logout-submit')), findsOneWidget);
  });

  testWidgets('DashboardScreen delete account requires confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboardWrap());
    await tester.pump();

    await tester.tap(find.byTooltip('ออกจากระบบ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-delete-account')));
    await tester.pumpAndSettle();

    // ต้องมี dialog ยืนยันชั้นสอง (ลบถาวร) + คำเตือนกู้คืนไม่ได้
    expect(find.byKey(const Key('parent-delete-confirm')), findsOneWidget);
    expect(find.textContaining('ไม่สามารถกู้คืน'), findsOneWidget);
  });

  testWidgets(
    'DashboardScreen progressOnly ล็อกเฉพาะความก้าวหน้า — ซ่อนแท็บ/บัญชี',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_dashboardWrap(progressOnly: true));
      await tester.pump();

      // เข้าจากหน้าเลือกเล่นฝั่งเด็ก: ต้องเข้าส่วนผู้ปกครองอื่นไม่ได้เลย
      expect(find.byTooltip('ออกจากระบบ'), findsNothing);
      expect(find.byTooltip('ตั้งชื่อเด็ก'), findsNothing);
      expect(find.byTooltip('คลังครอบครัว'), findsNothing);
      expect(find.byType(NavigationBar), findsNothing); // ไม่มีแถบสลับแท็บล่าง
      // แต่ยังเห็นหน้าความก้าวหน้า (title แท็บ)
      expect(find.text('ความก้าวหน้า'), findsWidgets);
    },
  );
}

Widget _dashboardWrap({
  _FakeScenarioSettingsStore? settings,
  bool progressOnly = false,
}) {
  return _wrap(
    DashboardScreen(progressOnly: progressOnly),
    overrides: [
      parentAuthenticatedProvider.overrideWithValue(true),
      uidProvider.overrideWithValue('uid-1'),
      activityLogRepositoryProvider.overrideWithValue(
        _FakeActivityLogReader([
          _record('session-1', '711_milk_001', kModuleDailyLife),
        ]),
      ),
      scenarioSettingsRepositoryProvider.overrideWithValue(
        settings ?? _FakeScenarioSettingsStore(),
      ),
      contentRepositoryProvider.overrideWithValue(
        _FakeContentRepository([_scenario('711_milk_001', 'ซื้อนม')]),
      ),
    ],
  );
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(overrides: overrides, child: MaterialApp(home: child));
}

class _FakeAuthService implements ParentAuthService {
  @override
  String? get currentUid => null;

  @override
  Stream<User?> authStateChanges() => Stream.value(null);

  @override
  Future<void> createParentAccount({
    required String email,
    required String password,
  }) async {}

  @override
  Future<User> ensureAnonymousChildSession() {
    throw UnimplementedError();
  }

  @override
  Future<User> signInAnonymouslyIfNeeded() {
    throw UnimplementedError();
  }

  @override
  Future<void> signInParent({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOutParent() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> deleteAccountAndData() async {}
}

class _FakeActivityLogReader implements ActivityLogReader {
  _FakeActivityLogReader(this.records);

  final List<SessionRecord> records;

  @override
  Stream<List<SessionRecord>> watchRecentSessions(
    String uid, {
    required int limit,
  }) {
    return Stream.value(records);
  }
}

class _FakeScenarioSettingsStore implements ScenarioSettingsStore {
  final writes = <(String uid, String scenarioId, bool enabled)>[];

  @override
  Stream<Map<String, bool>> watchScenarioSettings(String uid) {
    return Stream.value(const {});
  }

  @override
  Future<void> setScenarioEnabled({
    required String uid,
    required String scenarioId,
    required bool enabled,
  }) async {
    writes.add((uid, scenarioId, enabled));
  }
}

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository(this.scenarios);

  final List<ScenarioSummary> scenarios;

  @override
  Future<List<ScenarioSummary>> fetchScenarioIndex() async => scenarios;

  @override
  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl) {
    throw UnimplementedError();
  }

  @override
  Future<LoadedScenarioConfig> fetchLoadedScenarioConfig(String assetOrUrl) {
    throw UnimplementedError();
  }

  @override
  Future<List<VocabularyItem>> fetchVocabulary() {
    throw UnimplementedError();
  }
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

SessionRecord _record(String sessionId, String scenarioId, String module) {
  return SessionRecord(
    sessionId: sessionId,
    uid: 'uid-1',
    scenarioId: scenarioId,
    module: module,
    startedAt: '2026-04-25T10:00:00.000Z',
    endedAt: '2026-04-25T10:01:00.000Z',
    durationMs: 60000,
    completed: true,
  );
}
