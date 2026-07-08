import 'package:flutter/widgets.dart';

// Helper สำหรับทำ UI ให้ยืดหยุ่นตามขนาดจอ (spec 1.3) — สร้างขึ้นเพื่อแก้ปัญหาที่เกิดซ้ำ:
// การ์ด/องค์ประกอบที่ใช้ค่า pixel ตายตัวแล้วล้นจอเมื่อเปลี่ยนเครื่อง (เช่น การ์ดที่พอดีบน
// iPhone 12 Pro แต่ล้นบน Samsung S8+ ที่จอเตี้ยกว่า)
//
// แนวคิด: แทนที่จะไล่แก้ตัวเลขทีละเครื่อง ให้ทุกหน้าจอใหม่ใช้ helper เหล่านี้คำนวณขนาดจาก
// พื้นที่จริง เพื่อไม่ให้ปัญหาเดิมกลับมาอีกในอนาคต
//
// วิธีใช้ที่แนะนำ: ครอบเนื้อหาด้วย LayoutBuilder แล้วคำนวณขนาดจาก constraints ที่ได้จริง
// (ดูตัวอย่างใน module_a_screen.dart และ memory_game_screen.dart) helper ด้านล่างเป็น
// ตัวช่วยเสริมสำหรับเคสที่อยากตัดสินใจจาก "ประเภทจอ" แทนการวัด pixel ตรงๆ

// Breakpoints อิงความกว้างที่สั้นที่สุดของจอ (shortestSide) เพราะแอปล็อกแนวนอน การใช้
// shortestSide จึงสะท้อน "ขนาดเครื่อง" ได้ตรงกว่า width/height ที่สลับกันตามการหมุนจอ
class Breakpoints {
  const Breakpoints._();

  /// โทรศัพท์ทั่วไป (shortestSide < 360) เช่น Samsung S8+ ในแนวนอน
  static const double phone = 360;

  /// โทรศัพท์ใหญ่/แท็บเล็ตเล็ก (360–600)
  static const double largePhone = 600;

  /// แท็บเล็ต (> 600) — แพลตฟอร์มหลักของแอป
  static const double tablet = 600;
}

enum DeviceSize { phone, largePhone, tablet }

extension ResponsiveContext on BuildContext {
  Size get _screenSize => MediaQuery.of(this).size;

  double get shortestSide => _screenSize.shortestSide;
  double get longestSide => _screenSize.longestSide;

  DeviceSize get deviceSize {
    final s = shortestSide;
    if (s < Breakpoints.phone) return DeviceSize.phone;
    if (s < Breakpoints.largePhone) return DeviceSize.largePhone;
    return DeviceSize.tablet;
  }

  bool get isPhone => deviceSize == DeviceSize.phone;
  bool get isTablet => deviceSize == DeviceSize.tablet;

  /// เลือกค่าตามประเภทจอ — เขียนสั้นกว่า if/else เช่น
  /// `final cols = context.responsive(phone: 3, tablet: 4);`
  T responsive<T>({required T phone, T? largePhone, required T tablet}) {
    switch (deviceSize) {
      case DeviceSize.phone:
        return phone;
      case DeviceSize.largePhone:
        return largePhone ?? tablet;
      case DeviceSize.tablet:
        return tablet;
    }
  }
}
