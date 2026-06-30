import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'break_reminder_dialog.dart';
import '../features/usage_timer/usage_timer_notifier.dart';

// วิดเจ็ตครอบทั้งแอป (เสียบผ่าน MaterialApp.router(builder: ...)) ที่ทำหน้าที่:
//   1) ผูก UsageTimerNotifier เข้ากับ app lifecycle — pause เมื่อแอปถูกย่อ/สลับไปแอปอื่น
//      resume เมื่อกลับมา
//   2) เปิด BreakReminderDialog เมื่อ notifier ส่งสัญญาณ breakDue=true
//
// ที่ต้องแยกชั้นกันแบบนี้ (notifier vs gate) เพราะ notifier ควรเป็น pure state ไม่ติดกับ
// BuildContext, Navigator, หรือ WidgetsBinding ทำให้ทดสอบได้ง่าย ส่วน "การพา state ไป
// ทำงานในโลกจริง" (เปิด dialog, ฟัง lifecycle) เป็นหน้าที่ของวิดเจ็ตชั้นนี้

class UsageTimerGate extends ConsumerStatefulWidget {
  const UsageTimerGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UsageTimerGate> createState() => _UsageTimerGateState();
}

class _UsageTimerGateState extends ConsumerState<UsageTimerGate>
    with WidgetsBindingObserver {
  // กันการเปิด dialog ซ้อนกัน 2 ครั้ง — listen อาจ fire ซ้ำได้ถ้า state รีบเสริฟ rebuild
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // เริ่มนับเวลาเมื่อ gate ขึ้นมาเป็นครั้งแรก (หลัง splash) — ใช้ post-frame เพื่อกัน
    // การแก้ provider ระหว่าง build (ทำใน build/initState ตรงๆ จะ trigger warning ของ
    // Riverpod ว่ามี side-effect ระหว่าง widget tree build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(usageTimerProvider.notifier).resume();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(usageTimerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        notifier.resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        // pause ในทุกสถานะที่ไม่ใช่ resumed — เด็กไม่ได้มองจอแล้วก็ไม่ควรนับเวลาต่อ
        // โดยเฉพาะ .paused (กดปุ่ม home/สลับแอป) เป็นเคสที่สำคัญที่สุด เพราะถ้าไม่ pause
        // เด็กที่วางแท็บเล็ตทิ้งไว้ 10 นาทีแล้วกลับมาเปิด จะโดน popup ทันทีโดยไม่สมเหตุสมผล
        notifier.pause();
        break;
    }
  }

  Future<void> _showBreakDialog() async {
    if (_dialogShowing) return;
    _dialogShowing = true;
    // ตอน popup กำลังแสดง เราถือว่าเด็กไม่ได้เล่นเกมแล้ว (popup บังอยู่) จึง pause ตัวจับ
    // เวลาไว้ก่อน — ถ้าไม่ทำ และ tick interval มาตรงตอน dialog เปิด ค่าจะข้ามขีดจำกัด
    // ไปเรื่อยๆไม่หยุด พอ ack ก็ reset ก็จริง แต่ระหว่างเปิด dialog นานๆเวลายังเดิน
    ref.read(usageTimerProvider.notifier).pause();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      // ผู้ใช้ปุ่ม back ระบบจะปิดไม่ได้ — ต้องกดปุ่มในกล่องเอง
      builder: (_) => BreakReminderDialog(
        onAcknowledged: () {
          ref.read(usageTimerProvider.notifier).reset();
          // หลัง reset ให้ resume ใหม่อัตโนมัติ เพื่อเริ่มนับรอบถัดไป — ใช้ post-frame
          // กันการ trigger provider rebuild กลางการปิด dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref.read(usageTimerProvider.notifier).resume();
            }
          });
        },
      ),
    );

    _dialogShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    // ฟังเฉพาะการเปลี่ยน breakDue (false→true) — ใช้ listen ไม่ใช่ watch เพราะไม่อยาก
    // ให้วิดเจ็ตทั้งหน้าแอป rebuild ทุกครั้งที่ elapsed ขยับ (ทุก tickInterval = 5s)
    ref.listen<UsageTimerState>(usageTimerProvider, (previous, next) {
      final wasFlagged = previous?.breakDue ?? false;
      if (!wasFlagged && next.breakDue) {
        _showBreakDialog();
      }
    });

    return widget.child;
  }
}