import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// คิวการเด้ง toast "ปลดล็อกความสำเร็จ" (สไตล์ Steam/Google Play Games) — เมื่อจบเกมแล้ว
// ปลดสติกเกอร์/เหรียญใหม่ จะ enqueue เข้าคิวนี้ แล้ว AchievementOverlay (ครอบ app root)
// จะโชว์ทีละใบ. เก็บใน memory อย่างเดียว (ไม่ต้อง persist — เป็นการแจ้งเตือนชั่วคราว)

/// ข้อมูลหนึ่ง toast ที่จะเด้ง
@immutable
class AchievementNotice {
  const AchievementNotice({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  /// unique ต่อชิ้น (เช่น sticker_cat / medal_stars_10) — กันโชว์ซ้ำถ้า enqueue ซ้ำ
  final String id;
  final String emoji;

  /// บรรทัดบน เช่น "ปลดล็อกเหรียญ!" / "ได้สติกเกอร์ใหม่!"
  final String title;

  /// บรรทัดล่าง = ชื่อของรางวัลนั้น (ชื่อเหรียญ/ชื่อสติกเกอร์)
  final String subtitle;
}

class AchievementQueueNotifier extends Notifier<List<AchievementNotice>> {
  @override
  List<AchievementNotice> build() => const [];

  /// ต่อท้ายคิว (ข้ามชิ้นที่ id ซ้ำกับที่ยังค้างในคิวอยู่)
  void enqueue(List<AchievementNotice> notices) {
    if (notices.isEmpty) return;
    final existing = {for (final n in state) n.id};
    final toAdd = [
      for (final n in notices)
        if (existing.add(n.id)) n,
    ];
    if (toAdd.isEmpty) return;
    state = [...state, ...toAdd];
  }

  /// ปลดใบแรกออก (เมื่อ toast โชว์จบแล้ว) — โชว์ใบถัดไปต่อ
  void dismissFirst() {
    if (state.isEmpty) return;
    state = state.sublist(1);
  }
}

final achievementQueueProvider =
    NotifierProvider<AchievementQueueNotifier, List<AchievementNotice>>(
      AchievementQueueNotifier.new,
    );
