import 'package:flutter/foundation.dart';

// คลังของรางวัล + ตรรกะการปลดล็อก (pure, ไม่ผูก UI/Hive → test ตรงๆ ได้)
//
// ปรัชญาให้ตรงกลุ่มเป้าหมาย (เด็กดาวน์ซินโดรม): **สะสมอย่างเดียว ไม่มีวันเสีย** —
// ไม่มีระบบ "เอาดาวไปแลก" (ดาวลด = รู้สึกเหมือนของหาย + ต้องตัดสินใจซับซ้อน) ทุกอย่าง
// ปลดล็อกอัตโนมัติเมื่อถึงหลักไมล์ เดาได้ล่วงหน้า เห็นความคืบหน้าเป็นรูปธรรม

// ---------------------------------------------------------------------------
// A. สมุดสะสมสติกเกอร์ — ดาวสะสมรวมปลดล็อกทีละใบตามเกณฑ์ขั้นบันได (ดู [stickerThreshold])
// ---------------------------------------------------------------------------

/// เกณฑ์ดาวสะสมของสติกเกอร์ใบที่ 1..6 (index 0..5). ใบที่ 7 เป็นต้นไปเพิ่มทีละ [_kStickerStep]
/// (ผู้ใช้กำหนด 2026-07-14: 10, 25, 40, 70, 100, 130 แล้ว +30 ไปเรื่อยๆ จนครบ)
const List<int> _kStickerThresholds = [10, 25, 40, 70, 100, 130];
const int _kStickerStep = 30;

/// ดาวสะสมที่ต้องมีเพื่อปลดสติกเกอร์ [index] (0-based). index >= 6 = 130 + (index-5)*30
int stickerThreshold(int index) {
  if (index < _kStickerThresholds.length) return _kStickerThresholds[index];
  final extra = index - (_kStickerThresholds.length - 1);
  return _kStickerThresholds.last + extra * _kStickerStep;
}

@immutable
class StickerDef {
  const StickerDef({required this.id, required this.emoji, required this.name});

  final String id;
  final String emoji;

  /// ชื่อไทยของสติกเกอร์ (โชว์ใต้ภาพ + อ่านออกเสียงได้ในอนาคต)
  final String name;
}

/// ชุดสติกเกอร์เริ่มต้น — ใช้อิโมจิไปก่อน (ทีมสลับเป็นภาพวาดจริงได้โดยแก้เฉพาะไฟล์นี้).
/// เรียงไล่ธีมสนุกๆ: สัตว์ → ผลไม้ → ธรรมชาติ/ของขวัญ เพื่อให้ช่องถัดไปที่จะได้ดูน่าลุ้น
const List<StickerDef> kStickers = [
  StickerDef(id: 'cat', emoji: '🐱', name: 'เจ้าเหมียว'),
  StickerDef(id: 'dog', emoji: '🐶', name: 'เจ้าตูบ'),
  StickerDef(id: 'rabbit', emoji: '🐰', name: 'กระต่าย'),
  StickerDef(id: 'bear', emoji: '🐻', name: 'หมีน้อย'),
  StickerDef(id: 'panda', emoji: '🐼', name: 'แพนด้า'),
  StickerDef(id: 'fox', emoji: '🦊', name: 'จิ้งจอก'),
  StickerDef(id: 'lion', emoji: '🦁', name: 'สิงโต'),
  StickerDef(id: 'frog', emoji: '🐸', name: 'เจ้ากบ'),
  StickerDef(id: 'turtle', emoji: '🐢', name: 'เต่าน้อย'),
  StickerDef(id: 'butterfly', emoji: '🦋', name: 'ผีเสื้อ'),
  StickerDef(id: 'fish', emoji: '🐠', name: 'ปลาทอง'),
  StickerDef(id: 'chick', emoji: '🐥', name: 'ลูกเจี๊ยบ'),
  StickerDef(id: 'apple', emoji: '🍎', name: 'แอปเปิล'),
  StickerDef(id: 'banana', emoji: '🍌', name: 'กล้วย'),
  StickerDef(id: 'strawberry', emoji: '🍓', name: 'สตรอว์เบอร์รี'),
  StickerDef(id: 'watermelon', emoji: '🍉', name: 'แตงโม'),
  StickerDef(id: 'grapes', emoji: '🍇', name: 'องุ่น'),
  StickerDef(id: 'orange', emoji: '🍊', name: 'ส้ม'),
  StickerDef(id: 'rainbow', emoji: '🌈', name: 'สายรุ้ง'),
  StickerDef(id: 'star', emoji: '⭐', name: 'ดาว'),
  StickerDef(id: 'sunflower', emoji: '🌻', name: 'ทานตะวัน'),
  StickerDef(id: 'moon', emoji: '🌙', name: 'พระจันทร์'),
  StickerDef(id: 'balloon', emoji: '🎈', name: 'ลูกโป่ง'),
  StickerDef(id: 'gift', emoji: '🎁', name: 'กล่องของขวัญ'),
];

