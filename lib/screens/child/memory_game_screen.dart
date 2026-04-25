import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../l10n/tts_strings_th.dart';
import '../../models/memory_pack.dart';
import '../../models/session_record.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/tts_provider.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';

// Memory game — 4×4 grid, 8 pairs (spec 03 Flow 2).
class MemoryGameScreen extends ConsumerWidget {
  const MemoryGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPack = ref.watch(memoryPackProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            asyncPack.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (_, __) =>
                      Center(child: Text('โหลดไม่สำเร็จ', style: kTextLg)),
              data: (pack) => _MemoryBoard(pack: pack),
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}

class _MemoryBoard extends ConsumerStatefulWidget {
  const _MemoryBoard({required this.pack});
  final MemoryPack pack;

  @override
  ConsumerState<_MemoryBoard> createState() => _MemoryBoardState();
}

class _MemoryBoardState extends ConsumerState<_MemoryBoard> {
  late final List<_Tile> _tiles;
  late final DateTime _startedAt;
  final List<MatchEvent> _matchEvents = [];
  int? _firstFlippedIndex;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _tiles = _buildShuffledDeck(widget.pack);
    _startedAt = DateTime.now().toUtc();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(kTtsMemoryStart);
    });
  }

  List<_Tile> _buildShuffledDeck(MemoryPack pack) {
    final doubled = <_Tile>[];
    for (final pair in pack.pairs) {
      doubled.add(_Tile(pair: pair));
      doubled.add(_Tile(pair: pair));
    }
    doubled.shuffle(Random());
    return doubled;
  }

  bool get _allMatched => _tiles.every((t) => t.matched);

  void _onTileTap(int idx) {
    if (_locked) return;
    final tile = _tiles[idx];
    if (tile.matched || tile.faceUp) return;

    HapticService.tapLight();
    setState(() => tile.faceUp = true);
    ref.read(ttsServiceProvider).speak(tile.pair.ttsName);

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = idx;
      return;
    }

    final firstIdx = _firstFlippedIndex!;
    _firstFlippedIndex = null;
    final first = _tiles[firstIdx];

    final elapsedMs =
        DateTime.now().toUtc().difference(_startedAt).inMilliseconds;
    if (first.pair.id == tile.pair.id) {
      // Match (spec 03 Flow 2 §4 MATCH).
      _matchEvents.add(
        MatchEvent(pairId: tile.pair.id, matched: true, atMs: elapsedMs),
      );
      setState(() {
        first.matched = true;
        tile.matched = true;
      });
      HapticService.memoryMatch();
      ref.read(ttsServiceProvider).speak(kTtsMemoryMatch);
      if (_allMatched) _onComplete();
    } else {
      _matchEvents.add(
        MatchEvent(pairId: tile.pair.id, matched: false, atMs: elapsedMs),
      );
      // No match — hold both face-up 1.2s, then flip back (spec 03 Flow 2 §4).
      _locked = true;
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          first.faceUp = false;
          tile.faceUp = false;
          _locked = false;
        });
      });
    }
  }

  Future<void> _onComplete() async {
    ref.read(ttsServiceProvider).speak(kTtsMemoryComplete);

    final uid = ref.read(uidProvider);
    if (uid != null) {
      final endedAt = DateTime.now().toUtc();
      final totalPairs = widget.pack.pairs.length;
      final record = SessionRecord(
        sessionId: const Uuid().v4(),
        uid: uid,
        scenarioId: widget.pack.packId,
        module: 'memory',
        startedAt: _startedAt.toIso8601String(),
        endedAt: endedAt.toIso8601String(),
        durationMs: endedAt.difference(_startedAt).inMilliseconds,
        completed: true,
        pairsMatched: totalPairs,
        totalPairs: totalPairs,
        matchEvents: List.unmodifiable(_matchEvents),
      );
      ref.read(sessionRepositoryProvider).writeSession(record);
    }

    await Future<void>.delayed(const Duration(seconds: 4));
    if (mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpace12, kSpace10, kSpace8, kSpace6),
      child: GridView.builder(
        itemCount: _tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: kSpace3,
          crossAxisSpacing: kSpace3,
        ),
        itemBuilder:
            (context, i) =>
                _MemoryTileView(tile: _tiles[i], onTap: () => _onTileTap(i)),
      ),
    );
  }
}

class _Tile {
  _Tile({required this.pair});
  final MemoryPair pair;
  bool faceUp = false;
  bool matched = false;
}

class _MemoryTileView extends StatelessWidget {
  const _MemoryTileView({required this.tile, required this.onTap});
  final _Tile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color:
              tile.matched
                  ? kYellowLight
                  : (tile.faceUp ? kBlueLight : kBluePrimary),
          borderRadius: kRadiusMd,
          boxShadow: const [kShadowSm],
        ),
        child: Center(
          child:
              tile.faceUp || tile.matched
                  ? Text(tile.pair.ttsName, style: kChildLabel)
                  : Icon(
                    Icons.star_rounded,
                    size: 48,
                    color: kYellowPrimary.withValues(alpha: 0.8),
                  ),
        ),
      ),
    );
  }
}
