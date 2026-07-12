import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'
    show
        BlurStyle,
        Canvas,
        Color,
        Curves,
        MaskFilter,
        Paint,
        PaintingStyle,
        RRect,
        Radius,
        Rect;

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
    this.entryDelay = 0,
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

  /// หน่วงเวลาก่อนอนิเมชันเข้าฉาก (วินาที) — ไล่ทีละใบให้ดูนุ่ม (0 = ไม่หน่วง)
  final double entryDelay;

  final Vector2 _startPosition;
  bool _isBeingDragged = false;
  bool _settledInZone = false;

  // โซนที่ hitbox กำลังคาบเกี่ยวอยู่ตอนนี้ — ใช้ตัดสินตอน "ปล่อย" ว่าวางลงโซนไหน
  // (ไอเทมบางชิ้นเริ่มเกมโดยคาบเกี่ยวโซนอยู่แล้วเพราะถาดอยู่ใกล้ ต้องรอผู้เล่นลาก)
  final Set<DropZoneComponent> _overlappingZones = {};

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

    // เข้าฉากนุ่ม ๆ: การ์ดค่อยๆ ขยายเข้ามา ไล่ทีละใบ (subtle ไม่กระตุ้นตา — spec 1.3)
    if (showCard && !reduceMotion) {
      scale = Vector2.all(0.82);
      add(
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(
            duration: 0.28,
            startDelay: entryDelay,
            curve: Curves.easeOut,
          ),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!showCard || _settledInZone) return;
    // การ์ดรองหลังรูป (วาดก่อน children = อยู่ใต้รูปเสมอ): เงานุ่ม + ขอบบางอุ่น
    final r = Radius.circular(size.x * 0.22);
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      r,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.y * 0.05, size.x, size.y),
        r,
      ),
      Paint()
        ..color = const Color(0x1F000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(card, Paint()..color = kWarmWhite);
    canvas.drawRRect(
      card,
      Paint()
        ..color = kYellowPrimary.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.x * 0.018,
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_settledInZone) return;
    super.onDragStart(event);
    _isBeingDragged = true;
    priority = 100;
    // ยกเลิก entrance ที่อาจยังวิ่งอยู่ ก่อนตั้ง scale ตอนจับ
    children.whereType<ScaleEffect>().forEach((e) => e.removeFromParent());
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
    priority = 2;
    scale = Vector2.all(1.0);

    // ปล่อยขณะคาบเกี่ยวโซนที่รับได้ → วางลงโซนนั้น. ครอบคลุมกรณีที่ collisionStart
    // ไม่ยิงระหว่างลาก (ไอเทมคาบเกี่ยวโซนมาตั้งแต่ตอนโหลด แล้วผู้เล่นลากอยู่ในโซน)
    for (final zone in _overlappingZones.toList()) {
      zone.onInteractableEntered(this);
      if (_settledInZone) {
        _isBeingDragged = false;
        return;
      }
    }
    _isBeingDragged = false;

    // วางไม่ถูก zone — เด้งกลับ (หน่วง 1 เฟรมเผื่อ collision callback ปิดท้าย)
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (_settledInZone || _isBeingDragged) return;
      onMistake?.call(); // นับเป็นความผิดพลาด 1 ครั้ง
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

  /// "ถูกดูดหายเข้าโซน" — พุ่งเข้าปากถังพร้อมหดเล็กจนหาย แล้วออกจากฉาก
  /// (ฉาก swallow_items เช่น ทิ้งขยะ — เหมือนขยะตกลงถังจริง)
  void consumeInZone(Vector2 zoneMouth) {
    _settledInZone = true;
    _isBeingDragged = false;
    priority = 5;
    if (reduceMotion) {
      removeFromParent();
      return;
    }
    add(
      MoveEffect.to(
        zoneMouth,
        EffectController(duration: 0.28, curve: Curves.easeIn),
      ),
    );
    add(
      ScaleEffect.to(
        Vector2.all(0.05),
        EffectController(duration: 0.28, curve: Curves.easeIn),
      )..onComplete = removeFromParent,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is DropZoneComponent) {
      _overlappingZones.add(other);
      // ยอมรับเฉพาะตอน "กำลังลากจริง" — กันการวางเองตอนโหลด ถ้าไอเทมเริ่มเกม
      // โดยคาบเกี่ยวโซนพอดี (เช่นถ้วยผลไม้ที่โซนกินลงมาใกล้แถวไอเทม)
      if (_isBeingDragged) other.onInteractableEntered(this);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is DropZoneComponent) {
      _overlappingZones.remove(other);
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