/// จำนวนสติกเกอร์ที่ปลดล็อกแล้วจากดาวสะสม (clamp ไม่ให้เกินจำนวนใบทั้งหมด)
int stickersUnlockedCount(int totalStars) {
  if (totalStars <= 0) return 0;
  var n = 0;
  while (n < kStickers.length && stickerThreshold(n) <= totalStars) {
    n++;
  }
  return n;
}

/// ดาวที่ยังต้องเก็บอีกเพื่อปลดใบถัดไป — 0 เมื่อครบทุกใบแล้ว
int starsToNextSticker(int totalStars) {
  final unlocked = stickersUnlockedCount(totalStars);
  if (unlocked >= kStickers.length) return 0;
  final s = totalStars < 0 ? 0 : totalStars;
  return stickerThreshold(unlocked) - s;
}

/// ความคืบหน้า 0..1 ภายในช่วงปัจจุบันสู่สติกเกอร์ใบถัดไป (1.0 = ครบทุกใบ) — สำหรับแถบ progress
double stickerProgress(int totalStars) {
  final unlocked = stickersUnlockedCount(totalStars);
  if (unlocked >= kStickers.length) return 1.0;
  final prev = unlocked == 0 ? 0 : stickerThreshold(unlocked - 1);
  final next = stickerThreshold(unlocked);
  final seg = next - prev;
  if (seg <= 0) return 1.0;
  final s = totalStars < prev ? prev : totalStars;
  return ((s - prev) / seg).clamp(0.0, 1.0);
}

// ---------------------------------------------------------------------------
// B. เหรียญความสำเร็จ — ปลดล็อกอัตโนมัติเมื่อถึงเป้า (ดาว/จำนวนครั้ง/ครบทุกเกม/สตรีค)
// ---------------------------------------------------------------------------

/// ตัวชี้วัดของเหรียญแต่ละแบบ — map ไปยังฟิลด์ใน [RewardsStats]
enum MedalMetric { stars, games, modules, streak }

@immutable
class MedalDef {
  const MedalDef({
    required this.id,
    required this.emoji,
    required this.title,
    required this.metric,
    required this.target,
  });

  final String id;
  final String emoji;
  final String title;
  final MedalMetric metric;

  /// ค่าที่ต้องถึงเพื่อปลดล็อก (เทียบกับ metric)
  final int target;
}

