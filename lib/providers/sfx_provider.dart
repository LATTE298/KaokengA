import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sfx_player.dart';
// Picks sfx_io.dart on native, sfx_web.dart on web (แพทเทิร์นเดียวกับ tts_provider)
import '../services/sfx_platform_impl_stub.dart'
    if (dart.library.io) '../services/sfx_io.dart'
    if (dart.library.html) '../services/sfx_web.dart';

// ตัวเล่นเสียงเอฟเฟกต์กลาง (เช่น เสียงทิ้งขยะลงถัง) — แยกจากตัวเล่นเสียงพูด
// เพื่อให้เอฟเฟกต์เล่นคู่กับ TTS ได้โดยไม่ตัดกัน
final sfxPlayerProvider = Provider<SfxPlayer>((ref) {
  final player = makeSfxPlayer();
  ref.onDispose(player.dispose);
  return player;
});
