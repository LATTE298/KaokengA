import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:daily_life/screens/child/module_b_screen.dart';
import 'package:daily_life/theme/colors.dart';
import 'package:daily_life/theme/spacing.dart';
import 'package:daily_life/widgets/child/child_async_view.dart';
import 'package:daily_life/widgets/child/module_card.dart';
import 'package:daily_life/widgets/child/pressable_child_card.dart';
import 'package:daily_life/widgets/child/scenario_card.dart';
import 'package:daily_life/widgets/child/vocab_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('PressableChildCard invokes tap callback', (tester) async {
    var taps = 0;
    await _pumpOnStage(
      tester,
      PressableChildCard(
        onTap: () => taps++,
        child: const SizedBox(width: 80, height: 80, child: Text('Tap')),
      ),
    );

    await tester.tap(find.text('Tap'));
    // ให้ timer กันกดซ้ำ (kTapCooldown) ใน PressableChildCard หมดอายุก่อนจบ test
    // ไม่งั้น flutter_test ฟ้อง "A Timer is still pending"
    await tester.pump(kTapCooldown);

    expect(taps, 1);
  });

  testWidgets('ModuleCard renders label and triggers callback', (tester) async {
    var taps = 0;
    await _pumpOnStage(
      tester,
      ModuleCard(
        label: 'Module A',
        description: 'ลองทำกิจกรรม',
        icon: Icons.home_rounded,
        background: kYellowLight,
        onTap: () => taps++,
        cardWidth: 220,
      ),
    );

    expect(find.text('Module A'), findsOneWidget);
    await tester.tap(find.text('Module A'));
    await tester.pump(kTapCooldown);
    expect(taps, 1);
  });

  testWidgets('ScenarioCard renders label and triggers callback', (
    tester,
  ) async {
    var taps = 0;
    await _pumpOnStage(
      tester,
      ScenarioCard(
        summary: const ScenarioSummary(
          scenarioId: 'known',
          titleTh: 'ซื้อนม',
          category: 'daily_life',
          module: 'A',
          configUrl: 'assets/scenarios/known.json',
          thumbnailUrl: 'assets/images/known.webp',
          version: 1,
          published: true,
        ),
        onTap: () => taps++,
        cardHeight: 240,
      ),
    );

    expect(find.text('ซื้อนม'), findsOneWidget);
    await tester.tap(find.text('ซื้อนม'));
    await tester.pump(kTapCooldown);
    expect(taps, 1);
  });

  testWidgets('VocabCard renders word and triggers callback', (tester) async {
    var tappedWord = '';
    await tester.pumpWidget(
      _wrap(
        VocabCard(
          item: const VocabularyItem(
            itemId: 'cat',
            image: 'assets/images/cat.webp',
            ttsWord: 'แมว',
            category: 'animals',
          ),
          onTap: (item) async => tappedWord = item.ttsWord,
        ),
      ),
    );

    expect(find.text('แมว'), findsOneWidget);
    await tester.tap(find.text('แมว'));
    await tester.pump(const Duration(seconds: 1));
    expect(tappedWord, 'แมว');
  });

  testWidgets('VocabCard scales down inside a small grid cell', (tester) async {
    // ช่องเล็กระดับที่เจอบนจอแคบ — เดิม (ไอคอน 48 + kChildLabel 22) ล้นช่องแบบนี้
    // ถ้าล้น flutter_test จะ throw RenderFlex overflow ให้ test fail เอง
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 80,
          height: 80,
          child: VocabCard(
            item: const VocabularyItem(
              itemId: 'toothbrush',
              image: 'assets/images/toothbrush.webp',
              ttsWord: 'แปรงสีฟัน',
              category: 'household',
            ),
            onTap: (_) async {},
          ),
        ),
      ),
    );

    expect(find.text('แปรงสีฟัน'), findsOneWidget);
  });

  testWidgets('ModuleBScreen fits a short landscape screen', (tester) async {
    // จอเตี้ยอ้างอิง Samsung S8+ แนวนอน — การ์ดต้องย่อตามพื้นที่ ไม่ล้นจอ
    await tester.binding.setSurfaceSize(const Size(740, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ModuleBScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PressableChildCard), findsOneWidget);
  });

  testWidgets('ChildAsyncView renders loading, error, empty, and data states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ChildAsyncView<List<String>>(
          value: const AsyncLoading(),
          loading: const Text('Loading'),
          data: (items) => Text(items.single),
        ),
      ),
    );
    expect(find.text('Loading'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        ChildAsyncView<List<String>>(
          value: AsyncError(Exception('bad'), StackTrace.empty),
          error: (_, __) => const Text('Error'),
          data: (items) => Text(items.single),
        ),
      ),
    );
    expect(find.text('Error'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        ChildAsyncView<List<String>>(
          value: const AsyncData([]),
          isEmpty: (items) => items.isEmpty,
          empty: const Text('Empty'),
          data: (items) => Text(items.single),
        ),
      ),
    );
    expect(find.text('Empty'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        ChildAsyncView<List<String>>(
          value: const AsyncData(['Ready']),
          data: (items) => Text(items.single),
        ),
      ),
    );
    expect(find.text('Ready'), findsOneWidget);
  });
}

// pump บนจอขนาดแน่นอน 900x600 (แนวนอน — แอปล็อก landscape) การ์ดฝั่งเด็กคำนวณขนาด
// แบบ responsive จากพื้นที่จริง จึงต้องล็อกขนาดจอ test ไว้ ไม่ให้ layout เพี้ยน/ล้นแบบสุ่ม
Future<void> _pumpOnStage(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(900, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_wrap(child));
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}
