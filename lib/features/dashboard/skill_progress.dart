import '../../models/app_types.dart';
import '../../models/session_record.dart';

// คำนวณสรุปพัฒนาการสำหรับ Dashboard ผู้ปกครอง (เอกสารข้อเสนอ §Dashboard) — pure
// logic ล้วน ไม่ผูก Flutter เพื่อ test ได้ตรงๆ แบบเดียวกับ MemoryGameController
//
// แหล่งข้อมูลเดียว: List<SessionRecord> ที่ไหลมาจาก Firestore ผ่าน activityLogProvider
// ทุก record มี score 0-10 (คิดจากเกณฑ์เดียวกันทุกเกม) → ×10 = เปอร์เซ็นต์

// 4 ด้านพัฒนาการตาม mockup เอกสาร
enum SkillDimension { memory, observation, dailyLife, communication }

extension SkillDimensionLabel on SkillDimension {
  String get titleTh => switch (this) {
    SkillDimension.memory => 'ความจำ',
    SkillDimension.observation => 'การสังเกต',
    SkillDimension.dailyLife => 'การใช้ชีวิตประจำวัน',
    SkillDimension.communication => 'การสื่อสาร',
  };
}

// จับคู่ module (ที่บันทึกจริง) → ด้านพัฒนาการที่ได้ฝึก. เกมคำศัพท์ (vocab quiz)
// ฝึกทั้ง "การสังเกต" (ดูรูปแล้วแยกแยะเลือกคำตอบ) และ "การสื่อสาร" (เรียนรู้คำเรียก
// สิ่งของ) — ตรงหลักพัฒนาการเด็กดาวน์ซินโดรมที่คำศัพท์เป็นรากฐานของทั้งสองด้าน
const Map<String, List<SkillDimension>> kModuleSkillMap = {
  kModuleMemory: [SkillDimension.memory],
  kModuleVocab: [SkillDimension.observation, SkillDimension.communication],
  kModuleDailyLife: [SkillDimension.dailyLife],
};

/// แปลงเปอร์เซ็นต์ (0-100) เป็นระดับคำอธิบายภาษาไทย (ใช้ทั้งภาพรวมและรายด้าน)
String skillLevelLabel(double percent) {
  if (percent >= 85) return 'ดีมาก';
  if (percent >= 70) return 'ดี';
  if (percent >= 50) return 'พอใช้';
  return 'ควรฝึกเพิ่ม';
}

class SkillScore {
  const SkillScore({
    required this.dimension,
    required this.percent,
    required this.sessionCount,
  });

  final SkillDimension dimension;

  /// null = ยังไม่มีข้อมูลของด้านนี้ (ยังไม่เคยเล่นเกมที่ฝึกด้านนี้)
  final double? percent;
  final int sessionCount;
}

class DailyTrendPoint {
  const DailyTrendPoint({required this.date, required this.percent});

  /// วันที่ (local, ปัดเป็นเที่ยงคืน)
  final DateTime date;
  final double percent;
}

class RecentGame {
  const RecentGame({
    required this.module,
    required this.scenarioId,
    required this.score,
    required this.playedAt,
  });

  final String module;
  final String scenarioId;
  final int score; // 0-10
  final DateTime playedAt;
}

class DashboardSummary {
  const DashboardSummary({
    required this.overallPercent,
    required this.totalSessions,
    required this.lastPlayedAt,
    required this.skills,
    required this.trend,
    required this.recentGames,
  });

  /// ภาพรวม % (เฉลี่ยคะแนนทุกเกมที่มีคะแนน) — null = ยังไม่มีข้อมูลเลย
  final double? overallPercent;
  final int totalSessions;
  final DateTime? lastPlayedAt;

  /// 4 ด้าน เรียงตามลำดับ enum เสมอ (แม้ด้านที่ยังไม่มีข้อมูล)
  final List<SkillScore> skills;

  /// จุดกราฟแนวโน้ม เรียงจากวันเก่า → ใหม่ (เฉพาะวันที่มีข้อมูล)
  final List<DailyTrendPoint> trend;
  final List<RecentGame> recentGames;

  bool get hasData => totalSessions > 0;
}