/// รายการเหรียญ เรียงจากง่าย → ยาก (ให้เหรียญแรกๆ ปลดก่อน เห็นความสำเร็จเร็ว)
const List<MedalDef> kMedals = [
  MedalDef(
    id: 'first_game',
    emoji: '🎈',
    title: 'เล่นเกมแรก',
    metric: MedalMetric.games,
    target: 1,
  ),
  MedalDef(
    id: 'stars_10',
    emoji: '⭐',
    title: 'ดาว 10 ดวง',
    metric: MedalMetric.stars,
    target: 10,
  ),
  MedalDef(
    id: 'all_games',
    emoji: '🎯',
    title: 'เล่นครบทุกเกม',
    metric: MedalMetric.modules,
    target: 4,
  ),
  MedalDef(
    id: 'streak_3',
    emoji: '🔥',
    title: 'เล่น 3 วันติด',
    metric: MedalMetric.streak,
    target: 3,
  ),
  MedalDef(
    id: 'games_10',
    emoji: '🎮',
    title: 'เล่น 10 ครั้ง',
    metric: MedalMetric.games,
    target: 10,
  ),
  MedalDef(
    id: 'stars_50',
    emoji: '🌟',
    title: 'ดาว 50 ดวง',
    metric: MedalMetric.stars,
    target: 50,
  ),
  MedalDef(
    id: 'streak_7',
    emoji: '📅',
    title: 'เล่น 7 วันติด',
    metric: MedalMetric.streak,
    target: 7,
  ),
  MedalDef(
    id: 'stars_100',
    emoji: '💯',
    title: 'ดาว 100 ดวง',
    metric: MedalMetric.stars,
    target: 100,
  ),
  MedalDef(
    id: 'games_50',
    emoji: '🏆',
    title: 'เล่น 50 ครั้ง',
    metric: MedalMetric.games,
    target: 50,
  ),
  MedalDef(
    id: 'stars_200',
    emoji: '👑',
    title: 'ดาว 200 ดวง',
    metric: MedalMetric.stars,
    target: 200,
  ),
];

/// สถิติสะสมทั้งหมดที่ใช้ตัดสินการปลดล็อก (ประกอบจากหลาย provider ในหน้าจอ)
@immutable
class RewardsStats {
  const RewardsStats({
    required this.totalStars,
    required this.gamesCompleted,
    required this.modulesPlayed,
    required this.bestStreak,
  });

  final int totalStars;
  final int gamesCompleted;

  /// ชุด module ที่เคยเล่นจบ (daily_life/memory/vocab/family) — ใช้กับเหรียญ "ครบทุกเกม"
  final Set<String> modulesPlayed;

  /// สตรีคที่ดีที่สุดเท่าที่เคยทำได้ (ไม่ใช่สตรีคปัจจุบัน) — เหรียญสตรีคจะไม่ล็อกกลับ
  final int bestStreak;
}

/// ค่าปัจจุบันของ metric ที่เหรียญนี้ใช้
int medalCurrentValue(MedalDef m, RewardsStats s) {
  switch (m.metric) {
    case MedalMetric.stars:
      return s.totalStars;
    case MedalMetric.games:
      return s.gamesCompleted;
    case MedalMetric.modules:
      return s.modulesPlayed.length;
    case MedalMetric.streak:
      return s.bestStreak;
  }
}

/// เหรียญนี้ปลดล็อกแล้วหรือยัง
bool medalUnlocked(MedalDef m, RewardsStats s) =>
    medalCurrentValue(m, s) >= m.target;

/// จำนวนเหรียญที่ปลดล็อกแล้วทั้งหมด
int medalsUnlockedCount(RewardsStats s) =>
    kMedals.where((m) => medalUnlocked(m, s)).length;

/// สิ่งที่ "เพิ่งปลดล็อก" เมื่อสถิติเปลี่ยนจาก [before] → [after] (เช่นหลังจบเกม 1 รอบ) —
/// ใช้ trigger การเด้ง toast แสดงความสำเร็จ. pure → test ได้. สติกเกอร์เรียงตามลำดับใบที่ปลด,
/// เหรียญเรียงตามลำดับใน kMedals
({List<StickerDef> stickers, List<MedalDef> medals}) newlyUnlocked({
  required RewardsStats before,
  required RewardsStats after,
}) {
  final beforeStickers = stickersUnlockedCount(before.totalStars);
  final afterStickers = stickersUnlockedCount(after.totalStars);
  final stickers = [
    for (var i = beforeStickers; i < afterStickers; i++) kStickers[i],
  ];

  final beforeMedalIds = {
    for (final m in kMedals)
      if (medalUnlocked(m, before)) m.id,
  };
  final medals = [
    for (final m in kMedals)
      if (medalUnlocked(m, after) && !beforeMedalIds.contains(m.id)) m,
  ];

  return (stickers: stickers, medals: medals);
}
