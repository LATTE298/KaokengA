import 'dart:math';

import '../../models/family_card.dart';
import '../../models/session_record.dart';

// เกม "หมวดครอบครัว" (เฟส 2.1) — logic ล้วน ไม่ผูก Flutter เพื่อ test ได้ตรงๆ
// เลียนแบบ VocabQuizController: โชว์รูปการ์ด → เลือกว่าเป็นใคร → ตอบผิดล็อกปุ่ม
// แล้วลองใหม่จนถูก (ไม่มี "แพ้") → คะแนน 10/8/6/4 ตามจำนวนผิด
//
// ต่างจาก vocab quiz: ตัวเลือกเป็น "ข้อความ" (answer + distractors ที่ผู้ปกครอง
// กำหนดเอง) ไม่ใช่คำจากหมวดเดียวกัน — และรูปมาจาก bytes (Hive) ไม่ใช่ asset
class FamilyQuizQuestion {
  FamilyQuizQuestion({required this.card, required this.choices});

  final FamilyCard card;

  /// ตัวเลือกทั้งหมด (answer + distractors สลับลำดับแล้ว)
  final List<String> choices;
}

class FamilyQuizTapResult {
  const FamilyQuizTapResult({
    required this.accepted,
    this.correct = false,
    this.completed = false,
  });

  final bool accepted;
  final bool correct;
  final bool completed;
}

class FamilyQuizController {
  FamilyQuizController({
    required List<FamilyCard> cards,
    this.questionCount = 5,
    Random? random,
    int Function()? elapsedMs,
  }) : _elapsedMs = elapsedMs ?? (() => 0) {
    _questions = _buildQuestions(cards, random ?? Random());
  }

  final int questionCount;
  final int Function() _elapsedMs;

  late final List<FamilyQuizQuestion> _questions;
  final List<MatchEvent> answerEvents = [];

  int _currentIndex = 0;
  bool _completed = false;

  /// ตัวเลือก (ข้อความ) ที่ตอบผิดไปแล้วในข้อปัจจุบัน — ล็อกกันกดซ้ำ
  final Set<String> lockedChoices = {};
  int wrongCount = 0;

  bool get completed => _completed;
  int get currentNumber => _currentIndex + 1;
  int get totalQuestions => _questions.length;
  FamilyQuizQuestion get currentQuestion => _questions[_currentIndex];

  FamilyQuizTapResult answer(String choice) {
    if (_completed || lockedChoices.contains(choice)) {
      return const FamilyQuizTapResult(accepted: false);
    }

    final question = currentQuestion;
    final correct = choice == question.card.answer;
    answerEvents.add(
      MatchEvent(
        pairId: question.card.id,
        matched: correct,
        atMs: _elapsedMs(),
      ),
    );

    if (!correct) {
      wrongCount++;
      lockedChoices.add(choice);
      return const FamilyQuizTapResult(accepted: true);
    }

    lockedChoices.clear();
    if (_currentIndex + 1 >= _questions.length) {
      _completed = true;
      return const FamilyQuizTapResult(
        accepted: true,
        correct: true,
        completed: true,
      );
    }
    _currentIndex++;
    return const FamilyQuizTapResult(accepted: true, correct: true);
  }

  /// เกณฑ์เดียวกับเกมอื่น: ไม่ผิดเลย=10, ผิด1=8, ผิด2=6, ตั้งแต่ 3=4
  int get score {
    if (wrongCount == 0) return 10;
    if (wrongCount == 1) return 8;
    if (wrongCount == 2) return 6;
    return 4;
  }

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

  List<FamilyQuizQuestion> _buildQuestions(
    List<FamilyCard> cards,
    Random random,
  ) {
    final pool = [...cards]..shuffle(random);
    final chosen = pool.take(min(questionCount, pool.length)).toList();
    return chosen.map((card) {
      // โหมดสุ่ม: ตัวลวงมาจากคำตอบของสมาชิกครอบครัวคนอื่น (สุ่มไม่เกิน 2)
      // โหมดปกติ: ใช้ตัวลวงที่ผู้ปกครองกรอกเอง
      final distractors =
          card.randomChoices
              ? _randomDistractors(card, cards, random)
              : card.distractors;
      final choices = [card.answer, ...distractors]..shuffle(random);
      return FamilyQuizQuestion(card: card, choices: choices);
    }).toList();
  }

  // คำเรียกญาติพื้นฐาน — ใช้เป็นตัวลวง "สำรอง" ในโหมดสุ่มเมื่อการ์ดในคลังยังน้อย
  // (< 3 ใบ) เพื่อให้มีตัวเลือกครบ 3 ปุ่มเสมอ ไม่เจอเกมปุ่มเดียว. เป็นทางแก้ชั่วคราว
  // จนกว่าจะมีสมาชิกจริงมากพอ — ตัวลวงจริงจากการ์ดอื่นถูกใช้ก่อนคำเหล่านี้เสมอ
  static const List<String> basicFamilyWords = [
    'พ่อ',
    'แม่',
    'พี่',
    'น้อง',
    'ปู่',
    'ย่า',
    'ตา',
    'ยาย',
    'ลุง',
    'ป้า',
    'น้า',
    'อา',
  ];

  // ตัวลวงโหมดสุ่ม: เอา "คำตอบของการ์ดอื่น" มาก่อน (ไม่ซ้ำคำตอบข้อนี้) สูงสุด 2 ตัว
  // ถ้ายังไม่ครบ 2 (การ์ดในคลัง < 3) เติมจาก basicFamilyWords ให้ครบ — กันซ้ำทั้ง
  // คำตอบข้อนี้และตัวลวงที่เลือกไปแล้ว
  List<String> _randomDistractors(
    FamilyCard card,
    List<FamilyCard> allCards,
    Random random,
  ) {
    final others =
        allCards
            .map((c) => c.answer)
            .where((name) => name != card.answer)
            .toSet()
            .toList()
          ..shuffle(random);
    final chosen = <String>{...others.take(2)};

    if (chosen.length < 2) {
      final fillers =
          basicFamilyWords
              .where((w) => w != card.answer && !chosen.contains(w))
              .toList()
            ..shuffle(random);
      for (final w in fillers) {
        if (chosen.length >= 2) break;
        chosen.add(w);
      }
    }
    return chosen.toList();
  }
}
