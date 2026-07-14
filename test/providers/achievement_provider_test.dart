import 'package:daily_life/providers/achievement_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AchievementNotice _notice(String id) =>
    AchievementNotice(id: id, emoji: '⭐', title: 't', subtitle: id);

void main() {
  group('AchievementQueueNotifier', () {
    test('เริ่มต้นคิวว่าง', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(achievementQueueProvider), isEmpty);
    });

    test('enqueue ต่อท้าย + enqueue ว่างไม่ทำอะไร', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(achievementQueueProvider.notifier);

      n.enqueue([_notice('a'), _notice('b')]);
      expect(c.read(achievementQueueProvider).map((e) => e.id), ['a', 'b']);

      n.enqueue([]);
      expect(c.read(achievementQueueProvider).length, 2);
    });

    test('กัน id ซ้ำที่ยังค้างในคิว', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(achievementQueueProvider.notifier);

      n.enqueue([_notice('a'), _notice('a'), _notice('b')]);
      expect(c.read(achievementQueueProvider).map((e) => e.id), ['a', 'b']);

      n.enqueue([_notice('b'), _notice('c')]); // b ยังค้าง → ข้าม
      expect(c.read(achievementQueueProvider).map((e) => e.id), ['a', 'b', 'c']);
    });

    test('dismissFirst ปลดใบแรก + คิวว่างเรียกได้ไม่พัง', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(achievementQueueProvider.notifier);

      n.enqueue([_notice('a'), _notice('b')]);
      n.dismissFirst();
      expect(c.read(achievementQueueProvider).map((e) => e.id), ['b']);
      n.dismissFirst();
      expect(c.read(achievementQueueProvider), isEmpty);
      expect(n.dismissFirst, returnsNormally);
    });
  });
}
