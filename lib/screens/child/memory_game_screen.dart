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
import '../../widgets/child/game_result_dialog.dart';
import '../../widgets/child/pressable_child_card.dart';

// Memory game — 4×4 grid, สุ่ม 8 คู่จากแพ็คของหมวดที่เลือก (spec 03 Flow 2).
class MemoryGameScreen extends ConsumerWidget {
  const MemoryGameScreen({super.key, required this.packId});

  final String packId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPack = ref.watch(memoryPackProvider(packId));

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
  bool _resultShown = false;

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
    // หมายเหตุ: ไม่ต้องเรียก HapticService.tapLight() ซ้ำที่นี่แล้ว เพราะ PressableChildCard
    // ที่ครอบการ์ดแต่ละใบใน _MemoryTileView สั่นให้แล้วตั้งแต่ตอนแตะติด (spec 1.3)
    setState(() {});

    // TTS: หนึ่งเหตุการณ์พูดครั้งเดียว — speak ครั้งใหม่ตัดเสียงก่อนหน้าเสมอ การยิงติดกัน
    // หลายครั้ง (ชื่อคู่ → จับคู่ได้ → จับคู่ครบ) จะเหลือแต่คำสุดท้าย คำอื่นโดนตัดทิ้งหมด
    final pairName = result.pairName;
    if (result.matched) {
      // Match (spec 03 Flow 2 §4 MATCH).
      HapticService.memoryMatch();
      if (result.completed) {
        _onComplete(); // พูด kTtsMemoryComplete ที่เดียวใน _onComplete
      } else {
        ref
            .read(ttsServiceProvider)
            .speak(
              pairName == null
                  ? kTtsMemoryMatch
                  : ttsMemoryMatchNamed(pairName),
            );
      }
    } else {
      if (pairName != null) {
        ref.read(ttsServiceProvider).speak(pairName);
      }
      if (result.mismatched) {
        // No match — hold both face-up 1.2s, then flip back (spec 03 Flow 2 §4).
        Future<void>.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(_controller.flipBackLastMismatch);
        });
      }
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

    // หน่วงเล็กน้อยให้ TTS คำว่า "จับคู่ครบแล้ว" เล่นจบก่อนเด้ง popup
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted || _resultShown) return;
    _resultShown = true;
    _showResultDialog();
  }

  void _showResultDialog() {
    final stars = _controller.starRating;
    final score = _controller.score;

    HapticService.success();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => GameResultDialog(
            stars: stars,
            score: score,
            detail: 'เปิดการ์ดทั้งหมด ${_controller.totalFlips} ครั้ง',
            onClose: () {
              Navigator.of(context).pop(); // ปิด dialog
              if (context.mounted && context.canPop())
                context.pop(); // กลับหน้าหลัก
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // เผื่อพื้นที่ปุ่มย้อนกลับด้านบนซ้าย (64dp) และ padding รอบขอบเล็กน้อย
        const horizontalPadding = kSpace4;
        const topPadding = kSpace2;
        const bottomPadding = kSpace2;
        const crossAxisCount = 4;
        const rowCount = 4;
        const spacing = kSpace2;

        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final availableHeight =
            constraints.maxHeight - topPadding - bottomPadding;

        // คำนวณขนาดการ์ดให้พอดีทั้งความกว้างและความสูงของจอเสมอ
        // ป้องกันปัญหาการ์ดล้นจอจนต้องเลื่อนดู (spec 1.3 — ปรับ UI ให้เหมาะเด็ก).
        final tileWidth =
            (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
        final tileHeight =
            (availableHeight - spacing * (rowCount - 1)) / rowCount;
        final tileSize = tileWidth < tileHeight ? tileWidth : tileHeight;

        final gridWidth =
            tileSize * crossAxisCount + spacing * (crossAxisCount - 1);
        final gridHeight = tileSize * rowCount + spacing * (rowCount - 1);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: Center(
            child: SizedBox(
              width: gridWidth,
              height: gridHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.tiles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemBuilder:
                    (context, i) => _MemoryTileView(
                      tile: _controller.tiles[i],
                      onTap: () => _onTileTap(i),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemoryTileView extends StatelessWidget {
  const _MemoryTileView({required this.tile, required this.onTap});
  final MemoryTileState tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFaceUp = tile.faceUp || tile.matched;
    // เปลี่ยนจาก GestureDetector ตรงๆ มาใช้ PressableChildCard (spec 1.3) เพื่อให้การ์ด
    // ทุกใบในกระดานมี press feedback (ขยาย+หรี่แสงเล็กน้อยตอนกดค้าง) และ haptic ที่สม่ำเสมอ
    // กับการ์ดอื่นๆทั้งแอป โดยไม่ต้องเขียน animation feedback ซ้ำเอง — ปิด min-tap-target
    // เพราะตัวการ์ดเองคำนวณขนาดให้เต็มช่อง grid อยู่แล้วเสมอ ใหญ่กว่า 64dp อยู่แล้วทุกกรณี
    return PressableChildCard(
      onTap: onTap,
      enforceMinTapTarget: false,
      scale: 1.03,
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
        // หน้าการ์ดเปิด = รูปจริงจากคลังคำศัพท์ (แทนอิโมจิเดิม — รูปทีมมาแล้ว)
        child:
            isFaceUp
                ? Padding(
                  padding: const EdgeInsets.all(kSpace2),
                  child: Image.asset(
                    tile.pair.image,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Center(
                          child: Icon(
                            Icons.image_rounded,
                            size: 40,
                            color: kTextSecondary,
                          ),
                        ),
                  ),
                )
                : Center(
                  child: Icon(
                    Icons.star_rounded,
                    size: 40,
                    color: kYellowPrimary.withValues(alpha: 0.8),
                  ),
                ),
      ),
    );
  }
}
