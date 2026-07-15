import 'dart:typed_data';

import 'package:daily_life/game/background_component.dart';
import 'package:daily_life/game/daily_life_game.dart';
import 'package:daily_life/game/drop_zone_component.dart';
import 'package:daily_life/game/interactable_component.dart';
import 'package:daily_life/game/placeholder_renderer.dart';
import 'package:daily_life/services/content_repository.dart';
import 'package:daily_life/services/tts_service.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'each bundled scenario renders placeholder-compatible Flame components',
    () async {
      final repo = AssetContentRepository();
      final scenarios = await repo.fetchScenarioIndex();

      expect(scenarios, isNotEmpty);

      for (final summary in scenarios) {
        final loaded = await repo.fetchLoadedScenarioConfig(summary.configUrl);
        final game = DailyLifeGame(
          loadedScenario: loaded,
          tts: _testTtsService(),
          reduceMotion: true,
          enablePromptTimers: false,
          onComplete: (_, __, ___) {},
        );

        game.onGameResize(Vector2(800, 450));
        await game.onLoad();

        expect(
          game.children.whereType<BackgroundComponent>(),
          hasLength(1),
          reason: summary.scenarioId,
        );
        // ฉากโหมดเดิมมีโซนเดียว (ตะกร้า) — ฉาก sort-all มีโซนตาม zones ใน JSON
        // (เช่น แยกขยะ = ถัง 4 ใบ, ผลไม้ = ถ้วย 1 ใบ)
        final expectedZones =
            loaded.config.zones.isEmpty ? 1 : loaded.config.zones.length;
        expect(
          game.children.whereType<DropZoneComponent>(),
          hasLength(expectedZones),
          reason: summary.scenarioId,
        );
        // โหมดซื้อของสุ่มโชว์แค่ display_count ชิ้นจาก pool — โหมดอื่นโชว์ครบทุกชิ้น
        final expectedItems =
            loaded.config.shopMode
                ? (loaded.config.displayCount ??
                    loaded.config.interactables.length)
                : loaded.config.interactables.length;
        expect(
          game.children.whereType<InteractableComponent>(),
          hasLength(expectedItems),
          reason: summary.scenarioId,
        );
        // PlaceholderComponent เกิดเฉพาะรูปที่ประกาศใน placeholder manifest —
        // รูปที่มีไฟล์จริงแล้ว (เช่น ฉากเซเว่น) ต้องเรนเดอร์เป็น Sprite แทน
        final expectedPlaceholders =
            (loaded.usesPlaceholder(loaded.config.backgroundImage) ? 1 : 0) +
            loaded.config.interactables
                .where((i) => loaded.usesPlaceholder(i.image))
                .length;
        expect(
          game.descendants().whereType<PlaceholderComponent>().length,
          expectedPlaceholders,
          reason: summary.scenarioId,
        );

        game.onRemove();
      }
    },
  );
}

TtsService _testTtsService() {
  return TtsService(
    client: const NoOpTtsClient(),
    cache: _NoOpTtsCache(),
    player: _NoOpTtsAudioPlayer(),
  );
}

class _NoOpTtsCache implements TtsAudioCache {
  @override
  Future<void> enforceMaxSize() async {}

  @override
  Future<Uint8List?> get(String key) async {
    throw StateError('The render smoke test should not request TTS audio.');
  }

  @override
  Future<void> put(String key, Uint8List bytes) async {
    throw StateError('The render smoke test should not cache TTS audio.');
  }
}

class _NoOpTtsAudioPlayer implements TtsAudioPlayer {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> playBytes(Uint8List bytes) async {}

  @override
  Future<void> stop() async {}
}
