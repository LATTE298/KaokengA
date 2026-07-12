/// Native (dart:io) — just_audio. Do NOT import on web.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'bgm_player.dart';

export 'bgm_player.dart';

BgmPlayer makeBgmPlayer() => NativeBgmPlayer();

class NativeBgmPlayer implements BgmPlayer {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _sub;
  void Function()? _onFirstPlay;
  bool _fired = false;
  bool _playRequested = false;

  @override
  set onFirstPlay(void Function() callback) => _onFirstPlay = callback;

  @override
  Future<void> load(String assetPath) async {
    try {
      final player = AudioPlayer();
      _player = player;
      _sub = player.playerStateStream.listen((s) {
        if (s.playing && !_fired) {
          _fired = true;
          _onFirstPlay?.call();
        }
      });
      await player.setAsset(assetPath);
      await player.setLoopMode(LoopMode.one);
      await player.setVolume(0);
      if (_playRequested) unawaited(player.play());
    } catch (e) {
      debugPrint('BGM load failed: $e');
    }
  }

  @override
  void play() {
    _playRequested = true;
    final player = _player;
    if (player != null) unawaited(player.play());
  }

  @override
  void pause() {
    final player = _player;
    if (player != null) unawaited(player.pause());
  }

  @override
  void setVolume(double value) {
    final player = _player;
    if (player != null) unawaited(player.setVolume(value.clamp(0.0, 1.0)));
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    await _player?.dispose();
  }
}
