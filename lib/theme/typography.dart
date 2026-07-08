import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

// Thai-first font: Sarabun (loaded via google_fonts).
// Usage: `kTextLg` etc. are base styles; components may copyWith(color:) as needed.
//
// ขนาดตัวอักษรปรับเพิ่มขึ้นจากเดิมทุกระดับ (spec 1.3) เพื่อให้อ่านง่ายขึ้นสำหรับเด็กที่มีภาวะ
// สายตา/การประมวลผลภาพต่างจากเด็กทั่วไป (พบร่วมกับดาวน์ซินโดรมได้บ่อย เช่น สายตาสั้น, ตาเข)
// คงน้ำหนักตัวอักษรไม่บางเกินไป (≥w500 สำหรับเนื้อหา, ≥w600 สำหรับ label/ปุ่ม) เพื่อความ
// คมชัดของรูปทรงตัวอักษร
//
// หมายเหตุ: ตั้งใจไม่เพิ่ม letterSpacing แบบที่นิยมทำกับฟอนต์ละติน เพราะภาษาไทยไม่มีช่องว่าง
// ระหว่างคำตามปกติ และสระ/วรรณยุกต์วางซ้อนบน-ล่างพยัญชนะ การถ่างตัวอักษรมากเกินไปอาจทำให้
// สระลอยห่างจากตัวพยัญชนะที่กำกับ แล้วอ่านยากขึ้นกว่าเดิม จึงใช้ "ขนาด" และ "น้ำหนัก" เป็น
// ตัวช่วยความชัดเจนหลักแทน

TextStyle _sarabun({
  required double fontSize,
  required FontWeight fontWeight,
  Color color = kTextPrimary,
  double height = 1.4,
}) {
  return GoogleFonts.sarabun(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

TextStyle get kTextXL =>
    _sarabun(fontSize: 34, fontWeight: FontWeight.w700, height: 1.3);

TextStyle get kTextLg =>
    _sarabun(fontSize: 26, fontWeight: FontWeight.w600, height: 1.4);

TextStyle get kTextMd =>
    _sarabun(fontSize: 20, fontWeight: FontWeight.w500, height: 1.5);

TextStyle get kTextBase =>
    _sarabun(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6);

TextStyle get kTextSm => _sarabun(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: kTextSecondary,
  height: 1.5,
);

TextStyle get kTextXs => _sarabun(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: kTextHint,
  height: 1.4,
);

// Larger labels for child-facing UI.
TextStyle get kChildLabel =>
    _sarabun(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4);

// ป้ายข้อความบนปุ่มหลักขนาดใหญ่ (เช่น "ปิด", "เล่นอีกครั้ง", "ส่งงาน") — ตัวหนาเป็นพิเศษ
// เพื่อให้เด่นเป็นจุดสนใจหลักของหน้าจอผลการเล่น ใช้เป็นค่าเริ่มต้นผ่าน FilledButtonTheme
// ใน app_theme.dart แล้ว ปกติไม่ต้องเรียกตรงๆ
TextStyle get kButtonLabel =>
    _sarabun(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
