import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show Canvas, Paint, PaintingStyle, RRect, Radius, Rect;

import '../theme/colors.dart';

// ถาดวางไอเทมแถวล่างของฉากโหมด sort-all (ตาม mockup ทีม — ถาดไม้ใต้ไอคอน)
// เป็นแถบพื้นอุ่นโปร่งแสงรองใต้การ์ดไอเทม ให้แถวไอเทมอ่านง่ายบนพื้นหลังฉากจริง
class ItemTrayComponent extends PositionComponent {
  ItemTrayComponent({required Vector2 position, required Vector2 size})
    : super(position: position, size: size, priority: 1);

  @override
  void render(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(size.y * 0.28),
    );
    canvas.drawRRect(rect, Paint()..color = kWarmWhite.withValues(alpha: 0.72));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = kWarmBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}
