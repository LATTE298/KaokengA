import 'package:flutter/material.dart';

import '../../models/scenario_config.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

// การ์ดเลือกสถานการณ์ใน Module A (spec 1.3).
//
// เดิมใช้ค่าตายตัว (width 220, image height 168) → พอเปลี่ยนเครื่องที่จอเตี้ยกว่า (เช่น
// Samsung S8+ สูง 360 เทียบกับ iPhone 12 Pro) การ์ดล้นจอ ต้องมานั่งไล่ขยับตัวเลขทีละเครื่อง
// ไม่มีวันจบ
//
// ใหม่: การ์ดรับ "ความสูงที่ใช้ได้จริง" (cardHeight) มาจาก ModuleAScreen ที่วัดด้วย
// LayoutBuilder แล้วคำนวณทุกอย่างเป็นสัดส่วนของความสูงนั้น (รูป ~62%, ข้อความ ~38%)
// พร้อมย่อขนาดฟอนต์ให้พอดีเมื่อจอเตี้ยมาก → ไม่มี overflow ไม่ว่าจอขนาดไหน โดยไม่ต้องแก้
// โค้ดเพิ่มเมื่อเจอเครื่องใหม่
class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.summary,
    required this.onTap,
    required this.cardHeight,
  });

  final ScenarioSummary summary;
  final VoidCallback onTap;

  /// ความสูงที่ใช้ได้จริงของการ์ด — ส่งมาจาก ModuleAScreen (วัดจากพื้นที่จริงของจอ)
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    // สัดส่วนรูป:ข้อความ = 62:38 ของความสูงการ์ด
    final imageHeight = cardHeight * 0.62;
    final textAreaHeight = cardHeight * 0.38;

    // ความกว้างอิงจากความสูง (อัตราส่วน ~0.82) เพื่อให้การ์ดได้สัดส่วนสวยงามคงที่ ไม่ว่าจอ
    // จะเตี้ยหรือสูง — clamp กันไม่ให้แคบ/กว้างเกินไปในเคสสุดขั้ว
    final cardWidth = (cardHeight * 0.82).clamp(150.0, 280.0);

    // ย่อขนาดฟอนต์หัวข้อลงตามส่วนเมื่อจอเตี้ยมาก (ถ้าพื้นที่ข้อความ < 110px จะเริ่มย่อ)
    // ป้องกันข้อความ 2 บรรทัด + ป้ายหมวดหมู่ ดันกันจนล้นในจอเล็กสุด
    final titleStyle = textAreaHeight < 110
        ? kChildLabel.copyWith(fontSize: 18, height: 1.2)
        : kChildLabel;

    return PressableChildCard(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: kWarmSurface,
          borderRadius: kRadiusMd,
          border: Border.all(color: kWarmBorder, width: 1.5),
          boxShadow: const [kShadowSm],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: imageHeight,
              child: Container(
                color: kYellowLight,
                child: Image.asset(
                  summary.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_rounded,
                        size: imageHeight * 0.4,
                        color: kYellowDark,
                      ),
                    );
                  },
                ),
              ),
            ),
            // ส่วนข้อความใช้ Expanded + จัดกึ่งกลางแนวตั้ง ให้เนื้อหาอยู่กลางพื้นที่ที่เหลือ
            // เสมอ ไม่ล้นแม้พื้นที่จะแคบ (ตัวหัวข้อ ellipsis ถ้ายาวเกิน 2 บรรทัด)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kSpace3,
                  vertical: kSpace2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        summary.titleTh,
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: kSpace1),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSpace3,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kBlueLight,
                        borderRadius: kRadiusFull,
                      ),
                      child: Text(
                        summary.category,
                        style: kTextXs.copyWith(color: kBlueDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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