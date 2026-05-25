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
  });

  final String label;
  final String description;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ปรับโครงสร้างให้ยืดหยุ่น ยึดตามความกว้างหน้าจอ แต่ไม่ล็อกความสูงตายตัวจนของล้น
    return PressableChildCard(
      onTap: onTap,
      playClickSound: true,
      child: Container(
        // บังคับความกว้างขั้นต่ำ-ขั้นสูงให้พอดีจอมือถือ ส่วนความสูงปล่อยให้ยืดหยุ่นตามเนื้อหาข้างใน
        constraints: const BoxConstraints(
          minWidth: 140,
          maxWidth: 340,
        ),
        padding: const EdgeInsets.symmetric(horizontal: kSpace4, vertical: kSpace5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: kRadiusLg,
          boxShadow: const [kShadowMd],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ให้ Column หดขนาดเท่าเนื้อหาจริง ไม่ยืดจนล้น
          children: [
            // ปรับขนาดไอคอนลงมานิดนึง จาก 80 เหลือ 56 เพื่อความสบายตาและไม่เบียดตัวหนังสือ
            Icon(icon, size: 56, color: kTextPrimary),
            const SizedBox(height: kSpace3),
            Text(
              label, 
              style: kTextLg.copyWith(fontWeight: FontWeight.bold), 
              textAlign: TextAlign.center
            ),
            const SizedBox(height: kSpace1),
            Text(
              description,
              style: kTextSm,
              textAlign: TextAlign.center,
              maxLines: 2, // เผื่อข้อความยาวให้ขึ้นได้ 2 บรรทัด
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}