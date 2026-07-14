import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/sessions/session_recorder.dart';
import '../../features/vocab_quiz/vocab_quiz_controller.dart';
import '../../l10n/tts_strings_th.dart';
import '../../models/app_types.dart';
import '../../models/vocabulary_item.dart';
import '../../providers/child_profile_provider.dart';
import '../../providers/rewards_provider.dart';
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
import '../../widgets/child/vocab_card.dart' show iconForVocabCategory;

// เกมตอบคำถามคำศัพท์ (Module C ตาม mockup ในเอกสารข้อเสนอ): เลือกหมวดจาก
// VocabQuizSelectScreen แล้วเข้ามาหน้านี้ → โชว์รูปใหญ่ → ถาม "นี่คือ...อะไร?"
// ตามหมวด → เลือกคำตอบจากปุ่ม ก/ข/ค → คะแนน 10/8/6/4 แล้วบันทึกการตอบรายคำ
// ลง Firestore แยกตามหมวด (scenarioId = quiz_<หมวด> — ข้อมูล dashboard เฟส 2.2)
class VocabQuizScreen extends ConsumerWidget {
  const VocabQuizScreen({super.key, required this.category});

  /// หมวดคำศัพท์ที่เล่น (key ตาม kVocabCategories เช่น 'animals')
  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(vocabularyProvider);

    return Scaffold(
      backgroundColor: kWarmWhite,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: PaperBackground()),
            ChildAsyncView(
              value: asyncItems,
              error:
                  (_, __) =>
                      Center(child: Text('โหลดไม่สำเร็จ', style: kTextLg)),
              data: (items) {
                final categoryItems =
                    items.where((i) => i.category == category).toList();
                // หมวดต้องมีคำพอทำตัวเลือก 3 ใบ — น้อยกว่านั้นถือว่าข้อมูลผิด
                if (categoryItems.length < 3) {
                  return Center(child: Text('โหลดไม่สำเร็จ', style: kTextLg));
                }
                return _QuizFlow(category: category, items: categoryItems);
              },
            ),
            const Positioned(top: 8, left: 8, child: ChildBackButton()),
          ],
        ),
      ),
    );
  }
}

// เลือกแบบก่อนเล่น (feedback ครู 2026-07-12): เลือกคำ (ช้อยส์เป็นคำ) หรือ
// เลือกภาพ (คำถามเป็นเสียง/ตัวหนังสือ → จิ้มเลือกรูปที่ถูก)
class _QuizFlow extends StatefulWidget {
  const _QuizFlow({required this.category, required this.items});

  final String category;
  final List<VocabularyItem> items;

  @override
  State<_QuizFlow> createState() => _QuizFlowState();
}

class _QuizFlowState extends State<_QuizFlow> {
  bool? _imageChoices;

  @override
  Widget build(BuildContext context) {
    if (_imageChoices == null) {
      return _QuizModePicker(
        onSelect:
            (imageChoices) => setState(() => _imageChoices = imageChoices),
      );
    }
    return _QuizBoard(
      category: widget.category,
      items: widget.items,
      imageChoices: _imageChoices!,
    );
  }
}

class _QuizModePicker extends StatelessWidget {
  const _QuizModePicker({required this.onSelect});

