import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

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
