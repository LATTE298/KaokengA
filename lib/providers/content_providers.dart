import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_types.dart';
import '../models/memory_pack.dart';
import '../models/loaded_scenario_config.dart';
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
  final loaded = await ref.watch(
    loadedScenarioConfigProvider(scenarioId).future,
  );
  return loaded.config;
});

final loadedScenarioConfigProvider =
    FutureProvider.family<LoadedScenarioConfig, String>((
      ref,
      scenarioId,
    ) async {
      final repo = ref.watch(contentRepositoryProvider);
      final list = await repo.fetchScenarioIndex();
      final summary = findScenarioSummary(list, scenarioId);
      return repo.fetchLoadedScenarioConfig(summary.configUrl);
    });

// แพ็คเกมจับคู่ภาพ: สร้างจากคลังคำศัพท์รายหมวด (แหล่งข้อมูลเดียวกับ sound board
// และเกมตอบคำถาม — ไม่มีไฟล์แพ็คแยกให้ดูแล เพิ่มคำใหม่แล้วทุกเกมได้พร้อมกัน)
// แพ็คละ ~15 คู่ ตัวเกมสุ่มหยิบ 8 คู่ต่อรอบใน MemoryGameController
final memoryPacksProvider = FutureProvider<List<MemoryPack>>((ref) async {
  final items = await ref.watch(vocabularyProvider.future);
  return [
    for (final category in kVocabCategories)
      MemoryPack(
        packId: 'memory_$category',
        titleTh: kVocabCategoryTitles[category] ?? category,
        pairs: [
          for (final item in items.where((i) => i.category == category))
            MemoryPair(
              id: item.itemId,
              image: item.image,
              ttsName: item.ttsWord,
            ),
        ],
      ),
  ].where((pack) => pack.pairs.length >= 2).toList();
});

final memoryPackProvider = FutureProvider.family<MemoryPack, String>((
  ref,
  packId,
) async {
  final packs = await ref.watch(memoryPacksProvider.future);
  return packs.firstWhere(
    (pack) => pack.packId == packId,
    orElse: () => throw StateError('ไม่พบแพ็คจับคู่ภาพ: $packId'),
  );
});

final vocabularyProvider = FutureProvider<List<VocabularyItem>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.fetchVocabulary();
});
