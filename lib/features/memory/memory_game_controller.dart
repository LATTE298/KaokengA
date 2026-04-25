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
    Random? random,
    int Function()? elapsedMs,
  }) : _elapsedMs = elapsedMs ?? (() => 0),
       tiles = _buildShuffledDeck(pack, random ?? Random());

  final int Function() _elapsedMs;
  final List<MemoryTileState> tiles;
  final List<MatchEvent> matchEvents = [];

  int? _firstFlippedIndex;
  bool locked = false;
  int? lastFirstIndex;
  int? lastSecondIndex;

  bool get allMatched => tiles.every((t) => t.matched);

  MemoryTapResult tapTile(int index) {
    if (locked) return const MemoryTapResult(accepted: false);

    final tile = tiles[index];
    if (tile.matched || tile.faceUp) {
      return const MemoryTapResult(accepted: false);
    }

    tile.faceUp = true;

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
    Random random,
  ) {
    final doubled = <MemoryTileState>[];
    for (final pair in pack.pairs) {
      doubled.add(MemoryTileState(pair: pair));
      doubled.add(MemoryTileState(pair: pair));
    }
    doubled.shuffle(random);
    return doubled;
  }
}
