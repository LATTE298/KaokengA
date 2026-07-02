import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Time-Limiter (spec 1.4 — เด็กใช้งานต่อเนื่อง 15 นาที → เตือนพักสายตา).
//
// เก็บเวลาเล่นสะสมต่อเนื่องของผู้ใช้ ออกแบบเป็น state กลางของแอปผ่าน Riverpod เพื่อให้ข้อมูล
// อยู่รอดข้ามการเปลี่ยนเส้นทาง (navigate) และข้ามการ rebuild ของ MaterialApp
//
// หัวใจของการนับเวลา: คำนวณจาก DateTime นาฬิกาจริงเสมอ (ไม่ใช่นับจำนวนครั้งที่ Timer ยิง)
// ทำให้ทนต่อการ pause/resume ถี่ๆ ได้ — โดยเฉพาะบน Chrome web ที่ยิง lifecycle event
// (focus/blur) บ่อยมาก ทุก delta เวลาจริงจะถูกเก็บสะสมครบผ่าน _commitElapsed() ที่เรียกทั้ง
// ตอน tick และตอน pause ไม่มีทางหาย
//
// pause/resume เก็บเวลาสะสมไว้เสมอ ห้ามรีเซ็ตเป็นศูนย์ มิฉะนั้นการที่เด็กวางแท็บเล็ตทิ้งไว้
// ชั่วครู่แล้วกลับมา จะกลายเป็น "นับ 15 นาทีใหม่ทุกครั้ง" ซึ่งทำให้การเตือนพักไม่ทำงานตาม
// วัตถุประสงค์ ตั้งใจไม่ persist ข้ามการเปิด-ปิดแอป (ปิดแอป = พักโดยปริยาย) ตามแผนเฟส 1

@immutable
class UsageTimerState {
  const UsageTimerState({
    required this.elapsed,
    required this.running,
    required this.breakDue,
  });

  /// เวลาเล่นต่อเนื่องสะสมตั้งแต่ครั้งล่าสุดที่ reset
  final Duration elapsed;

  /// ตอนนี้กำลังนับเวลาอยู่หรือไม่
  final bool running;

  /// ครบขีดจำกัดแล้ว ควรแสดง popup เตือนพัก — เป็นแฟล็กแยกเพื่อให้ UI จับ rising edge
  /// (false→true) แล้วโชว์ popup ครั้งเดียวต่อรอบ
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

  /// ความถี่ในการเช็คขีดจำกัด — 5 วินาทีเพียงพอเพราะ UI ไม่ได้แสดง countdown แบบวินาที
  /// (เวลา elapsed คำนวณจาก DateTime จริง ไม่ใช่จากจำนวน tick ความแม่นยำจึงไม่กระทบ)
  final Duration tickInterval;

  Timer? _timer;

  /// เวลาที่เริ่ม resume ครั้งล่าสุด — ใช้คำนวณ delta เวลาจริงตอน tick/pause
  DateTime? _resumeAt;

  void resume() {
    // กัน resume ซ้ำ และห้าม resume หลังครบขีดจำกัด (ต้อง ack ก่อน)
    if (state.running || state.breakDue) return;

    _resumeAt = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) => _tick());
    state = state.copyWith(running: true);
  }

  void pause() {
    if (!state.running) return;

    _commitElapsed();
    _resumeAt = null;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(running: false);
  }

  /// เคลียร์เวลาสะสมกลับเป็นศูนย์ — เรียกหลังผู้ใช้กดยืนยันว่าพักแล้ว
  /// ไม่ resume เองหลัง reset เพราะ gate widget เป็นคน resume ใหม่ตามสถานะแอป
  void reset() {
    _timer?.cancel();
    _timer = null;
    _resumeAt = null;
    state = UsageTimerState.initial();
  }

  // ย้ายเวลาจริงที่ผ่านไปตั้งแต่ _resumeAt ล่าสุด เข้าไปสะสมใน state.elapsed แล้วรีเซ็ต
  // _resumeAt เป็นตอนนี้ เพื่อไม่ให้นับ delta ซ้ำในรอบถัดไป
  void _commitElapsed() {
    if (_resumeAt == null) return;
    final now = DateTime.now();
    final delta = now.difference(_resumeAt!);
    _resumeAt = now;
    state = state.copyWith(elapsed: state.elapsed + delta);
  }

  void _tick() {
    _commitElapsed();

    if (state.elapsed >= limit) {
      _timer?.cancel();
      _timer = null;
      _resumeAt = null;
      state = state.copyWith(
        elapsed: limit,
        running: false,
        breakDue: true,
      );
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