import 'dart:math';

import 'package:flame/components.dart';

import 'game_asset_paths.dart';
import 'placeholder_renderer.dart';

class BackgroundComponent extends PositionComponent with HasGameReference {
  BackgroundComponent({
    required this.imagePath,
    required this.placeholderImagePaths,
    this.coverFit = false,
  }) : super(priority: 0);

  final String imagePath;
  final Set<String> placeholderImagePaths;

  /// true = สเกลรูปแบบ cover (รักษาสัดส่วน เต็มจอ ครอปส่วนเกิน) — ไม่ยืดภาพ
  /// ทำให้ภาพบนแท็บเล็ต/iPad ไม่เพี้ยน. false = ยืดเต็มจอ (พฤติกรรมเดิม)
  final bool coverFit;

  SpriteComponent? _sprite;
  Vector2 _imageSize = Vector2.zero();

  @override
  Future<void> onLoad() async {
    size = game.size;
    if (placeholderImagePaths.contains(imagePath)) {
      await add(
        PlaceholderComponent(size: size, label: 'background', priority: 0),
      );
      return;
    }

    final image = await game.images.load(flameImageKey(imagePath));
    _imageSize = Vector2(image.width.toDouble(), image.height.toDouble());
    _sprite = SpriteComponent(sprite: Sprite(image), size: size);
    await add(_sprite!);
    _layout();
  }

  // cover = รักษาสัดส่วน+ครอปส่วนเกิน (จัดกึ่งกลาง), ปกติ = ยืดเต็มจอ
  void _layout() {
    final sprite = _sprite;
    if (sprite == null) return;
    if (coverFit && _imageSize.x > 0 && _imageSize.y > 0) {
      final scale = max(size.x / _imageSize.x, size.y / _imageSize.y);
      final rendered = _imageSize * scale;
      sprite.size = rendered;
      sprite.position = (size - rendered) / 2;
    } else {
      sprite.size = size;
      sprite.position = Vector2.zero();
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (_sprite == null) {
      // placeholder (ยังไม่มี sprite) — ครอบเต็มจอเหมือนเดิม
      for (final child in children.whereType<PositionComponent>()) {
        child.size = size;
      }
    } else {
      _layout();
    }
  }
}