  final void Function(bool imageChoices) onSelect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(kSpace6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'เลือกแบบ',
              style: kTextXL.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: kSpace6),
            Wrap(
              spacing: kSpace4,
              runSpacing: kSpace4,
              alignment: WrapAlignment.center,
              children: [
                _QuizModeCard(
                  key: const Key('quiz_mode_words'),
                  icon: Icons.text_fields_rounded,
                  label: 'เลือกคำ',
                  hint: 'ดูรูป แล้วเลือกคำ',
                  bg: kYellowLight,
                  accent: kYellowPrimary,
                  onTap: () => onSelect(false),
                ),
                _QuizModeCard(
                  key: const Key('quiz_mode_images'),
                  icon: Icons.image_rounded,
                  label: 'เลือกภาพ',
                  hint: 'ฟังคำ แล้วเลือกรูป',
                  bg: kBlueLight,
                  accent: kBluePrimary,
                  onTap: () => onSelect(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizModeCard extends StatelessWidget {
  const _QuizModeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.bg,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final Color bg;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableChildCard(
      onTap: onTap,
      playClickSound: true,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(kSpace5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: kRadiusLg,
          boxShadow: const [kShadowMd],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: kSpace3),
            Text(
              label,
              style: kChildLabel.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: kSpace1),
            Text(
              hint,
              style: kTextSm.copyWith(color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizBoard extends ConsumerStatefulWidget {
  const _QuizBoard({
    required this.category,
    required this.items,
    required this.imageChoices,
  });

  final String category;

  /// คำเฉพาะหมวดที่เลือกแล้ว (กรองมาจากหน้าจอชั้นนอก)
  final List<VocabularyItem> items;

  /// true = ช้อยส์เป็นรูป (คำถามเป็นคำ/เสียง) · false = ช้อยส์เป็นคำ (โจทย์เป็นรูป)
  final bool imageChoices;

  @override
  ConsumerState<_QuizBoard> createState() => _QuizBoardState();
}

class _QuizBoardState extends ConsumerState<_QuizBoard> {
  late final VocabQuizController _controller;
  late final ActiveSession _session;

  /// itemId ที่เพิ่งตอบถูก — ไว้ flash ปุ่มเขียวช่วงรอเปลี่ยนข้อ
  String? _correctFlashId;

  /// กันแตะระหว่างรอเปลี่ยนข้อ/รอ popup
  bool _transitioning = false;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    _session = ref.read(
      activeSessionProvider(
        ActiveSessionKey(
          module: kModuleVocab,
          contentId: 'quiz_${widget.category}',
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
      // โหมดเลือกภาพ: พูด "คำ" ที่ต้องหาตั้งแต่เริ่ม (เด็กฟังแล้วจิ้มรูป)
      if (widget.imageChoices) {
        _speakQuestion();
      } else {
        ref.read(ttsServiceProvider).speak(kTtsQuizStart);
      }
    });
  }

  // โหมดเลือกคำ: พูดประโยคคำถามตามหมวด · โหมดเลือกภาพ: พูดคำที่ต้องหา
  // (ห้ามพูดคำตอบเองในโหมดเลือกคำ เพราะจะเฉลยทันที)
  void _speakQuestion() {
    final answer = _controller.currentQuestion.answer;
    ref
        .read(ttsServiceProvider)
        .speak(
          widget.imageChoices
              ? answer.ttsWord
              : ttsQuizQuestion(answer.category),
        );
  }

  Future<void> _onChoiceTap(String itemId) async {
    if (_transitioning) return;
    final result = _controller.answer(itemId);
    if (!result.accepted) return;

    if (!result.correct) {
      // ตอบผิด: ล็อกปุ่มที่ผิด + เตือนนุ่มๆ แล้วให้ลองต่อจนถูก (ไม่มีการ "แพ้")
      HapticService.tapLight();
      ref.read(sfxPlayerProvider).play(kSfxWrong);
      ref.read(ttsServiceProvider).speak(kTtsQuizRetry);
      setState(() {});
      return;
    }

    HapticService.memoryMatch();
    ref.read(sfxPlayerProvider).play(kSfxRight);
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
    // ขึ้นข้อใหม่แล้วค่อยอ่านคำถาม — หนึ่งเหตุการณ์หนึ่ง utterance
    _speakQuestion();
  }

  void _showResultDialog() {
    ref.read(totalStarsProvider.notifier).award(_controller.starRating);
    ref.read(rewardsStatsProvider.notifier).recordCompletion(kModuleVocab);
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
    final answer = question.answer;

    return LayoutBuilder(
      builder: (context, constraints) {
        // จอแนวนอน: ซ้าย = รูปโจทย์ใหญ่ + ประโยคคำถาม, ขวา = ปุ่มตอบ ก/ข/ค
        // ทุกขนาดคิดเป็นสัดส่วนจากพื้นที่จริง (กฎ responsive ข้อ 3) ไม่มี scroll
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            kSpace6,
            kSpace2,
            kSpace6,
            kSpace5,
          ),
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
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ฝั่งซ้าย: รูปโจทย์ (แตะเพื่อฟังคำถามซ้ำ) + ประโยคคำถาม
                    Expanded(
                      flex: 11,
                      child: Column(
                        children: [
                          Expanded(
                            child: PressableChildCard(
                              key: const Key('quiz_prompt'),
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
                                child:
                                    widget.imageChoices
                                        ? _PromptWord(item: answer)
                                        : _PromptImage(
                                          key: Key(
                                            'quiz_image_${answer.itemId}',
                                          ),
                                          item: answer,
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(height: kSpace3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.imageChoices
                                  ? 'แตะรูปที่ใช่'
                                  : 'คำถาม: ${ttsQuizQuestion(answer.category)}?',
                              key: const Key('quiz_question'),
                              style: kTextXL,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: kInteractiveGapMin),

                    // ฝั่งขวา: ปุ่มตอบ ก/ข/ค เรียงลงมา (ตาม mockup ในเอกสาร)
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: [
                          for (var i = 0; i < question.choices.length; i++) ...[
                            if (i > 0)
                              const SizedBox(height: kInteractiveGapMin),
                            Expanded(
                              child:
                                  widget.imageChoices
                                      ? _ImageChoice(
                                        key: Key(
                                          'choice_${question.choices[i].itemId}',
                                        ),
                                        item: question.choices[i],
                                        locked: _controller.lockedChoiceIds
                                            .contains(
                                              question.choices[i].itemId,
                                            ),
                                        correctFlash:
                                            _correctFlashId ==
                                            question.choices[i].itemId,
                                        onTap:
                                            () => _onChoiceTap(
                                              question.choices[i].itemId,
                                            ),
                                        onListen:
                                            () => ref
                                                .read(ttsServiceProvider)
                                                .speak(
                                                  question.choices[i].ttsWord,
                                                ),
                                      )
                                      : _ChoicePill(
                                        key: Key(
                                          'choice_${question.choices[i].itemId}',
                                        ),
                                        prefix: _kChoicePrefixes[i],
                                        item: question.choices[i],
                                        background:
                                            _kChoiceBackgrounds[i %
                                                _kChoiceBackgrounds.length],
                                        locked: _controller.lockedChoiceIds
                                            .contains(
                                              question.choices[i].itemId,
                                            ),
                                        correctFlash:
                                            _correctFlashId ==
                                            question.choices[i].itemId,
                                        onTap:
                                            () => _onChoiceTap(
                                              question.choices[i].itemId,
                                            ),
                                        onListen:
                                            () => ref
                                                .read(ttsServiceProvider)
                                                .speak(
                                                  question.choices[i].ttsWord,
                                                ),
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
      },
    );
  }
}

// ตัวนำหน้าตัวเลือกตามเอกสารข้อเสนอ (ก/ข/ค)
const _kChoicePrefixes = ['ก', 'ข', 'ค'];

// สีพื้นปุ่มไล่ตามตำแหน่ง (ตกแต่งอย่างเดียว ไม่สื่อถูก/ผิด — สถานะถูก/ผิดใช้
// ขอบเขียว/หรี่จางแทน) ให้เด็กแยกปุ่มแต่ละอันได้ง่ายแบบเดียวกับ mockup
const _kChoiceBackgrounds = [kBlueLight, kYellowLight, kWarmSurface];

// ปุ่มลำโพงเล็ก — กดฟังเสียงคำ (แยกจากการตอบ) ช่วยเด็กที่ยังอ่านไม่คล่อง
class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.volume_up_rounded),
      color: kBlueDark,
      tooltip: 'ฟังเสียง',
    );
  }
}

// โจทย์โหมดเลือกภาพ = "คำ" ตัวใหญ่ + ไอคอนลำโพง (แตะการ์ดโจทย์เพื่อฟังซ้ำ)
class _PromptWord extends StatelessWidget {
  const _PromptWord({required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_up_rounded, color: kBluePrimary, size: 40),
            const SizedBox(width: kSpace3),
            Text(
              item.ttsWord,
              key: Key('quiz_word_${item.itemId}'),
              style: kTextXL.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

// ช้อยส์โหมดเลือกภาพ = รูปใหญ่ + ปุ่มลำโพง, แตะรูป = ตอบ
class _ImageChoice extends StatelessWidget {
  const _ImageChoice({
    super.key,
    required this.item,
    required this.locked,
    required this.correctFlash,
    required this.onTap,
    required this.onListen,
  });

  final VocabularyItem item;
  final bool locked;
  final bool correctFlash;
  final VoidCallback onTap;
  final VoidCallback onListen;

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
          padding: const EdgeInsets.symmetric(
            horizontal: kSpace3,
            vertical: kSpace2,
          ),
          decoration: BoxDecoration(
            color:
                correctFlash
                    ? kSuccessLight
                    : locked
                    ? kDisabledSurface
                    : Colors.white,
            borderRadius: kRadiusLg,
            border: Border.all(
              color: correctFlash ? kSuccess : kWarmBorder,
              width: correctFlash ? 2.5 : 1.5,
            ),
            boxShadow: const [kShadowSm],
          ),
          child: Row(
            children: [
              Expanded(
                child: Image.asset(
                  item.image,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (_, __, ___) => Icon(
                        iconForVocabCategory(item.category),
                        size: 44,
                        color: kTextSecondary,
                      ),
                ),
              ),
              const SizedBox(width: kSpace2),
              _ListenButton(onTap: onListen),
            ],
          ),
        ),
      ),
    );
  }
}

// รูปโจทย์: ใช้รูปจริงจาก assets ถ้ามี — ยังไม่มี (placeholder) ให้โชว์ไอคอนหมวด
// ขนาดใหญ่ไปก่อน จะกลายเป็นภาพจริงเองเมื่อทีมวางไฟล์รูป
class _PromptImage extends StatelessWidget {
  const _PromptImage({super.key, required this.item});

  final VocabularyItem item;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      item.image,
      fit: BoxFit.contain,
      errorBuilder:
          (_, __, ___) => LayoutBuilder(
            builder: (context, constraints) {
              final size = (constraints.maxHeight * 0.7).clamp(48.0, 200.0);
              return Icon(
                iconForVocabCategory(item.category),
                size: size.toDouble(),
                color: kTextSecondary,
              );
            },
          ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    super.key,
    required this.prefix,
    required this.item,
    required this.background,
    required this.locked,
    required this.correctFlash,
    required this.onTap,
    required this.onListen,
  });

  final String prefix;
  final VocabularyItem item;
  final Color background;

  /// เคยตอบผิดในข้อนี้ไปแล้ว — หรี่ลงและ controller ไม่รับซ้ำ
  final bool locked;
  final bool correctFlash;
  final VoidCallback onTap;

  /// กดฟังเสียงคำของช้อยส์นี้ (feedback ครู 2026-07-12) — ไม่ใช่การตอบ
  final VoidCallback onListen;

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
              // ไอคอนเล็กหน้าคำตอบ: ใช้รูปจริงถ้ามี ไม่มีใช้ไอคอนหมวด — ช่วยเด็ก
              // ที่ยังอ่านหนังสือไม่คล่องแยกตัวเลือกได้ (ตาม mockup)
              final iconSize = (constraints.maxHeight * 0.55).clamp(28.0, 48.0);
              final labelStyle =
                  constraints.maxHeight < 72
                      ? kChildLabel.copyWith(fontSize: 18, height: 1.2)
                      : kChildLabel;
              return Row(
                children: [
                  SizedBox(
                    width: iconSize.toDouble(),
                    height: iconSize.toDouble(),
                    child: Image.asset(
                      item.image,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) => Icon(
                            iconForVocabCategory(item.category),
                            size: iconSize.toDouble(),
                            color: kTextSecondary,
                          ),
                    ),
                  ),
                  const SizedBox(width: kSpace4),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$prefix. ${item.ttsWord}',
                        style: labelStyle,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: kSpace2),
                  _ListenButton(onTap: onListen),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