/// สร้างสรุปพัฒนาการจากรายการ session. [now] รับเข้ามาเพื่อให้ test เดตเวลาได้
/// (ห้ามเรียก DateTime.now() ในนี้). นับเฉพาะ record ที่ [SessionRecord.score]
/// ไม่เป็น null — record เก่าก่อนมีระบบคะแนนจะถูกข้ามในการคิดเปอร์เซ็นต์
DashboardSummary computeDashboardSummary(
  List<SessionRecord> records, {
  required DateTime now,
  int trendDays = 14,
  int recentGamesLimit = 4,
}) {
  final scored = records.where((r) => r.score != null).toList();

  final overallPercent = _averagePercent(scored.map((r) => r.score!));

  final skills = [
    for (final dimension in SkillDimension.values)
      _skillScore(scored, dimension),
  ];

  // แนวโน้มรายวัน: จำกัดช่วง [now - (trendDays-1) วัน .. now] แล้วเฉลี่ยต่อวัน
  final earliest = _dateOnly(now).subtract(Duration(days: trendDays - 1));
  final byDay = <DateTime, List<int>>{};
  for (final record in scored) {
    final playedAt = _parseLocal(record.endedAt);
    if (playedAt == null) continue;
    final day = _dateOnly(playedAt);
    if (day.isBefore(earliest)) continue;
    if (day.isAfter(_dateOnly(now))) continue;
    (byDay[day] ??= []).add(record.score!);
  }
  final trend =
      byDay.entries
          .map(
            (e) => DailyTrendPoint(
              date: e.key,
              percent: _averagePercent(e.value)!,
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  // เกมที่เล่นล่าสุด: เรียงตามเวลาจบล่าสุด
  final recentSorted =
      scored
          .map((r) => (record: r, at: _parseLocal(r.endedAt)))
          .where((e) => e.at != null)
          .toList()
        ..sort((a, b) => b.at!.compareTo(a.at!));
  final recentGames = [
    for (final e in recentSorted.take(recentGamesLimit))
      RecentGame(
        module: e.record.module,
        scenarioId: e.record.scenarioId,
        score: e.record.score!,
        playedAt: e.at!,
      ),
  ];

  return DashboardSummary(
    overallPercent: overallPercent,
    totalSessions: records.length,
    lastPlayedAt: recentSorted.isEmpty ? null : recentSorted.first.at,
    skills: skills,
    trend: trend,
    recentGames: recentGames,
  );
}

class SkillTip {
  const SkillTip({this.dimension, required this.titleTh, required this.bodyTh});

  /// null = คำแนะนำทั่วไป (เช่น เวลาเล่น) ไม่ผูกด้านใดด้านหนึ่ง
  final SkillDimension? dimension;
  final String titleTh;
  final String bodyTh;
}

const Map<SkillDimension, SkillTip> _dimensionTips = {
  SkillDimension.memory: SkillTip(
    dimension: SkillDimension.memory,
    titleTh: 'เสริมความจำ',
    bodyTh: 'ให้เล่นกิจกรรมจับคู่รูปภาพอย่างต่อเนื่อง เพื่อเสริมความจำ',
  ),
  SkillDimension.observation: SkillTip(
    dimension: SkillDimension.observation,
    titleTh: 'พัฒนาการสังเกต',
    bodyTh: 'ชวนสังเกตรายละเอียดของสิ่งของรอบตัว เช่น สี รูปร่าง ขนาด',
  ),
  SkillDimension.dailyLife: SkillTip(
    dimension: SkillDimension.dailyLife,
    titleTh: 'ฝึกทักษะการใช้ชีวิตประจำวัน',
    bodyTh:
        'ส่งเสริมให้เด็กทำกิจวัตรประจำวันด้วยตนเองมากขึ้น เช่น จัดของ '
        'เก็บของ แต่งตัว',
  ),
  SkillDimension.communication: SkillTip(
    dimension: SkillDimension.communication,
    titleTh: 'เพิ่มทักษะการสื่อสาร',
    bodyTh: 'พูดคุยและถามตอบในชีวิตประจำวัน เพื่อพัฒนาการสื่อสาร',
  ),
};

const SkillTip _playtimeTip = SkillTip(
  titleTh: 'แนะนำเวลาการเล่น',
  bodyTh: 'ควรเล่นเกมวันละ 15-20 นาที อย่างสม่ำเสมอ',
);

/// คำแนะนำสำหรับผู้ปกครอง — ด้านที่คะแนนต่ำกว่าถูกจัดขึ้นก่อน (ควรฝึกก่อน) แล้วปิด
/// ท้ายด้วยคำแนะนำเวลาเล่นเสมอ. ยังไม่มีข้อมูล → แนะนำครบทั้ง 4 ด้านตามลำดับมาตรฐาน
List<SkillTip> skillTips(DashboardSummary summary) {
  final scored =
      summary.skills.where((s) => s.percent != null).toList()
        ..sort((a, b) => a.percent!.compareTo(b.percent!));
  final ordered =
      scored.isEmpty
          ? SkillDimension.values
          : scored.map((s) => s.dimension);
  return [
    for (final dimension in ordered) _dimensionTips[dimension]!,
    _playtimeTip,
  ];
}

SkillScore _skillScore(List<SessionRecord> scored, SkillDimension dimension) {
  final relevant =
      scored
          .where(
            (r) => kModuleSkillMap[r.module]?.contains(dimension) ?? false,
          )
          .map((r) => r.score!)
          .toList();
  return SkillScore(
    dimension: dimension,
    percent: _averagePercent(relevant),
    sessionCount: relevant.length,
  );
}

/// เฉลี่ยคะแนน 0-10 แล้วคูณ 10 เป็นเปอร์เซ็นต์ — คืน null ถ้าไม่มีข้อมูล
double? _averagePercent(Iterable<int> scores) {
  final list = scores.toList();
  if (list.isEmpty) return null;
  final sum = list.reduce((a, b) => a + b);
  return (sum / list.length) * 10;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

DateTime? _parseLocal(String iso) => DateTime.tryParse(iso)?.toLocal();
