/// ตัวเล่นเพลงพื้นหลังข้ามแพลตฟอร์ม — native ใช้ just_audio, web ใช้ AudioElement ดิบ
/// (นิ่งกว่าเรื่อง autoplay). BgmService เป็นตัวคุมสถานะ/fade, ตัวนี้เล่นล้วนๆ
abstract class BgmPlayer {
  /// โหลดล่วงหน้า (preload) — ตั้ง loop + volume 0
  Future<void> load(String assetPath);

  /// เล่น (idempotent) — เรียกได้ทันทีในจังหวะแตะบนเว็บ (ไม่ต้อง await อะไรก่อน)
  void play();

  void pause();

  void setVolume(double value);

  Future<void> dispose();

  /// เรียกครั้งเดียวเมื่อ "เริ่มเล่นจริง" ครั้งแรก — ให้ service เริ่ม fade ตอนนั้น
  set onFirstPlay(void Function() callback);
}
