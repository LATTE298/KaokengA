import 'package:daily_life/features/rewards/rewards_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

RewardsStats _stats({
  int totalStars = 0,
  int gamesCompleted = 0,
  Set<String> modulesPlayed = const {},
  int bestStreak = 0,
}) => RewardsStats(
  totalStars: totalStars,
  gamesCompleted: gamesCompleted,
  modulesPlayed: modulesPlayed,
  bestStreak: bestStreak,
);

MedalDef _medal(String id) => kMedals.firstWhere((m) => m.id == id);

void main() {
  group('catalog integrity', () {
    test('sticker ids ไม่ซ้ำ', () {
      final ids = kStickers.map((s) => s.id).toSet();
      expect(ids.length, kStickers.length);
    });

    test('medal ids ไม่ซ้ำ', () {
      final ids = kMedals.map((m) => m.id).toSet();
      expect(ids.length, kMedals.length);
    });
  });

  group('สติกเกอร์: stickerThreshold (เกณฑ์ขั้นบันได)', () {
    test('ใบที่ 1..6 = 10/25/40/70/100/130', () {
      expect(
        [for (var i = 0; i < 6; i++) stickerThreshold(i)],
        [10, 25, 40, 70, 100, 130],
      );
    });

    test('ใบที่ 7 เป็นต้นไป +30 ต่อใบ', () {
      expect(stickerThreshold(6), 160);
      expect(stickerThreshold(7), 190);
      expect(stickerThreshold(8), 220);
    });
  });

  group('สติกเกอร์: stickersUnlockedCount', () {
    test('ดาว 0/ติดลบ → 0 ใบ', () {
      expect(stickersUnlockedCount(0), 0);
      expect(stickersUnlockedCount(-5), 0);
    });

    test('ปลดตามเกณฑ์ (>= threshold ของใบนั้น)', () {
      expect(stickersUnlockedCount(9), 0);
      expect(stickersUnlockedCount(10), 1);
      expect(stickersUnlockedCount(24), 1);
      expect(stickersUnlockedCount(25), 2);
      expect(stickersUnlockedCount(40), 3);
      expect(stickersUnlockedCount(69), 3);
      expect(stickersUnlockedCount(70), 4);
      expect(stickersUnlockedCount(100), 5);
      expect(stickersUnlockedCount(130), 6);
      expect(stickersUnlockedCount(159), 6);
      expect(stickersUnlockedCount(160), 7);
    });

    test('ไม่เกินจำนวนใบทั้งหมด (clamp)', () {
      expect(stickersUnlockedCount(100000), kStickers.length);
    });
  });

  group('สติกเกอร์: starsToNextSticker', () {
    test('เริ่มต้น → ถึงเกณฑ์ใบแรก (10)', () {
      expect(starsToNextSticker(0), 10);
      expect(starsToNextSticker(7), 3);
    });

    test('ระหว่างช่วง = เกณฑ์ถัดไป - ดาวปัจจุบัน', () {
      expect(starsToNextSticker(10), 15); // ถัดไป 25
      expect(starsToNextSticker(40), 30); // ถัดไป 70
      expect(starsToNextSticker(130), 30); // ถัดไป 160
    });

    test('ครบทุกใบแล้ว → 0 (ไม่มีใบถัดไป)', () {
      expect(starsToNextSticker(100000), 0);
    });
  });

  group('สติกเกอร์: stickerProgress', () {
    test('กลางช่วงแรก 0..10', () {
      expect(stickerProgress(0), 0.0);
      expect(stickerProgress(5), closeTo(0.5, 1e-9));
    });

    test('เพิ่งปลดใบ → เริ่มนับช่วงถัดไปที่ 0', () {
      expect(stickerProgress(10), closeTo(0.0, 1e-9)); // เข้าใบ 2 (10..25)
      expect(stickerProgress(55), closeTo(0.5, 1e-9)); // ใบ 4 ช่วง 40..70
    });

    test('ครบทุกใบ = 1.0', () {
      expect(stickerProgress(100000), 1.0);
    });
  });

  group('เหรียญ: การปลดล็อกตามหลักไมล์', () {
    test('เริ่มต้น (ยังไม่เล่นอะไร) = ไม่มีเหรียญ', () {
      final s = _stats();
      expect(medalsUnlockedCount(s), 0);
      expect(medalUnlocked(_medal('first_game'), s), isFalse);
    });

    test('เล่นจบเกมแรก → ปลด first_game', () {
      final s = _stats(gamesCompleted: 1);
      expect(medalUnlocked(_medal('first_game'), s), isTrue);
      expect(medalUnlocked(_medal('games_10'), s), isFalse);
    });

    test('เหรียญดาวปลดตามเกณฑ์ (>= target)', () {
      expect(medalUnlocked(_medal('stars_10'), _stats(totalStars: 9)), isFalse);
      expect(medalUnlocked(_medal('stars_10'), _stats(totalStars: 10)), isTrue);
      expect(medalUnlocked(_medal('stars_50'), _stats(totalStars: 10)), isFalse);
      expect(
        medalUnlocked(_medal('stars_200'), _stats(totalStars: 250)),
        isTrue,
      );
    });

    test('เหรียญ "ครบทุกเกม" ต้องเล่นครบ 4 module ที่ต่างกัน', () {
      final three = _stats(
        modulesPlayed: {'daily_life', 'memory', 'vocab'},
        gamesCompleted: 9, // เล่นเยอะแต่ module ซ้ำ ไม่ครบ
      );
      expect(medalUnlocked(_medal('all_games'), three), isFalse);

      final four = _stats(
        modulesPlayed: {'daily_life', 'memory', 'vocab', 'family'},
      );
      expect(medalUnlocked(_medal('all_games'), four), isTrue);
    });

    test('เหรียญสตรีคใช้ bestStreak (สตรีคดีที่สุด)', () {
      expect(medalUnlocked(_medal('streak_3'), _stats(bestStreak: 2)), isFalse);
      final s = _stats(bestStreak: 7);
      expect(medalUnlocked(_medal('streak_3'), s), isTrue);
      expect(medalUnlocked(_medal('streak_7'), s), isTrue);
    });

    test('medalCurrentValue ดึงค่าตาม metric ถูกช่อง', () {
      final s = _stats(
        totalStars: 42,
        gamesCompleted: 7,
        modulesPlayed: {'memory', 'vocab'},
        bestStreak: 5,
      );
      expect(medalCurrentValue(_medal('stars_10'), s), 42);
      expect(medalCurrentValue(_medal('first_game'), s), 7);
      expect(medalCurrentValue(_medal('all_games'), s), 2);
      expect(medalCurrentValue(_medal('streak_3'), s), 5);
    });
  });

  group('newlyUnlocked (before → after)', () {
    test('ไม่มีอะไรเปลี่ยน = ว่างเปล่า', () {
      final s = _stats(totalStars: 5, gamesCompleted: 2);
      final r = newlyUnlocked(before: s, after: s);
      expect(r.stickers, isEmpty);
      expect(r.medals, isEmpty);
    });

    test('ข้ามเส้นสติกเกอร์ = ได้เฉพาะใบใหม่ (ตามลำดับ)', () {
      // 5 → 12 ดาว: ปลดสติกเกอร์ใบแรก 1 ใบ
      final r = newlyUnlocked(
        before: _stats(totalStars: 5),
        after: _stats(totalStars: 12),
      );
      expect(r.stickers.map((s) => s.id), [kStickers.first.id]);

      // 5 → 25 ดาว: ปลด 2 ใบแรก
      final r2 = newlyUnlocked(
        before: _stats(totalStars: 5),
        after: _stats(totalStars: 25),
      );
      expect(r2.stickers.length, 2);
    });

    test('จบเกมได้ทั้งสติกเกอร์ + เหรียญใหม่พร้อมกัน', () {
      final r = newlyUnlocked(
        before: _stats(totalStars: 5, gamesCompleted: 0),
        after: _stats(totalStars: 12, gamesCompleted: 1),
      );
      expect(r.stickers.map((s) => s.id), [kStickers.first.id]);
      // เกมแรก + ดาวครบ 10 → 2 เหรียญใหม่
      final ids = r.medals.map((m) => m.id).toSet();
      expect(ids, containsAll(<String>['first_game', 'stars_10']));
    });

    test('เหรียญที่ปลดไปแล้วไม่ถูกรายงานซ้ำ', () {
      final r = newlyUnlocked(
        before: _stats(gamesCompleted: 1), // first_game ปลดแล้ว
        after: _stats(gamesCompleted: 2), // games_10 ยังไม่ถึง
      );
      expect(r.medals, isEmpty);
      expect(r.stickers, isEmpty);
    });
  });
}
