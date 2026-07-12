import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// พื้นหลังเท็กซ์เจอร์กระดาษครีม (Cream Paper) สำหรับหน้าเกม/เมนูฝั่งเด็ก —
/// ใช้เป็นชั้นล่างสุดใน Stack ของแต่ละหน้า (`Positioned.fill(child: PaperBackground())`)
/// ตกไปสีครีม kWarmWhite ถ้าไฟล์หาย. ไม่ใช้กับฉากที่มีพื้นหลังเป็นภาพเอง
/// (Module A drag-drop, mode-select วิดีโอ)
///
/// เต็มขอบจอได้เพราะโซนเด็กเป็นแนวนอน + immersive (ซ่อนแถบระบบ ไม่มี inset ให้ SafeArea
/// หด — ตั้งใน OrientationLock) → Stack กินเต็มจอ พื้นหลังจึงเต็มขอบทุกด้าน
class PaperBackground extends StatelessWidget {
  const PaperBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/paper_bg.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: kWarmWhite),
    );
  }
}
