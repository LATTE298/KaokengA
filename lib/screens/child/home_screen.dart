import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_routes.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/pressable_child_card.dart';
import '../../widgets/orientation_lock.dart';

// หน้าเริ่มต้น (Title screen, ล็อกแนวตั้ง) — มาก่อนหน้าเลือกโหมด
// 1) ปุ่ม "เริ่มเล่น" → หน้าเลือกโหมด (ครอบด้วย OrientationLock portrait:false = เข้าโหมด
//    แนวนอนทันที) 2) ปุ่มผู้ปกครองมุมขวาบน → parent gate 3) โลโก้ + ชื่อแอป
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationLock(
      portrait: true,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        body: Stack(
          children: [
            const Positioned.fill(child: _Background()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(kSpace6),
                child: Column(
                  children: [
                    // แถวบน — ปุ่มผู้ปกครองเกาะมุมขวา
                    Row(
                      children: [
                        const Spacer(),
                        _ParentButton(
                          onTap: () {
                            HapticService.parentGateComplete();
                            parentAreaOrigin =
                                kRouteHome; // กลับมาหน้านี้เมื่อกดกลับ
                            context.push(kRouteParentGate);
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _BrandLogo(),
                            const SizedBox(height: kSpace5),
                            Text(
                              'ก้าวเก่ง',
                              style: kTextXL.copyWith(
                                color: kBlueDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: kSpace2),
                            Text(
                              'เรียนรู้ผ่านการเล่น',
                              style: kTextMd.copyWith(color: kTextSecondary),
                            ),
                            const SizedBox(height: kSpace10),
                            _PlayButton(
                              onTap: () => context.go(kRouteModeSelect),
                            ),
                          ],
                        ),
                      ),
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

// พื้นหลังไล่สีนุ่ม (โทนเดียวกับพื้นหลังหน้าเลือกโหมด)
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kBlueLight, kWarmWhite, kSuccessLight],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// ปกแอป (รูปจริง) เหนือปุ่มเริ่มเล่น — ถ้าโหลดไม่ได้ตกไปโลโก้วงกลม gradient สำรอง
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
      child: Image.asset(
        'assets/images/home_cover.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [kBluePrimary, kYellowPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [kShadowMd],
      ),
      child: const Icon(
        Icons.child_care_rounded,
        color: Colors.white,
        size: 72,
      ),
    );
  }
}

// ปุ่ม "เริ่มเล่น" ใหญ่ กดง่าย (haptic + เสียงคลิกผ่าน PressableChildCard)
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      playClickSound: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpace8,
          vertical: kSpace4,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kYellowPrimary, kYellowDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: kRadiusFull,
          boxShadow: const [kShadowMd],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: kTextPrimary, size: 34),
            const SizedBox(width: kSpace2),
            Text(
              'เริ่มเล่น',
              style: kTextLg.copyWith(
                color: kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ปุ่มผู้ปกครอง (มุมขวาบน) — พาไป parent gate
class _ParentButton extends StatelessWidget {
  const _ParentButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      enforceMinTapTarget: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(kSpace3, kSpace2, kSpace4, kSpace2),
        decoration: BoxDecoration(
          color: kWarmWhite,
          borderRadius: kRadiusFull,
          boxShadow: const [kShadowSm],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_circle_rounded,
              color: kBluePrimary,
              size: 22,
            ),
            const SizedBox(width: kSpace2),
            Text(
              'ผู้ปกครอง',
              style: kTextSm.copyWith(
                color: kBlueDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
