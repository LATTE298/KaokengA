import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Time-Limiter (spec 1.4 — เด็กใช้งานต่อเนื่อง 15 นาที → เตือนพักสายตา).
//
// เก็บเวลาเล่นสะสมต่อเนื่องของผู้ใช้ ออกแบบเป็น state กลางของแอปผ่าน Riverpod (ไม่ใช่ state
// ในวิดเจ็ตเดี่ยวๆ) เพื่อให้ข้อมูลอยู่รอดข้ามการเปลี่ยนเส้นทาง (navigate) และข้ามการ rebuild
// ของ MaterialApp — เป็นเหตุผลเดียวกับที่ session recorder/auth ใช้ provider ระดับแอป
//
// แนวคิดสำคัญ: pause/resume ต้องเก็บเวลาสะสมไว้ ห้ามรีเซ็ตเป็นศูนย์ มิฉะนั้นการที่เด็กวาง
// แท็บเล็ตทิ้งไว้ชั่วครู่แล้วกลับมาเปิดใหม่ จะกลายเป็น "นับ 15 นาทีใหม่ทุกครั้ง" ซึ่งทำให้
// การเตือนพักไม่ทำงานตามวัตถุประสงค์เลย
//
// ตั้งใจไม่ persist ข้ามการเปิด-ปิดแอป (ปิดแอป = พักโดยปริยาย) ตามแผนเฟส 1 — ถ้าจะให้
// เคร่งกว่านี้ (ปิดแอปหลบไปเล่นใหม่ก็ยังเตือนอยู่) ต้องใช้ SharedPreferences ในเฟสถัดไป

@immutable
class UsageTimerState {
  const UsageTimerState({
    required this.elapsed,
    required this.running,
    required this.breakDue,
  });

  /// เวลาเล่นต่อเนื่องสะสมตั้งแต่ครั้งล่าสุดที่ reset
  final Duration elapsed;

  /// ตอนนี้กำลังนับเวลาอยู่หรือไม่ (true เมื่ออยู่ในแอปและไม่ถึงขีดจำกัด)
  final bool running;

  /// ครบขีดจำกัดแล้ว ควรแสดง popup เตือนพัก
  /// ตั้งใจเป็นแฟล็กแยกจาก (elapsed >= limit) เพื่อให้ UI ทราบเฉพาะ "ขอบเข้ามาใหม่"
  /// (rising edge) ไม่ใช่ "อยู่ค้างที่ขอบ" — listener จึงโชว์ popup ครั้งเดียวต่อรอบ
  final bool breakDue;

  factory UsageTimerState.initial() => const UsageTimerState(
    elapsed: Duration.zero,
    running: false,
    breakDue: false,
  );

  UsageTimerState copyWith({
    Duration? elapsed,
    bool? running,
    bool? breakDue,
  }) {
    return UsageTimerState(
      elapsed: elapsed ?? this.elapsed,
      running: running ?? this.running,
      breakDue: breakDue ?? this.breakDue,
    );
  }
}

class UsageTimerNotifier extends StateNotifier<UsageTimerState> {
  UsageTimerNotifier({
    required this.limit,
    this.tickInterval = const Duration(seconds: 5),
  }) : super(UsageTimerState.initial());

  /// ขีดจำกัดเวลาใช้งานต่อเนื่อง (ค่ามาตรฐาน 15 นาทีตามแผนเฟส 1.4)
  final Duration limit;

  /// ความถี่ในการเช็คขีดจำกัด — ตั้งเป็น 5 วินาทีเพราะ UI ไม่ได้แสดง countdown แบบวินาที
  /// per วินาที ดังนั้นไม่จำเป็นต้อง tick ถี่ ลด rebuild ของ provider listener
  /// (เวลา elapsed คำนวณจาก DateTime จริง ไม่ใช่จากจำนวน tick — ความแม่นยำไม่กระทบ)
  final Duration tickInterval;

  Timer? _timer;

  /// เวลาที่เริ่ม resume ครั้งล่าสุด — ใช้คำนวณ delta เวลาสะสมตอน pause/tick
  /// เก็บแยกจาก state.elapsed เพื่อให้ tick คำนวณแบบ "เวลาจริง" จาก DateTime ได้
  /// ไม่ขึ้นกับความถี่ของ Timer (ถ้าระบบ busy แล้ว tick มาช้า ก็ยังนับถูก)
  DateTime? _resumeAt;

  void resume() {
    // กันการ resume ซ้ำ (เช่น lifecycle เรียก resume() สองครั้งติดกันจาก
    // .inactive → .resumed) และห้าม resume หลังครบขีดจำกัดแล้ว (ต้อง ack ก่อน)
    if (state.running || state.breakDue) return;

    _resumeAt = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) => _tick());
    state = state.copyWith(running: true);
  }

  void pause() {
    if (!state.running) return;

    // หยุดและสะสมเวลาที่ผ่านมาตั้งแต่ resume ครั้งล่าสุดไว้ใน elapsed
    final delta = _resumeAt != null
        ? DateTime.now().difference(_resumeAt!)
        : Duration.zero;
    _resumeAt = null;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      running: false,
      elapsed: state.elapsed + delta,
    );
  }

  /// เคลียร์เวลาสะสมและแฟล็ก breakDue กลับเป็นศูนย์ — เรียกหลังผู้ใช้กดยืนยันว่าพักแล้ว
  /// ไม่ resume เองหลัง reset เพราะ gate widget จะเป็นคน resume ใหม่ตามสถานะแอป
  /// (เช่น ถ้าแอปอยู่ background ระหว่างที่ ack จะยัง resume ไม่ได้จนกว่าจะกลับมา)
  void reset() {
    _timer?.cancel();
    _timer = null;
    _resumeAt = null;
    state = UsageTimerState.initial();
  }

  void _tick() {
    if (_resumeAt == null) return;
    final delta = DateTime.now().difference(_resumeAt!);
    final currentElapsed = state.elapsed + delta;

    if (currentElapsed >= limit) {
      // ครบขีดจำกัด — snap เป็น limit พอดี (ไม่ใช่ค่าที่เกิน) ปิด Timer และจุดแฟล็ก
      _timer?.cancel();
      _timer = null;
      _resumeAt = null;
      state = state.copyWith(
        elapsed: limit,
        running: false,
        breakDue: true,
      );
    } else {
      // ยังไม่ครบ — อัปเดต elapsed (ไม่ commit เข้า state ก็ได้เพราะไม่มี UI แสดงผล
      // แต่ commit ไว้เผื่ออนาคตอยากเพิ่ม progress bar ในเฟสถัดไป)
      state = state.copyWith(elapsed: currentElapsed);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider ของขีดจำกัด แยกออกมาจาก notifier เพื่อให้ override ได้ง่ายในเทสต์/พ่อแม่ตั้งค่า
// ในเฟสถัดไป (เช่น ลดเหลือ 10 นาทีตามอายุเด็ก) โดยไม่ต้องแก้โค้ดของ notifier
final usageTimerLimitProvider = Provider<Duration>(
  (ref) => const Duration(minutes: 15),
);

final usageTimerProvider =
    StateNotifierProvider<UsageTimerNotifier, UsageTimerState>((ref) {
  return UsageTimerNotifier(limit: ref.watch(usageTimerLimitProvider));
});