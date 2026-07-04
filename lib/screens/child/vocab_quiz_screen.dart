import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/sessions/session_recorder.dart';
import '../../features/vocab_quiz/vocab_quiz_controller.dart';
import '../../l10n/tts_strings_th.dart';
import '../../models/app_types.dart';
import '../../models/vocabulary_item.dart';
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
import '../../widgets/child/vocab_card.dart' show iconForVocabCategory;

// เกมตอบคำถามคำศัพท์ (Module C ตามเอกสารข้อเสนอ): พูด/โชว์คำ → เลือกจากการ์ด
// 3 ใบ → ให้คะแนน 10/8/6/4 + ดาว แล้วบันทึกการตอบรายคำลง Firestore
// (ข้อมูลตั้งต้นของ dashboard เฟส 2.2)
class VocabQuizScreen extends ConsumerWidget {
  const VocabQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(vocabularyProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            ChildAsyncView(
              value: asyncItems,
              error:
                  (_, __) =>
                      Center(child: Text('โหลดไม่สำเร็จ', style: kTextLg)),
              data: (items) => _QuizBoard(items: items),
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}

class _QuizBoard extends ConsumerStatefulWidget {
  const _QuizBoard({required this.items});

  final List<VocabularyItem> items;

  @override
  ConsumerState<_QuizBoard> createState() => _QuizBoardState();
}

class _QuizBoardState extends ConsumerState<_QuizBoard> {
  late final VocabQuizController _controller;
  late final ActiveSession _session;

  /// itemId ที่เพิ่งตอบถูก — ไว้ flash การ์ดเขียวช่วงรอเปลี่ยนข้อ
  String? _correctFlashId;

  /// กันแตะระหว่างรอเปลี่ยนข้อ/รอ popup
  bool _transitioning = false;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _session = ref.read(
      activeSessionProvider(
        const ActiveSessionKey(
          module: kModuleVocab,
          contentId: kVocabQuizContentId,
        ),
      ),
    );
    _controller = VocabQuizController(
      items: widget.items,
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

  void _speakQuestionWord() {
    ref.read(ttsServiceProvider).speak(_controller.currentQuestion.answer.ttsWord);
  }

  Future<void> _onChoiceTap(String itemId) async {
    if (_transitioning) return;
    final result = _controller.answer(itemId);
    if (!result.accepted) return;

    if (!result.correct) {
      // ตอบผิด: ล็อกการ์ดที่ผิด + เตือนนุ่มๆ แล้วให้ลองต่อจนถูก (ไม่มีการ "แพ้")
      HapticService.tapLight();
      ref.read(ttsServiceProvider).speak(kTtsQuizRetry);
      setState(() {});
      return;
    }

    HapticService.memoryMatch();
    setState(() {
      _correctFlashId = itemId;
      _transitioning = true;
    });

    if (result.completed) {
      ref.read(ttsServiceProvider).speak(kTtsQuizComplete);
      await ref
          .read(sessionRecorderProvider)
          .recordVocabQuizCompleted(
            VocabQuizCompletedEvent(
              session: _session,
              answerEvents: _controller.answerEvents,
              score: _controller.score,
              stars: _controller.starRating,
            ),
          );
      // หน่วงให้เสียงชมเล่นจบก่อน popup (แพทเทิร์นเดียวกับ memory game)
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
      _correctFlashId = null;
      _transitioning = false;
    });
    // ขึ้นข้อใหม่แล้วค่อยอ่านโจทย์ — หนึ่งเหตุการณ์หนึ่ง utterance
    _speakQuestionWord();
  }

  void _showResultDialog() {
    HapticService.success();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameResultDialog(
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

    return LayoutBuilder(
      builder: (context, constraints) {
        // แบ่งพื้นที่เป็นสัดส่วนจากจอจริง (กฎ responsive ข้อ 3): แถบบน ~10%,
        // การ์ดโจทย์ ~28%, ตัวเลือก ~ที่เหลือ — ไม่มี scroll ทุกขนาดจอ
        final promptHeight = (constraints.maxHeight * 0.28).clamp(88.0, 160.0);
        final choiceWidth =
            ((constraints.maxWidth - kSpace6 * 2 - kInteractiveGapMin * 2) / 3)
                .clamp(120.0, 300.0)
                .toDouble();

        return Padding(
          padding: const EdgeInsets.fromLTRB(kSpace6, kSpace2, kSpace6, kSpace5),
          child: Column(
            children: [
              // แถบบน: เลขข้อ (เว้นซ้ายให้ปุ่มย้อนกลับที่ลอยอยู่)
              Padding(
                padding: const EdgeInsets.only(left: kTouchTargetMin + kSpace2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'ข้อ ${_controller.currentNumber}/${_controller.totalQuestions}',
                      key: const Key('quiz_progress'),
                      style: kTextMd.copyWith(color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kSpace2),

              // การ์ดโจทย์: โชว์คำ + แตะเพื่อฟังซ้ำได้เสมอ
              PressableChildCard(
                key: const Key('quiz_prompt'),
                onTap: _speakQuestionWord,
                child: Container(
                  width: double.infinity,
                  height: promptHeight,
                  decoration: BoxDecoration(
                    color: kBlueLight,
                    borderRadius: kRadiusLg,
                    boxShadow: const [kShadowMd],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        size: promptHeight * 0.4,
                        color: kBlueDark,
                      ),
                      const SizedBox(width: kSpace4),
                      Text(
                        question.answer.ttsWord,
                        key: const Key('quiz_word'),
                        style: kTextXL,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: kInteractiveGapMin),

              // ตัวเลือก 3 ใบ (ก/ข/ค ตามเอกสาร) — เว้นระยะกันกดพลาด
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < question.choices.length; i++) ...[
                      if (i > 0) const SizedBox(width: kInteractiveGapMin),
                      _ChoiceCard(
                        key: Key('choice_${question.choices[i].itemId}'),
                        item: question.choices[i],
                        width: choiceWidth,
                        locked: _controller.lockedChoiceIds.contains(
                          question.choices[i].itemId,
                        ),
                        correctFlash:
                            _correctFlashId == question.choices[i].itemId,
                        onTap: () => _onChoiceTap(question.choices[i].itemId),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.item,
    required this.width,
    required this.locked,
    required this.correctFlash,
    required this.onTap,
  });

  final VocabularyItem item;
  final double width;

  /// เคยตอบผิดในข้อนี้ไปแล้ว — หรี่ลงและไม่รับแตะ (controller กันซ้ำอีกชั้น)
  final bool locked;
  final bool correctFlash;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background =
        correctFlash
            ? kSuccessLight
            : locked
            ? kDisabledSurface
            : Colors.white;

    return PressableChildCard(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: locked ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: width,
          decoration: BoxDecoration(
            color: background,
            borderRadius: kRadiusMd,
            border: Border.all(
              color: correctFlash ? kSuccess : kWarmBorder,
              width: correctFlash ? 2 : 1,
            ),
            boxShadow: const [kShadowSm],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // ย่อไอคอน/ฟอนต์ตามช่องจริง — แพทเทิร์นเดียวกับ VocabCard
              final cell = constraints.maxHeight;
              final iconSize = (cell * 0.35).clamp(32.0, 72.0).toDouble();
              final labelStyle =
                  cell < 110
                      ? kChildLabel.copyWith(fontSize: 18, height: 1.2)
                      : kChildLabel;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconForVocabCategory(item.category),
                    size: iconSize,
                    color: kTextSecondary,
                  ),
                  const SizedBox(height: kSpace2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kSpace1),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(item.ttsWord, style: labelStyle, maxLines: 1),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
