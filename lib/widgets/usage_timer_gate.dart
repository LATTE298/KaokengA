import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'break_reminder_dialog.dart';
import '../features/usage_timer/usage_timer_notifier.dart';
import '../routes/app_router.dart';

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
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
        notifier.pause();
        break;
    }
  }

  Future<void> _showBreakDialog() async {
    if (_dialogShowing) return;

    // ใช้ context ของ root navigator (ไม่ใช่ context ของ gate เอง) เพราะ gate อยู่เหนือ
    // Navigator ใน widget tree — showDialog ต้องการ context ที่อยู่ใต้ Navigator (spec 1.4)
    // ถ้า navigator ยังไม่พร้อม (เช่น ช่วง transition) ให้ข้ามรอบนี้ไป breakDue ยังคงค้าง
    // เป็น true อยู่ ไว้ค่อยลองใหม่ก็ได้ แต่ในทางปฏิบัติ navigator พร้อมเสมอ ณ จุดนี้
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;

    _dialogShowing = true;
    ref.read(usageTimerProvider.notifier).pause();

    await showDialog<void>(
      context: navContext,
      barrierDismissible: false,
      builder:
          (_) => BreakReminderDialog(
            onAcknowledged: () {
              ref.read(usageTimerProvider.notifier).reset();
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
    ref.listen<UsageTimerState>(usageTimerProvider, (previous, next) {
      final wasFlagged = previous?.breakDue ?? false;
      if (!wasFlagged && next.breakDue) {
        _showBreakDialog();
      }
    });

    return widget.child;
  }
}
