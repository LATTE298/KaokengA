import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../features/streak/streak_tracker.dart';
import '../../l10n/tts_strings_th.dart';
import '../../providers/bgm_provider.dart';
import '../../providers/child_profile_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/tts_provider.dart';
import '../../services/bgm_service.dart';
import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/pressable_child_card.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/orientation_lock.dart';

// หน้าเลือกเล่นฝั่งเด็ก (ธีมใหม่ตาม mockup 2026-07-11)
// asset จริงแล้ว: พื้นหลังวิดีโอลูป `assets/video/kaokeng_bg.mp4` (+ ภาพนิ่งสำรอง
// `home_bg.jpg`) + รูปปกโหมด `assets/images/mode_{daily,memory,vocab,family}.jpg`
// รออยู่: รูป avatar `assets/images/home_avatar.png` (ตกไปไอคอนหน้ายิ้มระหว่างรอ)
//
// ข้อมูลจริงทั้งหมดแล้ว: สตรีค = streakProvider, ชื่อเด็ก = childNameProvider
// (ผู้ปกครองตั้งจาก dashboard), ดาวสะสม = totalStarsProvider (บวกทุกครั้งจบเกม) —
// ทั้งหมดเก็บ Hive `app_prefs`. เมนู "ความคืบหน้า" เปิด dashboard ผู้ปกครอง (แท็บ
// ความก้าวหน้า); เมนู "รางวัล" ยัง coming-soon (ผูกเฟส 3.1 มาสคอตที่พักไว้รอ design)

// เปิดวิดีโอพื้นหลัง — เดิมแตก (เส้นเขียว) เพราะ Impeller; ปิด Impeller ใน AndroidManifest
// แล้วใช้ Skia เรนเดอร์วิดีโอปกติ (2026-07-13). ถ้ายังแตกให้ตั้ง false = ใช้ภาพนิ่งแทน
const bool _kEnableBgVideo = true;

// asset พื้นหลัง: วิดีโอลูป (หลัก) + ภาพนิ่ง (ขึ้นทันที/สำรองถ้าวิดีโอโหลดไม่ทัน)
const String _kHomeBgVideo = 'assets/video/kaokeng_bg.mp4';
const String _kHomeBgAsset = 'assets/images/home_bg.jpg';
const String _kAvatarAsset = 'assets/images/home_avatar.png';

class _ModeData {
  const _ModeData({
    required this.label,
    required this.description,
    required this.coverAsset,
    required this.fallbackIcon,
    required this.background,
    required this.accent,
    required this.onAccent,
    required this.route,
    this.ttsKey,
  });

