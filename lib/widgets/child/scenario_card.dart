import 'package:flutter/material.dart';

import '../../models/scenario_config.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({super.key, required this.summary, required this.onTap});

  final ScenarioSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      child: Container(
        width: 220,
        // เดิม: height: 280 ตายตัว แบ่งเป็น Expanded(flex:3)/Expanded(flex:2) แบบ pixel
        // คงที่ — พอ typography.dart ขยายขนาดตัวอักษร (spec 1.3) ข้อความ 2 บรรทัด + ป้าย
        // หมวดหมู่ที่เคยพอดี เลยล้นออกมาไม่กี่ pixel
        // ใหม่: ไม่ล็อกความสูงรวมอีกต่อไป ส่วนรูปคงสัดส่วนเดิมด้วย SizedBox สูงตายตัว
        // (168 = 280*3/5 เท่าของเดิมเป๊ะ) ส่วนข้อความให้ Column ขยายตามเนื้อหาจริง
        // (mainAxisSize.min) แทนการถูกบี้ใน Expanded คงที่ — แก้ปัญหานี้ทั้งคลาส ไม่ใช่แค่
        // ขยับเลขให้พอดีรอบนี้ ต่อให้ปรับฟอนต์อีกในอนาคตก็จะไม่ล้นซ้ำ
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
              height: 168,
              child: Container(
                color: kYellowLight,
                child: Image.asset(
                  summary.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_rounded,
                        size: 72,
                        color: kYellowDark,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kSpace4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.titleTh,
                    style: kChildLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: kSpace2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kSpace3,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kBlueLight,
                      borderRadius: kRadiusFull,
                    ),
                    child: Text(
                      summary.category,
                      style: kTextXs.copyWith(color: kBlueDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}