import 'package:daily_life/screens/child/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('HomeScreen โชว์ชื่อแอป + ปุ่มเริ่มเล่น + ปุ่มผู้ปกครอง', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 820));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );

    expect(find.text('ก้าวเก่ง'), findsOneWidget);
    expect(find.text('เริ่มเล่น'), findsOneWidget);
    expect(find.text('ผู้ปกครอง'), findsOneWidget);
  });
}
