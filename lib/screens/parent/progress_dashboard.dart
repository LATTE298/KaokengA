import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/skill_progress.dart';
import '../../models/app_types.dart';
import '../../models/session_record.dart';
import '../../providers/content_providers.dart';
import '../../providers/parent_dashboard_providers.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/child_async_view.dart';

// Dashboard พัฒนาการผู้เรียน (เอกสารข้อเสนอ §Dashboard) — ภาพรวม %, พัฒนาการ 4 ด้าน,
// กราฟแนวโน้ม 14 วัน, คำแนะนำ, เกมที่เล่นล่าสุด. Data มาจาก activityLogProvider
// แปลงผ่าน computeDashboardSummary (logic ทั้งหมดอยู่ที่ features/dashboard)
//
// สีประจำด้าน: จำเป็นต้องแยกแต่ละด้านด้วยสี (data viz) จึงกำหนด palette เฉพาะที่นี่
// อิงโทนใน mockup — เขียว/ม่วง/ชมพู/ฟ้า
const Map<SkillDimension, Color> _skillColors = {
  SkillDimension.memory: kSuccess,
  SkillDimension.observation: Color(0xFF9B6DD6),
  SkillDimension.dailyLife: Color(0xFFE86A9C),
  SkillDimension.communication: kBluePrimary,
};

const Map<SkillDimension, IconData> _skillIcons = {
  SkillDimension.memory: Icons.psychology_rounded,
  SkillDimension.observation: Icons.search_rounded,
  SkillDimension.dailyLife: Icons.home_rounded,
  SkillDimension.communication: Icons.chat_bubble_rounded,
};

class ProgressDashboard extends ConsumerWidget {
  const ProgressDashboard({super.key, this.now});

  /// เวลาอ้างอิงสำหรับกรอบกราฟ — ปกติ null (ใช้เวลาจริง) ส่งค่าเฉพาะใน test
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(activityLogProvider);
    final scenarios = ref.watch(scenarioListProvider).valueOrNull ?? const [];
    final titles = {
      for (final s in scenarios) s.scenarioId: s.titleTh,
    };

    return ChildAsyncView<List<SessionRecord>>(
      value: records,
      loading: const Center(child: CircularProgressIndicator()),
      error:
          (_, __) => Center(child: Text('โหลดข้อมูลไม่สำเร็จ', style: kTextMd)),
      data: (items) {
        final summary = computeDashboardSummary(items, now: now ?? DateTime.now());
        if (!summary.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kSpace8),
              child: Text(
                'ยังไม่มีข้อมูลการเล่น เริ่มเล่นกับน้องเพื่อดูพัฒนาการนะครับ',
                style: kTextMd,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _DashboardBody(summary: summary, titles: titles);
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary, required this.titles});

  final DashboardSummary summary;
  final Map<String, String> titles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // จอกว้างพอ (แท็บเล็ตแนวนอน) → 2 คอลัมน์ตาม mockup: เนื้อหาหลัก | คำแนะนำ
        final twoColumn = constraints.maxWidth >= 900;
        final main = _MainColumn(summary: summary, titles: titles);
        final tips = _TipsPanel(tips: skillTips(summary));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(kSpace6),
          child:
              twoColumn
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: main),
                      const SizedBox(width: kSpace5),
                      Expanded(flex: 1, child: tips),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      main,
                      const SizedBox(height: kSpace5),
                      tips,
                    ],
                  ),
        );
      },
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({required this.summary, required this.titles});

  final DashboardSummary summary;
  final Map<String, String> titles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderCard(summary: summary),
        const SizedBox(height: kSpace5),
        _OverallCard(percent: summary.overallPercent ?? 0),
        const SizedBox(height: kSpace5),
        Text('พัฒนาการรายด้าน', style: kTextLg),
        const SizedBox(height: kSpace3),
        _SkillRow(skills: summary.skills),
        const SizedBox(height: kSpace5),
        _TrendCard(trend: summary.trend),
        const SizedBox(height: kSpace5),
        Text('เกมที่เล่นล่าสุด', style: kTextLg),
        const SizedBox(height: kSpace3),
        _RecentGames(games: summary.recentGames, titles: titles),
      ],
    );
  }
}

