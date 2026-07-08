import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import 'pressable_child_card.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.background,
    required this.onTap,
    this.cardWidth,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  /// ความกว้างที่กำหนดจากหน้าจอ (แบ่งพื้นที่จริงเท่าๆกัน) — ถ้าไม่ส่งมา จะใช้ constraints
  /// ยืดหยุ่นแบบเดิม เดิมใช้ minWidth 140 ตายตัว ทำให้การ์ด 3 ใบรวมกันกว้างเกินจอแคบ
  /// (เช่น iPhone 12 Pro 390px) แล้วล้น 186px — การรับความกว้างจากหน้าจอแก้ที่ต้นเหตุ
  /// (spec 1.3)
  final double? cardWidth;

  @override
  Widget build(BuildContext context) {
    // ย่อไอคอน/ฟอนต์ลงเมื่อการ์ดแคบมาก (< 130px) กันเนื้อหาเบียดจนล้น
    final isNarrow = cardWidth != null && cardWidth! < 130;
    final iconSize = isNarrow ? 42.0 : 56.0;
    final labelStyle = (isNarrow ? kTextMd : kTextLg).copyWith(
      fontWeight: FontWeight.bold,
    );

    return PressableChildCard(
      onTap: onTap,
      playClickSound: true,
      child: Container(
        width: cardWidth,
        constraints:
            cardWidth == null
                ? const BoxConstraints(minWidth: 140, maxWidth: 340)
                : null,
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? kSpace2 : kSpace4,
          vertical: kSpace5,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: kRadiusLg,
          boxShadow: const [kShadowMd],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: kTextPrimary),
            const SizedBox(height: kSpace3),
            Text(
              label,
              style: labelStyle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: kSpace1),
            Text(
              description,
              style: kTextSm,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
