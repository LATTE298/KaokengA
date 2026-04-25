import 'package:cloud_firestore/cloud_firestore.dart';

class ScenarioSettingOverride {
  const ScenarioSettingOverride({
    required this.scenarioId,
    required this.enabled,
  });

  factory ScenarioSettingOverride.fromJson(Map<String, dynamic> json) {
    return ScenarioSettingOverride(
      scenarioId: json['scenario_id'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  final String scenarioId;
  final bool enabled;

  Map<String, Object?> toJson({String? updatedAt}) {
    return {
      'scenario_id': scenarioId,
      'enabled': enabled,
      'updated_at': updatedAt ?? DateTime.now().toUtc().toIso8601String(),
    };
  }
}

abstract class ScenarioSettingsReader {
  Stream<Map<String, bool>> watchScenarioSettings(String uid);
}

abstract class ScenarioSettingsWriter {
  Future<void> setScenarioEnabled({
    required String uid,
    required String scenarioId,
    required bool enabled,
  });
}

abstract class ScenarioSettingsStore
    implements ScenarioSettingsReader, ScenarioSettingsWriter {}

class ScenarioSettingsRepository implements ScenarioSettingsStore {
  ScenarioSettingsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<Map<String, bool>> watchScenarioSettings(String uid) {
    return _firestore
        .collection('scenario_settings')
        .doc(uid)
        .collection('overrides')
        .snapshots()
        .map((snapshot) {
          return {
            for (final override in snapshot.docs.map(
              (doc) => ScenarioSettingOverride.fromJson(doc.data()),
            ))
              override.scenarioId: override.enabled,
          };
        });
  }

  @override
  Future<void> setScenarioEnabled({
    required String uid,
    required String scenarioId,
    required bool enabled,
  }) {
    final override = ScenarioSettingOverride(
      scenarioId: scenarioId,
      enabled: enabled,
    );
    return _firestore
        .collection('scenario_settings')
        .doc(uid)
        .collection('overrides')
        .doc(scenarioId)
        .set(override.toJson());
  }
}
