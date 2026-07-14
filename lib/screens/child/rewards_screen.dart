import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/rewards/rewards_catalog.dart';
import '../../providers/child_profile_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/paper_background.dart';
import '../../widgets/child/pressable_child_card.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/orientation_lock.dart';

// หน้า "รางวัลของฉัน" (เข้าจากปุ่ม 🏆 มุมขวาบนหน้าเลือกเล่น) — 2 ส่วน:
//   A. สมุดสะสมสติกเกอร์ — ดาวสะสมปลดล็อกทีละใบ (เกณฑ์ขั้นบันได 10/25/40/70/100/130 แล้ว +30)
//   B. เหรียญความสำเร็จ — ปลดล็อกอัตโนมัติเมื่อถึงหลักไมล์ (ดาว/จำนวนครั้ง/ครบทุกเกม/สตรีค)
// ทั้งคู่ "สะสมอย่างเดียว ไม่มีวันเสีย" (ดู rewards_catalog.dart) เหมาะกับกลุ่มเป้าหมาย
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalStars = ref.watch(totalStarsProvider);
    final playStats = ref.watch(rewardsStatsProvider);
    final stats = RewardsStats(
      totalStars: totalStars,
      gamesCompleted: playStats.gamesCompleted,
      modulesPlayed: playStats.modulesPlayed,
      bestStreak: playStats.bestStreak,
    );

    final stickersUnlocked = stickersUnlockedCount(totalStars);
    final medalsUnlocked = medalsUnlockedCount(stats);

    return OrientationLock(
      portrait: false,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: PaperBackground()),
              FadeSlideIn(
                child: Center(
                  child: ConstrainedBox(
                    // กันยืดกว้างเกินไปบนแท็บเล็ตจอใหญ่ — เนื้อหาอยู่กลางจอ
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      children: [
                        _Header(
                          totalStars: totalStars,
                          stickersUnlocked: stickersUnlocked,
                          medalsUnlocked: medalsUnlocked,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              kSpace5,
                              0,
                              kSpace5,
                              kSpace6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle(
                                  icon: Icons.auto_awesome_rounded,
                                  color: kYellowDark,
                                  title: 'สมุดสะสมสติกเกอร์',
                                  trailing: '$stickersUnlocked/${kStickers.length}',
                                ),
                                const SizedBox(height: kSpace3),
                                _StickerGrid(unlockedCount: stickersUnlocked),
                                const SizedBox(height: kSpace6),
                                _SectionTitle(
                                  icon: Icons.emoji_events_rounded,
                                  color: kYellowDark,
                                  title: 'เหรียญรางวัล',
                                  trailing: '$medalsUnlocked/${kMedals.length}',
                                ),
                                const SizedBox(height: kSpace3),
                                _MedalGrid(stats: stats),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned(top: 8, left: 8, child: ChildBackButton()),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- ส่วนหัว: ชื่อหน้า + ดาวสะสม + ความคืบหน้าสู่สติกเกอร์ใบถัดไป --------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.totalStars,
    required this.stickersUnlocked,
    required this.medalsUnlocked,
  });

  final int totalStars;
  final int stickersUnlocked;
  final int medalsUnlocked;

  @override
  Widget build(BuildContext context) {
    final toNext = starsToNextSticker(totalStars);
    final allStickers = stickersUnlocked >= kStickers.length;
    // ความคืบหน้าภายในช่วงปัจจุบันสู่ใบถัดไป (0..1) — เต็มแถบเมื่อสะสมครบทุกใบ (เกณฑ์ขั้นบันได)
    final progress = stickerProgress(totalStars);

    return Padding(
      // เว้นซ้าย 72 ให้พ้นปุ่มย้อนกลับที่ลอยมุมบนซ้าย (8 + 64)
      padding: const EdgeInsets.fromLTRB(
        kTouchTargetMin + kSpace2,
        kSpace2,
        kSpace5,
        kSpace3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'รางวัลของฉัน',
                  style: kTextXL.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  allStickers
                      ? 'สะสมสติกเกอร์ครบทุกใบแล้ว เก่งมาก! 🎉'
                      : 'อีก $toNext ดาว ได้สติกเกอร์ใบใหม่!',
                  style: kTextSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: kSpace2),
                // แถบความคืบหน้าสู่สติกเกอร์ใบถัดไป
                ClipRRect(
                  borderRadius: kRadiusFull,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: kWarmSurface,
                    valueColor: const AlwaysStoppedAnimation(kYellowPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: kSpace4),
          _StarsBadge(totalStars: totalStars),
        ],
      ),
    );
  }
}

// ป้ายกลมโชว์ดาวสะสมรวม
class _StarsBadge extends StatelessWidget {
  const _StarsBadge({required this.totalStars});

  final int totalStars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpace4,
        vertical: kSpace2,
      ),
      decoration: BoxDecoration(
        color: kWarmWhite,
        borderRadius: kRadiusFull,
        boxShadow: const [kShadowSm],
        border: Border.all(color: kYellowPrimary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: kYellowPrimary, size: 26),
          const SizedBox(width: kSpace1),
          Text(
            '$totalStars',
            style: kTextLg.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.color,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: kSpace2),
        Text(title, style: kTextLg.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: kSpace2),
        // ตัวนับ ปลดล็อกแล้ว/ทั้งหมด
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpace3,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: kWarmWhite,
            borderRadius: kRadiusFull,
            boxShadow: const [kShadowSm],
          ),
          child: Text(
            trailing,
            style: kTextSm.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------- A. ตารางสติกเกอร์ --------------------

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.unlockedCount});

  final int unlockedCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kSpace3,
      runSpacing: kSpace3,
      children: [
        for (var i = 0; i < kStickers.length; i++)
          _StickerTile(sticker: kStickers[i], unlocked: i < unlockedCount),
      ],
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.sticker, required this.unlocked});

  final StickerDef sticker;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: 96,
      height: 112,
      padding: const EdgeInsets.all(kSpace1),
      decoration: BoxDecoration(
        color: unlocked ? kWarmWhite : kDisabledSurface,
        borderRadius: kRadiusMd,
        boxShadow: unlocked ? const [kShadowSm] : null,
        border: Border.all(
          color: unlocked ? kYellowPrimary : kWarmBorder,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (unlocked)
            Text(sticker.emoji, style: const TextStyle(fontSize: 46))
          else
            const Icon(Icons.lock_rounded, color: kDisabledText, size: 34),
          const SizedBox(height: kSpace1),
          Text(
            unlocked ? sticker.name : 'ยังไม่ได้',
            style: kTextXs.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked ? kTextPrimary : kDisabledText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    // ปลดล็อกแล้วกดได้ (มีเสียง+เด้งเล็กน้อยให้รู้สึกสนุก); ยังไม่ปลด = ไม่ตอบสนอง
    if (!unlocked) return tile;
    return PressableChildCard(
      onTap: () {},
      playClickSound: true,
      enforceMinTapTarget: false,
      child: tile,
    );
  }
}

// -------------------- B. ตารางเหรียญ --------------------

class _MedalGrid extends StatelessWidget {
  const _MedalGrid({required this.stats});

  final RewardsStats stats;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kSpace3,
      runSpacing: kSpace3,
      children: [for (final m in kMedals) _MedalTile(medal: m, stats: stats)],
    );
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({required this.medal, required this.stats});

  final MedalDef medal;
  final RewardsStats stats;

  @override
  Widget build(BuildContext context) {
    final unlocked = medalUnlocked(medal, stats);
    final current = medalCurrentValue(medal, stats);
    final shown = current > medal.target ? medal.target : current;
    final progress = medal.target == 0 ? 1.0 : shown / medal.target;

    final tile = Container(
      width: 156,
      padding: const EdgeInsets.symmetric(
        horizontal: kSpace3,
        vertical: kSpace4,
      ),
      decoration: BoxDecoration(
        color: unlocked ? kYellowLight : kWarmWhite,
        borderRadius: kRadiusLg,
        boxShadow: const [kShadowSm],
        border: Border.all(
          color: unlocked ? kYellowPrimary : kWarmBorder,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // แผ่นเหรียญ
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? kYellowPrimary : kDisabledSurface,
              boxShadow:
                  unlocked
                      ? [
                        BoxShadow(
                          color: kYellowPrimary.withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Center(
              // ยังไม่ปลด = โชว์อิโมจิจางๆ ให้เห็นว่ากำลังลุ้นอะไรอยู่
              child: Opacity(
                opacity: unlocked ? 1 : 0.35,
                child: Text(medal.emoji, style: const TextStyle(fontSize: 34)),
              ),
            ),
          ),
          const SizedBox(height: kSpace2),
          Text(
            medal.title,
            style: kTextSm.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: kSpace2),
          if (unlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: kSuccess,
                  size: 18,
                ),
                const SizedBox(width: kSpace1),
                Text(
                  'สำเร็จ!',
                  style: kTextXs.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kSuccess,
                  ),
                ),
              ],
            )
          else ...[
            ClipRRect(
              borderRadius: kRadiusFull,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: kWarmSurface,
                valueColor: const AlwaysStoppedAnimation(kBluePrimary),
              ),
            ),
            const SizedBox(height: kSpace1),
            Text(
              '$shown/${medal.target}',
              style: kTextXs.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );

    if (!unlocked) return tile;
    return PressableChildCard(
      onTap: () {},
      playClickSound: true,
      enforceMinTapTarget: false,
      child: tile,
    );
  }
}
