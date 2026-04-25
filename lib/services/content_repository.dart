import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/memory_pack.dart';
import '../models/scenario_config.dart';
import '../models/vocabulary_item.dart';

class ContentNotFoundException implements Exception {
  const ContentNotFoundException(this.message);

  final String message;

  @override
  String toString() => 'ContentNotFoundException: $message';
}

ScenarioSummary findScenarioSummary(
  List<ScenarioSummary> summaries,
  String scenarioId,
) {
  for (final summary in summaries) {
    if (summary.scenarioId == scenarioId) return summary;
  }
  throw ContentNotFoundException('Unknown scenario id: $scenarioId');
}

// Content loader. MVP source is bundled assets (spec 03 E-02 fallback path —
// promoted to primary because Firebase Storage requires Blaze billing).
// When Storage is re-enabled, this class is the single swap-point: rewrite
// `loadJson` to HTTP-fetch from the config URL with local cache, and the rest
// of the app won't change.
class ContentRepository {
  const ContentRepository();

  Future<List<ScenarioSummary>> fetchScenarioIndex() async {
    final raw = await _loadAssetJson('assets/scenarios/index.json');
    final list = (raw['scenarios'] as List).cast<Map<String, dynamic>>();
    return list.map(ScenarioSummary.fromJson).toList();
  }

  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl) async {
    final raw = await _loadJson(assetOrUrl);
    return ScenarioConfig.fromJson(raw);
  }

  Future<MemoryPack> fetchDefaultMemoryPack() async {
    final raw = await _loadAssetJson(
      'assets/memory_packs/thai_animals_001.json',
    );
    return MemoryPack.fromJson(raw);
  }

  Future<List<VocabularyItem>> fetchVocabulary() async {
    final raw = await _loadAssetJson('assets/vocabulary/vocabulary.json');
    final list = (raw['items'] as List).cast<Map<String, dynamic>>();
    return list.map(VocabularyItem.fromJson).toList();
  }

  Future<Map<String, dynamic>> _loadJson(String source) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      throw UnimplementedError(
        'Remote content URLs require firebase_storage (Blaze plan). '
        'Current MVP path loads from bundled assets only.',
      );
    }
    return _loadAssetJson(source);
  }

  Future<Map<String, dynamic>> _loadAssetJson(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
