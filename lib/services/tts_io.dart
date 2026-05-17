/// Native (dart:io) implementations of [TtsAudioCache] and [TtsAudioPlayer].
///
/// Do NOT import this file on web; use [tts_web.dart] instead.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import 'tts_service.dart';

export 'tts_service.dart';

// ---------------------------------------------------------------------------
// File-based cache (native only)
// ---------------------------------------------------------------------------

typedef TtsCacheDirectoryProvider = Future<Directory> Function();

class LocalTtsAudioCache implements TtsAudioCache {
  LocalTtsAudioCache({
    TtsCacheDirectoryProvider? directoryProvider,
    int maxBytes = kTtsMaxCacheBytes,
  }) : _directoryProvider = directoryProvider ?? _defaultDirectoryProvider,
       _maxBytes = maxBytes;

  final TtsCacheDirectoryProvider _directoryProvider;
  final int _maxBytes;

  @override
  Future<Uint8List?> get(String key) async {
    final file = await _fileFor(key);
    if (!await file.exists()) return null;

    final length = await file.length();
    if (length <= 0) {
      await file.delete();
      return null;
    }

    final now = DateTime.now();
    await file.setLastModified(now);
    return file.readAsBytes();
  }

  @override
  Future<void> put(String key, Uint8List bytes) async {
    final directory = await _cacheDirectory();
    await directory.create(recursive: true);
    final file = File('${directory.path}${Platform.pathSeparator}$key');
    await file.writeAsBytes(bytes, flush: true);
    await file.setLastModified(DateTime.now());
  }

  @override
  Future<void> enforceMaxSize() async {
    final directory = await _cacheDirectory();
    if (!await directory.exists()) return;

    final files = <File>[];
    await for (final entity in directory.list()) {
      if (entity is File &&
          entity.path.split(Platform.pathSeparator).last.startsWith('tts_')) {
        files.add(entity);
      }
    }

    var totalBytes = 0;
    final stats = <({File file, DateTime modified, int bytes})>[];
    for (final file in files) {
      final stat = await file.stat();
      totalBytes += stat.size;
      stats.add((file: file, modified: stat.modified, bytes: stat.size));
    }
    if (totalBytes <= _maxBytes) return;

    stats.sort((a, b) => a.modified.compareTo(b.modified));
    for (final entry in stats) {
      if (totalBytes <= _maxBytes) break;
      try {
        await entry.file.delete();
        totalBytes -= entry.bytes;
      } on FileSystemException {
        // Best-effort eviction; future calls can retry.
      }
    }
  }

  Future<File> _fileFor(String key) async {
    final directory = await _cacheDirectory();
    return File('${directory.path}${Platform.pathSeparator}$key');
  }

  Future<Directory> _cacheDirectory() async {
    final root = await _directoryProvider();
    return Directory(
      '${root.path}${Platform.pathSeparator}tts_cache',
    );
  }

  static Future<Directory> _defaultDirectoryProvider() {
    return getApplicationDocumentsDirectory();
  }
}

// ---------------------------------------------------------------------------
// just_audio player — native path-based playback
// ---------------------------------------------------------------------------

/// A [StreamAudioSource] that serves raw OGG/OPUS bytes.
class _BytesAudioSource extends StreamAudioSource {
  _BytesAudioSource(this._bytes);

  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/ogg; codecs=opus',
    );
  }
}

// ---------------------------------------------------------------------------
// Platform factory functions — called by tts_provider.dart via conditional import
// ---------------------------------------------------------------------------

TtsAudioCache makeTtsCache() => LocalTtsAudioCache();
TtsAudioPlayer makeTtsPlayer() => JustAudioTtsPlayer();

class JustAudioTtsPlayer implements TtsAudioPlayer {
  JustAudioTtsPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> playBytes(Uint8List bytes) async {
    await _player.stop();
    await _player.setVolume(0.8);
    await _player.setAudioSource(_BytesAudioSource(bytes));
    await _player.play();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
