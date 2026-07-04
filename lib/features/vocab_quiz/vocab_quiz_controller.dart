import 'dart:math';

import '../../models/session_record.dart';
import '../../models/vocabulary_item.dart';

// เกมตอบคำถามคำศัพท์ (Module C ตามเอกสารข้อเสนอ: โชว์คำ/ฟังเสียง → เลือกการ์ด
// → ให้คะแนน) — logic ล้วน ไม่ผูก Flutter เพื่อให้ test ได้ตรงๆ แบบเดียวกับ
// MemoryGameController
//
// กติกา: ตอบผิดได้ไม่จำกัด (การ์ดที่ผิดโดนล็อก แล้วลองใหม่จนถูกจึงไปข้อถัดไป —
// เด็กได้จบทุกข้อด้วยความสำเร็จเสมอ) แต่ทุกการตอบถูกบันทึกเป็น MatchEvent
// (pairId = คำที่ถูกถาม, matched = ตอบถูกไหม) เพื่อให้ dashboard เฟส 2.2
// มีข้อมูลถูก/ผิดรายคำไปทำกราฟพัฒนาการ
class VocabQuizQuestion {
  VocabQuizQuestion({required this.answer, required this.choices});

  final VocabularyItem answer;

  /// ตัวเลือกทั้งหมด (รวมคำตอบ สลับลำดับแล้ว) — 3 ใบตามเอกสาร (ก/ข/ค)
  final List<VocabularyItem> choices;
}

class VocabQuizTapResult {
  const VocabQuizTapResult({
    required this.accepted,
    this.correct = false,
    this.completed = false,
  });

  /// false = แตะตัวเลือกที่ถูกล็อกไปแล้ว/เกมจบแล้ว — ไม่นับอะไรทั้งนั้น
  final bool accepted;
  final bool correct;

  /// ตอบข้อสุดท้ายถูก → จบเกม
  final bool completed;
}

class VocabQuizController {
  VocabQuizController({
    required List<VocabularyItem> items,
    this.questionCount = 5,
    this.choiceCount = 3,
    Random? random,
    int Function()? elapsedMs,
  }) : _elapsedMs = elapsedMs ?? (() => 0) {
    _questions = _buildQuestions(items, random ?? Random());
  }

  final int questionCount;
  final int choiceCount;
  final int Function() _elapsedMs;

  late final List<VocabQuizQuestion> _questions;
  final List<MatchEvent> answerEvents = [];

  int _currentIndex = 0;
  bool _completed = false;

  /// itemId ของตัวเลือกที่ตอบผิดไปแล้วในข้อปัจจุบัน (ล็อกไว้กันกดซ้ำ)
  final Set<String> lockedChoiceIds = {};

  /// จำนวนการตอบผิดสะสมทั้งเกม (ใช้คิดคะแนน)
  int wrongCount = 0;

  bool get completed => _completed;

  int get currentNumber => _currentIndex + 1; // เลขข้อแบบ 1-based สำหรับ UI

  int get totalQuestions => _questions.length;

  VocabQuizQuestion get currentQuestion => _questions[_currentIndex];

  VocabQuizTapResult answer(String itemId) {
    if (_completed || lockedChoiceIds.contains(itemId)) {
      return const VocabQuizTapResult(accepted: false);
    }

    final question = currentQuestion;
    final correct = itemId == question.answer.itemId;
    answerEvents.add(
      MatchEvent(
        pairId: question.answer.itemId,
        matched: correct,
        atMs: _elapsedMs(),
      ),
    );

    if (!correct) {
      wrongCount++;
      lockedChoiceIds.add(itemId);
      return const VocabQuizTapResult(accepted: true);
    }

    lockedChoiceIds.clear();
    if (_currentIndex + 1 >= _questions.length) {
      _completed = true;
      return const VocabQuizTapResult(
        accepted: true,
        correct: true,
        completed: true,
      );
    }
    _currentIndex++;
    return const VocabQuizTapResult(accepted: true, correct: true);
  }

  /// เกณฑ์เดียวกับ Module A (spec 1.2): นับจำนวนครั้งที่ตอบผิดทั้งเกม
  /// ไม่ผิดเลย=10, ผิด1=8, ผิด2=6, ตั้งแต่ 3 ขึ้นไป=4
  int get score {
    if (wrongCount == 0) return 10;
    if (wrongCount == 1) return 8;
    if (wrongCount == 2) return 6;
    return 4;
  }

  /// แปลงคะแนนเป็นดาว 0-3 ดวง (เกณฑ์เดียวกับ Module B)
  int get starRating {
    switch (score) {
      case 10:
        return 3;
      case 8:
        return 2;
      case 6:
        return 1;
      default:
        return 0;
    }
  }

  List<VocabQuizQuestion> _buildQuestions(
    List<VocabularyItem> items,
    Random random,
  ) {
    assert(items.length >= choiceCount, 'คลังคำต้องมีอย่างน้อย $choiceCount คำ');
    final pool = [...items]..shuffle(random);
    final answers = pool.take(min(questionCount, pool.length)).toList();

    return answers.map((answer) {
      // ตัวลวงเอาจากหมวดเดียวกันก่อน (แยกยากกว่า = ได้เรียนรู้จริง และเมื่อรูปจริง
      // มาแทน placeholder จะยิ่งมีความหมาย) — หมวดละ 6 คำ จึงมีให้เลือกพอเสมอ
      // แต่กันเคสข้อมูลอนาคต (เช่น แพ็คคัสตอม) ด้วยการเติมจากหมวดอื่นถ้าไม่พอ
      final sameCategory =
          items
              .where(
                (i) =>
                    i.category == answer.category &&
                    i.itemId != answer.itemId,
              )
              .toList()
            ..shuffle(random);
      final others =
          items
              .where(
                (i) =>
                    i.category != answer.category &&
                    i.itemId != answer.itemId,
              )
              .toList()
            ..shuffle(random);
      final distractors =
          [...sameCategory, ...others].take(choiceCount - 1).toList();

      final choices = [answer, ...distractors]..shuffle(random);
      return VocabQuizQuestion(answer: answer, choices: choices);
    }).toList();
  }
}
