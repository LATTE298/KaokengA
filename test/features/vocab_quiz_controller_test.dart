import 'dart:math';

import 'package:daily_life/features/vocab_quiz/vocab_quiz_controller.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VocabQuizController', () {
    test('builds unique questions with the answer among 3 choices', () {
      final controller = VocabQuizController(
        items: _items(),
        random: Random(7),
      );

      expect(controller.totalQuestions, 5);
      final seenAnswers = <String>{};
      for (var i = 0; i < controller.totalQuestions; i++) {
        final q = controller.currentQuestion;
        expect(seenAnswers.add(q.answer.itemId), isTrue, reason: 'โจทย์ห้ามซ้ำ');
        expect(q.choices, hasLength(3));
        expect(
          q.choices.map((c) => c.itemId).toSet(),
          hasLength(3),
          reason: 'ตัวเลือกห้ามซ้ำ',
        );
        expect(
          q.choices.any((c) => c.itemId == q.answer.itemId),
          isTrue,
          reason: 'คำตอบต้องอยู่ในตัวเลือกเสมอ',
        );
        controller.answer(q.answer.itemId); // ไปข้อถัดไป
      }
      expect(controller.completed, isTrue);
    });

    test('prefers distractors from the same category', () {
      final controller = VocabQuizController(
        items: _items(),
        random: Random(3),
      );

      for (var i = 0; i < controller.totalQuestions; i++) {
        final q = controller.currentQuestion;
        for (final choice in q.choices) {
          expect(
            choice.category,
            q.answer.category,
            reason: 'หมวดละ 6 คำ มีตัวลวงหมวดเดียวกันพอเสมอ',
          );
        }
        controller.answer(q.answer.itemId);
      }
    });

    test('correct answer advances and records a matched event', () {
      final controller = VocabQuizController(
        items: _items(),
        random: Random(1),
        elapsedMs: () => 1234,
      );
      final answerId = controller.currentQuestion.answer.itemId;

      final result = controller.answer(answerId);

      expect(result.accepted, isTrue);
      expect(result.correct, isTrue);
      expect(result.completed, isFalse);
      expect(controller.currentNumber, 2);
      final event = controller.answerEvents.single;
      expect(event.pairId, answerId);
      expect(event.matched, isTrue);
      expect(event.atMs, 1234);
    });

    test('wrong answer locks the choice and stays on the question', () {
      final controller = VocabQuizController(
        items: _items(),
        random: Random(1),
      );
      final q = controller.currentQuestion;
      final wrongId =
          q.choices.firstWhere((c) => c.itemId != q.answer.itemId).itemId;

      final result = controller.answer(wrongId);

      expect(result.accepted, isTrue);
      expect(result.correct, isFalse);
      expect(controller.currentNumber, 1, reason: 'ยังอยู่ข้อเดิม');
      expect(controller.lockedChoiceIds, contains(wrongId));
      expect(controller.wrongCount, 1);
      expect(controller.answerEvents.single.matched, isFalse);
      expect(
        controller.answerEvents.single.pairId,
        q.answer.itemId,
        reason: 'event ผูกกับคำที่ถูกถาม ไม่ใช่การ์ดที่กด',
      );

      // กดการ์ดที่ล็อกแล้วซ้ำ — ต้องไม่นับอะไรเพิ่ม
      expect(controller.answer(wrongId).accepted, isFalse);
      expect(controller.wrongCount, 1);

      // ตอบถูกแล้วล็อกต้องเคลียร์ พร้อมไปข้อถัดไป
      controller.answer(q.answer.itemId);
      expect(controller.currentNumber, 2);
      expect(controller.lockedChoiceIds, isEmpty);
    });

    test('scores follow the Module A tiers by total wrong answers', () {
      int scoreWithWrongs(int wrongs) {
        final controller = VocabQuizController(
          items: _items(),
          random: Random(5),
        );
        var remainingWrongs = wrongs;
        while (!controller.completed) {
          final q = controller.currentQuestion;
          if (remainingWrongs > 0) {
            final wrongId =
                q.choices
                    .firstWhere((c) => c.itemId != q.answer.itemId)
                    .itemId;
            controller.answer(wrongId);
            remainingWrongs--;
          }
          controller.answer(q.answer.itemId);
        }
        return controller.score;
      }

      expect(scoreWithWrongs(0), 10);
      expect(scoreWithWrongs(1), 8);
      expect(scoreWithWrongs(2), 6);
      expect(scoreWithWrongs(3), 4);
    });

    test('star rating mirrors the memory game mapping', () {
      final controller = VocabQuizController(
        items: _items(),
        random: Random(2),
      );
      while (!controller.completed) {
        controller.answer(controller.currentQuestion.answer.itemId);
      }
      expect(controller.score, 10);
      expect(controller.starRating, 3);
    });
  });
}

// คลังคำจำลอง 2 หมวด หมวดละ 6 คำ (โครงเดียวกับ vocabulary.json จริง)
List<VocabularyItem> _items() {
  return [
    for (var i = 0; i < 6; i++)
      VocabularyItem(
        itemId: 'animal_$i',
        image: 'assets/images/a$i.webp',
        ttsWord: 'สัตว์$i',
        category: 'animals',
      ),
    for (var i = 0; i < 6; i++)
      VocabularyItem(
        itemId: 'food_$i',
        image: 'assets/images/f$i.webp',
        ttsWord: 'อาหาร$i',
        category: 'food',
      ),
  ];
}
