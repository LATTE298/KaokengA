import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../game/daily_life_game.dart';
import '../../features/sessions/session_recorder.dart';
import '../../l10n/tts_strings_th.dart';
import '../../models/app_types.dart';
import '../../models/loaded_scenario_config.dart';
import '../../providers/rewards_provider.dart';
import '../../providers/content_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/sfx_provider.dart';
import '../../providers/tts_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/game_result_dialog.dart';
import '../../widgets/child_back_button.dart';

class ScenarioGameScreen extends ConsumerStatefulWidget {
  const ScenarioGameScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<ScenarioGameScreen> createState() =>
      _ScenarioGameScreenState();
}

class _ScenarioGameScreenState extends ConsumerState<ScenarioGameScreen> {
  // สุ่ม target + สร้าง game "ครั้งเดียว" ต่อ instance หน้าจอ (cache ไว้) — เดิมสุ่มใน build()
  // ด้วย Random() ทุก build ทำให้ target ที่ game พูด (เสียงพากย์) กับที่แถบโจทย์โชว์เพี้ยน
  // กันตอน build ซ้ำ (เห็นชัดตอนกด "เล่นอีกครั้ง"). replay = State ใหม่ = สุ่มใหม่ แต่เสถียร
  // ตลอดการเล่นรอบนั้น
  LoadedScenarioConfig? _randomized;
  DailyLifeGame? _game;

  @override
  Widget build(BuildContext context) {
    final asyncConfig = ref.watch(
      loadedScenarioConfigProvider(widget.scenarioId),
    );
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
          // สุ่ม target ครั้งเดียว (cache) — โหมดโจทย์ชิ้นเดียวเท่านั้น; ฉาก sort-all
          // ไม่มี target เดี่ยว (_randomizeTarget คืน original ให้)
          final randomized = _randomized ??= _randomizeTarget(loadedScenario);
          final config = randomized.config;
          final sortAll = config.zones.isNotEmpty;
          final targetItem =
              sortAll
                  ? null
                  : config.interactables.firstWhere((i) => i.isTarget);

          final session = ref.watch(
            activeSessionProvider(
              ActiveSessionKey(
                module: kModuleDailyLife,
                contentId: config.scenarioId,
              ),
            ),
          );

          final game = _game ??= DailyLifeGame(
            loadedScenario: randomized,
            tts: tts,
            sfx: ref.watch(sfxPlayerProvider),
            reduceMotion: reduceMotion,
            onComplete: (dragPath, score, stars) async {
              // เสียงฉลองจบด่าน (congrat) เล่นในเกม พร้อม confetti (daily_life_game)
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
              awardGameResult(ref, module: kModuleDailyLife, stars: stars);
              if (!context.mounted) return;
              await showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder:
                    (dialogCtx) => GameResultDialog(
                      stars: stars,
                      score: score,
                      detail: 'ทำกิจกรรมสำเร็จแล้ว!',
                      onClose: () {
                        final router = GoRouter.of(context);
                        Navigator.of(dialogCtx).pop();
                        if (router.canPop()) router.pop();
                      },
                      // เล่นอีกครั้ง = pop หน้าเกมเดิม แล้ว push เส้นทางเดิมใหม่ (สุ่ม target ใหม่)
                      onPlayAgain: () {
                        final router = GoRouter.of(context);
                        final loc = GoRouterState.of(context).uri.toString();
                        Navigator.of(dialogCtx).pop();
                        router.pop();
                        router.push(loc);
                      },
                    ),
              );
            },
          );

