import 'dart:math';
import 'dart:typed_data';

import 'package:daily_life/features/family_quiz/family_quiz_controller.dart';
import 'package:daily_life/models/family_card.dart';
import 'package:flutter_test/flutter_test.dart';

FamilyCard _card(String id, String answer, List<String> distractors) =>
    FamilyCard(
      id: id,
      imageBytes: Uint8List(0),
      answer: answer,
      distractors: distractors,
      createdAt: 0,
    );

void main() {
  group('FamilyQuizController', () {
    test('ตัวเลือก = คำตอบ + ตัวลวงที่ผู้ปกครองกำหนด', () {
      final c = FamilyQuizController(
        cards: [
          _card('1', 'แม่', ['พ่อ', 'พี่']),
        ],
        random: Random(1),
      );
      expect(c.currentQuestion.choices.toSet(), {'แม่', 'พ่อ', 'พี่'});
    });

    test('ตอบถูกทุกข้อ = 10 คะแนน 3 ดาว', () {
      final c = FamilyQuizController(
        cards: [
          _card('1', 'แม่', ['พ่อ', 'พี่']),
          _card('2', 'พ่อ', ['แม่', 'ปู่']),
        ],
        questionCount: 2,
        random: Random(1),
      );
      c.answer(c.currentQuestion.card.answer);
      final r = c.answer(c.currentQuestion.card.answer);
      expect(r.completed, isTrue);
      expect(c.score, 10);
      expect(c.starRating, 3);
    });

    test('ตอบผิดล็อกปุ่ม + คะแนนลดเป็น 8', () {
      final c = FamilyQuizController(
        cards: [
          _card('1', 'แม่', ['พ่อ', 'พี่']),
        ],
        questionCount: 1,
        random: Random(1),
      );
      final wrong = c.currentQuestion.choices.firstWhere((ch) => ch != 'แม่');
      expect(c.answer(wrong).correct, isFalse);
      expect(c.lockedChoices, contains(wrong));
      expect(c.answer(wrong).accepted, isFalse); // แตะซ้ำปุ่มที่ล็อกแล้ว
      expect(c.answer('แม่').completed, isTrue);
      expect(c.score, 8);
    });

    test('บันทึก MatchEvent ทุกครั้งที่ตอบ (ถูก/ผิด)', () {
      final c = FamilyQuizController(
        cards: [
          _card('1', 'แม่', ['พ่อ', 'พี่']),
        ],
        questionCount: 1,
        random: Random(1),
      );
      final wrong = c.currentQuestion.choices.firstWhere((ch) => ch != 'แม่');
      c.answer(wrong);
      c.answer('แม่');
      expect(c.answerEvents, hasLength(2));
      expect(c.answerEvents.where((e) => e.matched), hasLength(1));
    });
  });
}
