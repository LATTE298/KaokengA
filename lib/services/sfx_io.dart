/// Native (dart:io) implementation of [SfxPlayer] — just_audio จาก asset ตรงๆ
/// (ExoPlayer เดา format จากเนื้อไฟล์ ไม่ผูก mime แบบตัวเล่น TTS bytes)
///
/// Do NOT import this file on web; use [sfx_web.dart] instead.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'sfx_player.dart';

export 'sfx_player.dart';

SfxPlayer makeSfxPlayer() => JustAudioSfxPlayer();

class JustAudioSfxPlayer implements SfxPlayer {
  // player ต่อ asset — โหลดครั้งแรกครั้งเดียว เล่นซ้ำแค่ seek(0)
  final Map<String, AudioPlayer> _players = {};

  @override
  Future<void> play(String assetPath) async {
    try {
      var player = _players[assetPath];
      if (player == null) {
        player = AudioPlayer();
        await player.setAsset(assetPath);
        await player.setVolume(0.75);
        _players[assetPath] = player;
      }
      await player.seek(Duration.zero);
      // ไม่ await ให้จบ — เสียงสั้น เล่นคู่ไปกับเสียงพูด/อนิเมชันได้
      unawaited(player.play());
    } catch (e) {
      debugPrint('SFX play failed ($assetPath): $e');
    }
  }

  @override
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}
