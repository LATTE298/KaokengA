import 'package:flutter/material.dart';

// Primary — Yellow
const kYellowPrimary = Color(0xFFFFC53D);
const kYellowLight = Color(0xFFFFF3C0);
const kYellowDark = Color(0xFFB97C00);
const kYellowAccent = Color(0xFFFFE082);

// Primary — Blue
const kBluePrimary = Color(0xFF4A90D9);
const kBlueLight = Color(0xFFD6EAFF);
const kBlueDark = Color(0xFF1A4F7A);
const kBlueDeep = Color(0xFF0D3359);

// Warm neutrals
const kWarmWhite = Color(0xFFFDF8EE);
const kWarmSurface = Color(0xFFF5EDD8);
const kWarmBorder = Color(0xFFE8D5A3);
const kWarmMuted = Color(0xFFC4A96B);
const kTextPrimary = Color(0xFF3D2C00);
const kTextSecondary = Color(0xFF7A6235);
const kTextHint = Color(0xFFB8A06A);

// Semantic
// kError ปรับจากแดงสดมาตรฐาน (#E53935) เป็นโทนแดงอมส้ม (terracotta) — แดงจัดจ้านมักถูกตี
// ความหมายเป็น "ผิด/อันตราย" รุนแรงเกินไปและกระตุ้นความเครียดได้ง่ายในเด็กที่ sensory
// sensitivity สูง ยังอ่านแยกจาก kSuccess ได้ชัดเจน แค่ลดความ "ตกใจ" ลง (spec 1.3)
const kSuccess = Color(0xFF4CAF50);
const kError = Color(0xFFD9603E);
const kOverlay = Color(0x663D2C00);

// พื้นหลังโทนอ่อนคู่กับ kSuccess / kError — ใช้เวลาต้องบอกถูก/ผิดแบบนุ่มนวล (เช่น พื้นการ์ด
// คำตอบ) โดยไม่ต้องพึ่งสีสดจัดเพียงอย่างเดียว ช่วยคนที่แยกสีได้ไม่ชัด (มักพบร่วมกับสายตา
// ที่แตกต่างในเด็กดาวน์ซินโดรม) ให้ยังพอแยกสถานะได้จากความเข้ม ไม่ใช่แค่จากเฉดสี
const kSuccessLight = Color(0xFFE3F3E1);
const kErrorLight = Color(0xFFFBE6E0);

// ทาบบนการ์ด/ปุ่มตอนถูกกดค้าง (pressed state) — ใช้คู่กับ AnimatedOpacity ใน
// PressableChildCard ให้เห็นการเปลี่ยนแปลงชัดเจนกว่าการสเกลขนาดอย่างเดียว ช่วยตอกย้ำว่า
// "นิ้วที่แตะ" กับ "สิ่งที่เกิดขึ้นบนจอ" เป็นเหตุและผลของกัน
const kPressOverlay = Color(0x143D2C00);

// โทนปุ่ม/การ์ดที่ถูกปิดใช้งานชั่วคราว (เช่น สถานการณ์ที่ผู้ปกครองปิดไว้ใน Module A)
const kDisabledSurface = Color(0xFFEDE6D2);
const kDisabledText = Color(0xFFB3A684);
