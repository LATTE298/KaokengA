import 'dart:math';

import 'package:daily_life/features/memory/memory_game_controller.dart';
import 'package:daily_life/models/memory_pack.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryGameController', () {
    test('builds exactly two tiles per pair', () {
      final controller = MemoryGameController(pack: _pack(), random: Random(1));

      expect(controller.tiles, hasLength(4));
      expect(
        controller.tiles.where((tile) => tile.pair.id == 'cat'),
        hasLength(2),
      );
      expect(
        controller.tiles.where((tile) => tile.pair.id == 'dog'),
        hasLength(2),
      );
    });

    test('first tap flips one tile and records no event', () {
      final controller = MemoryGameController(pack: _pack(), random: Random(1));

      final result = controller.tapTile(0);

      expect(result.accepted, isTrue);
      expect(controller.tiles[0].faceUp, isTrue);
      expect(controller.matchEvents, isEmpty);
    });

    test('matching second tap marks both matched and records success', () {
      var elapsed = 2500;
      final controller = MemoryGameController(
        pack: _pack(),
        random: Random(1),
        elapsedMs: () => elapsed,
      );
      final indices = _indicesForPair(controller, 'cat');

      controller.tapTile(indices.first);
      final result = controller.tapTile(indices.last);

      expect(result.matched, isTrue);
      expect(controller.tiles[indices.first].matched, isTrue);
      expect(controller.tiles[indices.last].matched, isTrue);
      expect(controller.matchEvents.single.pairId, 'cat');
      expect(controller.matchEvents.single.matched, isTrue);
      expect(controller.matchEvents.single.atMs, 2500);
    });

    test('non-matching second tap locks board and records failure', () {
      final controller = MemoryGameController(
        pack: _pack(),
        random: Random(1),
        elapsedMs: () => 3200,
      );
      final firstCat = _indicesForPair(controller, 'cat').first;
      final firstDog = _indicesForPair(controller, 'dog').first;

      controller.tapTile(firstCat);
      final result = controller.tapTile(firstDog);

      expect(result.mismatched, isTrue);
      expect(controller.locked, isTrue);
      expect(controller.matchEvents.single.pairId, 'dog');
      expect(controller.matchEvents.single.matched, isFalse);
      expect(controller.matchEvents.single.atMs, 3200);
    });

    test('flipBackLastMismatch clears only unmatched face-up tiles', () {
      final controller = MemoryGameController(pack: _pack(), random: Random(1));
      final catIndices = _indicesForPair(controller, 'cat');
      final firstDog = _indicesForPair(controller, 'dog').first;

      controller.tapTile(catIndices.first);
      controller.tapTile(catIndices.last);
      controller.tapTile(firstDog);
      controller.flipBackLastMismatch();

      expect(controller.tiles[catIndices.first].faceUp, isTrue);
      expect(controller.tiles[catIndices.last].faceUp, isTrue);
      expect(controller.tiles[firstDog].faceUp, isFalse);
      expect(controller.locked, isFalse);
    });

    test('completion is true only when all pairs are matched', () {
      final controller = MemoryGameController(pack: _pack(), random: Random(1));
      final catIndices = _indicesForPair(controller, 'cat');
      final dogIndices = _indicesForPair(controller, 'dog');

      final firstMatch =
          controller
            ..tapTile(catIndices.first)
            ..tapTile(catIndices.last);

      expect(firstMatch.allMatched, isFalse);

      controller.tapTile(dogIndices.first);
      final result = controller.tapTile(dogIndices.last);

      expect(result.completed, isTrue);
      expect(controller.allMatched, isTrue);
    });

    test('samples 8 pairs per round from a larger pack', () {
      // แพ็คจากคลังคำมี ~15 คู่/หมวด — กระดาน 4×4 ต้องสุ่มหยิบแค่ 8 คู่
      final bigPack = MemoryPack(
        packId: 'memory_animals',
        titleTh: 'สัตว์',
        pairs: [
          for (var i = 0; i < 15; i++)
            MemoryPair(
              id: 'animal_$i',
              image: 'assets/images/vocab/animal_$i.png',
              ttsName: 'สัตว์$i',
            ),
        ],
      );

      final controller = MemoryGameController(pack: bigPack, random: Random(1));

      expect(controller.tiles, hasLength(16));
      final pairIds = controller.tiles.map((t) => t.pair.id).toSet();
      expect(pairIds, hasLength(8), reason: '8 คู่ไม่ซ้ำกัน คู่ละ 2 ใบ');

      // สุ่มจริง: seed ต่างกันควรได้ชุดคู่ต่างกัน (เทียบกับอีก seed)
      final other = MemoryGameController(pack: bigPack, random: Random(2));
      final otherIds = other.tiles.map((t) => t.pair.id).toSet();
      expect(otherIds, isNot(equals(pairIds)));
    });
  });

  group('คะแนนเชิงบวก (feedback ครู 2026-07-12)', () {
    test('จบไม่มีจับผิด = 10 คะแนน 3 ดาว', () {
      final c = MemoryGameController(pack: _pack(), random: Random(1));
      expect(c.mismatches, 0);
      expect(c.score, 10);
      expect(c.starRating, 3);
    });

    test('จับผิดเยอะยังได้อย่างน้อย 2 ดาว (ไม่ลงโทษการเปิดซ้ำ)', () {
      final c = MemoryGameController(
        pack: _pack(),
        pairCount: 2,
        random: Random(1),
      );
      c.matchEvents.addAll([
        for (var i = 0; i < 9; i++)
          MatchEvent(pairId: 'x', matched: false, atMs: 0),
      ]);
      expect(c.mismatches, 9);
      expect(c.score, 6); // ผิด > จำนวนคู่ → 6 (ไม่ต่ำกว่านี้)
      expect(c.starRating, 2); // ขั้นต่ำ 2 ดาวเสมอ
    });
  });
}

MemoryPack _pack() {
  return const MemoryPack(
    packId: 'thai_animals',
    titleTh: 'สัตว์',
    pairs: [
      MemoryPair(id: 'cat', image: 'assets/images/cat.webp', ttsName: 'แมว'),
      MemoryPair(id: 'dog', image: 'assets/images/dog.webp', ttsName: 'หมา'),
    ],
  );
}

List<int> _indicesForPair(MemoryGameController controller, String pairId) {
  final indices = <int>[];
  for (var i = 0; i < controller.tiles.length; i++) {
    if (controller.tiles[i].pair.id == pairId) indices.add(i);
  }
  return indices;
}
