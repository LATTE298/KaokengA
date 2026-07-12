import 'dart:async';
import 'dart:math' as math;

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
import '../../providers/sfx_provider.dart';
import '../../providers/tts_provider.dart';
import '../../services/haptic_service.dart';
import '../../services/sfx_player.dart';
import '../../theme/colors.dart';
import '../../widgets/child/paper_background.dart';
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
            const Positioned.fill(child: PaperBackground()),
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
      ref.read(sfxPlayerProvider).play(kSfxRight);
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
        // จงใจไม่มีเสียง "ผิด" ที่เกมจับคู่ — เกมนี้ผิดบ่อยโดยธรรมชาติ เสียงผิดจะ
        // กดดันเด็ก (ผู้ใช้กำหนด) เปิดการ์ดค้าง 1.2 วิ แล้วพลิกกลับ (spec 03 Flow 2 §4)
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
              if (context.mounted && context.canPop()) {
                context.pop(); // กลับหน้าหลัก
              }
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
    // PressableChildCard ให้ press feedback + haptic สม่ำเสมอกับการ์ดอื่นทั้งแอป (spec 1.3)
    // ปิด min-tap-target เพราะการ์ดคำนวณขนาดเต็มช่อง grid อยู่แล้ว (ใหญ่กว่า 64dp)
    return PressableChildCard(
      onTap: onTap,
      enforceMinTapTarget: false,
      scale: 1.03,
      // พลิกการ์ดแบบ 3D (หมุนรอบแกน Y จริง): ครึ่งแรกยังเห็นด้านหลัง พอเลยครึ่งทาง
      // ค่อยสลับเป็นด้านหน้าแล้วกลับด้านไม่ให้ภาพมิเรอร์ — ให้ความรู้สึกพลิกการ์ดจริง
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isFaceUp ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        builder: (context, t, _) {
          final showFront = t >= 0.5;
          final face =
              showFront
                  ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _FrontFace(tile: tile),
                  )
                  : const _BackFace();
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.0012) // perspective เล็กน้อยให้ดูมีมิติ
                  ..rotateY(t * math.pi),
            child: face,
          );
        },
      ),
    );
  }
}

// ด้านหลังการ์ด (คว่ำ) — ไล่เฉดฟ้า + ดาวใหญ่กลาง + ประกายมุม ดูมีมิติน่ากดพลิก
class _BackFace extends StatelessWidget {
  const _BackFace();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBluePrimary, kBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: kRadiusLg,
        boxShadow: const [kShadowMd],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: FittedBox(
            child: Icon(Icons.star_rounded, color: kYellowPrimary),
          ),
        ),
      ),
    );
  }
}

// ด้านหน้าการ์ด (หงาย) — พื้นขาว (เขียวอ่อนตอนจับคู่ได้) + กรอบเน้น + รูปใหญ่เกือบเต็มการ์ด
class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.tile});
  final MemoryTileState tile;

  @override
  Widget build(BuildContext context) {
    final matched = tile.matched;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: matched ? kSuccessLight : Colors.white,
        borderRadius: kRadiusLg,
        boxShadow: const [kShadowMd],
        border: Border.all(
          color: matched ? kSuccess : kBlueLight,
          width: matched ? 3 : 2,
        ),
      ),
      // รูปเต็มการ์ด (cover) ให้ใหญ่ชัด — clip ตามมุมโค้งการ์ด กันภาพล้นมุม
      child: ClipRRect(
        borderRadius: kRadiusLg,
        child: Image.asset(
          tile.pair.image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder:
              (_, __, ___) => const Center(
                child: Icon(
                  Icons.image_rounded,
                  size: 40,
                  color: kTextSecondary,
                ),
              ),
        ),
      ),
    );
  }
}
