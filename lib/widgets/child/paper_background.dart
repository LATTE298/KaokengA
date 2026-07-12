import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// พื้นหลังเท็กซ์เจอร์กระดาษครีม (Cream Paper) สำหรับหน้าเกม/เมนูฝั่งเด็ก —
/// ใช้เป็นชั้นล่างสุดใน Stack ของแต่ละหน้า (`Positioned.fill(child: PaperBackground())`)
/// ตกไปสีครีม kWarmWhite ถ้าไฟล์หาย. ไม่ใช้กับฉากที่มีพื้นหลังเป็นภาพเอง
/// (Module A drag-drop, mode-select วิดีโอ)
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
