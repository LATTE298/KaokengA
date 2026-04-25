import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scenario_config.dart';
import '../models/session_record.dart';
import '../services/activity_log_repository.dart';
import '../services/scenario_settings_repository.dart';
import 'auth_provider.dart';
import 'content_providers.dart';

final activityLogRepositoryProvider = Provider<ActivityLogReader>((ref) {
  return ActivityLogRepository(FirebaseFirestore.instance);
});

final scenarioSettingsRepositoryProvider = Provider<ScenarioSettingsStore>((
  ref,
) {
  return ScenarioSettingsRepository(FirebaseFirestore.instance);
});

final activityLogLimitProvider =
    NotifierProvider<ActivityLogLimitNotifier, int>(
      ActivityLogLimitNotifier.new,
    );

class ActivityLogLimitNotifier extends Notifier<int> {
  @override
  int build() => 20;

  void loadMore() {
    state += 20;
  }
}

final activityLogProvider = StreamProvider<List<SessionRecord>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const <SessionRecord>[]);
  return ref
      .watch(activityLogRepositoryProvider)
      .watchRecentSessions(uid, limit: ref.watch(activityLogLimitProvider));
});

final scenarioSettingsProvider = StreamProvider<Map<String, bool>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(const <String, bool>{});
  return ref
      .watch(scenarioSettingsRepositoryProvider)
      .watchScenarioSettings(uid);
});

final enabledScenariosProvider = Provider<AsyncValue<List<ScenarioSummary>>>((
  ref,
) {
  final scenarios = ref.watch(scenarioListProvider);
  final settings = ref.watch(scenarioSettingsProvider);
  return scenarios.whenData((list) {
    final overrides = settings.valueOrNull ?? const <String, bool>{};
    return list
        .where((scenario) => overrides[scenario.scenarioId] != false)
        .toList();
  });
});

final scenarioToggleSavingProvider = StateProvider<Set<String>>((ref) => {});

final scenarioToggleControllerProvider = Provider<ScenarioToggleController>((
  ref,
) {
  return ScenarioToggleController(ref);
});

class ScenarioToggleController {
  ScenarioToggleController(this._ref);

  final Ref _ref;

  Future<void> setEnabled({
    required String scenarioId,
    required bool enabled,
  }) async {
    final uid = _ref.read(uidProvider);
    if (uid == null) throw const ParentAuthRequiredException();
    _setSaving(scenarioId, true);
    try {
      await _ref
          .read(scenarioSettingsRepositoryProvider)
          .setScenarioEnabled(
            uid: uid,
            scenarioId: scenarioId,
            enabled: enabled,
          );
    } finally {
      _setSaving(scenarioId, false);
    }
  }

  void _setSaving(String scenarioId, bool saving) {
    final notifier = _ref.read(scenarioToggleSavingProvider.notifier);
    final next = {...notifier.state};
    if (saving) {
      next.add(scenarioId);
    } else {
      next.remove(scenarioId);
    }
    notifier.state = next;
  }
}
