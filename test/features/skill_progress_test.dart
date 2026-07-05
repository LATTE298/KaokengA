import 'package:daily_life/features/dashboard/skill_progress.dart';
import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 6, 16, 18);

  group('computeDashboardSummary', () {
    test('overall percent averages all scored sessions (x10)', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: 10, endedAt: '2026-06-16T10:00:00'),
        _rec(module: kModuleDailyLife, score: 6, endedAt: '2026-06-16T11:00:00'),
      ], now: now);

      // (10 + 6) / 2 * 10 = 80
      expect(summary.overallPercent, 80);
      expect(summary.totalSessions, 2);
      expect(summary.hasData, isTrue);
    });

    test('maps modules to skill dimensions; vocab feeds two dimensions', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: 9, endedAt: '2026-06-16T10:00:00'),
        _rec(module: kModuleVocab, score: 8, endedAt: '2026-06-16T11:00:00'),
        _rec(module: kModuleDailyLife, score: 7, endedAt: '2026-06-16T12:00:00'),
      ], now: now);

      final byDim = {for (final s in summary.skills) s.dimension: s};
      expect(byDim[SkillDimension.memory]!.percent, 90);
      expect(byDim[SkillDimension.observation]!.percent, 80);
      expect(byDim[SkillDimension.communication]!.percent, 80);
      expect(byDim[SkillDimension.dailyLife]!.percent, 70);
      // ครบ 4 ด้านเสมอ เรียงตาม enum
      expect(
        summary.skills.map((s) => s.dimension),
        SkillDimension.values,
      );
    });

    test('a dimension with no sessions reports null percent', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: 8, endedAt: '2026-06-16T10:00:00'),
      ], now: now);

      final byDim = {for (final s in summary.skills) s.dimension: s};
      expect(byDim[SkillDimension.memory]!.percent, 80);
      expect(byDim[SkillDimension.dailyLife]!.percent, isNull);
      expect(byDim[SkillDimension.dailyLife]!.sessionCount, 0);
    });

    test('trend groups by local day and averages, oldest first', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: 6, endedAt: '2026-06-15T09:00:00'),
        _rec(module: kModuleMemory, score: 8, endedAt: '2026-06-15T20:00:00'),
        _rec(module: kModuleVocab, score: 10, endedAt: '2026-06-16T08:00:00'),
      ], now: now);

      expect(summary.trend, hasLength(2));
      expect(summary.trend.first.date, DateTime(2026, 6, 15));
      expect(summary.trend.first.percent, 70); // (6+8)/2 * 10
      expect(summary.trend.last.date, DateTime(2026, 6, 16));
      expect(summary.trend.last.percent, 100);
    });

    test('trend excludes sessions older than the window', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: 5, endedAt: '2026-06-01T09:00:00'),
        _rec(module: kModuleMemory, score: 9, endedAt: '2026-06-16T09:00:00'),
      ], now: now, trendDays: 14);

      // 1 มิ.ย. อยู่นอกช่วง 14 วันล่าสุด (3-16 มิ.ย.)
      expect(summary.trend, hasLength(1));
      expect(summary.trend.single.date, DateTime(2026, 6, 16));
    });

    test('recent games are newest-first and limited', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: 4, endedAt: '2026-06-16T08:00:00'),
        _rec(module: kModuleVocab, score: 6, endedAt: '2026-06-16T09:00:00'),
        _rec(module: kModuleDailyLife, score: 8, endedAt: '2026-06-16T10:00:00'),
      ], now: now, recentGamesLimit: 2);

      expect(summary.recentGames, hasLength(2));
      expect(summary.recentGames.first.module, kModuleDailyLife);
      expect(summary.recentGames.first.score, 8);
      expect(summary.recentGames.last.module, kModuleVocab);
      expect(summary.lastPlayedAt, DateTime(2026, 6, 16, 10).toLocal());
    });

    test('sessions without a score are ignored', () {
      final summary = computeDashboardSummary([
        _rec(module: kModuleMemory, score: null, endedAt: '2026-06-16T10:00:00'),
        _rec(module: kModuleMemory, score: 10, endedAt: '2026-06-16T11:00:00'),
      ], now: now);

      expect(summary.overallPercent, 100); // นับเฉพาะตัวที่มีคะแนน
      expect(summary.totalSessions, 2); // แต่ยังนับจำนวนเล่นรวมทั้งหมด
      expect(summary.recentGames, hasLength(1));
    });

    test('empty input yields a no-data summary', () {
      final summary = computeDashboardSummary([], now: now);
      expect(summary.hasData, isFalse);
      expect(summary.overallPercent, isNull);
      expect(summary.trend, isEmpty);
      expect(summary.recentGames, isEmpty);
      expect(summary.skills.every((s) => s.percent == null), isTrue);
    });
  });

  group('skillLevelLabel', () {
    test('maps percent to Thai levels', () {
      expect(skillLevelLabel(90), 'ดีมาก');
      expect(skillLevelLabel(85), 'ดีมาก');
      expect(skillLevelLabel(70), 'ดี');
      expect(skillLevelLabel(55), 'พอใช้');
      expect(skillLevelLabel(40), 'ควรฝึกเพิ่ม');
    });
  });
}

SessionRecord _rec({
  required String module,
  required int? score,
  required String endedAt,
}) {
  return SessionRecord(
    sessionId: 's-$endedAt',
    uid: 'uid-1',
    scenarioId: '${module}_content',
    module: module,
    startedAt: endedAt,
    endedAt: endedAt,
    durationMs: 60000,
    completed: true,
    score: score,
  );
}
