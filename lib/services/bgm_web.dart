/// Web — AudioElement ดิบ (นิ่งกว่า just_audio เรื่อง autoplay-after-gesture)
library;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'bgm_player.dart';

export 'bgm_player.dart';

BgmPlayer makeBgmPlayer() => WebBgmPlayer();

class WebBgmPlayer implements BgmPlayer {
  html.AudioElement? _audio;
  void Function()? _onFirstPlay;
  bool _fired = false;
  bool _playRequested = false;

  @override
  set onFirstPlay(void Function() callback) => _onFirstPlay = callback;

  @override
  Future<void> load(String assetPath) async {
    // Flutter web เสิร์ฟ bundle ไว้ใต้ 'assets/<path ใน pubspec>'
    final audio =
        html.AudioElement('assets/$assetPath')
          ..loop = true
          ..volume = 0
          ..preload = 'auto';
    audio.onPlaying.listen((_) {
      if (!_fired) {
        _fired = true;
        _onFirstPlay?.call();
      }
    });
    _audio = audio;
    if (_playRequested) _tryPlay();
  }

  void _tryPlay() {
    // play() ต้องถูกเรียกใน user gesture บนเว็บ — catch rejection ถ้ายังไม่มี
    _audio?.play().catchError((Object _) {});
  }

  @override
  void play() {
    _playRequested = true;
    _tryPlay();
  }

  @override
  void pause() => _audio?.pause();

  @override
  void setVolume(double value) => _audio?.volume = value.clamp(0.0, 1.0);

  @override
  Future<void> dispose() async {
    _audio?.pause();
    _audio = null;
  }
}
