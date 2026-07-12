/// Web implementation of [SfxPlayer] — AudioElement ชี้ URL asset ตรงๆ
/// (เบราว์เซอร์ได้ mime ถูกจากเซิร์ฟเวอร์ ไม่ต้องพึ่ง Blob + mime เดา)
library;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import 'sfx_player.dart';

export 'sfx_player.dart';

SfxPlayer makeSfxPlayer() => WebSfxPlayer();

class WebSfxPlayer implements SfxPlayer {
  @override
  Future<void> play(String assetPath) async {
    try {
      // Flutter web เสิร์ฟ bundle ไว้ใต้ 'assets/<path ใน pubspec>'
      final audio = html.AudioElement('assets/$assetPath')..volume = 0.75;
      await audio.play();
    } catch (e) {
      debugPrint('SFX play failed ($assetPath): $e');
    }
  }

  @override
  Future<void> dispose() async {}
}
