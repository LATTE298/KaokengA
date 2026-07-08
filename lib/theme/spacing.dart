import 'package:flutter/material.dart';

// 8px base grid
const double kSpace1 = 4.0;
const double kSpace2 = 8.0;
const double kSpace3 = 12.0;
const double kSpace4 = 16.0;
const double kSpace5 = 20.0;
const double kSpace6 = 24.0;
const double kSpace8 = 32.0;
const double kSpace10 = 40.0;
const double kSpace12 = 48.0;
const double kSpace16 = 64.0;

// ขนาดพื้นที่กดขั้นต่ำสำหรับองค์ประกอบที่กดได้ทุกชนิดในแอป (spec 1.3).
// 64dp สูงกว่ามาตรฐาน WCAG (44px) และ Material (48dp) พอสมควร เพื่อรองรับกล้ามเนื้อมือ/
// นิ้วที่มักมีความตึงตัวต่ำ (hypotonia) ในเด็กกลุ่มอาการดาวน์ซินโดรม ทำให้เล็งตำแหน่งกด
// ได้ไม่แม่นยำเท่าเด็กทั่วไป
const double kTouchTargetMin = 64.0;

// ระยะห่างขั้นต่ำที่แนะนำระหว่างปุ่ม/การ์ดที่กดได้อิสระจากกัน 2 ชิ้น (เช่น การ์ดเลือกโหมด,
// ตัวเลือกคำตอบ) เพื่อลดโอกาสกดโดนชิ้นข้างเคียงโดยไม่ตั้งใจตอนเล็งนิ้วไม่แม่นยำ
const double kInteractiveGapMin = kSpace6;

// หน่วงเวลากันกดซ้ำโดยไม่ตั้งใจหลังแตะแต่ละครั้ง (เช่น มือสั่นเล็กน้อยแล้วแตะติดสองครั้ง)
// ใช้เป็นค่าเริ่มต้นใน PressableChildCard — ตั้งเป็น Duration.zero ต่อจุดได้ถ้าต้องการให้
// แตะซ้ำเร็วๆทำงานได้ทันที (เช่น การ์ดคำศัพท์ที่กดฟังเสียงซ้ำได้เรื่อยๆ)
const Duration kTapCooldown = Duration(milliseconds: 350);

// Border radius
final BorderRadius kRadiusSm = BorderRadius.circular(8);
final BorderRadius kRadiusMd = BorderRadius.circular(16);
final BorderRadius kRadiusLg = BorderRadius.circular(24);
final BorderRadius kRadiusXl = BorderRadius.circular(32);
final BorderRadius kRadiusFull = BorderRadius.circular(999);

// Shadows
const BoxShadow kShadowSm = BoxShadow(
  color: Color(0x20B97C00),
  blurRadius: 8,
  offset: Offset(0, 2),
);

const BoxShadow kShadowMd = BoxShadow(
  color: Color(0x30B97C00),
  blurRadius: 16,
  offset: Offset(0, 4),
);

const BoxShadow kShadowLg = BoxShadow(
  color: Color(0x40B97C00),
  blurRadius: 24,
  offset: Offset(0, 8),
);

// Animation
const Duration kDurationFast = Duration(milliseconds: 150);
const Duration kDurationNormal = Duration(milliseconds: 300);
const Duration kDurationSlow = Duration(milliseconds: 500);

const Curve kCurveDefault = Curves.easeInOut;
const Curve kCurveSpring = Curves.elasticOut;
const Curve kCurvePop = Curves.easeOutBack;
