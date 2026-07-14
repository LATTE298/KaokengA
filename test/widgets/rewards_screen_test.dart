import 'dart:io';

import 'package:daily_life/features/rewards/rewards_catalog.dart';
import 'package:daily_life/providers/streak_provider.dart'
    show kAppPrefsBoxName;
import 'package:daily_life/screens/child/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

Future<void> _pumpRewards(WidgetTester tester) async {
  // จอเด็กเป็นแนวนอน — ตรึงขนาดจอเตี้ยเพื่อจับ overflow ถ้ามี
  await tester.binding.setSurfaceSize(const Size(900, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: RewardsScreen())),
  );
  // pump เปล่า 2 เฟรม (ไม่ใช้ pumpAndSettle) — เรนเดอร์เฟรมแรกพอตรวจโครง/overflow แล้ว
  // และไม่รอ settle จึงค้างไม่ได้ แม้การ์ดที่ปลดล็อกจะห่อ PressableChildCard (implicit anim)
  await tester.pump();
  await tester.pump();
}

void main() {
  late Directory dir;

  setUpAll(() {
    // กัน google_fonts โหลดฟอนต์ผ่านเน็ตระหว่างเทสต์ (ไม่งั้น pump/settle ค้างรอ HTTP) —
    // ทำเหมือนเทสต์หน้าจออื่นในโปรเจกต์
    GoogleFonts.config.allowRuntimeFetching = false;
    dir = Directory.systemTemp.createTempSync('rewards_screen_hive_test');
    Hive.init(dir.path);
  });

  setUp(() async {
    final box = await Hive.openBox<dynamic>(kAppPrefsBoxName);
    await box.clear();
  });

  tearDown(() async {
    if (Hive.isBoxOpen(kAppPrefsBoxName)) {
      await Hive.box<dynamic>(kAppPrefsBoxName).close();
    }
  });

  tearDownAll(() {
    dir.deleteSync(recursive: true);
  });

  testWidgets('เริ่มต้น (0 ดาว) เรนเดอร์ครบ 2 ส่วน ไม่มี overflow', (
    tester,
  ) async {
    await _pumpRewards(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('รางวัลของฉัน'), findsOneWidget);
    expect(find.text('สมุดสะสมสติกเกอร์'), findsOneWidget);
    expect(find.text('เหรียญรางวัล'), findsOneWidget);
    // ยังไม่ได้ดาว → ชวนเก็บอีก 1 ช่วง + เหรียญแรกยังล็อกโชว์ความคืบหน้า 0/1
    expect(find.text('อีก $kStarsPerSticker ดาว ได้สติกเกอร์ใบใหม่!'),
        findsOneWidget);
    expect(find.text('เล่นเกมแรก'), findsOneWidget);
  });

  // หมายเหตุ: การเรนเดอร์สถานะ "ปลดล็อกแล้ว" เทสต์ใน flutter_tester ไม่ได้ เพราะการ์ดที่ปลด
  // ล็อกโชว์ emoji (🐱🏆…) ซึ่ง test runner ไม่มีฟอนต์ emoji สี → เรนเดอร์ค้าง. บน Android
  // จริงมี NotoColorEmoji เรนเดอร์ปกติ. ตรรกะการปลดล็อกคุมด้วย unit test ใน
  // test/features/rewards/rewards_catalog_test.dart แล้ว
}
