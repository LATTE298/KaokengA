import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/tts_strings_th.dart';
import '../providers/tts_provider.dart';
import '../routes/app_routes.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

// Popup เตือนพักสายตา (spec 1.4) — ออกแบบให้นุ่มนวล ไม่ใช้สีแดง/ไอคอนเตือนภัยที่ดู
// คุกคาม ใช้ภาพดวงตาปิด + โทนเหลือง/ฟ้าตามธีมเดิมของแอป
//
// สำคัญ: Kaokeng ล็อกแนวนอนเสมอ dialog นี้จึงต้อง "พอดีจอในครั้งเดียว ไม่มี scroll" —
// เดิมใส่ SingleChildScrollView เป็น fallback แต่มันทำให้ scrollbar โผล่มาแม้ในจอปกติ
// ตอนนี้เอา scroll ออกทั้งหมด แล้วคำนวณขนาดไอคอน/ระยะห่างจากความสูงจอจริงแทน (สเกลลง
// เมื่อจอเตี้ย) รับประกันว่าเนื้อหาพอดีจอเสมอโดยไม่ต้องเลื่อน
class BreakReminderDialog extends ConsumerStatefulWidget {
  const BreakReminderDialog({super.key, required this.onAcknowledged});

  final VoidCallback onAcknowledged;

  @override
  ConsumerState<BreakReminderDialog> createState() =>
      _BreakReminderDialogState();
}

class _BreakReminderDialogState extends ConsumerState<BreakReminderDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(kTtsBreakReminder);
    });
  }

  void _onContinue() {
    widget.onAcknowledged();
    Navigator.of(context).pop();
  }

  void _onExit() {
    widget.onAcknowledged();
    Navigator.of(context).pop();
    context.go(kRouteModeSelect);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // จอเตี้ย (< 400px เช่น Samsung S8+ 360) → ใช้เลย์เอาต์กระชับ (compact)
    // ไอคอนเล็กลง ระยะห่างชิดขึ้น หัวข้อ/คำอธิบายเล็กลง เพื่อให้พอดีจอโดยไม่ต้อง scroll
    final compact = screenHeight < 400;

    final iconOuter = compact ? 56.0 : 72.0;
    final iconInner = compact ? 32.0 : 40.0;
    final gapAfterIcon = compact ? kSpace2 : kSpace3;
    final gapAfterTitle = compact ? kSpace1 : kSpace2;
    final gapBeforeButton = compact ? kSpace3 : kSpace4;
    final gapBetweenButtons = compact ? kSpace1 : kSpace2;
    final vPadding = compact ? kSpace3 : kSpace4;

    final titleStyle = compact ? kTextMd.copyWith(fontWeight: FontWeight.w700) : kTextLg;
    final bodyStyle = (compact ? kTextXs : kTextSm).copyWith(
      color: kTextSecondary,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: kSpace6,
        vertical: kSpace2,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          // ไม่เกิน 96% ของจอ — เพื่อให้มีขอบเล็กน้อยและไม่มีทางล้น
          maxHeight: screenHeight * 0.96,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: kSpace6,
            vertical: vPadding,
          ),
          decoration: BoxDecoration(
            color: kWarmWhite,
            borderRadius: kRadiusLg,
            boxShadow: const [kShadowLg],
          ),
          // ไม่มี SingleChildScrollView แล้ว — Column mainAxisSize.min หดพอดีเนื้อหา
          // ซึ่งถูกออกแบบให้เตี้ยพอสำหรับจอแนวนอนที่สั้นสุดเสมอ
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: iconOuter,
                height: iconOuter,
                decoration: BoxDecoration(
                  color: kBlueLight,
                  shape: BoxShape.circle,
                  boxShadow: const [kShadowSm],
                ),
                child: Icon(
                  Icons.visibility_off_rounded,
                  size: iconInner,
                  color: kBlueDark,
                ),
              ),
              SizedBox(height: gapAfterIcon),
              Text(
                kBreakReminderTitle,
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: gapAfterTitle),
              Text(
                kBreakReminderBody,
                style: bodyStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: gapBeforeButton),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _onContinue,
                  icon: const Icon(Icons.check_rounded, size: 26),
                  label: const Text(kBreakReminderContinue),
                ),
              ),
              SizedBox(height: gapBetweenButtons),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _onExit,
                  child: const Text(kBreakReminderExit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}