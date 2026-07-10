import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:daily_life/game/daily_life_game.dart';
import 'package:daily_life/game/drop_zone_component.dart';
import 'package:daily_life/game/interactable_component.dart';
import 'package:daily_life/l10n/tts_strings_th.dart';
import 'package:daily_life/models/loaded_scenario_config.dart';
import 'package:daily_life/services/content_repository.dart';
import 'package:daily_life/services/tts_service.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

// เกมโหมด "คัดแยกครบทุกชิ้น" (sort-all) — ฉากแยกขยะ 4 ถัง / ผลไม้ลงถ้วย
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LoadedScenarioConfig> load(String scenarioId) async {
    final repo = AssetContentRepository();
    return repo.fetchLoadedScenarioConfig('assets/scenarios/$scenarioId.json');
  }

  DropZoneComponent zoneById(DailyLifeGame game, String id) => game.children
      .whereType<DropZoneComponent>()
      .firstWhere((z) => z.zoneId == id);

  InteractableComponent itemById(DailyLifeGame game, String id) => game.children
      .whereType<InteractableComponent>()
      .firstWhere((i) => i.config.id == id);

  test('ฉากแยกขยะ: ชิ้นผิดถังไม่ถูกรับ ชิ้นถูกถังวางสำเร็จ', () async {
    final loaded = await load('trash_sort_001');
    final game = DailyLifeGame(
      loadedScenario: loaded,
      tts: _FakeSpeaker(),
      reduceMotion: true,
      enablePromptTimers: false,
      onComplete: (_, __, ___) {},
    );
    game.onGameResize(Vector2(800, 450));
    await game.onLoad();

    expect(game.isSortAll, isTrue);
    final bottle = itemById(game, 'plastic_bottle');

    // ขวดพลาสติกลงถังขยะทั่วไป (ผิด) → โซนไม่รับ ยังไม่ settled
    zoneById(game, 'general').onInteractableEntered(bottle);
    expect(bottle.settled, isFalse);

    // ลงถังรีไซเคิล (ถูก) → วางสำเร็จ
    zoneById(game, 'recycle').onInteractableEntered(bottle);
    expect(bottle.settled, isTrue);

    // แตะซ้ำหลัง settle แล้วต้องไม่พังและไม่นับซ้ำ
    zoneById(game, 'recycle').onInteractableEntered(bottle);
    expect(bottle.settled, isTrue);
    game.onRemove();
  });

  test('ฉากแยกขยะ: เก็บครบ 4 ชิ้นจบเกม คะแนนตาม mistake', () async {
    final loaded = await load('trash_sort_001');
    final speaker = _FakeSpeaker();
    final completer = Completer<(int, int)>();
    final game = DailyLifeGame(
      loadedScenario: loaded,
      tts: speaker,
      reduceMotion: true,
      enablePromptTimers: false,
      onComplete: (_, score, stars) => completer.complete((score, stars)),
    );
    game.onGameResize(Vector2(800, 450));
    await game.onLoad();

    // จำลองวางผิด 1 ครั้ง (เด้งกลับ) ก่อนเก็บครบ
    game.mistakeCount = 1;

    for (final entry
        in const {
          'paper_ball': 'general',
          'battery': 'hazard',
          'plastic_bottle': 'recycle',
          'food_waste': 'organic',
        }.entries) {
      zoneById(
        game,
        entry.value,
      ).onInteractableEntered(itemById(game, entry.key));
    }

    final (score, stars) = await completer.future.timeout(
      const Duration(seconds: 5),
    );
    expect(score, 8); // ผิด 1 ครั้ง
    expect(stars, 2);
    // 3 ชิ้นแรกชมระหว่างทาง — ชิ้นสุดท้ายปล่อยให้เสียงฉลองใหญ่พูดแทน
    expect(speaker.spoken.where((s) => s == kTtsQuizCorrect), hasLength(3));
    game.onRemove();
  });

  test('ฉากผลไม้: สุ่มโจทย์ 2 ชนิด — นอกโจทย์โดนปฏิเสธ ครบ 2 จบเกม', () async {
    final loaded = await load('food_prep_001');
    final completer = Completer<(int, int)>();
    final game = DailyLifeGame(
      loadedScenario: loaded,
      tts: _FakeSpeaker(),
      reduceMotion: true,
      enablePromptTimers: false,
      random: Random(7),
      onComplete: (_, score, stars) => completer.complete((score, stars)),
    );
    game.onGameResize(Vector2(800, 450));
    await game.onLoad();

    final wanted = game.wantedIds;
    expect(wanted, isNotNull);
    expect(wanted, hasLength(2)); // pick_count = 2

    final bowl = zoneById(game, 'bowl');
    final items = game.children.whereType<InteractableComponent>().toList();
    expect(items, hasLength(4));

    // ชิ้นนอกโจทย์ลงถ้วย → โดนปฏิเสธ (ไม่ settled)
    final unwanted = items.firstWhere((i) => !wanted!.contains(i.config.id));
    bowl.onInteractableEntered(unwanted);
    expect(unwanted.settled, isFalse);

    // ชิ้นในโจทย์ทั้งสอง → รับ + กระจายตำแหน่งไม่ทับกัน + จบเกม
    final wantedItems =
        items.where((i) => wanted!.contains(i.config.id)).toList();
    for (final item in wantedItems) {
      bowl.onInteractableEntered(item);
    }
    expect(wantedItems.every((i) => i.settled), isTrue);
    final positions = wantedItems.map((i) => '${i.position.x},${i.position.y}');
    expect(positions.toSet(), hasLength(2));

    final (score, stars) = await completer.future.timeout(
      const Duration(seconds: 5),
    );
    expect(score, 10); // ไม่มี mistake
    expect(stars, 3);
    game.onRemove();
  });

  test('ฉากผลไม้: ประโยคโจทย์ทุกคู่ที่สุ่มได้ มีคลิปใน tts_manifest', () async {
    final loaded = await load('food_prep_001');
    final ids = loaded.config.interactables.map((i) => i.id).toList();
    final manifest =
        jsonDecode(File('assets/tts/tts_manifest.json').readAsStringSync())
            as Map<String, dynamic>;
    final clips = manifest['clips'] as Map<String, dynamic>;

    for (var a = 0; a < ids.length; a++) {
      for (var b = a + 1; b < ids.length; b++) {
        final sentence = ttsFruitPickAsk(
          scenarioItemNameTh(ids[a]),
          scenarioItemNameTh(ids[b]),
        );
        expect(
          clips.containsKey(sentence),
          isTrue,
          reason: 'ขาดคลิปโจทย์: $sentence',
        );
      }
    }
  });

  test(
    'ฉากผลไม้: instructionText ตรงกับคู่ที่สุ่มได้ (เรียงตามลำดับ JSON)',
    () async {
      final loaded = await load('food_prep_001');
      final game = DailyLifeGame(
        loadedScenario: loaded,
        tts: _FakeSpeaker(),
        reduceMotion: true,
        enablePromptTimers: false,
        random: Random(3),
        onComplete: (_, __, ___) {},
      );
      final wanted = game.wantedIds!;
      expect(
        game.instructionText,
        ttsFruitPickAsk(
          scenarioItemNameTh(wanted[0]),
          scenarioItemNameTh(wanted[1]),
        ),
      );
      // ลำดับใน wantedIds ต้องตามลำดับไอเทมใน JSON (กันประโยค/คลิปสลับคู่)
      final order = loaded.config.interactables.map((i) => i.id).toList();
      expect(order.indexOf(wanted[0]) < order.indexOf(wanted[1]), isTrue);
    },
  );
}

class _FakeSpeaker implements TtsSpeaker {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}
}
