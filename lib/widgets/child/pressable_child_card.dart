import 'package:flutter/material.dart';

import '../../services/haptic_service.dart';
import '../../services/sfx_player.dart';
import '../../theme/spacing.dart';

// การ์ด/ปุ่มที่กดได้สำหรับฝั่งเด็ก — เป็น building block กลางที่ ModuleCard, ScenarioCard,
// VocabCard และที่อื่นๆ ใช้ร่วมกัน (spec 1.3 — ปรับ UI/UX ให้เหมาะเด็กกลุ่มอาการดาวน์ซินโดรม
// ทั้งแอป) แก้ที่นี่ที่เดียว ทุกจุดที่เรียกใช้ widget นี้ได้ผลตามไปด้วยอัตโนมัติ ไม่ต้องไล่แก้
// ทีละหน้าจอ
//
// สิ่งที่เพิ่มจากเดิม:
// 1) บังคับพื้นที่กดขั้นต่ำ kTouchTargetMin (64dp) แม้ child ข้างในจะเล็กกว่านั้น เพราะ
//    กล้ามเนื้อมือ/นิ้วที่มีความตึงตัวต่ำ (hypotonia) ในเด็กกลุ่มนี้ทำให้เล็งตำแหน่งกดได้ไม่
//    แม่นยำเท่าเด็กทั่วไป (ปิดได้ผ่าน enforceMinTapTarget ถ้า child ใหญ่กว่านี้อยู่แล้ว)
// 2) สั่น haptic เบาๆ (tapLight) ทุกครั้งที่กดติด แบบรวมศูนย์ไว้ที่นี่ที่เดียว — เดิมต้องไป
//    เรียก HapticService เองทีละหน้าจอ ทำให้บางจอลืมเรียกจน feedback ไม่สม่ำเสมอกันทั้งแอป
// 3) กันกดซ้ำถี่เกินไป (debounce/cooldown) ป้องกันมือสั่นเล็กน้อยจนกดติดสองครั้งโดยไม่
//    ตั้งใจ เช่น เปิดหน้าเกมซ้อนกันสองหน้า ปิดเป็น Duration.zero ต่อจุดได้ถ้าต้องการให้แตะซ้ำ
//    เร็วๆทำงานได้ทันที (เช่น การ์ดคำศัพท์ที่กดฟังเสียงซ้ำ)
// 4) เพิ่มการหรี่ความโปร่งแสงเล็กน้อยตอนกดค้าง คู่กับการขยายขนาดเดิม ให้เห็นการเปลี่ยนแปลง
//    ชัดเจนขึ้น — ใช้ AnimatedOpacity (ไม่ใช่ชั้นสี่เหลี่ยมทาบ) จึงเข้ารูปทรง/มุมโค้งของ
//    child เดิมเสมอ ไม่มีปัญหาเหลี่ยมมุมโผล่เกินขอบการ์ดที่โค้งมน
class PressableChildCard extends StatefulWidget {
  const PressableChildCard({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 1.04,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.playClickSound = false,
    this.hapticOnTap = true,
    this.cooldown = kTapCooldown,
    this.enforceMinTapTarget = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  final Curve curve;
  final bool playClickSound;

  /// สั่น haptic เบาๆ ทุกครั้งที่แตะติด ปิดได้ถ้าหน้าจอนั้นอยากคุม haptic เองแบบเฉพาะทาง
  final bool hapticOnTap;

  /// ระยะเวลาหน่วงกันกดซ้ำหลังแตะแต่ละครั้ง ตั้งเป็น Duration.zero เพื่อปิดการกันกดซ้ำ
  final Duration cooldown;

  /// บังคับขนาดพื้นที่กดขั้นต่ำ kTouchTargetMin แม้ child จะเล็กกว่า (ไม่กระทบ child ที่
  /// ใหญ่กว่าอยู่แล้ว เพราะเป็นแค่ค่าต่ำสุด ไม่ใช่ค่าตายตัว)
  final bool enforceMinTapTarget;

  @override
  State<PressableChildCard> createState() => _PressableChildCardState();
}

class _PressableChildCardState extends State<PressableChildCard> {
  bool _pressed = false;
  bool _coolingDown = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  void _onTapDown(TapDownDetails _) {
    if (_coolingDown) return;
    _setPressed(true);
  }

  void _onTapUp(TapUpDetails _) {
    _setPressed(false);
    if (_coolingDown) return;

    if (widget.playClickSound) {
      playUiClick();
    }
    if (widget.hapticOnTap) {
      HapticService.tapLight();
    }
    widget.onTap();

    if (widget.cooldown > Duration.zero) {
      _coolingDown = true;
      Future<void>.delayed(widget.cooldown, () {
        if (mounted) _coolingDown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedScale(
      scale: _pressed ? widget.scale : 1.0,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.82 : 1.0,
        duration: widget.duration,
        child: widget.child,
      ),
    );

    if (widget.enforceMinTapTarget) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kTouchTargetMin,
          minHeight: kTouchTargetMin,
        ),
        child: content,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _setPressed(false),
      child: content,
    );
  }
}
