// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DragInteractionImpl _$$DragInteractionImplFromJson(
  Map<String, dynamic> json,
) => _$DragInteractionImpl(
  interactionId: json['interaction_id'] as String,
  objectId: json['object_id'] as String,
  wasTarget: json['was_target'] as bool,
  wasSuccessful: json['was_successful'] as bool,
  durationMs: (json['duration_ms'] as num).toInt(),
  straightnessScore: (json['straightness_score'] as num).toDouble(),
  pathPoints:
      (json['path_points'] as List<dynamic>)
          .map((e) => GamePosition.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$$DragInteractionImplToJson(
  _$DragInteractionImpl instance,
) => <String, dynamic>{
  'interaction_id': instance.interactionId,
  'object_id': instance.objectId,
  'was_target': instance.wasTarget,
  'was_successful': instance.wasSuccessful,
  'duration_ms': instance.durationMs,
  'straightness_score': instance.straightnessScore,
  'path_points': instance.pathPoints.map((e) => e.toJson()).toList(),
};

_$MatchEventImpl _$$MatchEventImplFromJson(Map<String, dynamic> json) =>
    _$MatchEventImpl(
      pairId: json['pair_id'] as String,
      matched: json['matched'] as bool,
      atMs: (json['at_ms'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchEventImplToJson(_$MatchEventImpl instance) =>
    <String, dynamic>{
      'pair_id': instance.pairId,
      'matched': instance.matched,
      'at_ms': instance.atMs,
    };

_$SessionRecordImpl _$$SessionRecordImplFromJson(Map<String, dynamic> json) =>
    _$SessionRecordImpl(
      sessionId: json['session_id'] as String,
      uid: json['uid'] as String,
      scenarioId: json['scenario_id'] as String,
      module: json['module'] as String,
      startedAt: json['started_at'] as String,
      endedAt: json['ended_at'] as String,
      durationMs: (json['duration_ms'] as num).toInt(),
      completed: json['completed'] as bool,
      dragInteractions:
          (json['drag_interactions'] as List<dynamic>?)
              ?.map((e) => DragInteraction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DragInteraction>[],
      pairsMatched: (json['pairs_matched'] as num?)?.toInt(),
      totalPairs: (json['total_pairs'] as num?)?.toInt(),
      matchEvents:
          (json['match_events'] as List<dynamic>?)
              ?.map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$SessionRecordImplToJson(
  _$SessionRecordImpl instance,
) => <String, dynamic>{
  'session_id': instance.sessionId,
  'uid': instance.uid,
  'scenario_id': instance.scenarioId,
  'module': instance.module,
  'started_at': instance.startedAt,
  'ended_at': instance.endedAt,
  'duration_ms': instance.durationMs,
  'completed': instance.completed,
  'drag_interactions':
      instance.dragInteractions.map((e) => e.toJson()).toList(),
  if (instance.pairsMatched case final value?) 'pairs_matched': value,
  if (instance.totalPairs case final value?) 'total_pairs': value,
  if (instance.matchEvents?.map((e) => e.toJson()).toList() case final value?)
    'match_events': value,
};