Widget _card({required Widget child, Color color = Colors.white}) {
  return Container(
    padding: const EdgeInsets.all(kSpace5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: kRadiusLg,
      boxShadow: const [kShadowSm],
    ),
    child: child,
  );
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _card(
      color: kBlueLight,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.face_rounded, size: 34, color: kBluePrimary),
          ),
          const SizedBox(width: kSpace4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('พัฒนาการของเด็ก', style: kTextLg),
                Text(
                  'เล่นทั้งหมด ${summary.totalSessions} ครั้ง'
                  '${_lastPlayedSuffix(summary.lastPlayedAt)}',
                  style: kTextSm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _lastPlayedSuffix(DateTime? at) {
  if (at == null) return '';
  final h = at.hour.toString().padLeft(2, '0');
  final m = at.minute.toString().padLeft(2, '0');
  return ' · เล่นล่าสุด ${at.day}/${at.month} $h:$m น.';
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ภาพรวมพัฒนาการ', style: kTextMd),
                    Text('สัปดาห์นี้', style: kTextSm),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${percent.round()}%',
                    style: kTextXL.copyWith(color: kBluePrimary),
                  ),
                  Text(
                    skillLevelLabel(percent),
                    style: kTextSm.copyWith(color: kBluePrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: kSpace3),
          ClipRRect(
            borderRadius: kRadiusFull,
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 14,
              backgroundColor: kWarmSurface,
              valueColor: const AlwaysStoppedAnimation(kBluePrimary),
            ),
          ),
          const SizedBox(height: kSpace1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: kTextXs),
              Text('50%', style: kTextXs),
              Text('100%', style: kTextXs),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skills});

  final List<SkillScore> skills;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 4 การ์ดต่อแถวถ้ากว้างพอ ไม่งั้นตัดเป็น 2 คอลัมน์ (กฎ responsive)
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        final cardWidth =
            (constraints.maxWidth - kSpace3 * (columns - 1)) / columns;
        return Wrap(
          spacing: kSpace3,
          runSpacing: kSpace3,
          children: [
            for (final skill in skills)
              SizedBox(
                width: cardWidth,
                child: _SkillCard(skill: skill),
              ),
          ],
        );
      },
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill});

  final SkillScore skill;

  @override
  Widget build(BuildContext context) {
    final color = _skillColors[skill.dimension]!;
    final percent = skill.percent;
    return _card(
      child: Column(
        children: [
          Text(
            skill.dimension.titleTh,
            style: kTextSm.copyWith(color: kTextPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: kSpace3),
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: percent == null ? 0 : (percent / 100).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: kWarmSurface,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Icon(_skillIcons[skill.dimension], color: color, size: 30),
              ],
            ),
          ),
          const SizedBox(height: kSpace3),
          Text(
            percent == null ? '—' : '${percent.round()}%',
            style: kTextLg.copyWith(color: color),
          ),
          Text(
            percent == null ? 'ยังไม่มีข้อมูล' : skillLevelLabel(percent),
            style: kTextXs.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});

  final List<DailyTrendPoint> trend;

  @override
  Widget build(BuildContext context) {
    return _card(
      color: kBlueLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('แนวโน้มพัฒนาการ (${trend.length} วันที่มีข้อมูล)', style: kTextMd),
          const SizedBox(height: kSpace4),
          SizedBox(
            height: 160,
            width: double.infinity,
            child:
                trend.length < 2
                    ? Center(
                      child: Text(
                        'เล่นอย่างน้อย 2 วันเพื่อดูแนวโน้ม',
                        style: kTextSm,
                      ),
                    )
                    : CustomPaint(painter: _TrendPainter(trend)),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.trend);

  final List<DailyTrendPoint> trend;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 40.0;
    const bottomPad = 22.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    final gridPaint = Paint()
      ..color = kBluePrimary.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    final axisStyle = kTextXs;

    // เส้นแนวนอน + ป้าย % ที่ 0/50/100
    for (final pct in [0, 50, 100]) {
      final y = chartH - (pct / 100) * chartH;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      _paintText(canvas, '$pct%', Offset(0, y - 7), axisStyle, width: leftPad - 6, alignRight: true);
    }

    // เส้นแนวโน้ม
    final points = <Offset>[];
    for (var i = 0; i < trend.length; i++) {
      final x = leftPad + (trend.length == 1 ? chartW / 2 : chartW * i / (trend.length - 1));
      final y = chartH - (trend[i].percent / 100).clamp(0.0, 1.0) * chartH;
      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = kBluePrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = kBluePrimary;
    final dotFill = Paint()..color = Colors.white;
    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 2.5, dotFill);
    }

    // ป้ายวันที่ (แสดงต้น/กลาง/ท้าย เพื่อไม่ให้ทับกัน)
    final labelIndexes = {0, trend.length ~/ 2, trend.length - 1};
    for (final i in labelIndexes) {
      final d = trend[i].date;
      _paintText(
        canvas,
        '${d.day}/${d.month}',
        Offset(points[i].dx - 18, size.height - bottomPad + 4),
        axisStyle,
        width: 36,
        center: true,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    double? width,
    bool alignRight = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: alignRight
          ? TextAlign.right
          : center
              ? TextAlign.center
              : TextAlign.left,
    )..layout(minWidth: width ?? 0, maxWidth: width ?? double.infinity);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.trend != trend;
}

class _RecentGames extends StatelessWidget {
  const _RecentGames({required this.games, required this.titles});

  final List<RecentGame> games;
  final Map<String, String> titles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kSpace3,
      runSpacing: kSpace3,
      children: [
        for (final game in games)
          SizedBox(
            width: 220,
            child: _card(
              child: Row(
                children: [
                  Icon(_gameIcon(game.module), color: kBluePrimary, size: 34),
                  const SizedBox(width: kSpace3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _gameLabel(game, titles),
                          style: kTextSm.copyWith(color: kTextPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'คะแนน ${game.score}/10',
                          style: kTextXs,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

IconData _gameIcon(String module) => switch (module) {
  kModuleDailyLife => Icons.shopping_basket_rounded,
  kModuleMemory => Icons.grid_view_rounded,
  kModuleVocab => Icons.quiz_rounded,
  _ => Icons.videogame_asset_rounded,
};

String _gameLabel(RecentGame game, Map<String, String> titles) {
  return switch (game.module) {
    kModuleDailyLife => titles[game.scenarioId] ?? 'ชีวิตประจำวัน',
    kModuleMemory =>
      'จับคู่ภาพ${_categorySuffix(game.scenarioId, 'memory_')}',
    kModuleVocab => 'ตอบคำถาม${_categorySuffix(game.scenarioId, 'quiz_')}',
    _ => game.scenarioId,
  };
}

// scenarioId เป็น memory_<หมวด> / quiz_<หมวด> → " · ชื่อหมวด"
String _categorySuffix(String scenarioId, String prefix) {
  if (!scenarioId.startsWith(prefix)) return '';
  final category = scenarioId.substring(prefix.length);
  final title = kVocabCategoryTitles[category];
  return title == null ? '' : ' · $title';
}

class _TipsPanel extends StatelessWidget {
  const _TipsPanel({required this.tips});

  final List<SkillTip> tips;

  @override
  Widget build(BuildContext context) {
    return _card(
      color: kWarmSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: kYellowDark),
              const SizedBox(width: kSpace2),
              Text('ข้อแนะนำ', style: kTextMd),
            ],
          ),
          const SizedBox(height: kSpace3),
          for (final tip in tips) ...[
            _TipItem(tip: tip),
            if (tip != tips.last) const SizedBox(height: kSpace4),
          ],
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.tip});

  final SkillTip tip;

  @override
  Widget build(BuildContext context) {
    final color =
        tip.dimension == null ? kYellowDark : _skillColors[tip.dimension]!;
    final icon =
        tip.dimension == null
            ? Icons.schedule_rounded
            : _skillIcons[tip.dimension]!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: kSpace3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tip.titleTh, style: kTextSm.copyWith(color: color)),
              Text(tip.bodyTh, style: kTextXs.copyWith(color: kTextSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
