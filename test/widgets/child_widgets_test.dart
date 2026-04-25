import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:daily_life/theme/colors.dart';
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
    await tester.pumpWidget(
      _wrap(
        PressableChildCard(
          onTap: () => taps++,
          child: const SizedBox(width: 80, height: 80, child: Text('Tap')),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));

    expect(taps, 1);
  });

  testWidgets('ModuleCard renders label and triggers callback', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        ModuleCard(
          label: 'Module A',
          description: 'ลองทำกิจกรรม',
          icon: Icons.home_rounded,
          background: kYellowLight,
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('Module A'), findsOneWidget);
    await tester.tap(find.text('Module A'));
    expect(taps, 1);
  });

  testWidgets('ScenarioCard renders label and triggers callback', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
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
        ),
      ),
    );

    expect(find.text('ซื้อนม'), findsOneWidget);
    await tester.tap(find.text('ซื้อนม'));
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

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}