  final String label;
  final String description;
  final String coverAsset;
  final IconData fallbackIcon;
  final Color background;
  final Color accent;
  final Color onAccent;
  final String route;
  final String? ttsKey;
}

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openParentArea() {
      HapticService.parentGateComplete();
      parentAreaOrigin = kRouteModeSelect; // กลับมาหน้านี้เมื่อกดกลับ
      context.push(kRouteParentGate);
    }

    // เมนู "ความคืบหน้า" → dashboard แบบ "ดูอย่างเดียว" (view=progress): ล็อกที่แท็บ
    // ความก้าวหน้า สลับแท็บ/เข้าบัญชี-ตั้งค่าไม่ได้ (กันเด็กเข้าส่วนผู้ปกครองอื่น)
    // หน้า dashboard กันตัวเองด้วยการล็อกอินอยู่แล้ว (ยังไม่ล็อกอิน = โชว์ปุ่มเข้าระบบ)
    void openProgress() {
      context.push('$kRouteDashboard?view=progress');
    }

    void comingSoon(String label) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: kBlueDark,
            duration: const Duration(seconds: 2),
            content: Text(
              '$label กำลังจะมาเร็ว ๆ นี้นะ',
              style: kTextSm.copyWith(color: kWarmWhite),
            ),
          ),
        );
    }

    const modes = <_ModeData>[
      _ModeData(
        label: kLabelModuleA,
        description: 'ลองทำกิจกรรม',
        coverAsset: 'assets/images/mode_daily.jpg',
        fallbackIcon: Icons.home_rounded,
        background: kYellowLight,
        accent: kYellowPrimary,
        onAccent: kTextPrimary,
        route: kRouteModuleA,
        ttsKey: kTtsModuleADesc,
      ),
      _ModeData(
        label: kLabelModuleB,
        description: 'จับคู่รูปภาพ',
        coverAsset: 'assets/images/mode_memory.jpg',
        fallbackIcon: Icons.grid_view_rounded,
        background: kBlueLight,
        accent: kBluePrimary,
        onAccent: kWarmWhite,
        route: kRouteModuleB,
        ttsKey: kTtsModuleBDesc,
      ),
      _ModeData(
        label: kLabelModuleC,
        description: 'เรียนคำศัพท์',
        coverAsset: 'assets/images/mode_vocab.jpg',
        fallbackIcon: Icons.record_voice_over_rounded,
        background: kYellowLight,
        accent: kYellowPrimary,
        onAccent: kTextPrimary,
        route: kRouteModuleC,
        ttsKey: kTtsModuleCDesc,
      ),
      _ModeData(
        label: 'ครอบครัว',
        description: 'ทายว่าใครเป็นใคร',
        coverAsset: 'assets/images/mode_family.jpg',
        fallbackIcon: Icons.diversity_3_rounded,
        background: kBlueLight,
        accent: kBluePrimary,
        onAccent: kWarmWhite,
        route: kRouteFamilyGame,
      ),
    ];

    return OrientationLock(
      portrait: false,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        body: Stack(
          children: [
            const Positioned.fill(child: _HomeBackground()),
            SafeArea(
              child: Padding(
                // ขวา 8px — ปุ่มรางวัล/ตั้งค่าชิดขวามากขึ้นแต่ยังไม่ติดขอบจอ
                padding: const EdgeInsets.fromLTRB(
                  kSpace4,
                  kSpace2,
                  kSpace2,
                  kSpace2,
                ),
                child: Column(
                  children: [
                    _TopBar(
                      streakDays: ref.watch(streakProvider),
                      onRewards: () => comingSoon('รางวัล'),
                      onSettings:
                          () => showDialog<void>(
                            context: context,
                            builder:
                                (_) => _BgmSettingsDialog(
                                  bgm: ref.read(bgmServiceProvider),
                                ),
                          ),
                    ),
                    Expanded(
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            const gap = kInteractiveGapMin;
                            final usableWidth = constraints.maxWidth.clamp(
                              0.0,
                              1280.0,
                            );
                            final cardWidth = ((usableWidth - gap * 3) / 4)
                                .clamp(120.0, 300.0);
                            // ขนาด "ธรรมชาติ" ของการ์ด (ใหญ่ขึ้น) — FittedBox ข้างล่าง
                            // ย่อทั้งบล็อกให้พอดีจอเสมอ (จอเตี้ย/เล็กแค่ไหนก็ไม่ overflow)
                            final cardHeight = (cardWidth * 1.55).clamp(
                              210.0,
                              410.0,
                            );

                            return FadeSlideIn(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const _PlayTitle(),
                                    const SizedBox(height: kSpace2),
                                    SizedBox(
                                      height: cardHeight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (
                                            var i = 0;
                                            i < modes.length;
                                            i++
                                          ) ...[
                                            if (i > 0)
                                              const SizedBox(width: gap),
                                            _ModeCard(
                                              data: modes[i],
                                              width: cardWidth,
                                              phase: i * 0.2,
                                              onTap: () {
                                                final tts = modes[i].ttsKey;
                                                if (tts != null) {
                                                  ref
                                                      .read(ttsServiceProvider)
                                                      .speak(tts);
                                                }
                                                context.push(modes[i].route);
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // ช่องว่างเล็กๆ คั่นการ์ดเกมกับแถบเมนูล่าง (ผู้ใช้กำหนด)
                    const SizedBox(height: kSpace3),
                    _BottomNav(
                      onParent: openParentArea,
                      onProgress: openProgress,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// พื้นหลัง — 3 ชั้นซ้อน (ล่าง→บน): gradient สำรอง → ภาพนิ่ง home_bg.jpg (ขึ้นทันที)
// → วิดีโอลูป kaokeng_bg.mp4 (เฟดทับเมื่อ init เสร็จ). ถ้าวิดีโอโหลดไม่ทัน/พังหรือเปิด
// reduce-motion ก็เห็นภาพนิ่งแทน ไม่มีทางว่างเปล่า
class _HomeBackground extends StatefulWidget {
  const _HomeBackground();

  @override
  State<_HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<_HomeBackground> {
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _initStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // เคารพ "ลดการเคลื่อนไหว" ของระบบ — ปิดวิดีโอ ใช้ภาพนิ่ง (spec accessibility)
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_kEnableBgVideo && !reduceMotion && !_initStarted) {
      _initStarted = true;
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(_kHomeBgVideo);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0); // พื้นหลังเงียบเสมอ
      await controller.play();
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      // วิดีโอเล่นไม่ได้ (เช่น web codec) — ปล่อยให้ภาพนิ่งทำงานแทน ไม่พัง
      await controller.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kBlueLight, kWarmWhite, kSuccessLight],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Image.asset(
          _kHomeBgAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        if (_videoReady && controller != null)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: kDurationNormal,
            builder: (_, value, child) => Opacity(opacity: value, child: child),
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
      ],
    );
  }
}

// หัวข้อ "เลือกเล่น" + ประกายตกแต่งสองข้าง
class _PlayTitle extends StatelessWidget {
  const _PlayTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome_rounded, color: kYellowPrimary, size: 15),
        const SizedBox(width: kSpace2),
        Text('เลือกเล่น', style: kTextLg.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: kSpace2),
        const Icon(Icons.auto_awesome_rounded, color: kBluePrimary, size: 15),
      ],
    );
  }
}

// -------------------- แถบบน: โปรไฟล์ + สตรีค + ปุ่มรางวัล/ตั้งค่า --------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.streakDays,
    required this.onRewards,
    required this.onSettings,
  });

  final int streakDays;
  final VoidCallback onRewards;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    // ทุกชิ้นห่อ FittedBox(scaleDown) — จอแคบแค่ไหนก็ย่อแทนการล้น (no overflow)
    // ชิดขอบบนทั้งแถว: ปุ่มรางวัล/ตั้งค่าเกาะมุมขวาบนเหมือนชิปโปรไฟล์ฝั่งซ้าย
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: const _ProfileChip(),
          ),
        ),
        const SizedBox(width: kSpace3),
        Expanded(
          flex: 4,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _StreakChip(days: streakDays),
            ),
          ),
        ),
        const SizedBox(width: kSpace3),
        _RoundActionButton(
          icon: Icons.emoji_events_rounded,
          color: kYellowPrimary,
          onTap: onRewards,
        ),
        const SizedBox(width: kSpace3),
        _RoundActionButton(
          icon: Icons.settings_rounded,
          color: kBluePrimary,
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _ProfileChip extends ConsumerWidget {
  const _ProfileChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childName = ref.watch(childNameProvider);
    final stars = ref.watch(totalStarsProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(kSpace1, kSpace1, kSpace4, kSpace1),
      decoration: BoxDecoration(
        color: kWarmWhite,
        borderRadius: kRadiusFull,
        boxShadow: const [kShadowSm],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: kYellowLight,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              _kAvatarAsset,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => const Icon(
                    Icons.face_rounded,
                    color: kYellowDark,
                    size: 24,
                  ),
            ),
          ),
          const SizedBox(width: kSpace2),
          Text(
            'สวัสดี $childName',
            style: kTextSm.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(width: kSpace2),
          const Icon(Icons.star_rounded, color: kYellowPrimary, size: 16),
          const SizedBox(width: 2),
          Text(
            '$stars',
            style: kTextXs.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

  /// จำนวนวันเข้าเล่นต่อเนื่องจริง (จาก streakProvider)
  final int days;

  @override
  Widget build(BuildContext context) {
    // เกิน 7 วันโชว์เต็มแถบ 7/7 (รอบเป้าหมายตาม mockup)
    final shown = days.clamp(0, kStreakGoalDays);
    final progress = (shown / kStreakGoalDays).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kSpace3,
        vertical: kSpace1,
      ),
      decoration: BoxDecoration(
        color: kWarmWhite,
        borderRadius: kRadiusFull,
        boxShadow: const [kShadowSm],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: kError,
            size: 18,
          ),
          const SizedBox(width: kSpace1),
          Text(
            'ต่อเนื่อง $days วัน',
            style: kTextXs.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(width: kSpace2),
          // แถบความคืบหน้าสตรีค
          Container(
            width: 68,
            height: 9,
            decoration: BoxDecoration(
              color: kWarmSurface,
              borderRadius: kRadiusFull,
            ),
            clipBehavior: Clip.antiAlias,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: kSuccess,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
              ),
            ),
          ),
          const SizedBox(width: kSpace2),
          Text(
            '$shown/$kStreakGoalDays',
            style: kTextXs.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(width: kSpace1),
          const Icon(Icons.card_giftcard_rounded, color: kError, size: 16),
        ],
      ),
    );
  }
}

