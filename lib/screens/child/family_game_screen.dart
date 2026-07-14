import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/family_quiz/family_quiz_controller.dart';
import '../../features/sessions/session_recorder.dart';
import '../../l10n/tts_strings_th.dart';
import '../../models/app_types.dart';
import '../../models/family_card.dart';
import '../../providers/child_profile_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../providers/family_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/sfx_provider.dart';
import '../../providers/tts_provider.dart';
import '../../routes/app_routes.dart';
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

// เกม "หมวดครอบครัว" (เฟส 2.1) — โชว์รูปคนในครอบครัว (จาก Hive) → ถาม "นี่คือใคร"
// → เลือกจากตัวเลือกที่ผู้ปกครองกำหนด → คะแนน/ดาว/บันทึก session (module=family)
// โครงเดียวกับ VocabQuizScreen แต่รูปเป็น Image.memory และตัวเลือกเป็นข้อความล้วน
class FamilyGameScreen extends ConsumerWidget {
  const FamilyGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(familyCardsProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: PaperBackground()),
            ChildAsyncView(
              value: cardsAsync,
              error:
                  (_, __) =>
                      Center(child: Text('โหลดไม่สำเร็จ', style: kTextLg)),
              data:
                  (cards) =>
                      cards.isEmpty
                          ? const _EmptyState()
                          : _FamilyBoard(cards: cards),
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpace8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diversity_3_rounded, size: 72, color: kWarmMuted),
            const SizedBox(height: kSpace4),
            Text('ยังไม่มีรูปครอบครัว', style: kTextXL),
            const SizedBox(height: kSpace2),
            Text(
              'ให้คุณพ่อคุณแม่เพิ่มรูปคนในครอบครัวก่อนนะครับ',
              style: kTextMd.copyWith(color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: kSpace6),
            // ปุ่มลัดไปหน้าจัดการคลังครอบครัว (เพิ่มรูปสมาชิก) — สะดวกตอนยังไม่มีรูป
            FilledButton.icon(
              onPressed: () => context.push(kRouteFamilyManager),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('เพิ่มคนในครอบครัว'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyBoard extends ConsumerStatefulWidget {
  const _FamilyBoard({required this.cards});

  final List<FamilyCard> cards;

  @override
  ConsumerState<_FamilyBoard> createState() => _FamilyBoardState();
}

class _FamilyBoardState extends ConsumerState<_FamilyBoard> {
  late final FamilyQuizController _controller;
  late final ActiveSession _session;

  /// ตัวเลือก (ข้อความ) ที่เพิ่งตอบถูก — ไว้ flash เขียวช่วงรอเปลี่ยนข้อ
  String? _correctFlash;
  bool _transitioning = false;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _session = ref.read(
      activeSessionProvider(
        const ActiveSessionKey(module: kModuleFamily, contentId: 'family_quiz'),
      ),
    );
    _controller = FamilyQuizController(
      cards: widget.cards,
      elapsedMs:
          () =>
              ref
                  .read(clockProvider)()
                  .toUtc()
                  .difference(_session.startedAt)
                  .inMilliseconds,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(kTtsQuizStart);
    });
  }

  void _speakQuestion() {
    ref.read(ttsServiceProvider).speak(kTtsFamilyAsk);
  }

  Future<void> _onChoiceTap(String choice) async {
    if (_transitioning) return;
    final result = _controller.answer(choice);
    if (!result.accepted) return;

    if (!result.correct) {
      HapticService.tapLight();
      ref.read(sfxPlayerProvider).play(kSfxWrong);
      ref.read(ttsServiceProvider).speak(kTtsQuizRetry);
      setState(() {});
      return;
    }

    HapticService.memoryMatch();
    ref.read(sfxPlayerProvider).play(kSfxRight);
    setState(() {
      _correctFlash = choice;
      _transitioning = true;
    });

    if (result.completed) {
      ref.read(ttsServiceProvider).speak(kTtsQuizComplete);
      await ref
          .read(sessionRecorderProvider)
          .recordFamilyQuizCompleted(
            FamilyQuizCompletedEvent(
              session: _session,
              answerEvents: _controller.answerEvents,
              score: _controller.score,
              stars: _controller.starRating,
            ),
          );
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted || _resultShown) return;
      _resultShown = true;
      _showResultDialog();
      return;
    }

    ref.read(ttsServiceProvider).speak(kTtsQuizCorrect);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _correctFlash = null;
      _transitioning = false;
    });
    _speakQuestion();
  }

  void _showResultDialog() {
    ref.read(totalStarsProvider.notifier).award(_controller.starRating);
    ref.read(rewardsStatsProvider.notifier).recordCompletion(kModuleFamily);
    HapticService.success();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => GameResultDialog(
            stars: _controller.starRating,
            score: _controller.score,
            detail: 'ตอบครบ ${_controller.totalQuestions} ข้อ',
            onClose: () {
              Navigator.of(context).pop();
              if (context.mounted && context.canPop()) context.pop();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _controller.currentQuestion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(kSpace6, kSpace2, kSpace6, kSpace5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: kTouchTargetMin + kSpace2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'ข้อ ${_controller.currentNumber}/${_controller.totalQuestions}',
                  key: const Key('family_progress'),
                  style: kTextMd.copyWith(color: kTextSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: kSpace2),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ซ้าย: รูปคนในครอบครัว (แตะฟังคำถามซ้ำ) + ประโยคคำถาม
                Expanded(
                  flex: 11,
                  child: Column(
                    children: [
                      Expanded(
                        child: PressableChildCard(
                          key: const Key('family_prompt'),
                          onTap: _speakQuestion,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(kSpace4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: kRadiusLg,
                              border: Border.all(
                                color: kWarmBorder,
                                width: 1.5,
                              ),
                              boxShadow: const [kShadowMd],
                            ),
                            child: ClipRRect(
                              borderRadius: kRadiusMd,
                              child: Image.memory(
                                question.card.imageBytes,
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: kSpace3),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'คำถาม: $kTtsFamilyAsk?',
                          key: const Key('family_question'),
                          style: kTextXL,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: kInteractiveGapMin),

                // ขวา: ปุ่มตอบ ก/ข/ค (ข้อความที่ผู้ปกครองกำหนด)
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      for (var i = 0; i < question.choices.length; i++) ...[
                        if (i > 0) const SizedBox(height: kInteractiveGapMin),
                        Expanded(
                          child: _ChoicePill(
                            key: Key('family_choice_${question.choices[i]}'),
                            prefix:
                                _kChoicePrefixes[i % _kChoicePrefixes.length],
                            label: question.choices[i],
                            background:
                                _kChoiceBackgrounds[i %
                                    _kChoiceBackgrounds.length],
                            locked: _controller.lockedChoices.contains(
                              question.choices[i],
                            ),
                            correctFlash: _correctFlash == question.choices[i],
                            onTap: () => _onChoiceTap(question.choices[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _kChoicePrefixes = ['ก', 'ข', 'ค', 'ง'];
const _kChoiceBackgrounds = [kBlueLight, kYellowLight, kWarmSurface];

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    super.key,
    required this.prefix,
    required this.label,
    required this.background,
    required this.locked,
    required this.correctFlash,
    required this.onTap,
  });

  final String prefix;
  final String label;
  final Color background;
  final bool locked;
  final bool correctFlash;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: locked ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: kSpace5),
          decoration: BoxDecoration(
            color:
                correctFlash
                    ? kSuccessLight
                    : locked
                    ? kDisabledSurface
                    : background,
            borderRadius: kRadiusFull,
            border: Border.all(
              color: correctFlash ? kSuccess : kWarmBorder,
              width: correctFlash ? 2.5 : 1.5,
            ),
            boxShadow: const [kShadowSm],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final labelStyle =
                  constraints.maxHeight < 72
                      ? kChildLabel.copyWith(fontSize: 18, height: 1.2)
                      : kChildLabel;
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$prefix. $label',
                    style: labelStyle,
                    maxLines: 1,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
