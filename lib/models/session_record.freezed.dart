// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DragInteraction _$DragInteractionFromJson(Map<String, dynamic> json) {
  return _DragInteraction.fromJson(json);
}

/// @nodoc
mixin _$DragInteraction {
  @JsonKey(name: 'interaction_id')
  String get interactionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'object_id')
  String get objectId => throw _privateConstructorUsedError;
  @JsonKey(name: 'was_target')
  bool get wasTarget => throw _privateConstructorUsedError;
  @JsonKey(name: 'was_successful')
  bool get wasSuccessful => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_ms')
  int get durationMs => throw _privateConstructorUsedError;
  @JsonKey(name: 'straightness_score')
  double get straightnessScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'path_points')
  List<GamePosition> get pathPoints => throw _privateConstructorUsedError;

  /// Serializes this DragInteraction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DragInteraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DragInteractionCopyWith<DragInteraction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DragInteractionCopyWith<$Res> {
  factory $DragInteractionCopyWith(
    DragInteraction value,
    $Res Function(DragInteraction) then,
  ) = _$DragInteractionCopyWithImpl<$Res, DragInteraction>;
  @useResult
  $Res call({
    @JsonKey(name: 'interaction_id') String interactionId,
    @JsonKey(name: 'object_id') String objectId,
    @JsonKey(name: 'was_target') bool wasTarget,
    @JsonKey(name: 'was_successful') bool wasSuccessful,
    @JsonKey(name: 'duration_ms') int durationMs,
    @JsonKey(name: 'straightness_score') double straightnessScore,
    @JsonKey(name: 'path_points') List<GamePosition> pathPoints,
  });
}

/// @nodoc
class _$DragInteractionCopyWithImpl<$Res, $Val extends DragInteraction>
    implements $DragInteractionCopyWith<$Res> {
  _$DragInteractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DragInteraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interactionId = null,
    Object? objectId = null,
    Object? wasTarget = null,
    Object? wasSuccessful = null,
    Object? durationMs = null,
    Object? straightnessScore = null,
    Object? pathPoints = null,
  }) {
    return _then(
      _value.copyWith(
            interactionId:
                null == interactionId
                    ? _value.interactionId
                    : interactionId // ignore: cast_nullable_to_non_nullable
                        as String,
            objectId:
                null == objectId
                    ? _value.objectId
                    : objectId // ignore: cast_nullable_to_non_nullable
                        as String,
            wasTarget:
                null == wasTarget
                    ? _value.wasTarget
                    : wasTarget // ignore: cast_nullable_to_non_nullable
                        as bool,
            wasSuccessful:
                null == wasSuccessful
                    ? _value.wasSuccessful
                    : wasSuccessful // ignore: cast_nullable_to_non_nullable
                        as bool,
            durationMs:
                null == durationMs
                    ? _value.durationMs
                    : durationMs // ignore: cast_nullable_to_non_nullable
                        as int,
            straightnessScore:
                null == straightnessScore
                    ? _value.straightnessScore
                    : straightnessScore // ignore: cast_nullable_to_non_nullable
                        as double,
            pathPoints:
                null == pathPoints
                    ? _value.pathPoints
                    : pathPoints // ignore: cast_nullable_to_non_nullable
                        as List<GamePosition>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DragInteractionImplCopyWith<$Res>
    implements $DragInteractionCopyWith<$Res> {
  factory _$$DragInteractionImplCopyWith(
    _$DragInteractionImpl value,
    $Res Function(_$DragInteractionImpl) then,
  ) = __$$DragInteractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'interaction_id') String interactionId,
    @JsonKey(name: 'object_id') String objectId,
    @JsonKey(name: 'was_target') bool wasTarget,
    @JsonKey(name: 'was_successful') bool wasSuccessful,
    @JsonKey(name: 'duration_ms') int durationMs,
    @JsonKey(name: 'straightness_score') double straightnessScore,
    @JsonKey(name: 'path_points') List<GamePosition> pathPoints,
  });
}

