// สตรีค "เข้าเล่นต่อเนื่องกี่วัน" (แถบบนหน้าเลือกเล่น) — logic ล้วน testable
// กติกา: เข้าเล่นวันเดิมซ้ำ = คงเดิม, เข้าเล่นวันถัดไป = +1, เว้นเกิน 1 วัน = เริ่มใหม่ที่ 1

/// จำนวนวันเป้าหมายของแถบสตรีค (3/7 แบบ mockup)
const int kStreakGoalDays = 7;

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// คำนวณสตรีคใหม่เมื่อ "เข้าเล่นวันนี้" — [lastPlayed] null = ครั้งแรก
int computeNextStreak({
  required int current,
  required DateTime? lastPlayed,
  required DateTime now,
}) {
  if (lastPlayed == null || current < 1) return 1;
  final today = _dateOnly(now);
  final last = _dateOnly(lastPlayed);
  final gap = today.difference(last).inDays;
  if (gap <= 0) return current; // วันเดิม (หรือนาฬิกาถอยหลัง) — คงเดิม
  if (gap == 1) return current + 1; // ต่อเนื่องจากเมื่อวาน
  return 1; // ขาดช่วง — เริ่มนับใหม่
}