          return Stack(
            children: [
              Positioned.fill(child: GameWidget(game: game)),

              // หัวข้อโจทย์ — โหมดเดิมบอกชิ้นที่ต้องหยิบ, โจทย์สุ่มโชว์รูป+ชื่อ
              // 2 ชิ้นที่ต้องเก็บ (เด็กยังไม่อ่านหนังสือดูรูปได้), sort-all
              // ธรรมดาบอกภารกิจรวม
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child:
                      game.shopOrder == null
                          ? _ObjectiveBar(
                            label:
                                targetItem == null
                                    ? config.titleTh
                                    : 'หยิบ: ${scenarioItemNameTh(targetItem.id)}',
                            wanted: [
                              for (final id
                                  in game.wantedIds ?? const <String>[])
                                (
                                  image:
                                      config.interactables
                                          .firstWhere((i) => i.id == id)
                                          .image,
                                  name: scenarioItemNameTh(id),
                                ),
                            ],
                          )
                          : _ShopObjectiveBar(
                            items: [
                              for (final o in game.shopOrder!)
                                (
                                  id: o.id,
                                  name: scenarioItemNameTh(o.id),
                                  image:
                                      config.interactables
                                          .firstWhere((i) => i.id == o.id)
                                          .image,
                                  need: o.count,
                                ),
                            ],
                            basket: game.basketNotifier,
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
// ฉาก sort-all (มี zones) ไม่สุ่ม: ทุกชิ้นคือโจทย์ ใช้ประโยค TTS จาก JSON ตรงๆ
LoadedScenarioConfig _randomizeTarget(LoadedScenarioConfig original) {
  final items = original.config.interactables;
  if (items.length <= 1 || original.config.zones.isNotEmpty) return original;

  final randomIndex = Random().nextInt(items.length);
  final newInteractables =
      items.indexed.map((entry) {
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

// สร้างประโยค TTS instruction จาก id ของ target (ชื่อจาก kScenarioItemNamesTh
// ใน l10n — เพิ่มไอเทมใหม่ต้องลงทะเบียนชื่อที่นั่น + คลิป sc_ask_*/sc_hint_*)
String _buildInstruction(String targetId) {
  final name = scenarioItemNameTh(targetId);
  return 'น้องช่วยหยิบ$nameใส่ตะกร้าให้หน่อยนะครับ';
}

String _buildHint(String targetId) {
  final name = scenarioItemNameTh(targetId);
  return 'ลองหยิบ$nameนะครับ';
}

// แถบหัวข้อโจทย์ด้านบน — โหมดเดิม "หยิบ: X", โจทย์สุ่ม = รูป+ชื่อของที่ต้องเก็บ,
// sort-all ธรรมดา = ชื่อภารกิจ (ชื่อไอเทมมาจาก kScenarioItemNamesTh ใน l10n)
class _ObjectiveBar extends StatelessWidget {
  const _ObjectiveBar({required this.label, this.wanted = const []});

  final String label;

  /// โจทย์สุ่ม: รูป+ชื่อของชิ้นที่ต้องเก็บ — ว่าง = โชว์ [label] ธรรมดา
  final List<({String image, String name})> wanted;

  @override
  Widget build(BuildContext context) {
    return Container(
      // ซ้ายต้องพ้นปุ่มย้อนกลับที่ลอยมุมบนซ้าย (8 + 64 = 72) ไม่งั้นปุ่มทับไอคอนแถบโจทย์
      margin: const EdgeInsets.fromLTRB(
        kTouchTargetMin + kSpace4,
        kSpace2,
        kSpace4,
        0,
      ),
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
          const Icon(
            Icons.shopping_basket_rounded,
            size: 20,
            color: kTextPrimary,
          ),
          const SizedBox(width: kSpace2),
          if (wanted.isEmpty)
            Text(
              label,
              style: kTextMd.copyWith(
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            )
          else ...[
            Text(
              'หยิบ: ',
              style: kTextMd.copyWith(
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            for (var i = 0; i < wanted.length; i++) ...[
              if (i > 0)
                Text(' กับ ', style: kTextMd.copyWith(color: kTextPrimary)),
              _WantedChip(image: wanted[i].image, name: wanted[i].name),
            ],
          ],
        ],
      ),
    );
  }
}

// ชิปรูป+ชื่อของชิ้นในโจทย์สุ่ม — รูปช่วยเด็กที่ยังอ่านหนังสือไม่คล่อง
class _WantedChip extends StatelessWidget {
  const _WantedChip({required this.image, required this.name});

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: kWarmWhite, borderRadius: kRadiusSm),
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: kSpace1),
        Text(
          name,
          style: kTextMd.copyWith(
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// แถบโจทย์เกมซื้อของ — โชว์ทุกชนิด+จำนวน พร้อมความคืบหน้า "ใส่แล้ว/ต้องการ" อัปเดตเรียลไทม์
// (ฟัง basketNotifier จากเกม). ชนิดที่ครบแล้วป้ายเปลี่ยนเป็นเขียว
class _ShopObjectiveBar extends StatelessWidget {
  const _ShopObjectiveBar({required this.items, required this.basket});

  final List<({String id, String name, String image, int need})> items;
  final ValueListenable<Map<String, int>> basket;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        kTouchTargetMin + kSpace4,
        kSpace2,
        kSpace4,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: kSpace4,
        vertical: kSpace2,
      ),
      decoration: BoxDecoration(
        color: kYellowPrimary.withValues(alpha: 0.92),
        borderRadius: kRadiusFull,
        boxShadow: const [kShadowSm],
      ),
      child: ValueListenableBuilder<Map<String, int>>(
        valueListenable: basket,
        builder: (context, counts, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_basket_rounded,
                size: 20,
                color: kTextPrimary,
              ),
              const SizedBox(width: kSpace2),
              Text(
                'หยิบ: ',
                style: kTextMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Text(' กับ ', style: kTextMd.copyWith(color: kTextPrimary)),
                _ShopChip(
                  image: items[i].image,
                  name: items[i].name,
                  current: counts[items[i].id] ?? 0,
                  need: items[i].need,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ShopChip extends StatelessWidget {
  const _ShopChip({
    required this.image,
    required this.name,
    required this.current,
    required this.need,
  });

  final String image;
  final String name;
  final int current;
  final int need;

  @override
  Widget build(BuildContext context) {
    final done = current >= need;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: kWarmWhite, borderRadius: kRadiusSm),
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: kSpace1),
        Text(
          '$name ',
          style: kTextMd.copyWith(
            fontWeight: FontWeight.w700,
            color: kTextPrimary,
          ),
        ),
        // ป้ายจำนวน current/need — เขียวเมื่อครบ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: kSpace2, vertical: 1),
          decoration: BoxDecoration(
            color: done ? kSuccess : kWarmWhite,
            borderRadius: kRadiusFull,
          ),
          child: Text(
            '$current/$need',
            style: kTextSm.copyWith(
              fontWeight: FontWeight.w800,
              color: done ? kWarmWhite : kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

