import 'package:daily_life/features/streak/streak_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 7, 11, 14);

  group('computeNextStreak', () {
    test('เข้าเล่นครั้งแรก = 1', () {
      expect(computeNextStreak(current: 0, lastPlayed: null, now: today), 1);
    });

    test('วันเดิมซ้ำ = คงเดิม', () {
      expect(
        computeNextStreak(
          current: 3,
          lastPlayed: DateTime(2026, 7, 11, 8),
          now: today,
        ),
        3,
      );
    });

    test('ต่อเนื่องจากเมื่อวาน = +1', () {
      expect(
        computeNextStreak(
          current: 3,
          lastPlayed: DateTime(2026, 7, 10, 22),
          now: today,
        ),
        4,
      );
    });

    test('ขาดช่วงเกิน 1 วัน = เริ่มใหม่ที่ 1', () {
      expect(
        computeNextStreak(
          current: 6,
          lastPlayed: DateTime(2026, 7, 8),
          now: today,
        ),
        1,
      );
    });
  });
}
