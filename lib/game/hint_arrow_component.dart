import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

// ลูกศรใบ้ชี้ลงเหนือ "ของที่ต้องหยิบ" เด้งขึ้นลงเรียกสายตา — visual hint คู่กับ
// เสียง TTS (spec 1.2) เมื่อเด็กนิ่งนานเกิน. โผล่หลังนิ่ง 15 วิ, หายเมื่อเริ่มลาก
class HintArrowComponent extends PositionComponent {
  HintArrowComponent({required Vector2 position, this.reduceMotion = false})
    : super(
        position: position,
        size: Vector2(48, 56),
        anchor: Anchor.bottomCenter,
        priority: 6,
      );

  final bool reduceMotion;

  final _fill = Paint()..color = kYellowPrimary;
  final _border = Paint()
    ..color = kYellowDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeJoin = StrokeJoin.round;

  @override
  Future<void> onLoad() async {
    if (!reduceMotion) {
      // เด้งขึ้นลงตลอด — ดึงความสนใจไปที่ของชิ้นที่ถูกต้อง
      add(
        MoveByEffect(
          Vector2(0, -14),
          EffectController(
            duration: 0.5,
            reverseDuration: 0.5,
            infinite: true,
            curve: Curves.easeInOut,
          ),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final stemW = w * 0.34;

    // ก้านลูกศร (มุมโค้ง) + หัวสามเหลี่ยมชี้ลง รวมเป็นรูปเดียว
    final shape = Path()
      ..moveTo((w - stemW) / 2, 0)
      ..lineTo((w + stemW) / 2, 0)
      ..lineTo((w + stemW) / 2, h * 0.5)
      ..lineTo(w * 0.9, h * 0.5)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.1, h * 0.5)
      ..lineTo((w - stemW) / 2, h * 0.5)
      ..close();

    canvas.drawPath(shape, _fill);
    canvas.drawPath(shape, _border);
  }
}
