import 'dart:io';

import 'package:daily_life/providers/child_profile_provider.dart';
import 'package:daily_life/providers/streak_provider.dart'
    show kAppPrefsBoxName;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('resolveChildName (pure)', () {
    test('ว่าง/null/เว้นวรรคล้วน → ชื่อเริ่มต้น', () {
      expect(resolveChildName(null), kDefaultChildName);
      expect(resolveChildName(''), kDefaultChildName);
      expect(resolveChildName('   '), kDefaultChildName);
    });

    test('มีชื่อจริง → ตัดช่องว่างหัวท้าย', () {
      expect(resolveChildName('น้องดาว'), 'น้องดาว');
      expect(resolveChildName('  น้องเก่ง  '), 'น้องเก่ง');
    });
  });

  group('Notifier (Hive-backed)', () {
    late Directory dir;

    setUpAll(() {
      dir = Directory.systemTemp.createTempSync('child_profile_hive_test');
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

    test('ชื่อเด็ก: เริ่มต้น default, setName เก็บลง Hive + อัปเดต state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(childNameProvider), kDefaultChildName);

      container.read(childNameProvider.notifier).setName('น้องเก่ง');
      expect(container.read(childNameProvider), 'น้องเก่ง');
      // อ่านผ่าน container ใหม่ = ต้องได้จาก Hive (persist จริง)
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      expect(container2.read(childNameProvider), 'น้องเก่ง');
    });

    test('ชื่อเด็ก: setName ว่าง = กลับไปใช้ default + ลบออกจาก Hive', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(childNameProvider.notifier).setName('น้องดาว');
      container.read(childNameProvider.notifier).setName('   ');
      expect(container.read(childNameProvider), kDefaultChildName);
    });

    test(
      'ดาวสะสม: เริ่มที่ 0, award บวกสะสม + persist, award(0) ไม่ทำอะไร',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(totalStarsProvider), 0);

        container.read(totalStarsProvider.notifier).award(3);
        container.read(totalStarsProvider.notifier).award(2);
        expect(container.read(totalStarsProvider), 5);

        container.read(totalStarsProvider.notifier).award(0);
        container.read(totalStarsProvider.notifier).award(-1);
        expect(container.read(totalStarsProvider), 5);

        // persist ข้าม container
        final container2 = ProviderContainer();
        addTearDown(container2.dispose);
        expect(container2.read(totalStarsProvider), 5);
      },
    );
  });

  group('box ยังไม่เปิด (กันไม่ให้ crash)', () {
    test('childName คืน default, award ไม่ throw', () {
      // ไม่มีการเปิด box `app_prefs` เลย — ต้องไม่พังเหมือน widget test ที่ไม่ตั้ง Hive
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(childNameProvider), kDefaultChildName);
      expect(
        () => container.read(totalStarsProvider.notifier).award(3),
        returnsNormally,
      );
      // state ในหน่วยความจำยังบวกได้ แม้ไม่ persist
      expect(container.read(totalStarsProvider), 3);
    });
  });
}
