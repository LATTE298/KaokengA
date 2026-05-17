import 'dart:io';
import 'dart:typed_data';

import 'package:daily_life/services/tts_service.dart';
import 'package:daily_life/services/tts_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalTtsAudioCache', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('tts_cache_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('uses SHA-256 cache keys and file names', () async {
      final key = ttsCacheKey('แมว');

      expect(key, startsWith('tts_'));
      expect(key, endsWith('.opus'));
      expect(key.length, 'tts_'.length + 64 + '.opus'.length);
    });

    test('stores and retrieves non-empty cache files', () async {
      final cache = LocalTtsAudioCache(directoryProvider: () async => tempDir);
      final key = ttsCacheKey('หมา');

      await cache.put(key, Uint8List.fromList([1, 2]));
      final cached = await cache.get(key);

      expect(cached, isNotNull);
      expect(cached, [1, 2]);
    });

    test('missing and empty cache files are treated as misses', () async {
      final cache = LocalTtsAudioCache(directoryProvider: () async => tempDir);
      final missingKey = ttsCacheKey('ไม่มี');
      final emptyKey = ttsCacheKey('ว่าง');

      expect(await cache.get(missingKey), isNull);
      await cache.put(emptyKey, Uint8List(0));
      expect(await cache.get(emptyKey), isNull);
    });

    test('LRU eviction removes oldest files until under max size', () async {
      final cache = LocalTtsAudioCache(
        directoryProvider: () async => tempDir,
        maxBytes: 5,
      );

      final oldKey = ttsCacheKey('เก่า');
      final newKey = ttsCacheKey('ใหม่');

      await cache.put(oldKey, Uint8List.fromList([1, 1, 1]));
      // Touch the mtime manually via the underlying file so eviction order is deterministic.
      final cacheDir = Directory('${tempDir.path}${Platform.pathSeparator}tts_cache');
      final oldFile = File('${cacheDir.path}${Platform.pathSeparator}$oldKey');
      await oldFile.setLastModified(DateTime.utc(2026, 1, 1));

      await cache.put(newKey, Uint8List.fromList([2, 2, 2]));
      final newFile = File('${cacheDir.path}${Platform.pathSeparator}$newKey');
      await newFile.setLastModified(DateTime.utc(2026, 1, 2));

      await cache.enforceMaxSize();

      expect(await oldFile.exists(), isFalse);
      expect(await newFile.exists(), isTrue);
    });
  });
}
