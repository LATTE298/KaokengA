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
      final choices = [card.answer, ...card.distractors]..shuffle(random);
      return FamilyQuizQuestion(card: card, choices: choices);
    }).toList();
  }
}
