import 'dart:io';

import 'package:daily_life/providers/rewards_provider.dart';
import 'package:daily_life/providers/streak_provider.dart'
    show kAppPrefsBoxName;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('RewardsStatsNotifier (Hive-backed)', () {
    late Directory dir;

    setUpAll(() {
      dir = Directory.systemTemp.createTempSync('rewards_hive_test');
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

    test('เริ่มต้นว่างเปล่า', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final s = container.read(rewardsStatsProvider);
      expect(s.gamesCompleted, 0);
      expect(s.modulesPlayed, isEmpty);
      expect(s.bestStreak, 0);
    });

    test('recordCompletion นับจำนวนครั้ง + จำ module (กันซ้ำ) + persist', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(rewardsStatsProvider.notifier);
      notifier.recordCompletion('memory');
      notifier.recordCompletion('memory'); // module ซ้ำ
      notifier.recordCompletion('vocab');

      final s = container.read(rewardsStatsProvider);
      expect(s.gamesCompleted, 3); // นับทุกครั้งที่เล่นจบ
      expect(s.modulesPlayed, {'memory', 'vocab'}); // แต่ module ไม่ซ้ำ

      // persist ข้าม container
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);
      final s2 = container2.read(rewardsStatsProvider);
      expect(s2.gamesCompleted, 3);
      expect(s2.modulesPlayed, {'memory', 'vocab'});
    });

    test('bestStreak: อ่าน best_streak, fallback เป็นสตรีคปัจจุบันถ้ามากกว่า', () {
      final box = Hive.box<dynamic>(kAppPrefsBoxName);

      box.put('best_streak', 5);
      box.put('streak_days', 3);
      final c1 = ProviderContainer();
      addTearDown(c1.dispose);
      expect(c1.read(rewardsStatsProvider).bestStreak, 5);

      // best ยังไม่ถูกเขียน แต่สตรีคปัจจุบันสูงกว่า → ใช้ค่าปัจจุบัน
      box.put('best_streak', 2);
      box.put('streak_days', 4);
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      expect(c2.read(rewardsStatsProvider).bestStreak, 4);
    });
  });

  group('box ยังไม่เปิด (กันไม่ให้ crash)', () {
    test('recordCompletion ไม่ throw + อัปเดต state ในหน่วยความจำ', () {
      // ไม่เปิด box `app_prefs` เลย (เหมือน widget test ที่ไม่ตั้ง Hive)
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container
            .read(rewardsStatsProvider.notifier)
            .recordCompletion('memory'),
        returnsNormally,
      );
      final s = container.read(rewardsStatsProvider);
      expect(s.gamesCompleted, 1);
      expect(s.modulesPlayed, {'memory'});
    });
  });
}
