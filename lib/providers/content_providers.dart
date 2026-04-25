import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/memory_pack.dart';
import '../models/scenario_config.dart';
import '../models/vocabulary_item.dart';
import '../services/content_repository.dart';

// Repository singleton.
final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => AssetContentRepository(),
);

// List of published scenarios — spec 13 §Scenario Providers (scenarioListProvider).
// MVP source is bundled assets; interface matches what a Firestore stream would
// emit so it swaps in cleanly later.
final scenarioListProvider = FutureProvider<List<ScenarioSummary>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  final scenarios = await repo.fetchScenarioIndex();
  return scenarios.where((scenario) => scenario.published).toList();
});

// Full config for one scenario, fetched lazily. Spec 13 §Content Providers.
final scenarioConfigProvider = FutureProvider.family<ScenarioConfig, String>((
  ref,
  scenarioId,
) async {
  final repo = ref.watch(contentRepositoryProvider);
  final list = await repo.fetchScenarioIndex();
  final summary = findScenarioSummary(list, scenarioId);
  return repo.fetchScenarioConfig(summary.configUrl);
});

final memoryPackProvider = FutureProvider<MemoryPack>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.fetchDefaultMemoryPack();
});

final vocabularyProvider = FutureProvider<List<VocabularyItem>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.fetchVocabulary();
});
