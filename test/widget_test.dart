import 'package:daily_life/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('DailyLifeApp builds the initial splash route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DailyLifeApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('ชีวิตประจำวัน'), findsOneWidget);
  });
}
