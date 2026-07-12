/// เสียงเอฟเฟกต์สั้นๆ ในเกม (ไม่ใช่เสียงพูด — เสียงพูดใช้ [TtsSpeaker])
/// เล่นจากไฟล์ asset ตรงๆ ให้แพลตฟอร์มเดา format จากไฟล์จริง (wav/mp3)
/// — เปลี่ยนเสียงแค่วางไฟล์ทับชื่อเดิม ไม่ต้องแก้โค้ด
library;

/// path เสียง "ทิ้งขยะลงถัง" (ฟิ้ว-ป๊อก) — ตอนนี้เป็นเสียงสังเคราะห์ placeholder
/// ทีมหาเสียงจริงมาวางทับได้เลย (คงชื่อ .wav เดิม)
const String kSfxTrashDrop = 'assets/sfx/trash_drop.wav';

/// path เสียง "ตอบถูก/วางถูก" (asset จริงจากทีม Right02) — ใช้กับทุกเกม
const String kSfxRight = 'assets/sfx/right.mp3';

/// path เสียง "ตอบผิด/วางผิด" (asset จริงจากทีม Wrong01) — ใช้ทุกเกม
/// **ยกเว้นเกมจับคู่ภาพ** ที่ผิดบ่อยโดยธรรมชาติ (กันเด็กกดดัน — ใส่แค่เสียงถูก)
const String kSfxWrong = 'assets/sfx/wrong.mp3';

/// ตัวเล่นเสียงเอฟเฟกต์ — กติกาเดียวกับเสียงระบบอื่น: **ห้าม throw ออกไปหาผู้เรียก**
/// (เสียงเป็น best-effort เล่นไม่ได้ = เงียบ ไม่ทำเกมล้ม)
abstract class SfxPlayer {
  Future<void> play(String assetPath);

  Future<void> dispose();
}

/// ใช้ในเทสต์/กรณีไม่ต้องการเสียง
class NoOpSfxPlayer implements SfxPlayer {
  const NoOpSfxPlayer();

  @override
  Future<void> play(String assetPath) async {}

  @override
  Future<void> dispose() async {}
}
