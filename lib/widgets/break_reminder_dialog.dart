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
// คุกคาม ใช้ภาพดวงตาปิด + โทนเหลือง/ฟ้าตามธีมเดิมของแอป เพื่อให้เด็กไม่รู้สึกว่าโดน "ดุ" หรือ
// "ห้าม" แต่เป็นการชวนพักแบบเพื่อนเตือน
//
// เปิดผ่าน UsageTimerGate เท่านั้น (ไม่เปิดเองจากที่อื่น) จึงไม่ต้องเช็คซ้ำว่าครบขีดจำกัดแล้ว
// หรือยัง — ถ้าเปิดมาแล้วก็เปิดเลย
class BreakReminderDialog extends ConsumerStatefulWidget {
  const BreakReminderDialog({super.key, required this.onAcknowledged});

  /// เรียกเมื่อผู้ใช้กดยืนยันว่าพักแล้ว — gate จะใช้ callback นี้ reset ตัวจับเวลา
  /// (ไม่ทำผ่าน ref.read ใน dialog เองเพื่อแยก concern: dialog แสดง UI, gate จัดการ state)
  final VoidCallback onAcknowledged;

  @override
  ConsumerState<BreakReminderDialog> createState() =>
      _BreakReminderDialogState();
}

class _BreakReminderDialogState extends ConsumerState<BreakReminderDialog> {
  @override
  void initState() {
    super.initState();
    // พูด TTS เตือนตอนเปิด popup — ใช้ post-frame เพื่อไม่ให้เสียงเริ่มก่อน UI โผล่
    // (ถ้าเริ่มเล่นใน initState ตรงๆ บางครั้งเสียงดังขึ้นก่อนภาพแสดงเสร็จ)
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
    // กลับไปหน้าเลือกโหมด ตามพฤติกรรมที่คาดหวัง: เด็ก/ผู้ปกครองอยากพักจริงๆ การพากลับมาที่
    // home มีโอกาสน้อยลงที่จะกดเข้าเกมต่อทันที
    if (context.canPop()) {
      context.go(kRouteModeSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: kSpace6,
        vertical: kSpace4,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenSize.height * 0.9,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: kSpace8,
            vertical: kSpace6,
          ),
          decoration: BoxDecoration(
            color: kWarmWhite,
            borderRadius: kRadiusLg,
            boxShadow: const [kShadowLg],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ไอคอนรูปดวงตาปิด — สื่อ "พักสายตา" ตรงๆ โดยไม่ต้องใช้สีแดง/นาฬิกาที่
                // อาจดูเตือนภัยเกินไป
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: kBlueLight,
                    shape: BoxShape.circle,
                    boxShadow: const [kShadowSm],
                  ),
                  child: const Icon(
                    Icons.visibility_off_rounded,
                    size: 56,
                    color: kBlueDark,
                  ),
                ),
                const SizedBox(height: kSpace5),
                Text(
                  kBreakReminderTitle,
                  style: kTextXL,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpace3),
                Text(
                  kBreakReminderBody,
                  style: kTextMd.copyWith(color: kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpace6),
                // ปุ่มยืนยันพักแล้ว — เป็นปุ่มหลัก เด่นกว่าปุ่มออก เพราะแนวทางที่อยากให้
                // เกิดบ่อยกว่าคือ "พักสักครู่แล้วเล่นต่อ" ไม่ใช่ "ออกไปเลย"
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _onContinue,
                    icon: const Icon(Icons.check_rounded, size: 28),
                    label: const Text(kBreakReminderContinue),
                  ),
                ),
                const SizedBox(height: kSpace3),
                // ปุ่มออกใช้ TextButton — ดูเป็นทางเลือกรอง สีเข้มน้อยกว่า ลดน้ำหนักทาง
                // สายตา แต่กดได้สะดวกเท่ากัน (theme บังคับขนาดกดขั้นต่ำ 64dp ให้แล้ว)
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
      ),
    );
  }
}