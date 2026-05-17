/// Web implementations of [TtsAudioCache] and [TtsAudioPlayer].
///
/// Uses an in-memory LRU map for caching and a Blob URL + dart:html
/// AudioElement for playback (works around just_audio's web limitations
/// with OGG/OPUS streaming).
library;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'tts_service.dart';

export 'tts_service.dart';

// ---------------------------------------------------------------------------
// Platform factory functions — called by tts_provider.dart via conditional import
// ---------------------------------------------------------------------------

TtsAudioCache makeTtsCache() => WebTtsAudioCache();
TtsAudioPlayer makeTtsPlayer() => WebTtsAudioPlayer();

// ---------------------------------------------------------------------------
// In-memory cache (web)
// ---------------------------------------------------------------------------

class WebTtsAudioCache implements TtsAudioCache {
  WebTtsAudioCache({int maxBytes = kTtsMaxCacheBytes}) : _maxBytes = maxBytes;

  final int _maxBytes;
  // key → bytes, insertion-order preserved for LRU eviction
  final _store = <String, Uint8List>{};
  var _totalBytes = 0;

  @override
  Future<Uint8List?> get(String key) async => _store[key];

  @override
  Future<void> put(String key, Uint8List bytes) async {
    if (_store.containsKey(key)) return; // already cached
    _store[key] = bytes;
    _totalBytes += bytes.length;
  }

  @override
  Future<void> enforceMaxSize() async {
    if (_totalBytes <= _maxBytes) return;
    final keys = _store.keys.toList();
    for (final key in keys) {
      if (_totalBytes <= _maxBytes) break;
      final removed = _store.remove(key);
      if (removed != null) _totalBytes -= removed.length;
    }
  }
}

// ---------------------------------------------------------------------------
// Web audio player — Blob URL via dart:html AudioElement
// ---------------------------------------------------------------------------

class WebTtsAudioPlayer implements TtsAudioPlayer {
  html.AudioElement? _audio;
  String? _currentBlobUrl;

  @override
  Future<void> playBytes(Uint8List bytes) async {
    await stop();

    // Create an object URL from the raw OGG/OPUS bytes.
    final blob = html.Blob([bytes], 'audio/ogg; codecs=opus');
    final url = html.Url.createObjectUrlFromBlob(blob);
    _currentBlobUrl = url;

    final audio = html.AudioElement(url)..volume = 0.8;
    _audio = audio;

    // Revoke the blob URL once playback ends to free memory.
    audio.onEnded.listen((_) => _revokeCurrentUrl());

    await audio.play();
  }

  @override
  Future<void> stop() async {
    final audio = _audio;
    if (audio != null) {
      audio.pause();
      audio.src = '';
      _audio = null;
    }
    _revokeCurrentUrl();
  }

  @override
  Future<void> dispose() => stop();

  void _revokeCurrentUrl() {
    final url = _currentBlobUrl;
    if (url != null) {
      html.Url.revokeObjectUrl(url);
      _currentBlobUrl = null;
    }
  }
}
