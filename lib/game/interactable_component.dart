import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Curves;

import '../models/scenario_config.dart';
import '../services/haptic_service.dart';
import 'drop_zone_component.dart';
import 'placeholder_renderer.dart';

// A draggable scene object (spec 04 §InteractableComponent).
// Renders a placeholder swatch until real sprites ship.
class InteractableComponent extends PositionComponent
    with DragCallbacks, CollisionCallbacks {
  InteractableComponent({
    required this.config,
    required Vector2 position,
    required this.reduceMotion,
    this.onPathSample,
  }) : _startPosition = position.clone(),
       super(
         position: position,
         size: Vector2.all(120),
         anchor: Anchor.center,
         priority: 2,
       );

  final InteractableConfig config;
  final bool reduceMotion;
  final void Function(Vector2 point)? onPathSample;

  final Vector2 _startPosition;
  bool _isBeingDragged = false;
  bool _settledInZone = false;

  bool get isTarget => config.isTarget;

  @override
  Future<void> onLoad() async {
    // Placeholder visual until real sprites are available. The ID doubles as
    // a human-readable label for debugging.
    final label = _labelFor(config.id);
    add(PlaceholderComponent(size: size, label: label));

    // 80% hitbox (spec 04 §Hitbox).
    add(
      RectangleHitbox(
        size: size * 0.8,
        position: size * 0.1,
        collisionType: CollisionType.active,
      ),
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_settledInZone) return;
    super.onDragStart(event);
    _isBeingDragged = true;
    priority = 100;
    scale = Vector2.all(1.05);
    HapticService.grab();
    onPathSample?.call(position.clone());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isBeingDragged) return;
    position += event.localDelta;
    onPathSample?.call(position.clone());
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_settledInZone) return;
    _isBeingDragged = false;
    priority = 2;
    scale = Vector2.all(1.0);

    // Let the collision callback fire first (it runs this frame). If the
    // target lands in the zone, DropZone claims us. Otherwise return home
    // after a one-frame grace.
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (_settledInZone || _isBeingDragged) return;
      if (reduceMotion) {
        position = _startPosition.clone();
      } else {
        add(
          MoveEffect.to(
            _startPosition,
            EffectController(duration: 0.4, curve: Curves.easeInOut),
          ),
        );
      }
    });
  }

  void settleInZone(Vector2 zoneCenter) {
    _settledInZone = true;
    _isBeingDragged = false;
    priority = 5;
    if (reduceMotion) {
      position = zoneCenter.clone();
    } else {
      add(
        MoveEffect.to(
          zoneCenter,
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
      );
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is DropZoneComponent) {
      other.onInteractableEntered(this);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is DropZoneComponent) {
      other.onInteractableExited(this);
    }
  }
}

// Lightweight ID -> Thai-ish readable label map for placeholder rendering.
// Gone as soon as real artwork replaces PlaceholderComponent.
String _labelFor(String id) {
  const map = {
    'milk_carton_blue': 'นม',
    'bread_loaf': 'ขนมปัง',
    'potato_chips': 'ขนม',
    'plastic_bottle': 'ขวด',
    'banana_peel': 'เปลือก',
    'paper_ball': 'กระดาษ',
    'banana': 'กล้วย',
    'toothbrush': 'แปรง',
    'pencil': 'ดินสอ',
  };
  return map[id] ?? id;
}