// ปุ่มกลมไอคอนล้วน (ไม่มีป้ายข้อความ — ผู้ใช้กำหนด ลดความรก)
class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      enforceMinTapTarget: false,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kWarmWhite,
          shape: BoxShape.circle,
          boxShadow: const [kShadowSm],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// -------------------- การ์ดโหมดเกม --------------------

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.data,
    required this.width,
    required this.onTap,
    this.phase = 0,
  });

  final _ModeData data;
  final double width;
  final VoidCallback onTap;

  /// จังหวะเริ่มของอนิเมชันลอย (0..1) — ไล่ให้การ์ดแต่ละใบไม่ขยับพร้อมกัน
  final double phase;

  @override
  Widget build(BuildContext context) {
    final card = PressableChildCard(
      onTap: onTap,
      playClickSound: true,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(kSpace3),
        decoration: BoxDecoration(
          color: data.background,
          borderRadius: kRadiusLg,
          boxShadow: const [kShadowMd],
        ),
        child: Column(
          children: [
            // ช่องรูปปก (slot) — ตกไปไอคอนบนพื้นขาวระหว่างรอไฟล์จริง
            Expanded(
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: kWarmWhite,
                  borderRadius: kRadiusMd,
                ),
                child: Image.asset(
                  data.coverAsset,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Center(
                        child: Icon(
                          data.fallbackIcon,
                          size: 48,
                          color: data.accent,
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: kSpace3),
            Text(
              data.label,
              style: kChildLabel.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: kSpace1),
            Text(
              data.description,
              style: kTextSm,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: kSpace3),
            // ปุ่มลูกศร (เป็นเพียง affordance — ทั้งการ์ดกดได้)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.accent,
                shape: BoxShape.circle,
                boxShadow: const [kShadowSm],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: data.onAccent,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
    return _FloatingCard(phase: phase, child: card);
  }
}

// ห่อการ์ดให้ "ลอยขึ้นลง + เอียงเบาๆ" วนไปเรื่อยๆ (subtle ไม่กระตุ้นตา — spec 1.3)
// [phase] 0..1 ไล่จังหวะให้แต่ละใบไม่ขยับพร้อมกัน. ปิดเมื่อระบบเปิด reduce-motion
class _FloatingCard extends StatefulWidget {
  const _FloatingCard({required this.child, required this.phase});

  final Widget child;
  final double phase;

  @override
  State<_FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<_FloatingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = (_controller.value + widget.phase) * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, math.sin(t) * 6),
          child: Transform.rotate(angle: math.sin(t) * 0.012, child: child),
        );
      },
    );
  }
}

