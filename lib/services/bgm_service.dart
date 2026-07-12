import 'dart:async';

import 'package:hive/hive.dart';

import 'bgm_platform_impl_stub.dart'
    if (dart.library.io) 'bgm_io.dart'
    if (dart.library.html) 'bgm_web.dart';

/// เพลงธีมของแอป (Boba date) — เล่นลูปทั้งแอป, fade-in ตอนเริ่มเล่นจริง
/// เปลี่ยนเพลงแค่วางไฟล์ทับชื่อเดิม
const String kBgmAsset = 'assets/sfx/bgm.mp3';

const String _kEnabledKey = 'bgm_enabled';
const String _kVolumeKey = 'bgm_volume';
const double _kDefaultVolume = 0.45;

/// ตัวคุมเพลงพื้นหลัง — best-effort. สถานะเปิด/ปิด+เสียงเก็บใน Hive (จำข้ามการเปิดแอป)
/// การเล่นจริงมอบให้ [BgmPlayer] ตามแพลตฟอร์ม (web=AudioElement นิ่งกว่าเรื่อง autoplay)
class BgmService {
  BgmService(this._box) {
    _player = makeBgmPlayer()..onFirstPlay = _fadeIn;
    _player.load(
      kBgmAsset,
    ); // preload ตั้งแต่เปิดแอป → play() ตอนแตะจึงเล่นได้ทันที
  }

  /// null = ไม่มี box (เช่น widget test) — ใช้ค่า default ไม่ persist
  final Box<dynamic>? _box;
  late final BgmPlayer _player;
  Timer? _fadeTimer;

  bool get enabled =>
      _box?.get(_kEnabledKey, defaultValue: true) as bool? ?? true;
  double get volume =>
      (_box?.get(_kVolumeKey, defaultValue: _kDefaultVolume) as num?)
          ?.toDouble() ??
      _kDefaultVolume;

  /// สั่งเล่น (idempotent) — Android เล่นเลย; web เล่นเมื่อเรียกในจังหวะแตะ
  /// ข้ามถ้าปิดเพลงอยู่
  void start() {
    if (enabled) _player.play();
  }

  /// พักเพลงเมื่อแอปลงพื้นหลัง (พับจอ/สลับแอป) — ไม่แตะค่า enabled ที่ผู้ใช้ตั้งไว้
  void pauseForBackground() {
    _fadeTimer?.cancel();
    _player.pause();
  }

  /// กลับมาเล่นเมื่อแอปกลับขึ้นหน้าจอ (ถ้าเปิดเพลงอยู่)
  void resumeForeground() {
    if (enabled) _player.play();
  }

  /// เปิด/ปิดเพลง (จำค่า)
  Future<void> setEnabled(bool value) async {
    await _box?.put(_kEnabledKey, value);
    if (value) {
      _player.play();
    } else {
      _fadeTimer?.cancel();
      _player.pause();
    }
  }

  /// ปรับระดับเสียง 0..1 (จำค่า) — มีผลทันที
  Future<void> setVolume(double value) async {
    final vol = value.clamp(0.0, 1.0);
    await _box?.put(_kVolumeKey, vol);
    _fadeTimer?.cancel(); // เลิก fade ถ้าผู้ใช้ปรับเอง
    _player.setVolume(vol);
  }

  // เริ่มเมื่อเพลงเล่นจริงครั้งแรก (callback จาก player) — 0 → volume ใน ~2.7 วิ
  void _fadeIn() {
    const steps = 30;
    var i = 0;
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      i++;
      _player.setVolume((volume * i / steps).clamp(0.0, volume));
      if (i >= steps) t.cancel();
    });
  }

  Future<void> dispose() async {
    _fadeTimer?.cancel();
    await _player.dispose();
  }
}
