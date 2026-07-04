import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/loaded_scenario_config.dart';
import '../models/scenario_config.dart';
import '../models/vocabulary_item.dart';

abstract class ContentRepository {
  const ContentRepository();

  Future<List<ScenarioSummary>> fetchScenarioIndex();

  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl);

  Future<LoadedScenarioConfig> fetchLoadedScenarioConfig(
    String assetOrUrl,
  ) async {
    return LoadedScenarioConfig(
      config: await fetchScenarioConfig(assetOrUrl),
      placeholderImagePaths: const {},
    );
  }

  Future<List<VocabularyItem>> fetchVocabulary();
}

abstract class ContentException implements Exception {
  const ContentException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ContentNotFoundException extends ContentException {
  const ContentNotFoundException(super.message);
}

class ContentMalformedJsonException extends ContentException {
  const ContentMalformedJsonException(super.message);
}

class ContentUnpublishedException extends ContentException {
  const ContentUnpublishedException(super.message);
}

class ContentRemoteUrlNotSupportedException extends ContentException {
  const ContentRemoteUrlNotSupportedException(super.message);
}

class ContentAssetLoadException extends ContentException {
  const ContentAssetLoadException(super.message);
}

ScenarioSummary findScenarioSummary(
  List<ScenarioSummary> summaries,
  String scenarioId,
) {
  for (final summary in summaries) {
    if (summary.scenarioId == scenarioId) {
      if (!summary.published) {
        throw ContentUnpublishedException(
          'Scenario is not published: $scenarioId',
        );
      }
      return summary;
    }
  }
  throw ContentNotFoundException('Unknown scenario id: $scenarioId');
}

// MVP source is bundled assets (spec 03 E-02 fallback path, promoted to
// primary because Firebase Storage requires Blaze billing).
class AssetContentRepository extends ContentRepository {
  AssetContentRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<List<ScenarioSummary>> fetchScenarioIndex() async {
    final raw = await _loadAssetJson('assets/scenarios/index.json');
    final list = _readObjectList(
      raw,
      'scenarios',
      'assets/scenarios/index.json',
    );
    return _parseList(
      list,
      ScenarioSummary.fromJson,
      'assets/scenarios/index.json',
    );
  }

  @override
  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl) async {
    final raw = await _loadJson(assetOrUrl);
    return _parseObject(raw, ScenarioConfig.fromJson, assetOrUrl);
  }

  @override
  Future<LoadedScenarioConfig> fetchLoadedScenarioConfig(
    String assetOrUrl,
  ) async {
    final config = await fetchScenarioConfig(assetOrUrl);
    final placeholderPaths = await _fetchPlaceholderImagePaths();
    await _validateScenarioImages(config, placeholderPaths);
    return LoadedScenarioConfig(
      config: config,
      placeholderImagePaths: placeholderPaths,
    );
  }

  @override
  Future<List<VocabularyItem>> fetchVocabulary() async {
    const path = 'assets/vocabulary/vocabulary.json';
    final raw = await _loadAssetJson(path);
    final list = _readObjectList(raw, 'items', path);
    return _parseList(list, VocabularyItem.fromJson, path);
  }

  Future<Map<String, dynamic>> _loadJson(String source) {
    if (_isRemoteUrl(source)) {
      throw ContentRemoteUrlNotSupportedException(
        'Remote content URLs are not supported by AssetContentRepository: '
        '$source',
      );
    }
    return _loadAssetJson(source);
  }

  Future<Map<String, dynamic>> _loadAssetJson(String path) async {
    try {
      final raw = await _bundle.loadString(path);
      return _decodeJsonObject(raw, path);
    } on FlutterError catch (e) {
      throw ContentNotFoundException('Content asset not found: $path ($e)');
    }
  }

  Future<Set<String>> _fetchPlaceholderImagePaths() async {
    const path = 'assets/images/placeholder_manifest.json';
    final raw = await _loadAssetJson(path);
    final list = raw['placeholder_images'];
    if (list is! List) {
      throw const ContentMalformedJsonException(
        'Expected "placeholder_images" to be a list at '
        'assets/images/placeholder_manifest.json',
      );
    }
    try {
      return list.cast<String>().toSet();
    } on TypeError catch (e) {
      throw ContentMalformedJsonException(
        'Expected "placeholder_images" to contain strings at $path: $e',
      );
    }
  }

