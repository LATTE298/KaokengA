import 'package:daily_life/models/app_types.dart';
import 'package:daily_life/models/loaded_scenario_config.dart';
import 'package:daily_life/models/memory_pack.dart';
import 'package:daily_life/models/scenario_config.dart';
import 'package:daily_life/models/session_record.dart';
import 'package:daily_life/models/vocabulary_item.dart';
import 'package:daily_life/providers/auth_provider.dart';
import 'package:daily_life/providers/content_providers.dart';
import 'package:daily_life/providers/parent_dashboard_providers.dart';
import 'package:daily_life/services/activity_log_repository.dart';
import 'package:daily_life/services/content_repository.dart';
import 'package:daily_life/services/scenario_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parent dashboard providers', () {
    test('activity log emits records and respects pagination limit', () async {
      final log = _FakeActivityLogReader([
        _record('session-1', '711_milk_001', kModuleDailyLife),
        _record('session-2', 'thai_animals', kModuleMemory),
      ]);
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWithValue('uid-1'),
          activityLogRepositoryProvider.overrideWithValue(log),
        ],
      );
      addTearDown(container.dispose);

      final first = await container.read(activityLogProvider.future);
      container.read(activityLogLimitProvider.notifier).loadMore();
      final second = await container.read(activityLogProvider.future);

      expect(first, hasLength(2));
      expect(second, hasLength(2));
      expect(log.limits, [20, 40]);
    });

    test(
      'enabledScenariosProvider defaults missing overrides to enabled',
      () async {
        final container = ProviderContainer(
          overrides: [
            contentRepositoryProvider.overrideWithValue(
              _FakeContentRepository([_scenario('a'), _scenario('b')]),
            ),
            scenarioSettingsProvider.overrideWith(
              (ref) => Stream.value(const {'b': false}),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(scenarioListProvider.future);
        await container.read(scenarioSettingsProvider.future);
        final enabled = container.read(enabledScenariosProvider).value!;

        expect(enabled.map((s) => s.scenarioId), ['a']);
      },
    );

    test('scenario toggle controller writes override document', () async {
      final store = _FakeScenarioSettingsStore();
      final container = ProviderContainer(
        overrides: [
          uidProvider.overrideWithValue('uid-1'),
          scenarioSettingsRepositoryProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(scenarioToggleControllerProvider)
          .setEnabled(scenarioId: '711_milk_001', enabled: false);

      expect(store.writes.single, ('uid-1', '711_milk_001', false));
      expect(container.read(scenarioToggleSavingProvider), isEmpty);
    });
  });
}

class _FakeActivityLogReader implements ActivityLogReader {
  _FakeActivityLogReader(this.records);

  final List<SessionRecord> records;
  final limits = <int>[];

  @override
  Stream<List<SessionRecord>> watchRecentSessions(
    String uid, {
    required int limit,
  }) {
    limits.add(limit);
    return Stream.value(records.take(limit).toList());
  }
}

class _FakeScenarioSettingsStore implements ScenarioSettingsStore {
  final writes = <(String uid, String scenarioId, bool enabled)>[];

  @override
  Stream<Map<String, bool>> watchScenarioSettings(String uid) {
    return Stream.value(const {});
  }

  @override
  Future<void> setScenarioEnabled({
    required String uid,
    required String scenarioId,
    required bool enabled,
  }) async {
    writes.add((uid, scenarioId, enabled));
  }
}

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository(this.scenarios);

  final List<ScenarioSummary> scenarios;

  @override
  Future<List<ScenarioSummary>> fetchScenarioIndex() async => scenarios;

  @override
  Future<ScenarioConfig> fetchScenarioConfig(String assetOrUrl) {
    throw UnimplementedError();
  }

  @override
  Future<LoadedScenarioConfig> fetchLoadedScenarioConfig(String assetOrUrl) {
    throw UnimplementedError();
  }

  @override
  Future<List<VocabularyItem>> fetchVocabulary() {
    throw UnimplementedError();
  }
}

ScenarioSummary _scenario(String id) {
  return ScenarioSummary(
    scenarioId: id,
    titleTh: id,
    category: 'daily_life',
    module: 'A',
    configUrl: 'assets/scenarios/$id.json',
    thumbnailUrl: 'assets/images/$id.webp',
    version: 1,
    published: true,
  );
}

SessionRecord _record(String sessionId, String scenarioId, String module) {
  return SessionRecord(
    sessionId: sessionId,
    uid: 'uid-1',
    scenarioId: scenarioId,
    module: module,
    startedAt: '2026-04-25T10:00:00.000Z',
    endedAt: '2026-04-25T10:01:00.000Z',
    durationMs: 60000,
    completed: true,
  );
}
