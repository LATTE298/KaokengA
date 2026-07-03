import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

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

// ---------------------------------------------------------------------------
// Abstract interfaces
// ---------------------------------------------------------------------------

// สัญญากลางของ "ตัวพูด" ที่ทั้งแอปเรียกผ่าน ttsServiceProvider — มีสองเครื่องเสียง:
// TtsService (Google Cloud TTS) และ DeviceTtsService (engine ในเครื่องผ่าน flutter_tts
// ใช้เมื่อไม่มีคีย์หรือ Cloud ล้มเหลว) จุดเรียกใช้ห้ามผูกกับ implementation ตรงๆ
abstract class TtsSpeaker {
  /// พูด [text] — การเรียกครั้งใหม่ต้องตัดเสียงที่ค้างอยู่เสมอ (latest wins)
  /// ห้าม throw ออกไปหาผู้เรียก: เสียงเป็น best-effort ต้องไม่ทำแอปล้ม
  Future<void> speak(String text);

  Future<void> cancel();

  Future<void> dispose();
}

abstract class TtsClient {
  Future<Uint8List> synthesize(String text);
}

abstract class TtsAudioPlayer {
  /// Play audio from raw OGG/OPUS [bytes].
  Future<void> playBytes(Uint8List bytes);

  Future<void> stop();

  Future<void> dispose();
}

abstract class TtsAudioCache {
  Future<Uint8List?> get(String key);

  Future<void> put(String key, Uint8List bytes);

  Future<void> enforceMaxSize();
}

// ---------------------------------------------------------------------------
// TtsClient implementations (no dart:io needed)
// ---------------------------------------------------------------------------

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

    if (response.statusCode != 200) {
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

// ---------------------------------------------------------------------------
// TtsService — orchestrates client + cache + player
// ---------------------------------------------------------------------------

class TtsService implements TtsSpeaker {
  TtsService({
    required TtsClient client,
    required TtsAudioCache cache,
    required TtsAudioPlayer player,
    TtsSpeaker? fallback,
  }) : _client = client,
       _cache = cache,
       _player = player,
       _fallback = fallback;

  final TtsClient _client;
  final TtsAudioCache _cache;
  final TtsAudioPlayer _player;

  // เครื่องเสียงสำรอง (เสียงในเครื่อง) เมื่อ Cloud ให้เสียงไม่ได้ — ไม่ได้เป็นเจ้าของ:
  // dispose() ของ service นี้จะไม่แตะ fallback ให้ provider ที่สร้างจัดการวงจรชีวิตเอง
  final TtsSpeaker? _fallback;

  var _generation = 0;
  var _disposed = false;

  @override
  Future<void> speak(String text) async {
    int? generation;
    try {
      generation = await _beginNewRequest();
      final bytes = await _getAudioBytes(text);
      if (!_isCurrent(generation)) return;
      if (bytes == null || bytes.isEmpty) {
        // client คืนค่าว่าง (เช่น NoOpTtsClient) → ส่งต่อเครื่องเสียงสำรองแทนการเงียบ
        await _fallback?.speak(text);
        return;
      }
      await _player.playBytes(bytes);
    } on Object catch (e, st) {
      developer.log(
        'TtsService.speak failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
      // Cloud ล้มเหลว (เช่น ออฟไลน์และประโยคนี้ยังไม่เคยแคช) → เสียงในเครื่องพูดแทน
      // เช็ค generation ก่อน กันคำเก่าที่ถูก speak ใหม่แทนที่ไปแล้วแทรกกลับมาพูด
      if (generation != null && _isCurrent(generation)) {
        await _fallback?.speak(text);
      }
    }
  }

  @override
  Future<void> cancel() async {
    _generation++;
    try {
      await _player.stop();
      await _fallback?.cancel();
    } on Object catch (e, st) {
      developer.log(
        'TtsService.cancel failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Synthesise [text] and return the raw audio bytes (cached).
  Future<Uint8List> synth(String text) async {
    final key = ttsCacheKey(text);
    final cached = await _cache.get(key);
    if (cached != null) return cached;

    final bytes = await _client.synthesize(text);
    if (bytes.isEmpty) return bytes;

    await _cache.put(key, bytes);
    await _cache.enforceMaxSize();
    return bytes;
  }

  @override
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
    // เผื่อรอบก่อนเครื่องเสียงสำรองกำลังพูดค้างอยู่ — เสียงใหม่ต้องแทนที่เสมอ
    await _fallback?.cancel();
    return generation;
  }

  bool _isCurrent(int generation) {
    return !_disposed && generation == _generation;
  }

  Future<Uint8List?> _getAudioBytes(String text) async {
    final key = ttsCacheKey(text);
    final cached = await _cache.get(key);
    if (cached != null) return cached;

    final bytes = await _client.synthesize(text);
    if (bytes.isEmpty) return null;

    await _cache.put(key, bytes);
    await _cache.enforceMaxSize();
    return bytes;
  }
}
