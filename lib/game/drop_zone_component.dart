import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'interactable_component.dart';

// Drop zone / basket (spec 04 §DropZoneComponent).
// Visual states per spec: idle (dashed yellow 30%), activated (gold full).
class DropZoneComponent extends PositionComponent with CollisionCallbacks {
  DropZoneComponent({
    required Vector2 position,
    required Vector2 size,
    required this.onTargetDropped,
  }) : super(position: position, size: size, priority: 1);

  final void Function(InteractableComponent target) onTargetDropped;

  bool _activated = false;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size, collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
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

  void onInteractableEntered(InteractableComponent obj) {
    if (_activated) return;
    if (!obj.isTarget) return; // distractors ignored (spec 04).
    _activated = true;
    final center = position + size / 2;
    obj.settleInZone(center);
    onTargetDropped(obj);
  }

  void onInteractableExited(InteractableComponent obj) {
    // Distractors exiting the zone do nothing. The target, once settled,
    // never exits.
  }
}
