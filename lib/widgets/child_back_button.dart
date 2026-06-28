import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/haptic_service.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

// ปุ่มย้อนกลับสำหรับฝั่งเด็ก (spec 1.3).
// เดิม: hitbox 60×60dp พื้นหลังโปร่งใสล้วน มีแค่ไอคอนลอยอยู่ — ทำให้กลืนไปกับพื้นหลังที่มี
// ลวดลาย/สีเข้มของแต่ละด่าน (เช่น พื้นหลังเกม Module A) ได้ง่าย เด็กอาจไม่รู้ว่ากดได้
// ใหม่: ขยับขึ้นมาใช้มาตรฐานเดียวกับปุ่มอื่นทั้งแอป (kTouchTargetMin = 64dp) และเพิ่มพื้นวงกลม
// สีอ่อนพร้อมเงานุ่มๆ ด้านหลังไอคอน ให้เห็นชัดเจนว่าเป็นปุ่มกดได้ ไม่ใช่ไอคอนตกแต่งเฉยๆ
// ไม่ว่าพื้นหลังหน้านั้นจะเป็นสีอะไรก็ตาม
class ChildBackButton extends StatelessWidget {
  const ChildBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kTouchTargetMin,
      height: kTouchTargetMin,
      // เงาวาดอยู่ที่ Container ชั้นนอกซึ่งไม่ถูก clip จึงลอยออกมานอกขอบวงกลมได้ตามปกติ
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [kShadowSm],
      ),
      child: Material(
        color: kWarmWhite.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          iconSize: 36,
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_rounded, color: kTextPrimary),
          tooltip: 'ย้อนกลับ',
          onPressed: () {
            if (context.canPop()) {
              HapticService.tapLight();
              context.pop();
            }
          },
        ),
      ),
    );
  }
}