import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/memory/memory_game_controller.dart';
import '../../features/sessions/session_recorder.dart';
import '../../l10n/tts_strings_th.dart';
import '../../models/app_types.dart';
import '../../models/memory_pack.dart';
import '../../providers/content_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/tts_provider.dart';
import '../../services/haptic_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';
import '../../widgets/child/child_async_view.dart';

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
            ChildAsyncView(
              value: asyncPack,
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
  late final MemoryGameController _controller;
  late final ActiveSession _session;

  @override
  void initState() {
    super.initState();
    _session = ref.read(
      activeSessionProvider(
        ActiveSessionKey(module: kModuleMemory, contentId: widget.pack.packId),
      ),
    );
    _controller = MemoryGameController(
      pack: widget.pack,
      elapsedMs:
          () =>
              ref
                  .read(clockProvider)()
                  .toUtc()
                  .difference(_session.startedAt)
                  .inMilliseconds,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(kTtsMemoryStart);
    });
  }

  void _onTileTap(int idx) {
    final result = _controller.tapTile(idx);
    if (!result.accepted) {
      return;
    }
    HapticService.tapLight();
    setState(() {});

    final pairName = result.pairName;
    if (pairName != null) {
      ref.read(ttsServiceProvider).speak(pairName);
    }
    if (result.matched) {
      // Match (spec 03 Flow 2 §4 MATCH).
      HapticService.memoryMatch();
      ref.read(ttsServiceProvider).speak(kTtsMemoryMatch);
      if (result.completed) _onComplete();
    } else if (result.mismatched) {
      // No match — hold both face-up 1.2s, then flip back (spec 03 Flow 2 §4).
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(_controller.flipBackLastMismatch);
      });
    }
  }

  Future<void> _onComplete() async {
    ref.read(ttsServiceProvider).speak(kTtsMemoryComplete);

    ref
        .read(sessionRecorderProvider)
        .recordMemoryCompleted(
          MemoryCompletedEvent(
            session: _session,
            pack: widget.pack,
            matchEvents: _controller.matchEvents,
          ),
        );

    await Future<void>.delayed(const Duration(seconds: 4));
    if (mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpace12, kSpace10, kSpace8, kSpace6),
      child: GridView.builder(
        itemCount: _controller.tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: kSpace3,
          crossAxisSpacing: kSpace3,
        ),
        itemBuilder:
            (context, i) => _MemoryTileView(
              tile: _controller.tiles[i],
              onTap: () => _onTileTap(i),
            ),
      ),
    );
  }
}

class _MemoryTileView extends StatelessWidget {
  const _MemoryTileView({required this.tile, required this.onTap});
  final MemoryTileState tile;
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
