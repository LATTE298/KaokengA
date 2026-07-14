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

  group('สติกเกอร์: stickersUnlockedCount', () {
    test('ดาว 0/ติดลบ → 0 ใบ', () {
      expect(stickersUnlockedCount(0), 0);
      expect(stickersUnlockedCount(-5), 0);
    });

    test('ปลดทีละใบทุก kStarsPerSticker ดาว', () {
      expect(stickersUnlockedCount(kStarsPerSticker - 1), 0);
      expect(stickersUnlockedCount(kStarsPerSticker), 1);
      expect(stickersUnlockedCount(kStarsPerSticker * 2 + 3), 2);
    });

    test('ไม่เกินจำนวนใบทั้งหมด (clamp)', () {
      expect(
        stickersUnlockedCount(kStarsPerSticker * (kStickers.length + 50)),
        kStickers.length,
      );
    });
  });

  group('สติกเกอร์: starsToNextSticker', () {
    test('เริ่มต้นต้องการครบ 1 ช่วง', () {
      expect(starsToNextSticker(0), kStarsPerSticker);
    });

    test('เหลือระยะที่ถูกต้องระหว่างช่วง', () {
      expect(starsToNextSticker(3), kStarsPerSticker - 3);
      expect(starsToNextSticker(kStarsPerSticker), kStarsPerSticker);
      expect(starsToNextSticker(kStarsPerSticker + 4), kStarsPerSticker - 4);
    });

    test('ครบทุกใบแล้ว → 0 (ไม่มีใบถัดไป)', () {
      expect(starsToNextSticker(kStarsPerSticker * kStickers.length), 0);
      expect(starsToNextSticker(kStarsPerSticker * kStickers.length + 99), 0);
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
}
