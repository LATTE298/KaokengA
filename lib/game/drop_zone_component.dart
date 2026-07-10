import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'interactable_component.dart';

// Drop zone / basket (spec 04 §DropZoneComponent).
// สองโหมด:
// - โหมดเดิม (zoneId == null): ตะกร้าเดียว รับเฉพาะชิ้น isTarget แล้วจบเกม —
//   วาดกรอบเหลืองให้เห็น (idle จาง, activated เต็ม)
// - โหมด sort-all (zoneId != null): รับเฉพาะชิ้นที่ zone_id ตรงกับโซนนี้ รับได้
//   หลายชิ้น (เช่น ผลไม้ 4 ลูกลงถ้วยเดียว) — ถัง/ถ้วยอยู่ในภาพพื้นหลังแล้ว
//   จึงไม่วาดกรอบทับ (visible: false)
class DropZoneComponent extends PositionComponent with CollisionCallbacks {
  DropZoneComponent({
    required Vector2 position,
    required Vector2 size,
    required this.onItemAccepted,
    this.zoneId,
    this.visible = true,
    this.wantedIds,
  }) : super(position: position, size: size, priority: 1);

  final void Function(InteractableComponent item) onItemAccepted;

  /// id โซนในโหมด sort-all — null = โหมดเดิม (รับชิ้น isTarget)
  final String? zoneId;

  /// วาดกรอบโซนไหม (โหมด sort-all ปิด เพราะภาพพื้นหลังมีถัง/ถ้วยอยู่แล้ว)
  final bool visible;

  /// โจทย์สุ่มบางชิ้น (pick_count): รับเฉพาะ id ในชุดนี้ — null = รับทุกชิ้น
  /// ของโซนตัวเอง. ชิ้นนอกโจทย์ลงโซนถูกก็โดนปฏิเสธ (เด้งกลับ นับ mistake)
  final Set<String>? wantedIds;

  bool _activated = false;

  /// จำนวนชิ้นที่วางสำเร็จในโซนนี้ — ใช้เลือกตำแหน่งกระจายไม่ให้ทับกัน
  int _settledCount = 0;

  // ตำแหน่งวางในโซนตามลำดับชิ้น (สัดส่วนของขนาดโซน จากจุดกึ่งกลาง) — ชิ้นแรก
  // กลางโซน ชิ้นถัดไปเยื้องไม่ทับกัน (ผลไม้เรียงในถ้วยแบบ mockup จัดจานผลไม้)
  static const List<Offset> _spreadFractions = [
    Offset(0, 0),
    Offset(0.2, 0.16),
    Offset(-0.2, 0.16),
    Offset(0.12, -0.18),
    Offset(-0.12, -0.18),
  ];

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size, collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(24),
    );

    if (_activated) {
      canvas.drawRRect(
        rect,
        Paint()..color = kYellowPrimary.withValues(alpha: 0.5),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = kYellowDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    } else {
      canvas.drawRRect(
        rect,
        Paint()..color = kYellowAccent.withValues(alpha: 0.3),
      );
      _drawDashedBorder(canvas, rect);
    }
  }

  void _drawDashedBorder(Canvas canvas, RRect rect) {
    final paint =
        Paint()
          ..color = kYellowDark.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    // Flame canvas doesn't do dashed strokes natively; render as a solid
    // thin border for MVP. Replacement: PathMetric dash walk if needed.
    canvas.drawRRect(rect, paint);
  }

  /// โซนนี้รับชิ้นนี้ไหม — โหมดเดิมรับ target, โหมด sort-all รับชิ้นของโซนตัวเอง
  /// (ถ้ามีโจทย์สุ่ม ต้องเป็นชิ้นในโจทย์ด้วย)
  bool _accepts(InteractableComponent obj) {
    if (zoneId == null) return obj.isTarget;
    if (obj.config.zoneId != zoneId) return false;
    return wantedIds?.contains(obj.config.id) ?? true;
  }

  void onInteractableEntered(InteractableComponent obj) {
    if (obj.settled) return;
    // โหมดเดิมล็อกโซนหลังรับชิ้นแรก — โหมด sort-all รับต่อได้จนครบของโซนตัวเอง
    if (zoneId == null && _activated) return;
    if (!_accepts(obj)) return; // ชิ้นผิดโซน: ปล่อยให้เด้งกลับเอง (นับ mistake)
    _activated = true;
    final fraction = _spreadFractions[_settledCount % _spreadFractions.length];
    _settledCount++;
    final center =
        position +
        size / 2 +
        Vector2(size.x * fraction.dx, size.y * fraction.dy);
    obj.settleInZone(center);
    onItemAccepted(obj);
  }

  void onInteractableExited(InteractableComponent obj) {
    // Distractors exiting the zone do nothing. The target, once settled,
    // never exits.
  }
}
