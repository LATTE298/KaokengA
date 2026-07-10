import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'
    show Canvas, Curves, Paint, PaintingStyle, RRect, Radius, Rect;

import '../models/scenario_config.dart';
import '../services/haptic_service.dart';
import '../theme/colors.dart';
import 'drop_zone_component.dart';
import 'game_asset_paths.dart';
import 'placeholder_renderer.dart';

// A draggable scene object (spec 04 §InteractableComponent).
// Renders a placeholder swatch until real sprites ship.
class InteractableComponent extends PositionComponent
    with DragCallbacks, CollisionCallbacks {
  InteractableComponent({
    required this.config,
    required Vector2 position,
    required this.reduceMotion,
    required this.placeholderImagePaths,
    this.onPathSample,
    this.onMistake,
    double displaySize = 120,
    this.showCard = false,
  }) : _startPosition = position.clone(),
       super(
         position: position,
         size: Vector2.all(displaySize),
         anchor: Anchor.center,
         priority: 2,
       );

  final InteractableConfig config;
  final bool reduceMotion;
  final Set<String> placeholderImagePaths;
  final void Function(Vector2 point)? onPathSample;
  final void Function()? onMistake; // เพิ่ม

  /// วาดการ์ดขาวรองหลังรูป (โหมด sort-all — ให้ไอเทมเด่นบนพื้นหลังฉากจริง
  /// แบบถาดไอเทมใน mockup) การ์ดหายเมื่อวางลงโซนสำเร็จ
  final bool showCard;

  final Vector2 _startPosition;
  bool _isBeingDragged = false;
  bool _settledInZone = false;

  bool get isTarget => config.isTarget;

  /// วางลงโซนสำเร็จแล้ว (ลากไม่ได้อีก) — เกมโหมด sort-all ใช้นับความคืบหน้า
  bool get settled => _settledInZone;

  @override
  Future<void> onLoad() async {
    if (placeholderImagePaths.contains(config.image)) {
      final label = _labelFor(config.id);
      await add(PlaceholderComponent(size: size, label: label));
    } else {
      final image = await findGame()!.images.load(flameImageKey(config.image));
      // fit แบบ contain รักษาสัดส่วนรูปจริง (รูปทีมไม่จัตุรัส — stretch แล้วเบี้ยว)
      final aspect = image.width / image.height;
      final inset = showCard ? size * 0.82 : size.clone();
      final spriteSize =
          aspect >= 1
              ? Vector2(inset.x, inset.x / aspect)
              : Vector2(inset.y * aspect, inset.y);
      await add(
        SpriteComponent(
          sprite: Sprite(image),
          size: spriteSize,
          position: (size - spriteSize) / 2,
        ),
      );
    }

    // 80% hitbox (spec 04 §Hitbox).
    await add(
      RectangleHitbox(
        size: size * 0.8,
        position: size * 0.1,
        collisionType: CollisionType.active,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!showCard || _settledInZone) return;
    // การ์ดรองหลังรูป (วาดก่อน children = อยู่ใต้รูปเสมอ)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(20),
    );
    canvas.drawRRect(rect, Paint()..color = kWarmWhite.withValues(alpha: 0.95));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = kYellowPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
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
      // วางไม่ถูก zone — นับเป็นความผิดพลาด 1 ครั้ง
      onMistake?.call();
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
    // ย่อเล็กน้อยให้ดู "วางลงไปแล้ว" ในถัง/ถ้วย (ภาพโซนอยู่ในพื้นหลัง)
    if (reduceMotion) {
      position = zoneCenter.clone();
      scale = Vector2.all(0.85);
    } else {
      add(
        MoveEffect.to(
          zoneCenter,
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
      );
      add(
        ScaleEffect.to(
          Vector2.all(0.85),
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
