import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

// Popup สรุปผลตอนจบเกม (ดาว 0-3 ดวง + คะแนน + บรรทัดรายละเอียด + ปุ่มปิด) พร้อม
// อนิเมชันเด้งเข้า + ดาวป๊อปทีละดวง (2026-07-13). ใช้ร่วมกันทุกเกม (จับคู่ภาพ/คำศัพท์/
// ครอบครัว/ชีวิตประจำวัน) — สไตล์เดียวกันเพื่อให้เด็กจำรูปแบบได้ (สำคัญกับกลุ่มเป้าหมาย)
class GameResultDialog extends StatefulWidget {
  const GameResultDialog({
    super.key,
    required this.stars,
    required this.score,
    required this.detail,
    required this.onClose,
  });

  final int stars;
  final int score;

  /// บรรทัดรายละเอียดใต้คะแนน เช่น "จับคู่ครบ 4 คู่" / "ตอบครบ 5 ข้อ"
  final String detail;
  final VoidCallback onClose;

  @override
  State<GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<GameResultDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // ค่าอนิเมชันช่วง [begin,end] ของ controller (0..1) หลังผ่าน curve
  double _seg(double begin, double end, Curve curve) {
    final t = ((_c.value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(t);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // สร้างทั้งกล่องใน builder (ไม่ใช้ child:) เพื่อให้ _StarsRow คำนวณ seg ใหม่ทุกเฟรม
    // — ไม่งั้นดาวจะค้างที่ scale 0 (ค่า animation ตอน build ครั้งเดียว) จึงไม่ขึ้น
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pop = _seg(0.0, 0.45, Curves.easeOutBack); // ทั้งกล่องเด้งเข้า
        return Opacity(
          opacity: pop.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.75 + 0.25 * pop,
            child: _buildCard(screenHeight),
          ),
        );
      },
    );
  }

  Widget _buildCard(double screenHeight) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: kSpace6,
        vertical: kSpace4,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            kSpace8,
            kSpace6,
            kSpace8,
            kSpace5,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kWarmWhite, kYellowLight],
              stops: [0.55, 1.0],
            ),
            borderRadius: kRadiusLg,
            boxShadow: const [kShadowLg],
            border: Border.all(color: kYellowPrimary, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: kYellowPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: kSpace2),
                    Text(
                      'เก่งมากเลย!',
                      style: kTextXL.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: kSpace2),
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: kBluePrimary,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: kSpace4),
                _StarsRow(stars: widget.stars, seg: _seg),
                const SizedBox(height: kSpace4),
                // คะแนนในป้ายกลม
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSpace5,
                    vertical: kSpace2,
                  ),
                  decoration: BoxDecoration(
                    color: kWarmWhite,
                    borderRadius: kRadiusFull,
                    boxShadow: const [kShadowSm],
                  ),
                  child: Text(
                    'คะแนน ${widget.score} เต็ม 10',
                    style: kTextLg.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: kSpace2),
                Text(
                  widget.detail,
                  style: kTextSm.copyWith(color: kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpace5),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onClose,
                    child: const Text('ปิด'),
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

// แถวดาว 3 ดวง — ป๊อปเข้าทีละดวง (staggered) + เด้ง (elasticOut); ดวงที่ได้มีแสงเรือง
class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars, required this.seg});

  final int stars;
  final double Function(double begin, double end, Curve curve) seg;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        // ดาวเริ่มโผล่หลังกล่องเด้งเสร็จ (0.4) ไล่ทีละ 0.18
        final begin = 0.4 + i * 0.18;
        final t = seg(begin, begin + 0.4, Curves.elasticOut);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpace1),
          child: Transform.scale(
            scale: t,
            child: Transform.rotate(
              angle: (1 - t) * math.pi * 0.3, // หมุนเล็กน้อยตอนโผล่
              child: Container(
                decoration:
                    filled
                        ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kYellowPrimary.withValues(alpha: 0.55),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        )
                        : null,
                child: Icon(
                  Icons.star_rounded,
                  size: 54,
                  color:
                      filled
                          ? kYellowPrimary
                          : kYellowPrimary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