/// @nodoc
class __$$DragInteractionImplCopyWithImpl<$Res>
    extends _$DragInteractionCopyWithImpl<$Res, _$DragInteractionImpl>
    implements _$$DragInteractionImplCopyWith<$Res> {
  __$$DragInteractionImplCopyWithImpl(
    _$DragInteractionImpl _value,
    $Res Function(_$DragInteractionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DragInteraction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interactionId = null,
    Object? objectId = null,
    Object? wasTarget = null,
    Object? wasSuccessful = null,
    Object? durationMs = null,
    Object? straightnessScore = null,
    Object? pathPoints = null,
  }) {
    return _then(
      _$DragInteractionImpl(
        interactionId:
            null == interactionId
                ? _value.interactionId
                : interactionId // ignore: cast_nullable_to_non_nullable
                    as String,
        objectId:
            null == objectId
                ? _value.objectId
                : objectId // ignore: cast_nullable_to_non_nullable
                    as String,
        wasTarget:
            null == wasTarget
                ? _value.wasTarget
                : wasTarget // ignore: cast_nullable_to_non_nullable
                    as bool,
        wasSuccessful:
            null == wasSuccessful
                ? _value.wasSuccessful
                : wasSuccessful // ignore: cast_nullable_to_non_nullable
                    as bool,
        durationMs:
            null == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                    as int,
        straightnessScore:
            null == straightnessScore
                ? _value.straightnessScore
                : straightnessScore // ignore: cast_nullable_to_non_nullable
                    as double,
        pathPoints:
            null == pathPoints
                ? _value._pathPoints
                : pathPoints // ignore: cast_nullable_to_non_nullable
                    as List<GamePosition>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DragInteractionImpl implements _DragInteraction {
  const _$DragInteractionImpl({
    @JsonKey(name: 'interaction_id') required this.interactionId,
    @JsonKey(name: 'object_id') required this.objectId,
    @JsonKey(name: 'was_target') required this.wasTarget,
    @JsonKey(name: 'was_successful') required this.wasSuccessful,
    @JsonKey(name: 'duration_ms') required this.durationMs,
    @JsonKey(name: 'straightness_score') required this.straightnessScore,
    @JsonKey(name: 'path_points') required final List<GamePosition> pathPoints,
  }) : _pathPoints = pathPoints;

  factory _$DragInteractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DragInteractionImplFromJson(json);

  @override
  @JsonKey(name: 'interaction_id')
  final String interactionId;
  @override
  @JsonKey(name: 'object_id')
  final String objectId;
  @override
  @JsonKey(name: 'was_target')
  final bool wasTarget;
  @override
  @JsonKey(name: 'was_successful')
  final bool wasSuccessful;
  @override
  @JsonKey(name: 'duration_ms')
  final int durationMs;
  @override
  @JsonKey(name: 'straightness_score')
  final double straightnessScore;
  final List<GamePosition> _pathPoints;
  @override
  @JsonKey(name: 'path_points')
  List<GamePosition> get pathPoints {
    if (_pathPoints is EqualUnmodifiableListView) return _pathPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pathPoints);
  }

  @override
  String toString() {
    return 'DragInteraction(interactionId: $interactionId, objectId: $objectId, wasTarget: $wasTarget, wasSuccessful: $wasSuccessful, durationMs: $durationMs, straightnessScore: $straightnessScore, pathPoints: $pathPoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DragInteractionImpl &&
            (identical(other.interactionId, interactionId) ||
                other.interactionId == interactionId) &&
            (identical(other.objectId, objectId) ||
                other.objectId == objectId) &&
            (identical(other.wasTarget, wasTarget) ||
                other.wasTarget == wasTarget) &&
            (identical(other.wasSuccessful, wasSuccessful) ||
                other.wasSuccessful == wasSuccessful) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.straightnessScore, straightnessScore) ||
                other.straightnessScore == straightnessScore) &&
            const DeepCollectionEquality().equals(
              other._pathPoints,
              _pathPoints,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    interactionId,
    objectId,
    wasTarget,
    wasSuccessful,
    durationMs,
    straightnessScore,
    const DeepCollectionEquality().hash(_pathPoints),
  );

  /// Create a copy of DragInteraction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DragInteractionImplCopyWith<_$DragInteractionImpl> get copyWith =>
      __$$DragInteractionImplCopyWithImpl<_$DragInteractionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DragInteractionImplToJson(this);
  }
}

abstract class _DragInteraction implements DragInteraction {
  const factory _DragInteraction({
    @JsonKey(name: 'interaction_id') required final String interactionId,
    @JsonKey(name: 'object_id') required final String objectId,
    @JsonKey(name: 'was_target') required final bool wasTarget,
    @JsonKey(name: 'was_successful') required final bool wasSuccessful,
    @JsonKey(name: 'duration_ms') required final int durationMs,
    @JsonKey(name: 'straightness_score')
    required final double straightnessScore,
    @JsonKey(name: 'path_points') required final List<GamePosition> pathPoints,
  }) = _$DragInteractionImpl;

  factory _DragInteraction.fromJson(Map<String, dynamic> json) =
      _$DragInteractionImpl.fromJson;

  @override
  @JsonKey(name: 'interaction_id')
  String get interactionId;
  @override
  @JsonKey(name: 'object_id')
  String get objectId;
  @override
  @JsonKey(name: 'was_target')
  bool get wasTarget;
  @override
  @JsonKey(name: 'was_successful')
  bool get wasSuccessful;
  @override
  @JsonKey(name: 'duration_ms')
  int get durationMs;
  @override
  @JsonKey(name: 'straightness_score')
  double get straightnessScore;
  @override
  @JsonKey(name: 'path_points')
  List<GamePosition> get pathPoints;

  /// Create a copy of DragInteraction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DragInteractionImplCopyWith<_$DragInteractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) {
  return _MatchEvent.fromJson(json);
}

/// @nodoc
mixin _$MatchEvent {
  @JsonKey(name: 'pair_id')
  String get pairId => throw _privateConstructorUsedError;
  @JsonKey(name: 'matched')
  bool get matched => throw _privateConstructorUsedError;
  @JsonKey(name: 'at_ms')
  int get atMs => throw _privateConstructorUsedError;

  /// Serializes this MatchEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchEventCopyWith<MatchEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchEventCopyWith<$Res> {
  factory $MatchEventCopyWith(
    MatchEvent value,
    $Res Function(MatchEvent) then,
  ) = _$MatchEventCopyWithImpl<$Res, MatchEvent>;
  @useResult
  $Res call({
    @JsonKey(name: 'pair_id') String pairId,
    @JsonKey(name: 'matched') bool matched,
    @JsonKey(name: 'at_ms') int atMs,
  });
}

/// @nodoc
class _$MatchEventCopyWithImpl<$Res, $Val extends MatchEvent>
    implements $MatchEventCopyWith<$Res> {
  _$MatchEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pairId = null,
    Object? matched = null,
    Object? atMs = null,
  }) {
    return _then(
      _value.copyWith(
            pairId:
                null == pairId
                    ? _value.pairId
                    : pairId // ignore: cast_nullable_to_non_nullable
                        as String,
            matched:
                null == matched
                    ? _value.matched
                    : matched // ignore: cast_nullable_to_non_nullable
                        as bool,
            atMs:
                null == atMs
                    ? _value.atMs
                    : atMs // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchEventImplCopyWith<$Res>
    implements $MatchEventCopyWith<$Res> {
  factory _$$MatchEventImplCopyWith(
    _$MatchEventImpl value,
    $Res Function(_$MatchEventImpl) then,
  ) = __$$MatchEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pair_id') String pairId,
    @JsonKey(name: 'matched') bool matched,
    @JsonKey(name: 'at_ms') int atMs,
  });
}

/// @nodoc
class __$$MatchEventImplCopyWithImpl<$Res>
    extends _$MatchEventCopyWithImpl<$Res, _$MatchEventImpl>
    implements _$$MatchEventImplCopyWith<$Res> {
  __$$MatchEventImplCopyWithImpl(
    _$MatchEventImpl _value,
    $Res Function(_$MatchEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pairId = null,
    Object? matched = null,
    Object? atMs = null,
  }) {
    return _then(
      _$MatchEventImpl(
        pairId:
            null == pairId
                ? _value.pairId
                : pairId // ignore: cast_nullable_to_non_nullable
                    as String,
        matched:
            null == matched
                ? _value.matched
                : matched // ignore: cast_nullable_to_non_nullable
                    as bool,
        atMs:
            null == atMs
                ? _value.atMs
                : atMs // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchEventImpl implements _MatchEvent {
  const _$MatchEventImpl({
    @JsonKey(name: 'pair_id') required this.pairId,
    @JsonKey(name: 'matched') required this.matched,
    @JsonKey(name: 'at_ms') required this.atMs,
  });

  factory _$MatchEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchEventImplFromJson(json);

  @override
  @JsonKey(name: 'pair_id')
  final String pairId;
  @override
  @JsonKey(name: 'matched')
  final bool matched;
  @override
  @JsonKey(name: 'at_ms')
  final int atMs;

  @override
  String toString() {
    return 'MatchEvent(pairId: $pairId, matched: $matched, atMs: $atMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchEventImpl &&
            (identical(other.pairId, pairId) || other.pairId == pairId) &&
            (identical(other.matched, matched) || other.matched == matched) &&
            (identical(other.atMs, atMs) || other.atMs == atMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, pairId, matched, atMs);

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchEventImplCopyWith<_$MatchEventImpl> get copyWith =>
      __$$MatchEventImplCopyWithImpl<_$MatchEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchEventImplToJson(this);
  }
}

abstract class _MatchEvent implements MatchEvent {
  const factory _MatchEvent({
    @JsonKey(name: 'pair_id') required final String pairId,
    @JsonKey(name: 'matched') required final bool matched,
    @JsonKey(name: 'at_ms') required final int atMs,
  }) = _$MatchEventImpl;

  factory _MatchEvent.fromJson(Map<String, dynamic> json) =
      _$MatchEventImpl.fromJson;

  @override
  @JsonKey(name: 'pair_id')
  String get pairId;
  @override
  @JsonKey(name: 'matched')
  bool get matched;
  @override
  @JsonKey(name: 'at_ms')
  int get atMs;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchEventImplCopyWith<_$MatchEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SessionRecord _$SessionRecordFromJson(Map<String, dynamic> json) {
  return _SessionRecord.fromJson(json);
}

/// @nodoc
mixin _$SessionRecord {
  @JsonKey(name: 'session_id')
  String get sessionId => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  @JsonKey(name: 'scenario_id')
  String get scenarioId => throw _privateConstructorUsedError;
  String get module => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  String get startedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'ended_at')
  String get endedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_ms')
  int get durationMs => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  @JsonKey(name: 'drag_interactions')
  List<DragInteraction> get dragInteractions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'pairs_matched', includeIfNull: false)
  int? get pairsMatched => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_pairs', includeIfNull: false)
  int? get totalPairs => throw _privateConstructorUsedError;
  @JsonKey(name: 'match_events', includeIfNull: false)
  List<MatchEvent>? get matchEvents => throw _privateConstructorUsedError;
  @JsonKey(name: 'score', includeIfNull: false)
  int? get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'stars', includeIfNull: false)
  int? get stars => throw _privateConstructorUsedError;

  /// Serializes this SessionRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SessionRecordCopyWith<SessionRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionRecordCopyWith<$Res> {
  factory $SessionRecordCopyWith(
    SessionRecord value,
    $Res Function(SessionRecord) then,
  ) = _$SessionRecordCopyWithImpl<$Res, SessionRecord>;
  @useResult
  $Res call({
    @JsonKey(name: 'session_id') String sessionId,
    String uid,
    @JsonKey(name: 'scenario_id') String scenarioId,
    String module,
    @JsonKey(name: 'started_at') String startedAt,
    @JsonKey(name: 'ended_at') String endedAt,
    @JsonKey(name: 'duration_ms') int durationMs,
    bool completed,
    @JsonKey(name: 'drag_interactions') List<DragInteraction> dragInteractions,
    @JsonKey(name: 'pairs_matched', includeIfNull: false) int? pairsMatched,
    @JsonKey(name: 'total_pairs', includeIfNull: false) int? totalPairs,
    @JsonKey(name: 'match_events', includeIfNull: false)
    List<MatchEvent>? matchEvents,
    @JsonKey(name: 'score', includeIfNull: false) int? score,
    @JsonKey(name: 'stars', includeIfNull: false) int? stars,
  });
}

/// @nodoc
class _$SessionRecordCopyWithImpl<$Res, $Val extends SessionRecord>
    implements $SessionRecordCopyWith<$Res> {
  _$SessionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? uid = null,
    Object? scenarioId = null,
    Object? module = null,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? durationMs = null,
    Object? completed = null,
    Object? dragInteractions = null,
    Object? pairsMatched = freezed,
    Object? totalPairs = freezed,
    Object? matchEvents = freezed,
    Object? score = freezed,
    Object? stars = freezed,
  }) {
    return _then(
      _value.copyWith(
            sessionId:
                null == sessionId
                    ? _value.sessionId
                    : sessionId // ignore: cast_nullable_to_non_nullable
                        as String,
            uid:
                null == uid
                    ? _value.uid
                    : uid // ignore: cast_nullable_to_non_nullable
                        as String,
            scenarioId:
                null == scenarioId
                    ? _value.scenarioId
                    : scenarioId // ignore: cast_nullable_to_non_nullable
                        as String,
            module:
                null == module
                    ? _value.module
                    : module // ignore: cast_nullable_to_non_nullable
                        as String,
            startedAt:
                null == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as String,
            endedAt:
                null == endedAt
                    ? _value.endedAt
                    : endedAt // ignore: cast_nullable_to_non_nullable
                        as String,
            durationMs:
                null == durationMs
                    ? _value.durationMs
                    : durationMs // ignore: cast_nullable_to_non_nullable
                        as int,
            completed:
                null == completed
                    ? _value.completed
                    : completed // ignore: cast_nullable_to_non_nullable
                        as bool,
            dragInteractions:
                null == dragInteractions
                    ? _value.dragInteractions
                    : dragInteractions // ignore: cast_nullable_to_non_nullable
                        as List<DragInteraction>,
            pairsMatched:
                freezed == pairsMatched
                    ? _value.pairsMatched
                    : pairsMatched // ignore: cast_nullable_to_non_nullable
                        as int?,
            totalPairs:
                freezed == totalPairs
                    ? _value.totalPairs
                    : totalPairs // ignore: cast_nullable_to_non_nullable
                        as int?,
            matchEvents:
                freezed == matchEvents
                    ? _value.matchEvents
                    : matchEvents // ignore: cast_nullable_to_non_nullable
                        as List<MatchEvent>?,
            score:
                freezed == score
                    ? _value.score
                    : score // ignore: cast_nullable_to_non_nullable
                        as int?,
            stars:
                freezed == stars
                    ? _value.stars
                    : stars // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SessionRecordImplCopyWith<$Res>
    implements $SessionRecordCopyWith<$Res> {
  factory _$$SessionRecordImplCopyWith(
    _$SessionRecordImpl value,
    $Res Function(_$SessionRecordImpl) then,
  ) = __$$SessionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'session_id') String sessionId,
    String uid,
    @JsonKey(name: 'scenario_id') String scenarioId,
    String module,
    @JsonKey(name: 'started_at') String startedAt,
    @JsonKey(name: 'ended_at') String endedAt,
    @JsonKey(name: 'duration_ms') int durationMs,
    bool completed,
    @JsonKey(name: 'drag_interactions') List<DragInteraction> dragInteractions,
    @JsonKey(name: 'pairs_matched', includeIfNull: false) int? pairsMatched,
    @JsonKey(name: 'total_pairs', includeIfNull: false) int? totalPairs,
    @JsonKey(name: 'match_events', includeIfNull: false)
    List<MatchEvent>? matchEvents,
    @JsonKey(name: 'score', includeIfNull: false) int? score,
    @JsonKey(name: 'stars', includeIfNull: false) int? stars,
  });
}

/// @nodoc
class __$$SessionRecordImplCopyWithImpl<$Res>
    extends _$SessionRecordCopyWithImpl<$Res, _$SessionRecordImpl>
    implements _$$SessionRecordImplCopyWith<$Res> {
  __$$SessionRecordImplCopyWithImpl(
    _$SessionRecordImpl _value,
    $Res Function(_$SessionRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? uid = null,
    Object? scenarioId = null,
    Object? module = null,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? durationMs = null,
    Object? completed = null,
    Object? dragInteractions = null,
    Object? pairsMatched = freezed,
    Object? totalPairs = freezed,
    Object? matchEvents = freezed,
    Object? score = freezed,
    Object? stars = freezed,
  }) {
    return _then(
      _$SessionRecordImpl(
        sessionId:
            null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                    as String,
        uid:
            null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                    as String,
        scenarioId:
            null == scenarioId
                ? _value.scenarioId
                : scenarioId // ignore: cast_nullable_to_non_nullable
                    as String,
        module:
            null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                    as String,
        startedAt:
            null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as String,
        endedAt:
            null == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                    as String,
        durationMs:
            null == durationMs
                ? _value.durationMs
                : durationMs // ignore: cast_nullable_to_non_nullable
                    as int,
        completed:
            null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                    as bool,
        dragInteractions:
            null == dragInteractions
                ? _value._dragInteractions
                : dragInteractions // ignore: cast_nullable_to_non_nullable
                    as List<DragInteraction>,
        pairsMatched:
            freezed == pairsMatched
                ? _value.pairsMatched
                : pairsMatched // ignore: cast_nullable_to_non_nullable
                    as int?,
        totalPairs:
            freezed == totalPairs
                ? _value.totalPairs
                : totalPairs // ignore: cast_nullable_to_non_nullable
                    as int?,
        matchEvents:
            freezed == matchEvents
                ? _value._matchEvents
                : matchEvents // ignore: cast_nullable_to_non_nullable
                    as List<MatchEvent>?,
        score:
            freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                    as int?,
        stars:
            freezed == stars
                ? _value.stars
                : stars // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SessionRecordImpl implements _SessionRecord {
  const _$SessionRecordImpl({
    @JsonKey(name: 'session_id') required this.sessionId,
    required this.uid,
    @JsonKey(name: 'scenario_id') required this.scenarioId,
    required this.module,
    @JsonKey(name: 'started_at') required this.startedAt,
    @JsonKey(name: 'ended_at') required this.endedAt,
    @JsonKey(name: 'duration_ms') required this.durationMs,
    required this.completed,
    @JsonKey(name: 'drag_interactions')
    final List<DragInteraction> dragInteractions = const <DragInteraction>[],
    @JsonKey(name: 'pairs_matched', includeIfNull: false) this.pairsMatched,
    @JsonKey(name: 'total_pairs', includeIfNull: false) this.totalPairs,
    @JsonKey(name: 'match_events', includeIfNull: false)
    final List<MatchEvent>? matchEvents,
    @JsonKey(name: 'score', includeIfNull: false) this.score,
    @JsonKey(name: 'stars', includeIfNull: false) this.stars,
  }) : _dragInteractions = dragInteractions,
       _matchEvents = matchEvents;

  factory _$SessionRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SessionRecordImplFromJson(json);

  @override
  @JsonKey(name: 'session_id')
  final String sessionId;
  @override
  final String uid;
  @override
  @JsonKey(name: 'scenario_id')
  final String scenarioId;
  @override
  final String module;
  @override
  @JsonKey(name: 'started_at')
  final String startedAt;
  @override
  @JsonKey(name: 'ended_at')
  final String endedAt;
  @override
  @JsonKey(name: 'duration_ms')
  final int durationMs;
  @override
  final bool completed;
  final List<DragInteraction> _dragInteractions;
  @override
  @JsonKey(name: 'drag_interactions')
  List<DragInteraction> get dragInteractions {
    if (_dragInteractions is EqualUnmodifiableListView)
      return _dragInteractions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dragInteractions);
  }

  @override
  @JsonKey(name: 'pairs_matched', includeIfNull: false)
  final int? pairsMatched;
  @override
  @JsonKey(name: 'total_pairs', includeIfNull: false)
  final int? totalPairs;
  final List<MatchEvent>? _matchEvents;
  @override
  @JsonKey(name: 'match_events', includeIfNull: false)
  List<MatchEvent>? get matchEvents {
    final value = _matchEvents;
    if (value == null) return null;
    if (_matchEvents is EqualUnmodifiableListView) return _matchEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'score', includeIfNull: false)
  final int? score;
  @override
  @JsonKey(name: 'stars', includeIfNull: false)
  final int? stars;

  @override
  String toString() {
    return 'SessionRecord(sessionId: $sessionId, uid: $uid, scenarioId: $scenarioId, module: $module, startedAt: $startedAt, endedAt: $endedAt, durationMs: $durationMs, completed: $completed, dragInteractions: $dragInteractions, pairsMatched: $pairsMatched, totalPairs: $totalPairs, matchEvents: $matchEvents, score: $score, stars: $stars)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionRecordImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.scenarioId, scenarioId) ||
                other.scenarioId == scenarioId) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            const DeepCollectionEquality().equals(
              other._dragInteractions,
              _dragInteractions,
            ) &&
            (identical(other.pairsMatched, pairsMatched) ||
                other.pairsMatched == pairsMatched) &&
            (identical(other.totalPairs, totalPairs) ||
                other.totalPairs == totalPairs) &&
            const DeepCollectionEquality().equals(
              other._matchEvents,
              _matchEvents,
            ) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.stars, stars) || other.stars == stars));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    uid,
    scenarioId,
    module,
    startedAt,
    endedAt,
    durationMs,
    completed,
    const DeepCollectionEquality().hash(_dragInteractions),
    pairsMatched,
    totalPairs,
    const DeepCollectionEquality().hash(_matchEvents),
    score,
    stars,
  );

  /// Create a copy of SessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionRecordImplCopyWith<_$SessionRecordImpl> get copyWith =>
      __$$SessionRecordImplCopyWithImpl<_$SessionRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SessionRecordImplToJson(this);
  }
}

