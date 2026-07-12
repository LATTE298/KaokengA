import 'dart:math';

import '../../models/memory_pack.dart';
import '../../models/session_record.dart';

class MemoryTileState {
  MemoryTileState({required this.pair});

  final MemoryPair pair;
  bool faceUp = false;
  bool matched = false;
}

class MemoryTapResult {
  const MemoryTapResult({
    required this.accepted,
    this.pairName,
    this.matchEvent,
    this.matched = false,
    this.mismatched = false,
    this.completed = false,
  });

  final bool accepted;
  final String? pairName;
  final MatchEvent? matchEvent;
  final bool matched;
  final bool mismatched;
  final bool completed;
}

class MemoryGameController {
  MemoryGameController({
    required MemoryPack pack,
    this.pairCount = 8,
    Random? random,
    int Function()? elapsedMs,
  }) : _elapsedMs = elapsedMs ?? (() => 0),
       tiles = _buildShuffledDeck(pack, pairCount, random ?? Random());

  /// จำนวนคู่ต่อรอบ (กระดาน 4×4 = 8 คู่) — แพ็คจากคลังคำมี ~15 คู่/หมวด
  /// จึงสุ่มหยิบมาเล่นรอบละ 8 ให้เล่นซ้ำแล้วเจอไม่ซ้ำหน้าเดิม
  final int pairCount;

  final int Function() _elapsedMs;
  final List<MemoryTileState> tiles;
  final List<MatchEvent> matchEvents = [];

  int? _firstFlippedIndex;
  bool locked = false;
  int? lastFirstIndex;
  int? lastSecondIndex;

  // จำนวนครั้งทั้งหมดที่ผู้เล่นเปิดการ์ด (นับทุกใบที่ถูกเปิด ไม่ใช่แค่คู่)
  int totalFlips = 0;

  bool get allMatched => tiles.every((t) => t.matched);

  MemoryTapResult tapTile(int index) {
    if (locked) return const MemoryTapResult(accepted: false);

    final tile = tiles[index];
    if (tile.matched || tile.faceUp) {
      return const MemoryTapResult(accepted: false);
    }

    tile.faceUp = true;
    totalFlips++;

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
      lastFirstIndex = index;
      lastSecondIndex = null;
      return MemoryTapResult(accepted: true, pairName: tile.pair.ttsName);
    }

    final firstIndex = _firstFlippedIndex!;
    final first = tiles[firstIndex];
    _firstFlippedIndex = null;
    lastFirstIndex = firstIndex;
    lastSecondIndex = index;

    if (first.pair.id == tile.pair.id) {
      first.matched = true;
      tile.matched = true;
      final event = MatchEvent(
        pairId: tile.pair.id,
        matched: true,
        atMs: _elapsedMs(),
      );
      matchEvents.add(event);
      return MemoryTapResult(
        accepted: true,
        pairName: tile.pair.ttsName,
        matchEvent: event,
        matched: true,
        completed: allMatched,
      );
    }

    locked = true;
    final event = MatchEvent(
      pairId: tile.pair.id,
      matched: false,
      atMs: _elapsedMs(),
    );
    matchEvents.add(event);
    return MemoryTapResult(
      accepted: true,
      pairName: tile.pair.ttsName,
      matchEvent: event,
      mismatched: true,
    );
  }

  void flipBackLastMismatch() {
    final firstIndex = lastFirstIndex;
    final secondIndex = lastSecondIndex;
    if (firstIndex != null) {
      final first = tiles[firstIndex];
      if (!first.matched) first.faceUp = false;
    }
    if (secondIndex != null) {
      final second = tiles[secondIndex];
      if (!second.matched) second.faceUp = false;
    }
    locked = false;
  }

  static List<MemoryTileState> _buildShuffledDeck(
    MemoryPack pack,
    int pairCount,
    Random random,
  ) {
    final pool = [...pack.pairs]..shuffle(random);
    final selected = pool.take(min(pairCount, pool.length));
    final doubled = <MemoryTileState>[];
    for (final pair in selected) {
      doubled.add(MemoryTileState(pair: pair));
      doubled.add(MemoryTileState(pair: pair));
    }
    doubled.shuffle(random);
    return doubled;
  }

  /// จำนวนครั้งที่จับผิดคู่ (พลิกแล้วไม่เข้าคู่)
  int get mismatches => matchEvents.where((e) => !e.matched).length;

  /// คะแนนเชิงบวก (feedback ครูโรงเรียนเด็กดาวน์ 2026-07-12): **เลิกหักคะแนนตามจำนวน
  /// ครั้งที่เปิดซ้ำ** เพราะบั่นทอนกำลังใจ. จับคู่ครบ = สำเร็จเสมอ — จับผิดน้อย = เต็ม,
  /// ผิดเยอะก็ยังได้คะแนนกำลังใจ (ขั้นต่ำ 6 "พอใช้" ไม่มี 4 อีกต่อไป)
  int get score {
    if (mismatches == 0) return 10;
    if (mismatches <= pairCount) return 8;
    return 6;
  }

  /// ดาว 0-3 ดวง — **ขั้นต่ำ 2 ดวงเสมอเมื่อเล่นจบ** (ไม่ให้ 0 ดาวมาลดกำลังใจเด็ก)
  int get starRating => score >= 8 ? 3 : 2;
}
