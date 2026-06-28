import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../game/daily_life_game.dart';
import '../../features/sessions/session_recorder.dart';
import '../../models/app_types.dart';
import '../../models/loaded_scenario_config.dart';
import '../../models/scenario_config.dart';
import '../../providers/content_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/tts_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child_back_button.dart';

class ScenarioGameScreen extends ConsumerWidget {
  const ScenarioGameScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConfig = ref.watch(loadedScenarioConfigProvider(scenarioId));
    final tts = ref.watch(ttsServiceProvider);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: asyncConfig.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'โหลดสถานการณ์ไม่สำเร็จ',
                  style: kTextLg,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        data: (LoadedScenarioConfig loadedScenario) {
          // สุ่ม target ใหม่ทุกครั้งที่โหลดด่าน
          final randomized = _randomizeTarget(loadedScenario);
          final config = randomized.config;
          final targetItem =
              config.interactables.firstWhere((i) => i.isTarget);

          final session = ref.watch(
            activeSessionProvider(
              ActiveSessionKey(
                module: kModuleDailyLife,
                contentId: config.scenarioId,
              ),
            ),
          );

          final game = DailyLifeGame(
            loadedScenario: randomized,
            tts: tts,
            reduceMotion: reduceMotion,
            onComplete: (dragPath, score, stars) async {
              ref
                  .read(sessionRecorderProvider)
                  .recordDailyLifeCompleted(
                    DailyLifeCompletedEvent(
                      session: session,
                      config: config,
                      dragPath: dragPath,
                      score: score,
                      stars: stars,
                    ),
                  );
              if (context.mounted) {
                await _showResultDialog(context, score, stars);
              }
              if (context.mounted && context.canPop()) context.pop();
            },
          );

          return Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),

              // หัวข้อโจทย์บอกว่าต้องหยิบอะไร
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _ObjectiveBar(
                    targetId: targetItem.id,
                    scenarioTitle: config.titleTh,
                  ),
                ),
              ),

              const Positioned(top: 8, left: 8, child: ChildBackButton()),
            ],
          );
        },
      ),
    );
  }
}

// สุ่ม target ใหม่จาก interactables ทั้งหมดทุกรอบ
// ไม่แก้ JSON — เปลี่ยน is_target ใน memory แทน
LoadedScenarioConfig _randomizeTarget(LoadedScenarioConfig original) {
  final items = original.config.interactables;
  if (items.length <= 1) return original;

  final randomIndex = Random().nextInt(items.length);
  final newInteractables = items.indexed.map((entry) {
    final (i, item) = entry;
    return item.copyWith(isTarget: i == randomIndex);
  }).toList();

  final newConfig = original.config.copyWith(
    interactables: newInteractables,
    ttsInstruction: _buildInstruction(newInteractables[randomIndex].id),
    ttsHint: _buildHint(newInteractables[randomIndex].id),
  );

  return LoadedScenarioConfig(
    config: newConfig,
    placeholderImagePaths: original.placeholderImagePaths,
  );
}

// สร้างประโยค TTS instruction จาก id ของ target
String _buildInstruction(String targetId) {
  final name = _thaiNameFor(targetId);
  return 'น้องช่วยหยิบ$nameใส่ตะกร้าให้หน่อยนะครับ';
}

String _buildHint(String targetId) {
  final name = _thaiNameFor(targetId);
  return 'ลองหยิบ$nameนะครับ';
}

// Map id → ชื่อภาษาไทยสำหรับ TTS และหัวข้อโจทย์
String _thaiNameFor(String id) {
  const map = {
    'milk_carton_blue': 'นมกล่องสีน้ำเงิน',
    'bread_loaf': 'ขนมปัง',
    'potato_chips': 'ขนมกรุบกรอบ',
    'plastic_bottle': 'ขวดพลาสติก',
    'banana_peel': 'เปลือกกล้วย',
    'paper_ball': 'กระดาษ',
    'banana': 'กล้วย',
    'toothbrush': 'แปรงสีฟัน',
    'pencil': 'ดินสอ',
  };
  return map[id] ?? id;
}

// แถบหัวข้อโจทย์ด้านบน — บอกว่าต้องหยิบอะไร
class _ObjectiveBar extends StatelessWidget {
  const _ObjectiveBar({
    required this.targetId,
    required this.scenarioTitle,
  });

  final String targetId;
  final String scenarioTitle;

  @override
  Widget build(BuildContext context) {
    final targetName = _thaiNameFor(targetId);

    return Container(
      margin: const EdgeInsets.fromLTRB(kSpace12, kSpace2, kSpace4, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: kSpace4,
        vertical: kSpace2,
      ),
      decoration: BoxDecoration(
        color: kYellowPrimary.withValues(alpha: 0.92),
        borderRadius: kRadiusFull,
        boxShadow: const [kShadowSm],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_basket_rounded, size: 20, color: kTextPrimary),
          const SizedBox(width: kSpace2),
          Text(
            'หยิบ: $targetName',
            style: kTextMd.copyWith(
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showResultDialog(
  BuildContext context,
  int score,
  int stars,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DailyLifeResultDialog(score: score, stars: stars),
  );
}

class _DailyLifeResultDialog extends StatelessWidget {
  const _DailyLifeResultDialog({required this.score, required this.stars});

  final int score;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: kSpace6,
        vertical: kSpace4,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: kSpace8,
            vertical: kSpace5,
          ),
          decoration: BoxDecoration(
            color: kWarmWhite,
            borderRadius: kRadiusLg,
            boxShadow: const [kShadowLg],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('เก่งมากเลย!', style: kTextXL),
                SizedBox(height: kSpace4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final filled = i < stars;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: kSpace1),
                      child: Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: filled
                            ? kYellowPrimary
                            : kYellowPrimary.withValues(alpha: 0.2),
                      ),
                    );
                  }),
                ),
                SizedBox(height: kSpace4),
                Text('คะแนน $score เต็ม 10', style: kTextLg),
                SizedBox(height: kSpace5),
                // เอา style: FilledButton.styleFrom(...) ที่เคยเซ็ตซ้ำเองตรงนี้ออก เพราะ
                // app_theme.dart ตั้งค่ากลางให้ทุกปุ่มในแอปแล้ว เหมือนกับใน
                // memory_game_screen.dart — ปุ่ม "ปิด" ของทั้งสองโมดูลจะหน้าตาเหมือนกัน
                // เป๊ะโดยไม่ต้องก็อปสไตล์มาวางซ้ำ (spec 1.3)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ปิด'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}