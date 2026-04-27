import 'package:flame/components.dart';

import 'game_asset_paths.dart';
import 'placeholder_renderer.dart';

class BackgroundComponent extends PositionComponent with HasGameReference {
  BackgroundComponent({
    required this.imagePath,
    required this.placeholderImagePaths,
  }) : super(priority: 0);

  final String imagePath;
  final Set<String> placeholderImagePaths;

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
    await add(SpriteComponent(sprite: Sprite(image), size: size));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    for (final child in children.whereType<PositionComponent>()) {
      child.size = size;
    }
  }
}
