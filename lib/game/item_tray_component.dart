import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show
        BlurStyle,
        Canvas,
        Color,
        MaskFilter,
        Paint,
        PaintingStyle,
        RRect,
        Radius,
        Rect;

import '../theme/colors.dart';

// ถาดวางไอเทมแถวล่างของฉากโหมด sort-all (ตาม mockup ทีม — ถาดไม้ใต้ไอคอน)
// แถบพื้นอุ่นโปร่งแสง + เงานุ่ม รองใต้การ์ดไอเทม ให้แถวไอเทมอ่านง่ายบนพื้นหลังฉากจริง
class ItemTrayComponent extends PositionComponent {
  ItemTrayComponent({required Vector2 position, required Vector2 size})
    : super(position: position, size: size, priority: 1);

  @override
  void render(Canvas canvas) {
    final r = Radius.circular(size.y * 0.30);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      r,
    );
    // เงานุ่มใต้ถาด
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.y * 0.03, size.x, size.y),
        r,
      ),
      Paint()
        ..color = const Color(0x14000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawRRect(rect, Paint()..color = kWarmWhite.withValues(alpha: 0.80));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = kWarmBorder.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }
}
