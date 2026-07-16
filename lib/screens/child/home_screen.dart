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
    title: 'นโยบายความเป็นส่วนตัว',
    body:
        'แอปก้าวเก่งให้ความสำคัญกับความเป็นส่วนตัวของเด็กและครอบครัวเป็นอันดับแรก\n\n'
        '1) ข้อมูลที่เราเก็บ\n'
        '• เด็กเล่นแบบไม่ระบุตัวตน เราไม่เก็บชื่อจริงหรือข้อมูลส่วนตัวของเด็ก\n'
        '• ชื่อเล่น (ที่ผู้ปกครองตั้ง) ดาวสะสม สตรีค และความคืบหน้าการเล่น '
        'เก็บไว้ในเครื่อง\n'
        '• หากผู้ปกครองสมัครบัญชี จะเก็บเพียงอีเมลเพื่อใช้เข้าสู่ระบบ\n\n'
        '2) การใช้ข้อมูล\n'
        '• ใช้เพื่อแสดงพัฒนาการของเด็กให้ผู้ปกครองดูเท่านั้น\n'
        '• ไม่ขายหรือแชร์ข้อมูลกับผู้อื่นเพื่อการโฆษณา และไม่มีโฆษณาในแอป\n\n'
        '3) รูปภาพครอบครัว\n'
        '• รูปที่ผู้ปกครองเพิ่มในเกม "ครอบครัว" เก็บไว้ในเครื่องเท่านั้น '
        'ไม่อัปโหลดขึ้นเซิร์ฟเวอร์\n'
        '• ลบออกได้ทุกเมื่อจากหน้าจัดการครอบครัว\n\n'
        '4) ความปลอดภัยของข้อมูล\n'
        '• ข้อมูลบัญชีรับส่งผ่านการเชื่อมต่อที่เข้ารหัส\n'
        '• เด็กไม่ต้องกรอกข้อมูลส่วนตัวใด ๆ เพื่อเล่น\n\n'
        '5) สิทธิ์ของคุณ\n'
        '• เล่นแบบไม่เข้าสู่ระบบ (guest) ได้โดยไม่ต้องให้ข้อมูล\n'
        '• ขอลบบัญชีและข้อมูลทั้งหมดได้จากเมนูผู้ปกครอง\n'
        '• ถอนรูปภาพครอบครัวได้ทุกเมื่อ',
  ),
  (
    label: 'Safety',
    title: 'ความปลอดภัย',
    body:
        'ก้าวเก่งออกแบบมาเพื่อเด็กพิเศษ (โดยเฉพาะกลุ่มดาวน์ซินโดรม) '
        'ให้ใช้งานได้อย่างปลอดภัยและสบายใจ\n\n'
        '• ปุ่มใหญ่ กดง่าย สีนุ่มไม่กระตุ้นสายตา และมีเสียงพูดประกอบ\n'
        '• มีตัวเตือนพักสายตาทุก 15 นาทีของการเล่นต่อเนื่อง\n'
        '• ไม่มีโฆษณา ไม่มีการซื้อในแอป และไม่มีลิงก์ออกภายนอกสำหรับเด็ก\n'
        '• ส่วนของผู้ปกครองมีด่านคำถามกั้น (parent gate) ป้องกันเด็กเข้าเอง\n'
        '• เนื้อหาทั้งหมดเหมาะสมและปลอดภัยสำหรับเด็ก',
  ),
  (
    label: 'Support',
    title: 'ความช่วยเหลือ',
    body:
        '1) คำถามที่พบบ่อย\n'
        '• ต้องต่ออินเทอร์เน็ตไหม — เล่นเกมได้แบบออฟไลน์ '
        '(การเข้าสู่ระบบผู้ปกครองหรือบางเสียงอาจต้องใช้เน็ต)\n'
        '• มีค่าใช้จ่ายไหม — ใช้ฟรี ไม่มีการซื้อในแอป\n'
        '• เพิ่มรูปครอบครัวอย่างไร — เข้าส่วนผู้ปกครอง แล้วเลือกจัดการครอบครัว\n'
        '• ลบข้อมูลอย่างไร — เมนูผู้ปกครอง เลือกออกจากระบบ แล้วลบบัญชี/ข้อมูล\n\n'
        '2) ติดต่อเรา\n'
        '• อีเมล: 53413@yupparaj.ac.th\n\n'
        '3) เกี่ยวกับโครงงาน\n'
        '• "ก้าวเก่ง" เป็นโครงงานของนักเรียนโรงเรียนยุพราชวิทยาลัย'
        'ซึ่งเป็นแอปพลิเคชันที่ช่วยให้เด็กที่มีภาวะดาวน์ซินโดรมได้เรียนรู้ทักษะการใช้ชีวิต'
        'และการสื่อสารผ่านเกม',
  ),
  (
    label: 'Terms',
    title: 'ข้อตกลงในการใช้ซอฟต์แวร์ (Disclaimer)',
    body:
        'ซอฟต์แวร์นี้เป็นผลงานที่พัฒนาขึ้นโดย นางสาวอันนา รัตรสาร นางสาวภิสารัตน์ '
        'จิตตนาน และนายสุรสีห์ ขำสงค์ จากโรงเรียนยุพราชวิทยาลัย ภายใต้การดูแลของ '
        'นางหทัยรัตน์ ศรีวิโรจน์ ภายใต้โครงการ "ก้าวเก่ง" แอปพลิเคชันเพื่อการเรียนรู้'
        'สำหรับผู้เยาว์ที่มีภาวะดาวน์ซินโดรม ซึ่งสนับสนุนโดยสำนักงานพัฒนาวิทยาศาสตร์'
        'และเทคโนโลยีแห่งชาติ โดยมีวัตถุประสงค์เพื่อส่งเสริมให้นักเรียนและนักศึกษาได้'
        'เรียนรู้และฝึกทักษะในการพัฒนาซอฟต์แวร์ ลิขสิทธิ์ของซอฟต์แวร์นี้จึงเป็นของ'
        'ผู้พัฒนา ซึ่งผู้พัฒนาได้อนุญาตให้สำนักงานพัฒนาวิทยาศาสตร์และเทคโนโลยีแห่งชาติ'
        'เผยแพร่ซอฟต์แวร์นี้ตาม "ต้นฉบับ" โดยไม่มีการแก้ไขดัดแปลงใด ๆ ทั้งสิ้น ให้แก่'
        'บุคคลทั่วไปได้ใช้เพื่อประโยชน์ส่วนบุคคลหรือประโยชน์ทางการศึกษาที่ไม่มี'
        'วัตถุประสงค์ในเชิงพาณิชย์โดยไม่คิดค่าตอบแทนการใช้ซอฟต์แวร์ ดังนั้น สำนักงาน'
        'พัฒนาวิทยาศาสตร์และเทคโนโลยีแห่งชาติ จึงไม่มีหน้าที่ในการดูแลบำรุงรักษา '
        'จัดการอบรมการใช้งาน หรือพัฒนาประสิทธิภาพซอฟต์แวร์ รวมทั้งไม่รับรองความถูกต้อง'
        'หรือประสิทธิภาพการทำงานของซอฟต์แวร์ ตลอดจนไม่รับประกันความเสียหายต่าง ๆ '
        'อันเกิดจากการใช้ซอฟต์แวร์นี้ทั้งสิ้น'
        '\n\n———\n\n'
        'License Agreement\n\n'
        'This software is a work developed by Anna Ratrasarn, Phisarat Jittanan, '
        'and Surasi Khamsong from Yupparaj Wittayalai School under the provision '
        'of Hathairat Sriviroj under the project "Kaokeng", Learning application '
        'for minors with Down syndrome, which has been supported by the National '
        'Science and Technology Development Agency (NSTDA), in order to encourage '
        'pupils and students to learn and practice their skills in developing '
        'software. Therefore, the intellectual property of this software shall '
        'belong to the developer and the developer gives NSTDA a permission to '
        'distribute this software as an "as is" and non-modified software for a '
        'temporary and non-exclusive use without remuneration to anyone for his '
        'or her own purpose or academic purpose which are not commercial '
        'purposes. In this connection, NSTDA shall not be responsible to the '
        'user for taking care, maintaining, training, or developing the '
        'efficiency of this software. Moreover, NSTDA shall not be liable for any '
        'error, software efficiency and damages in connection with or arising '
        'out of the use of the software.',
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
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                body,
                style: kTextSm.copyWith(color: kTextSecondary, height: 1.6),
              ),
            ),
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