// แผงตั้งค่าเพลงประกอบ (เปิดจากปุ่ม ⚙️) — เปิด/ปิด + ปรับความดัง (จำค่าลง Hive)
class _BgmSettingsDialog extends StatefulWidget {
  const _BgmSettingsDialog({required this.bgm});

  final BgmService bgm;

  @override
  State<_BgmSettingsDialog> createState() => _BgmSettingsDialogState();
}

class _BgmSettingsDialogState extends State<_BgmSettingsDialog> {
  late bool _enabled = widget.bgm.enabled;
  late double _volume = widget.bgm.volume;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kWarmWhite,
      shape: RoundedRectangleBorder(borderRadius: kRadiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(kSpace6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    color: kBluePrimary,
                    size: 26,
                  ),
                  const SizedBox(width: kSpace2),
                  Text(
                    'ตั้งค่าเพลงประกอบ',
                    style: kTextLg.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: kSpace5),
              Row(
                children: [
                  Expanded(child: Text('เปิดเพลงประกอบ', style: kTextMd)),
                  Switch(
                    value: _enabled,
                    activeThumbColor: kBluePrimary,
                    onChanged: (v) {
                      setState(() => _enabled = v);
                      widget.bgm.setEnabled(v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: kSpace2),
              Opacity(
                opacity: _enabled ? 1 : 0.4,
                child: Row(
                  children: [
                    const Icon(
                      Icons.volume_down_rounded,
                      color: kTextSecondary,
                    ),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        activeColor: kBluePrimary,
                        onChanged:
                            _enabled
                                ? (v) {
                                  setState(() => _volume = v);
                                  widget.bgm.setVolume(v);
                                }
                                : null,
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded, color: kTextSecondary),
                  ],
                ),
              ),
              const SizedBox(height: kSpace4),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('เสร็จ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- แถบเมนูล่าง --------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onParent, required this.onProgress});

  final VoidCallback onParent;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kSpace2, vertical: 4),
      decoration: BoxDecoration(
        color: kWarmWhite,
        borderRadius: kRadiusFull,
        boxShadow: const [kShadowMd],
      ),
      // 3 เมนูพอ (ผู้ใช้กำหนด) — ห่อ FittedBox กันล้นบนจอแคบมาก
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              color: kBluePrimary,
              active: true,
              onTap: () {}, // อยู่หน้านี้อยู่แล้ว
            ),
            _NavItem(
              icon: Icons.bar_chart_rounded,
              color: kSuccess,
              onTap: onProgress,
            ),
            _NavItem(
              icon: Icons.groups_rounded,
              color: kBlueDark,
              onTap: onParent,
            ),
          ],
        ),
      ),
    );
  }
}

// เมนูล่างแบบไอคอนล้วน (ไม่มีป้ายข้อความ — ผู้ใช้กำหนด) + จุดบอก active ใต้ไอคอน
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      enforceMinTapTarget: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kSpace3, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            // จุดบอกสถานะ active ใต้เมนูที่เลือกอยู่
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: active ? color : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