abstract class _SessionRecord implements SessionRecord {
  const factory _SessionRecord({
    @JsonKey(name: 'session_id') required final String sessionId,
    required final String uid,
    @JsonKey(name: 'scenario_id') required final String scenarioId,
    required final String module,
    @JsonKey(name: 'started_at') required final String startedAt,
    @JsonKey(name: 'ended_at') required final String endedAt,
    @JsonKey(name: 'duration_ms') required final int durationMs,
    required final bool completed,
    @JsonKey(name: 'drag_interactions')
    final List<DragInteraction> dragInteractions,
    @JsonKey(name: 'pairs_matched', includeIfNull: false)
    final int? pairsMatched,
    @JsonKey(name: 'total_pairs', includeIfNull: false) final int? totalPairs,
    @JsonKey(name: 'match_events', includeIfNull: false)
    final List<MatchEvent>? matchEvents,
    @JsonKey(name: 'score', includeIfNull: false) final int? score,
    @JsonKey(name: 'stars', includeIfNull: false) final int? stars,
  }) = _$SessionRecordImpl;

  factory _SessionRecord.fromJson(Map<String, dynamic> json) =
      _$SessionRecordImpl.fromJson;

  @override
  @JsonKey(name: 'session_id')
  String get sessionId;
  @override
  String get uid;
  @override
  @JsonKey(name: 'scenario_id')
  String get scenarioId;
  @override
  String get module;
  @override
  @JsonKey(name: 'started_at')
  String get startedAt;
  @override
  @JsonKey(name: 'ended_at')
  String get endedAt;
  @override
  @JsonKey(name: 'duration_ms')
  int get durationMs;
  @override
  bool get completed;
  @override
  @JsonKey(name: 'drag_interactions')
  List<DragInteraction> get dragInteractions;
  @override
  @JsonKey(name: 'pairs_matched', includeIfNull: false)
  int? get pairsMatched;
  @override
  @JsonKey(name: 'total_pairs', includeIfNull: false)
  int? get totalPairs;
  @override
  @JsonKey(name: 'match_events', includeIfNull: false)
  List<MatchEvent>? get matchEvents;
  @override
  @JsonKey(name: 'score', includeIfNull: false)
  int? get score;
  @override
  @JsonKey(name: 'stars', includeIfNull: false)
  int? get stars;

  /// Create a copy of SessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionRecordImplCopyWith<_$SessionRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
