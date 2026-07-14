import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../features/rewards/rewards_catalog.dart';
import 'achievement_provider.dart';
import 'child_profile_provider.dart';
import 'streak_provider.dart' show kAppPrefsBoxName;

// สถิติการเล่นสะสมฝั่งเด็ก (จำนวนครั้งเล่นจบ + เกมที่เคยเล่น) เก็บใน Hive `app_prefs`
// กล่องเดียวกับดาว/สตรีค — ใช้ปลดล็อกเหรียญรางวัล ทำงานออฟไลน์/ไม่ต้องล็อกอิน. กัน
// "box ยังไม่เปิด" (เช่น widget test ที่ไม่ตั้ง Hive) → อัปเดตในหน่วยความจำอย่างเดียว ไม่ throw
// (ปรัชญาเดียวกับ child_profile_provider)

const String _kGamesCompletedKey = 'games_completed';
const String _kModulesPlayedKey = 'modules_played';

// best_streak เขียนโดย streakProvider (ตอนคำนวณสตรีคใหม่); streak_days = สตรีคปัจจุบัน
const String _kBestStreakKey = 'best_streak';
const String _kStreakDaysKey = 'streak_days';

Box<dynamic>? _prefsBox() =>
    Hive.isBoxOpen(kAppPrefsBoxName)
        ? Hive.box<dynamic>(kAppPrefsBoxName)
        : null;

/// สถิติสะสมสำหรับระบบเหรียญ (ไม่รวมดาว — ดาวมาจาก totalStarsProvider แหล่งเดียว)
class PlayStats {
  const PlayStats({
    required this.gamesCompleted,
    required this.modulesPlayed,
    required this.bestStreak,
  });

  final int gamesCompleted;
  final Set<String> modulesPlayed;
  final int bestStreak;

  PlayStats copyWith({
    int? gamesCompleted,
    Set<String>? modulesPlayed,
    int? bestStreak,
  }) => PlayStats(
    gamesCompleted: gamesCompleted ?? this.gamesCompleted,
    modulesPlayed: modulesPlayed ?? this.modulesPlayed,
    bestStreak: bestStreak ?? this.bestStreak,
  );
}

class RewardsStatsNotifier extends Notifier<PlayStats> {
  @override
  PlayStats build() {
    final box = _prefsBox();
    final games = (box?.get(_kGamesCompletedKey) as int?) ?? 0;
    final modulesRaw =
        (box?.get(_kModulesPlayedKey) as List<dynamic>?) ?? const [];
    final best = (box?.get(_kBestStreakKey) as int?) ?? 0;
    final currentStreak = (box?.get(_kStreakDaysKey) as int?) ?? 0;
    return PlayStats(
      gamesCompleted: games,
      modulesPlayed: {for (final m in modulesRaw) m as String},
      // best_streak อาจยังไม่ถูกเขียน (เปิดรางวัลก่อน streakProvider ทำงาน) → เผื่อ
      // fallback เป็นสตรีคปัจจุบัน กันเหรียญสตรีคหายทั้งที่ทำถึงแล้ว
      bestStreak: best > currentStreak ? best : currentStreak,
    );
  }

  /// บันทึกว่าเล่นจบ 1 เกม — เรียกคู่กับ award ดาวทุกจุดจบเกม. +1 ครั้ง + จำ module
  /// (กันซ้ำด้วย Set) เพื่อปลดเหรียญ "เล่นครบทุกเกม"
  void recordCompletion(String module) {
    final box = _prefsBox();
    final games = state.gamesCompleted + 1;
    final modules = {...state.modulesPlayed, module};
    box?.put(_kGamesCompletedKey, games);
    box?.put(_kModulesPlayedKey, modules.toList());
    state = state.copyWith(gamesCompleted: games, modulesPlayed: modules);
  }
}

final rewardsStatsProvider = NotifierProvider<RewardsStatsNotifier, PlayStats>(
  RewardsStatsNotifier.new,
);

/// บันทึกผลจบเกม 1 รอบแบบรวมศูนย์ — เรียกจากทุกหน้าเกมแทนการบวกดาว/นับสถิติเองทีละบรรทัด:
/// (1) บวกดาว (2) นับครั้งเล่น + จำ module (3) ตรวจว่าปลดสติกเกอร์/เหรียญใหม่ไหม → enqueue
/// toast ให้ AchievementOverlay เด้งโชว์ + เล่นเสียง. รวมไว้ที่เดียวเพื่อกันหน้าเกมทำไม่ครบ
void awardGameResult(
  WidgetRef ref, {
  required String module,
  required int stars,
}) {
  RewardsStats snapshot() {
    final play = ref.read(rewardsStatsProvider);
    return RewardsStats(
      totalStars: ref.read(totalStarsProvider),
      gamesCompleted: play.gamesCompleted,
      modulesPlayed: play.modulesPlayed,
      bestStreak: play.bestStreak,
    );
  }

  final before = snapshot();
  ref.read(totalStarsProvider.notifier).award(stars);
  ref.read(rewardsStatsProvider.notifier).recordCompletion(module);
  final after = snapshot();

  final unlocked = newlyUnlocked(before: before, after: after);
  if (unlocked.stickers.isEmpty && unlocked.medals.isEmpty) return;

  ref.read(achievementQueueProvider.notifier).enqueue([
    for (final s in unlocked.stickers)
      AchievementNotice(
        id: 'sticker_${s.id}',
        emoji: s.emoji,
        title: 'ได้สติกเกอร์ใหม่!',
        subtitle: s.name,
      ),
    for (final m in unlocked.medals)
      AchievementNotice(
        id: 'medal_${m.id}',
        emoji: m.emoji,
        title: 'ปลดล็อกเหรียญ!',
        subtitle: m.title,
      ),
  ]);
}
