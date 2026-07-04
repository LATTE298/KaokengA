import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

// Popup สรุปผลตอนจบเกม (ดาว 0-3 ดวง + คะแนน + บรรทัดรายละเอียด + ปุ่มปิด)
// ใช้ร่วมกันระหว่าง Module B (จับคู่ภาพ) และ Module C (เกมตอบคำถาม) — สไตล์/ขนาด
// ต้องเหมือนกันทุกเกมเพื่อให้เด็กจำรูปแบบได้ (ความคงเส้นคงวาสำคัญกับกลุ่มเป้าหมาย)
class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.stars,
    required this.score,
    required this.detail,
    required this.onClose,
  });

  final int stars;
  final int score;

  /// บรรทัดรายละเอียดใต้คะแนน เช่น "เปิดการ์ดทั้งหมด 32 ครั้ง" / "ตอบครบ 5 ข้อ"
  final String detail;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: kSpace6,
        vertical: kSpace4,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpace8,
            vertical: kSpace5,
          ),
          decoration: BoxDecoration(
            color: kWarmWhite,
            borderRadius: kRadiusLg,
            boxShadow: const [kShadowLg],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('เก่งมากเลย!', style: kTextXL),
                const SizedBox(height: kSpace4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final filled = i < stars;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kSpace1),
                      child: Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: filled
                            ? kYellowPrimary
                            : kYellowPrimary.withValues(alpha: 0.2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: kSpace4),
                Text('คะแนน $score เต็ม 10', style: kTextLg),
                const SizedBox(height: kSpace2),
                Text(detail, style: kTextSm.copyWith(color: kTextSecondary)),
                const SizedBox(height: kSpace5),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onClose,
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
