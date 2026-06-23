import 'package:freezed_annotation/freezed_annotation.dart';

import 'scenario_config.dart';

part 'session_record.freezed.dart';
part 'session_record.g.dart';

// Firestore /sessions/{uid}/records/{session_id} — spec 06 §4.
@freezed
class DragInteraction with _$DragInteraction {
  const factory DragInteraction({
    @JsonKey(name: 'interaction_id') required String interactionId,
    @JsonKey(name: 'object_id') required String objectId,
    @JsonKey(name: 'was_target') required bool wasTarget,
    @JsonKey(name: 'was_successful') required bool wasSuccessful,
    @JsonKey(name: 'duration_ms') required int durationMs,
    @JsonKey(name: 'straightness_score') required double straightnessScore,
    @JsonKey(name: 'path_points') required List<GamePosition> pathPoints,
  }) = _DragInteraction;

  factory DragInteraction.fromJson(Map<String, dynamic> json) =>
      _$DragInteractionFromJson(json);
}

@freezed
class MatchEvent with _$MatchEvent {
  const factory MatchEvent({
    @JsonKey(name: 'pair_id') required String pairId,
    @JsonKey(name: 'matched') required bool matched,
    @JsonKey(name: 'at_ms') required int atMs,
  }) = _MatchEvent;

  factory MatchEvent.fromJson(Map<String, dynamic> json) =>
      _$MatchEventFromJson(json);
}

@freezed
class SessionRecord with _$SessionRecord {
  const factory SessionRecord({
    @JsonKey(name: 'session_id') required String sessionId,
    required String uid,
    @JsonKey(name: 'scenario_id') required String scenarioId,
    required String module,
    @JsonKey(name: 'started_at') required String startedAt,
    @JsonKey(name: 'ended_at') required String endedAt,
    @JsonKey(name: 'duration_ms') required int durationMs,
    required bool completed,
    @JsonKey(name: 'drag_interactions')
    @Default(<DragInteraction>[])
    List<DragInteraction> dragInteractions,
    @JsonKey(name: 'pairs_matched', includeIfNull: false) int? pairsMatched,
    @JsonKey(name: 'total_pairs', includeIfNull: false) int? totalPairs,
    @JsonKey(name: 'match_events', includeIfNull: false)
    List<MatchEvent>? matchEvents,
    @JsonKey(name: 'score', includeIfNull: false) int? score,
    @JsonKey(name: 'stars', includeIfNull: false) int? stars,
  }) = _SessionRecord;

  factory SessionRecord.fromJson(Map<String, dynamic> json) =>
      _$SessionRecordFromJson(json);
}
