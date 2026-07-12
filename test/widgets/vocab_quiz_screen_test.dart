import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:daily_life/providers/auth_provider.dart';
import 'package:daily_life/providers/content_providers.dart';
import 'package:daily_life/providers/session_provider.dart';
import 'package:daily_life/providers/sfx_provider.dart';
import 'package:daily_life/providers/tts_provider.dart';
import 'package:daily_life/screens/child/module_c_screen.dart';
import 'package:daily_life/screens/child/vocab_quiz_screen.dart';
import 'package:daily_life/screens/child/vocab_quiz_select_screen.dart';
import 'package:daily_life/services/session_repository.dart';
import 'package:daily_life/services/sfx_player.dart';
import 'package:daily_life/services/tts_service.dart';
import 'package:daily_life/theme/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ModuleCScreen hub shows both vocabulary modes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ModuleCScreen())),
    );

    expect(find.text('ฟังเสียงคำศัพท์'), findsOneWidget);
    expect(find.text('เกมตอบคำถาม'), findsOneWidget);
  });

  testWidgets('VocabQuizSelectScreen lists every category', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vocabularyProvider.overrideWith((ref) => Future.value(_items)),
        ],
        child: const MaterialApp(home: VocabQuizSelectScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // fixture มีแค่ 2 หมวด — การ์ดต้องขึ้นตามหมวดที่มีจริงเท่านั้น
    expect(find.byKey(const Key('quiz_cat_animals')), findsOneWidget);
    expect(find.byKey(const Key('quiz_cat_food')), findsOneWidget);
    expect(find.text('สัตว์'), findsOneWidget);
    expect(find.text('อาหาร'), findsOneWidget);
    expect(find.byKey(const Key('quiz_cat_drinks')), findsNothing);
  });

  group('VocabQuizScreen', () {
    testWidgets('advances to the next question on a correct answer', (
      tester,
    ) async {
      await _pumpQuiz(tester, _FakeSessionWriter(), _FakeSpeaker());

      expect(_progressText(tester), 'ข้อ 1/5');
      await _answerCurrentQuestionCorrectly(tester);
      expect(_progressText(tester), 'ข้อ 2/5');
    });

    testWidgets('wrong answer stays on the question until answered right', (
      tester,
    ) async {
      final sfx = _FakeSfx();
      await _pumpQuiz(tester, _FakeSessionWriter(), _FakeSpeaker(), sfx: sfx);

      final answer = _currentAnswerItem(tester);
      final wrongId = _visibleChoiceIds(
        tester,
      ).firstWhere((id) => id != answer.itemId);
      await tester.tap(find.byKey(Key('choice_$wrongId')));
      await tester.pump();
      await tester.pump(kTapCooldown);

      expect(_progressText(tester), 'ข้อ 1/5', reason: 'ตอบผิดต้องอยู่ข้อเดิม');
      expect(sfx.played, [kSfxWrong], reason: 'ตอบผิดต้องมีเสียงเอฟเฟกต์');

      await _answerCurrentQuestionCorrectly(tester);
      expect(_progressText(tester), 'ข้อ 2/5');
      expect(sfx.played, [
        kSfxWrong,
        kSfxRight,
      ], reason: 'ตอบถูกเล่นเสียงถูก ต่อจากเสียงผิดเดิม');
    });

    testWidgets('completing the quiz records a session and shows the result', (
      tester,
    ) async {
      final writer = _FakeSessionWriter();
      await _pumpQuiz(tester, writer, _FakeSpeaker());

      for (var i = 0; i < 5; i++) {
        await _answerCurrentQuestionCorrectly(tester);
      }

      expect(find.text('เก่งมากเลย!'), findsOneWidget);
      expect(find.text('ตอบครบ 5 ข้อ'), findsOneWidget);

      final record = writer.records.single;
      expect(record.module, kModuleVocab);
      expect(record.scenarioId, 'quiz_animals');
      expect(record.completed, isTrue);
      expect(record.score, 10);
      expect(record.stars, 3);
      expect(record.matchEvents, hasLength(5));
      expect(record.matchEvents!.every((e) => e.matched), isTrue);
    });
  });
}

// --- helpers ----------------------------------------------------------------

final _items = [
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

Future<void> _pumpQuiz(
  WidgetTester tester,
  SessionWriter writer,
  TtsSpeaker speaker, {
  SfxPlayer? sfx,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        vocabularyProvider.overrideWith((ref) => Future.value(_items)),
        ttsServiceProvider.overrideWithValue(speaker),
        sfxPlayerProvider.overrideWithValue(sfx ?? const NoOpSfxPlayer()),
        sessionRepositoryProvider.overrideWithValue(writer),
        uidProvider.overrideWithValue('uid-1'),
      ],
      child: const MaterialApp(home: VocabQuizScreen(category: 'animals')),
    ),
  );
  // รอ vocabularyProvider (Future) แล้วเลือกโหมด "เลือกคำ" (เทสต์ชุดนี้ครอบเส้นทาง
  // ช้อยส์เป็นคำ) จากนั้นบอร์ดจึงขึ้น
  await tester.pump();
  await tester.pump();
  await tester.tap(find.byKey(const Key('quiz_mode_words')));
  await tester.pump();
  await tester.pump();
}

String _progressText(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('quiz_progress'))).data!;
}

VocabularyItem _currentAnswerItem(WidgetTester tester) {
  // โจทย์ไม่โชว์คำตอบเป็นตัวหนังสือแล้ว (โชว์รูป) — อ่านจาก key ของรูปโจทย์แทน
  for (final item in _items) {
    if (tester.any(find.byKey(Key('quiz_image_${item.itemId}')))) return item;
  }
  fail('ไม่พบรูปโจทย์บนหน้าจอ');
}

List<String> _visibleChoiceIds(WidgetTester tester) {
  return [
    for (final item in _items)
      if (tester.any(find.byKey(Key('choice_${item.itemId}')))) item.itemId,
  ];
}

Future<void> _answerCurrentQuestionCorrectly(WidgetTester tester) async {
  final answer = _currentAnswerItem(tester);
  await tester.tap(find.byKey(Key('choice_${answer.itemId}')));
  await tester.pump();
  // ผ่านช่วง flash เขียว + delay เปลี่ยนข้อ (1200ms) + cooldown กันกดซ้ำของการ์ด
  await tester.pump(const Duration(milliseconds: 1300));
  await tester.pump(kTapCooldown);
}

class _FakeSpeaker implements TtsSpeaker {
  final spoken = <String>[];

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeSessionWriter implements SessionWriter {
  final records = <SessionRecord>[];

  @override
  Future<void> writeSession(SessionRecord record) async {
    records.add(record);
  }
}

class _FakeSfx implements SfxPlayer {
  final played = <String>[];

  @override
  Future<void> play(String assetPath) async {
    played.add(assetPath);
  }

  @override
  Future<void> dispose() async {}
}