  Future<void> _validateScenarioImages(
    ScenarioConfig config,
    Set<String> placeholderPaths,
  ) async {
    final imagePaths = <String>{
      config.backgroundImage,
      for (final item in config.interactables) item.image,
    };

    for (final path in imagePaths) {
      if (placeholderPaths.contains(path)) continue;
      await _ensureAssetExists(path);
    }
  }

  Future<void> _ensureAssetExists(String path) async {
    if (_isRemoteUrl(path)) {
      throw ContentRemoteUrlNotSupportedException(
        'Remote image URLs are not supported by AssetContentRepository: $path',
      );
    }
    try {
      await _bundle.load(path);
    } on FlutterError catch (e) {
      throw ContentAssetLoadException(
        'Scenario image asset is missing and is not declared as a placeholder: '
        '$path ($e)',
      );
    }
  }
}

// Optional remote/cache implementation. It is not the MVP default provider yet,
// but it uses the same interface so callers do not change when enabled.
class CachedRemoteContentRepository extends ContentRepository {
  CachedRemoteContentRepository({
    required ContentRepository assetFallback,
    BaseCacheManager? cacheManager,
  }) : _assetFallback = assetFallback,
       _cacheManager = cacheManager ?? DefaultCacheManager();

  final ContentRepository _assetFallback;
  final BaseCacheManager _cacheManager;

  @override
  Future<List<ScenarioSummary>> fetchScenarioIndex() {
    return _assetFallback.fetchScenarioIndex();
  }

  @override
  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl) async {
    if (!_isRemoteUrl(assetOrUrl)) {
      return _assetFallback.fetchScenarioConfig(assetOrUrl);
    }

    final raw = await _loadRemoteJson(assetOrUrl);
    return _parseObject(raw, ScenarioConfig.fromJson, assetOrUrl);
  }

  @override
  Future<LoadedScenarioConfig> fetchLoadedScenarioConfig(String assetOrUrl) {
    if (!_isRemoteUrl(assetOrUrl)) {
      return _assetFallback.fetchLoadedScenarioConfig(assetOrUrl);
    }
    return super.fetchLoadedScenarioConfig(assetOrUrl);
  }

  @override
  Future<List<VocabularyItem>> fetchVocabulary() {
    return _assetFallback.fetchVocabulary();
  }

  Future<Map<String, dynamic>> _loadRemoteJson(String url) async {
    try {
      final file = await _cacheManager.getSingleFile(url);
      return _decodeJsonObject(await file.readAsString(), url);
    } on FileSystemException catch (e) {
      throw ContentNotFoundException('Remote content not found: $url ($e)');
    }
  }
}

bool _isRemoteUrl(String source) {
  return source.startsWith('http://') || source.startsWith('https://');
}

Map<String, dynamic> _decodeJsonObject(String raw, String source) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
  } on FormatException catch (e) {
    throw ContentMalformedJsonException('Malformed JSON at $source: $e');
  }
  throw ContentMalformedJsonException('Expected a JSON object at $source');
}

List<Map<String, dynamic>> _readObjectList(
  Map<String, dynamic> raw,
  String key,
  String source,
) {
  final value = raw[key];
  if (value is List) {
    try {
      return value.cast<Map<String, dynamic>>();
    } on TypeError catch (e) {
      throw ContentMalformedJsonException(
        'Expected "$key" to contain objects at $source: $e',
      );
    }
  }
  throw ContentMalformedJsonException(
    'Expected "$key" to be a list at $source',
  );
}

T _parseObject<T>(
  Map<String, dynamic> raw,
  T Function(Map<String, dynamic>) parser,
  String source,
) {
  try {
    return parser(raw);
  } on Object catch (e) {
    throw ContentMalformedJsonException('Invalid content shape at $source: $e');
  }
}

List<T> _parseList<T>(
  List<Map<String, dynamic>> raw,
  T Function(Map<String, dynamic>) parser,
  String source,
) {
  try {
    return raw.map(parser).toList();
  } on Object catch (e) {
    throw ContentMalformedJsonException('Invalid content shape at $source: $e');
  }
}
