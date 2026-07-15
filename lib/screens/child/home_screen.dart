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
                    const SizedBox(height: kSpace4),
                    const _Footer(),
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

// ลิงก์ footer (Privacy / Safety / Support / Terms) — แตะเปิด dialog ข้อมูลสั้นๆ.
// เนื้อหา (title/body) แก้/เพิ่มฉบับเต็มได้ที่ [_kFooterItems]
const List<({String label, String title, String body})> _kFooterItems = [
  (
    label: 'Privacy',
    title: 'ความเป็นส่วนตัว',
    body:
        'ก้าวเก่งให้ความสำคัญกับความเป็นส่วนตัว — เด็กเล่นแบบไม่ระบุตัวตน '
        'ไม่เก็บข้อมูลส่วนบุคคลของเด็ก และข้อมูลการเล่นเก็บในเครื่องเป็นหลัก\n\n'
        '(เพิ่มรายละเอียดนโยบายฉบับเต็มได้ภายหลัง)',
  ),
  (
    label: 'Safety',
    title: 'ความปลอดภัย',
    body:
        'ออกแบบสำหรับเด็กพิเศษ — มีตัวเตือนพักสายตาระหว่างเล่น '
        'ไม่มีโฆษณา และไม่มีการซื้อในแอป',
  ),
  (
    label: 'Support',
    title: 'ติดต่อเรา',
    body:
        'มีคำถามหรือข้อเสนอแนะ ติดต่อทีมพัฒนาได้ที่\n'
        '(ใส่อีเมล/ช่องทางติดต่อภายหลัง)',
  ),
  (
    label: 'Terms',
    title: 'เงื่อนไขการใช้งาน',
    body: 'เงื่อนไขการใช้งานแอปก้าวเก่ง\n(เพิ่มเนื้อหาฉบับเต็มได้ภายหลัง)',
  ),
];

void _showFooterInfo(BuildContext context, String title, String body) {
  showDialog<void>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          backgroundColor: kWarmWhite,
          shape: RoundedRectangleBorder(borderRadius: kRadiusLg),
          title: Text(
            title,
            style: kTextLg.copyWith(fontWeight: FontWeight.w800),
          ),
          content: Text(
            body,
            style: kTextBase.copyWith(color: kTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ปิด'),
            ),
          ],
        ),
  );
}

// แถบลิงก์ด้านล่างหน้าเริ่ม — 4 ลิงก์คั่นด้วยจุด (ตามภาพตัวอย่าง)
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < _kFooterItems.length; i++) ...[
          if (i > 0)
            Text('·', style: kTextSm.copyWith(color: kTextHint)),
          _FooterLink(item: _kFooterItems[i]),
        ],
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.item});

  final ({String label, String title, String body}) item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showFooterInfo(context, item.title, item.body),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: kSpace3,
          vertical: kSpace1,
        ),
        child: Text(
          item.label,
          style: kTextSm.copyWith(
            color: kTextSecondary,
            fontWeight: FontWeight.w600,
          ),
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
