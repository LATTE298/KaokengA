import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../features/streak/streak_tracker.dart';

/// box เก็บค่าตั้งต้นเล็กๆ ของแอปฝั่งเด็ก (เปิดใน main.dart ก่อน runApp)
const String kAppPrefsBoxName = 'app_prefs';

const String _kStreakKey = 'streak_days';
const String _kLastPlayedKey = 'streak_last_played_ms';
// สตรีคที่ดีที่สุดเท่าที่เคยทำได้ — ให้ระบบเหรียญ (rewards_provider) อ่านไปปลดเหรียญสตรีค
// โดยไม่ล็อกกลับเมื่อสตรีคขาด. เขียนที่นี่เพราะเป็นจุดเดียวที่รู้ค่าสตรีคใหม่ทุกครั้ง
const String _kBestStreakKey = 'best_streak';

/// สตรีคเข้าเล่นต่อเนื่อง (วัน) — อ่านครั้งแรกจะ "บันทึกการเข้าเล่นวันนี้" ให้เลย
/// (หน้าเลือกเล่นคือประตูเข้าเกมของเด็ก) แล้วเก็บกลับลง Hive ใช้ข้ามวัน/ออฟไลน์ได้
final streakProvider = Provider<int>((ref) {
  final box = Hive.box<dynamic>(kAppPrefsBoxName);
  final lastMs = box.get(_kLastPlayedKey) as int?;
  final next = computeNextStreak(
    current: (box.get(_kStreakKey) as int?) ?? 0,
    lastPlayed:
        lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs),
    now: DateTime.now(),
  );
  box.put(_kStreakKey, next);
  box.put(_kLastPlayedKey, DateTime.now().millisecondsSinceEpoch);
  // อัปเดต "สตรีคดีที่สุด" ถ้าทุบสถิติ (ใช้กับเหรียญสตรีค ไม่ให้หายเมื่อขาดวัน)
  final best = (box.get(_kBestStreakKey) as int?) ?? 0;
  if (next > best) box.put(_kBestStreakKey, next);
  return next;
});
