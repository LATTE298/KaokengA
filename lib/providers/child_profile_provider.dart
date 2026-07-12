import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'streak_provider.dart' show kAppPrefsBoxName;

// โปรไฟล์เด็กฝั่งเด็ก (ชื่อที่ผู้ปกครองตั้ง + ดาวสะสมจากการเล่น) เก็บใน Hive `app_prefs`
// กล่องเดียวกับสตรีค — ทำงานออฟไลน์/ไม่ต้องล็อกอิน. ทุกจุดกัน "box ยังไม่เปิด" ไว้
// (เช่นใน widget test ที่ไม่ได้เปิด Hive) → คืนค่า default / ไม่บันทึก แทนที่จะ throw
// (ปรัชญาเดียวกับทั้งแอป: ไม่ crash เพราะเรื่องข้อมูลสำรอง)

const String _kChildNameKey = 'child_name';
const String _kTotalStarsKey = 'total_stars';

/// ชื่อเริ่มต้นเมื่อผู้ปกครองยังไม่ได้ตั้งชื่อเด็ก
const String kDefaultChildName = 'หนูน้อย';

Box<dynamic>? _prefsBox() =>
    Hive.isBoxOpen(kAppPrefsBoxName)
        ? Hive.box<dynamic>(kAppPrefsBoxName)
        : null;

/// ชื่อเด็กที่โชว์บนหน้าเลือกเล่น — ว่าง/ยังไม่ตั้ง → [kDefaultChildName]. แยกเป็น
/// ฟังก์ชัน pure เพื่อ test ตรงๆ (ไม่ผูก Hive)
String resolveChildName(String? saved) {
  final trimmed = saved?.trim();
  return (trimmed == null || trimmed.isEmpty) ? kDefaultChildName : trimmed;
}

/// ชื่อเด็ก (ผู้ปกครองตั้งจากหน้า dashboard, เก็บ Hive). โชว์บนชิปโปรไฟล์หน้าเลือกเล่น
class ChildNameNotifier extends Notifier<String> {
  @override
  String build() =>
      resolveChildName(_prefsBox()?.get(_kChildNameKey) as String?);

  /// ตั้งชื่อเด็ก (ตัดช่องว่างหัวท้าย). ว่าง = กลับไปใช้ค่าเริ่มต้น
  void setName(String name) {
    final trimmed = name.trim();
    final box = _prefsBox();
    if (trimmed.isEmpty) {
      box?.delete(_kChildNameKey);
    } else {
      box?.put(_kChildNameKey, trimmed);
    }
    state = resolveChildName(trimmed);
  }
}

final childNameProvider = NotifierProvider<ChildNameNotifier, String>(
  ChildNameNotifier.new,
);

/// ดาวสะสมรวมทุกเกม — บวกทีละ 0-3 ดวงเมื่อจบเกม เก็บสะสมข้ามวัน/ออฟไลน์ได้
class TotalStarsNotifier extends Notifier<int> {
  @override
  int build() => (_prefsBox()?.get(_kTotalStarsKey) as int?) ?? 0;

  /// บวกดาวที่เพิ่งได้ (0-3) แล้วเก็บลง Hive. box ยังไม่เปิด = อัปเดตในหน่วยความจำ
  /// อย่างเดียว ไม่ throw
  void award(int stars) {
    if (stars <= 0) return;
    final next = state + stars;
    _prefsBox()?.put(_kTotalStarsKey, next);
    state = next;
  }
}

final totalStarsProvider = NotifierProvider<TotalStarsNotifier, int>(
  TotalStarsNotifier.new,
);
