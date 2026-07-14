import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/achievement_provider.dart';
import '../providers/sfx_provider.dart';
import '../services/sfx_player.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

// ครอบ app root (main.dart builder) — คอยฟังคิว achievement แล้วเด้ง toast ทีละใบจากขอบบน
// (สไตล์ Steam/Google Play Games) พร้อมเสียง Kaokeng Achievement. ลอยเหนือทุกหน้า/dialog
// และไม่ขวางการกด (IgnorePointer) เพื่อไม่รบกวนการเล่น
class AchievementOverlay extends ConsumerStatefulWidget {
  const AchievementOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends ConsumerState<AchievementOverlay>
    with SingleTickerProviderStateMixin {
  // สร้างใน initState (ตอน element ยัง active) ไม่ใช่ late-init ตอนแตะครั้งแรก — ไม่งั้นถ้า
  // ไม่เคยมี toast เด้งเลย _c จะถูกสร้างครั้งแรกตอน dispose() ซึ่ง lookup TickerMode ของ
  // element ที่ถูก deactivate แล้ว = crash (ทำให้ unmount ค้าง timer อื่นไม่ถูกยกเลิก)
  late final AnimationController _c;
  late final Animation<double> _anim;

  AchievementNotice? _current;
  Timer? _dwell;

  // เวลาที่ toast ค้างอยู่บนจอก่อนสไลด์ออก
  static const Duration _dwellDuration = Duration(milliseconds: 2600);

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _dwell?.cancel();
    _c.dispose();
    super.dispose();
  }

  // โชว์ใบถัดไปในคิว (ถ้าว่างอยู่และมีของ)
  void _pump() {
    if (_current != null || !mounted) return;
    final queue = ref.read(achievementQueueProvider);
    if (queue.isEmpty) return;
    setState(() => _current = queue.first);
    ref.read(sfxPlayerProvider).play(kSfxAchievement);
    _c.forward(from: 0);
    _dwell?.cancel();
    _dwell = Timer(_dwellDuration, _exit);
  }

  Future<void> _exit() async {
    if (!mounted) return;
    await _c.reverse();
    if (!mounted) return;
    setState(() => _current = null);
    ref.read(achievementQueueProvider.notifier).dismissFirst();
    _pump(); // ใบถัดไป (ถ้ามี)
  }

  @override
  Widget build(BuildContext context) {
    // คิวมีของใหม่ → เริ่มโชว์ (guard ใน _pump กันซ้อน)
    ref.listen<List<AchievementNotice>>(achievementQueueProvider, (_, next) {
      if (next.isNotEmpty) _pump();
    });

    final notice = _current;
    return Stack(
      children: [
        widget.child,
        if (notice != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, child) {
                    final v = _anim.value;
                    return Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      // สไลด์ลงมาจากเหนือขอบจอ (มีเด้งเล็กน้อยจาก easeOutBack)
                      child: Transform.translate(
                        offset: Offset(0, (1 - v) * -80),
                        child: child,
                      ),
                    );
                  },
                  child: _AchievementCard(notice: notice),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.notice});

  final AchievementNotice notice;

  @override
  Widget build(BuildContext context) {
    // ต้องครอบ Material — toast ลอยอยู่เหนือ Scaffold ของแต่ละหน้า จึง "ไม่มี Material
    // ancestor" ถ้าไม่ครอบ Text ทุกตัว (emoji/title/subtitle) จะถูกวาดด้วยสไตล์ error ของ
    // Flutter = ขีดเส้นใต้เหลืองคู่ใต้ข้อความ. type.transparency = ให้ Material semantics
    // โดยไม่วาดพื้นหลังทับการ์ดที่จัดสไตล์เอง
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.only(top: kSpace3),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.fromLTRB(
              kSpace3,
              kSpace2,
              kSpace5,
              kSpace2,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kWarmWhite, kYellowLight],
              ),
              borderRadius: kRadiusFull,
              border: Border.all(color: kYellowPrimary, width: 2),
              boxShadow: const [kShadowLg],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ตราวงกลมทองพร้อม emoji ของรางวัล + ประกายรอบ
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kYellowPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: kYellowPrimary.withValues(alpha: 0.55),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      notice.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: kSpace3),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: kYellowDark,
                            size: 15,
                          ),
                          const SizedBox(width: kSpace1),
                          Flexible(
                            child: Text(
                              notice.title,
                              style: kTextXs.copyWith(
                                fontWeight: FontWeight.w700,
                                color: kYellowDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        notice.subtitle,
                        style: kTextMd.copyWith(
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
