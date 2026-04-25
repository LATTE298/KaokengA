import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

const int kTtsMaxCacheBytes = 50 * 1024 * 1024;

String ttsCacheKey(String text) {
  final digest = sha256.convert(utf8.encode(text)).toString();
  return 'tts_$digest.opus';
}

class TtsException implements Exception {
  const TtsException(this.message);

  final String message;

  @override
  String toString() => 'TtsException: $message';
}

abstract class TtsClient {
  Future<Uint8List> synthesize(String text);
}

abstract class TtsAudioPlayer {
  Future<void> playFile(String path);

  Future<void> stop();

  Future<void> dispose();
}

abstract class TtsAudioCache {
  Future<File?> get(String key);

  Future<File> put(String key, Uint8List bytes);

  Future<void> enforceMaxSize();
}

typedef TtsCacheDirectoryProvider = Future<Directory> Function();

class GoogleTtsClient implements TtsClient {
  GoogleTtsClient({required http.Client httpClient, required String apiKey})
    : _httpClient = httpClient,
      _apiKey = apiKey;

  final http.Client _httpClient;
  final String _apiKey;

  @override
  Future<Uint8List> synthesize(String text) async {
    final uri = Uri.https(
      'texttospeech.googleapis.com',
      '/v1/text:synthesize',
      {'key': _apiKey},
    );
    final response = await _httpClient.post(
      uri,
      headers: const {'content-type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'input': {'text': text},
        'voice': {'languageCode': 'th-TH', 'name': 'th-TH-Neural2-C'},
        'audioConfig': {
          'audioEncoding': 'OGG_OPUS',
          'speakingRate': 0.9,
          'pitch': 2.0,
        },
      }),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw TtsException(
        'Google TTS failed with ${response.statusCode}: ${response.body}',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw TtsException('Google TTS returned malformed JSON: $e');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const TtsException('Google TTS returned a non-object response');
    }
    final audioContent = decoded['audioContent'];
    if (audioContent is! String || audioContent.isEmpty) {
      throw const TtsException('Google TTS response is missing audioContent');
    }

    try {
      return base64Decode(audioContent);
    } on FormatException catch (e) {
      throw TtsException('Google TTS audioContent is not valid base64: $e');
    }
  }
}

class NoOpTtsClient implements TtsClient {
  const NoOpTtsClient();

  @override
  Future<Uint8List> synthesize(String text) async => Uint8List(0);
}

class LocalTtsAudioCache implements TtsAudioCache {
  LocalTtsAudioCache({
    TtsCacheDirectoryProvider? directoryProvider,
    int maxBytes = kTtsMaxCacheBytes,
  }) : _directoryProvider = directoryProvider ?? _defaultDirectoryProvider,
       _maxBytes = maxBytes;

  final TtsCacheDirectoryProvider _directoryProvider;
  final int _maxBytes;

  @override
  Future<File?> get(String key) async {
    final file = await _fileFor(key);
    if (!await file.exists()) return null;

    final length = await file.length();
    if (length <= 0) {
      await file.delete();
      return null;
    }

    final now = DateTime.now();
    await file.setLastModified(now);
    return file;
  }

  @override
  Future<File> put(String key, Uint8List bytes) async {
    final directory = await _cacheDirectory();
    await directory.create(recursive: true);
    final file = File(_joinPath(directory.path, key));
    await file.writeAsBytes(bytes, flush: true);
    await file.setLastModified(DateTime.now());
    return file;
  }

  @override
  Future<void> enforceMaxSize() async {
    final directory = await _cacheDirectory();
    if (!await directory.exists()) return;

    final files = <File>[];
    await for (final entity in directory.list()) {
      if (entity is File && _basename(entity.path).startsWith('tts_')) {
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
    return File(_joinPath(directory.path, key));
  }

  Future<Directory> _cacheDirectory() async {
    final root = await _directoryProvider();
    return Directory(_joinPath(root.path, 'tts_cache'));
  }

  static Future<Directory> _defaultDirectoryProvider() {
    return getApplicationDocumentsDirectory();
  }
}

String _joinPath(String directory, String child) {
  return '$directory${Platform.pathSeparator}$child';
}

String _basename(String path) {
  return path.split(Platform.pathSeparator).last;
}

class JustAudioTtsPlayer implements TtsAudioPlayer {
  JustAudioTtsPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> playFile(String path) async {
    await _player.stop();
    await _player.setVolume(0.8);
    await _player.setFilePath(path);
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

class TtsService {
  TtsService({
    required TtsClient client,
    required TtsAudioCache cache,
    required TtsAudioPlayer player,
  }) : _client = client,
       _cache = cache,
       _player = player;

  final TtsClient _client;
  final TtsAudioCache _cache;
  final TtsAudioPlayer _player;

  var _generation = 0;
  var _disposed = false;

  Future<void> speak(String text) async {
    try {
      final generation = await _beginNewRequest();
      final file = await _getAudioFile(text);
      if (file == null || !_isCurrent(generation)) return;
      await _player.playFile(file.path);
    } on Object catch (e, st) {
      developer.log(
        'TtsService.speak failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> cancel() async {
    _generation++;
    try {
      await _player.stop();
    } on Object catch (e, st) {
      developer.log(
        'TtsService.cancel failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<Uint8List> synth(String text) async {
    final key = ttsCacheKey(text);
    final cached = await _cache.get(key);
    if (cached != null) return cached.readAsBytes();

    final bytes = await _client.synthesize(text);
    if (bytes.isEmpty) return bytes;

    await _cache.put(key, bytes);
    await _cache.enforceMaxSize();
    return bytes;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    try {
      await _player.stop();
      await _player.dispose();
    } on Object catch (e, st) {
      developer.log(
        'TtsService.dispose failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<int> _beginNewRequest() async {
    _generation++;
    final generation = _generation;
    await _player.stop();
    return generation;
  }

  bool _isCurrent(int generation) {
    return !_disposed && generation == _generation;
  }

  Future<File?> _getAudioFile(String text) async {
    final key = ttsCacheKey(text);
    final cached = await _cache.get(key);
    if (cached != null) return cached;

    final bytes = await _client.synthesize(text);
    if (bytes.isEmpty) return null;

    final file = await _cache.put(key, bytes);
    await _cache.enforceMaxSize();
    return file;
  }
}
