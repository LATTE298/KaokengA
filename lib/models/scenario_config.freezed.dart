// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scenario_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GamePosition _$GamePositionFromJson(Map<String, dynamic> json) {
  return _GamePosition.fromJson(json);
}

/// @nodoc
mixin _$GamePosition {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;

  /// Serializes this GamePosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GamePosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamePositionCopyWith<GamePosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamePositionCopyWith<$Res> {
  factory $GamePositionCopyWith(
    GamePosition value,
    $Res Function(GamePosition) then,
  ) = _$GamePositionCopyWithImpl<$Res, GamePosition>;
  @useResult
  $Res call({double x, double y});
}

/// @nodoc
class _$GamePositionCopyWithImpl<$Res, $Val extends GamePosition>
    implements $GamePositionCopyWith<$Res> {
  _$GamePositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamePosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null}) {
    return _then(
      _value.copyWith(
            x:
                null == x
                    ? _value.x
                    : x // ignore: cast_nullable_to_non_nullable
                        as double,
            y:
                null == y
                    ? _value.y
                    : y // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GamePositionImplCopyWith<$Res>
    implements $GamePositionCopyWith<$Res> {
  factory _$$GamePositionImplCopyWith(
    _$GamePositionImpl value,
    $Res Function(_$GamePositionImpl) then,
  ) = __$$GamePositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y});
}

/// @nodoc
class __$$GamePositionImplCopyWithImpl<$Res>
    extends _$GamePositionCopyWithImpl<$Res, _$GamePositionImpl>
    implements _$$GamePositionImplCopyWith<$Res> {
  __$$GamePositionImplCopyWithImpl(
    _$GamePositionImpl _value,
    $Res Function(_$GamePositionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamePosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null}) {
    return _then(
      _$GamePositionImpl(
        x:
            null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                    as double,
        y:
            null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GamePositionImpl implements _GamePosition {
  const _$GamePositionImpl({required this.x, required this.y});

  factory _$GamePositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamePositionImplFromJson(json);

  @override
  final double x;
  @override
  final double y;

  @override
  String toString() {
    return 'GamePosition(x: $x, y: $y)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamePositionImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y);

  /// Create a copy of GamePosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamePositionImplCopyWith<_$GamePositionImpl> get copyWith =>
      __$$GamePositionImplCopyWithImpl<_$GamePositionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GamePositionImplToJson(this);
  }
}

abstract class _GamePosition implements GamePosition {
  const factory _GamePosition({
    required final double x,
    required final double y,
  }) = _$GamePositionImpl;

  factory _GamePosition.fromJson(Map<String, dynamic> json) =
      _$GamePositionImpl.fromJson;

  @override
  double get x;
  @override
  double get y;

  /// Create a copy of GamePosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamePositionImplCopyWith<_$GamePositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TargetZone _$TargetZoneFromJson(Map<String, dynamic> json) {
  return _TargetZone.fromJson(json);
}

/// @nodoc
mixin _$TargetZone {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this TargetZone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TargetZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TargetZoneCopyWith<TargetZone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TargetZoneCopyWith<$Res> {
  factory $TargetZoneCopyWith(
    TargetZone value,
    $Res Function(TargetZone) then,
  ) = _$TargetZoneCopyWithImpl<$Res, TargetZone>;
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class _$TargetZoneCopyWithImpl<$Res, $Val extends TargetZone>
    implements $TargetZoneCopyWith<$Res> {
  _$TargetZoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TargetZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _value.copyWith(
            x:
                null == x
                    ? _value.x
                    : x // ignore: cast_nullable_to_non_nullable
                        as double,
            y:
                null == y
                    ? _value.y
                    : y // ignore: cast_nullable_to_non_nullable
                        as double,
            width:
                null == width
                    ? _value.width
                    : width // ignore: cast_nullable_to_non_nullable
                        as double,
            height:
                null == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TargetZoneImplCopyWith<$Res>
    implements $TargetZoneCopyWith<$Res> {
  factory _$$TargetZoneImplCopyWith(
    _$TargetZoneImpl value,
    $Res Function(_$TargetZoneImpl) then,
  ) = __$$TargetZoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class __$$TargetZoneImplCopyWithImpl<$Res>
    extends _$TargetZoneCopyWithImpl<$Res, _$TargetZoneImpl>
    implements _$$TargetZoneImplCopyWith<$Res> {
  __$$TargetZoneImplCopyWithImpl(
    _$TargetZoneImpl _value,
    $Res Function(_$TargetZoneImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TargetZone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _$TargetZoneImpl(
        x:
            null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                    as double,
        y:
            null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                    as double,
        width:
            null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                    as double,
        height:
            null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TargetZoneImpl implements _TargetZone {
  const _$TargetZoneImpl({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory _$TargetZoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$TargetZoneImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'TargetZone(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TargetZoneImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, width, height);

  /// Create a copy of TargetZone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TargetZoneImplCopyWith<_$TargetZoneImpl> get copyWith =>
      __$$TargetZoneImplCopyWithImpl<_$TargetZoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TargetZoneImplToJson(this);
  }
}

abstract class _TargetZone implements TargetZone {
  const factory _TargetZone({
    required final double x,
    required final double y,
    required final double width,
    required final double height,
  }) = _$TargetZoneImpl;

  factory _TargetZone.fromJson(Map<String, dynamic> json) =
      _$TargetZoneImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of TargetZone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TargetZoneImplCopyWith<_$TargetZoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DropZoneConfig _$DropZoneConfigFromJson(Map<String, dynamic> json) {
  return _DropZoneConfig.fromJson(json);
}

/// @nodoc
mixin _$DropZoneConfig {
  String get id => throw _privateConstructorUsedError;
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this DropZoneConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DropZoneConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DropZoneConfigCopyWith<DropZoneConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DropZoneConfigCopyWith<$Res> {
  factory $DropZoneConfigCopyWith(
    DropZoneConfig value,
    $Res Function(DropZoneConfig) then,
  ) = _$DropZoneConfigCopyWithImpl<$Res, DropZoneConfig>;
  @useResult
  $Res call({String id, double x, double y, double width, double height});
}

/// @nodoc
class _$DropZoneConfigCopyWithImpl<$Res, $Val extends DropZoneConfig>
    implements $DropZoneConfigCopyWith<$Res> {
  _$DropZoneConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DropZoneConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            x:
                null == x
                    ? _value.x
                    : x // ignore: cast_nullable_to_non_nullable
                        as double,
            y:
                null == y
                    ? _value.y
                    : y // ignore: cast_nullable_to_non_nullable
                        as double,
            width:
                null == width
                    ? _value.width
                    : width // ignore: cast_nullable_to_non_nullable
                        as double,
            height:
                null == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DropZoneConfigImplCopyWith<$Res>
    implements $DropZoneConfigCopyWith<$Res> {
  factory _$$DropZoneConfigImplCopyWith(
    _$DropZoneConfigImpl value,
    $Res Function(_$DropZoneConfigImpl) then,
  ) = __$$DropZoneConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, double x, double y, double width, double height});
}

/// @nodoc
class __$$DropZoneConfigImplCopyWithImpl<$Res>
    extends _$DropZoneConfigCopyWithImpl<$Res, _$DropZoneConfigImpl>
    implements _$$DropZoneConfigImplCopyWith<$Res> {
  __$$DropZoneConfigImplCopyWithImpl(
    _$DropZoneConfigImpl _value,
    $Res Function(_$DropZoneConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DropZoneConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _$DropZoneConfigImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        x:
            null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                    as double,
        y:
            null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                    as double,
        width:
            null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                    as double,
        height:
            null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DropZoneConfigImpl implements _DropZoneConfig {
  const _$DropZoneConfigImpl({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory _$DropZoneConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$DropZoneConfigImplFromJson(json);

  @override
  final String id;
  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'DropZoneConfig(id: $id, x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DropZoneConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, x, y, width, height);

  /// Create a copy of DropZoneConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DropZoneConfigImplCopyWith<_$DropZoneConfigImpl> get copyWith =>
      __$$DropZoneConfigImplCopyWithImpl<_$DropZoneConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DropZoneConfigImplToJson(this);
  }
}

abstract class _DropZoneConfig implements DropZoneConfig {
  const factory _DropZoneConfig({
    required final String id,
    required final double x,
    required final double y,
    required final double width,
    required final double height,
  }) = _$DropZoneConfigImpl;

  factory _DropZoneConfig.fromJson(Map<String, dynamic> json) =
      _$DropZoneConfigImpl.fromJson;

  @override
  String get id;
  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of DropZoneConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DropZoneConfigImplCopyWith<_$DropZoneConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InteractableConfig _$InteractableConfigFromJson(Map<String, dynamic> json) {
  return _InteractableConfig.fromJson(json);
}

/// @nodoc
mixin _$InteractableConfig {
  String get id => throw _privateConstructorUsedError;
  String get image =>
      throw _privateConstructorUsedError; // โหมดเดิม (โจทย์สุ่มชิ้นเดียว) ใช้ is_target — ฉาก sort-all ไม่ต้องใส่
  @JsonKey(name: 'is_target')
  bool get isTarget => throw _privateConstructorUsedError; // โหมด sort-all: id ของโซนที่รับชิ้นนี้ (เช่น ขวดพลาสติก → "recycle")
  @JsonKey(name: 'zone_id')
  String? get zoneId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_pos')
  GamePosition get startPos => throw _privateConstructorUsedError;

  /// Serializes this InteractableConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InteractableConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InteractableConfigCopyWith<InteractableConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InteractableConfigCopyWith<$Res> {
  factory $InteractableConfigCopyWith(
    InteractableConfig value,
    $Res Function(InteractableConfig) then,
  ) = _$InteractableConfigCopyWithImpl<$Res, InteractableConfig>;
  @useResult
  $Res call({
    String id,
    String image,
    @JsonKey(name: 'is_target') bool isTarget,
    @JsonKey(name: 'zone_id') String? zoneId,
    @JsonKey(name: 'start_pos') GamePosition startPos,
  });

  $GamePositionCopyWith<$Res> get startPos;
}

/// @nodoc
class _$InteractableConfigCopyWithImpl<$Res, $Val extends InteractableConfig>
    implements $InteractableConfigCopyWith<$Res> {
  _$InteractableConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InteractableConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? image = null,
    Object? isTarget = null,
    Object? zoneId = freezed,
    Object? startPos = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            image:
                null == image
                    ? _value.image
                    : image // ignore: cast_nullable_to_non_nullable
                        as String,
            isTarget:
                null == isTarget
                    ? _value.isTarget
                    : isTarget // ignore: cast_nullable_to_non_nullable
                        as bool,
            zoneId:
                freezed == zoneId
                    ? _value.zoneId
                    : zoneId // ignore: cast_nullable_to_non_nullable
                        as String?,
            startPos:
                null == startPos
                    ? _value.startPos
                    : startPos // ignore: cast_nullable_to_non_nullable
                        as GamePosition,
          )
          as $Val,
    );
  }

  /// Create a copy of InteractableConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GamePositionCopyWith<$Res> get startPos {
    return $GamePositionCopyWith<$Res>(_value.startPos, (value) {
      return _then(_value.copyWith(startPos: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InteractableConfigImplCopyWith<$Res>
    implements $InteractableConfigCopyWith<$Res> {
  factory _$$InteractableConfigImplCopyWith(
    _$InteractableConfigImpl value,
    $Res Function(_$InteractableConfigImpl) then,
  ) = __$$InteractableConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String image,
    @JsonKey(name: 'is_target') bool isTarget,
    @JsonKey(name: 'zone_id') String? zoneId,
    @JsonKey(name: 'start_pos') GamePosition startPos,
  });

  @override
  $GamePositionCopyWith<$Res> get startPos;
}

/// @nodoc
class __$$InteractableConfigImplCopyWithImpl<$Res>
    extends _$InteractableConfigCopyWithImpl<$Res, _$InteractableConfigImpl>
    implements _$$InteractableConfigImplCopyWith<$Res> {
  __$$InteractableConfigImplCopyWithImpl(
    _$InteractableConfigImpl _value,
    $Res Function(_$InteractableConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InteractableConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? image = null,
    Object? isTarget = null,
    Object? zoneId = freezed,
    Object? startPos = null,
  }) {
    return _then(
      _$InteractableConfigImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        image:
            null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                    as String,
        isTarget:
            null == isTarget
                ? _value.isTarget
                : isTarget // ignore: cast_nullable_to_non_nullable
                    as bool,
        zoneId:
            freezed == zoneId
                ? _value.zoneId
                : zoneId // ignore: cast_nullable_to_non_nullable
                    as String?,
        startPos:
            null == startPos
                ? _value.startPos
                : startPos // ignore: cast_nullable_to_non_nullable
                    as GamePosition,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InteractableConfigImpl implements _InteractableConfig {
  const _$InteractableConfigImpl({
    required this.id,
    required this.image,
    @JsonKey(name: 'is_target') this.isTarget = false,
    @JsonKey(name: 'zone_id') this.zoneId,
    @JsonKey(name: 'start_pos') required this.startPos,
  });

  factory _$InteractableConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$InteractableConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String image;
  // โหมดเดิม (โจทย์สุ่มชิ้นเดียว) ใช้ is_target — ฉาก sort-all ไม่ต้องใส่
  @override
  @JsonKey(name: 'is_target')
  final bool isTarget;
  // โหมด sort-all: id ของโซนที่รับชิ้นนี้ (เช่น ขวดพลาสติก → "recycle")
  @override
  @JsonKey(name: 'zone_id')
  final String? zoneId;
  @override
  @JsonKey(name: 'start_pos')
  final GamePosition startPos;

  @override
  String toString() {
    return 'InteractableConfig(id: $id, image: $image, isTarget: $isTarget, zoneId: $zoneId, startPos: $startPos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractableConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.isTarget, isTarget) ||
                other.isTarget == isTarget) &&
            (identical(other.zoneId, zoneId) || other.zoneId == zoneId) &&
            (identical(other.startPos, startPos) ||
                other.startPos == startPos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, image, isTarget, zoneId, startPos);

  /// Create a copy of InteractableConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractableConfigImplCopyWith<_$InteractableConfigImpl> get copyWith =>
      __$$InteractableConfigImplCopyWithImpl<_$InteractableConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InteractableConfigImplToJson(this);
  }
}

abstract class _InteractableConfig implements InteractableConfig {
  const factory _InteractableConfig({
    required final String id,
    required final String image,
    @JsonKey(name: 'is_target') final bool isTarget,
    @JsonKey(name: 'zone_id') final String? zoneId,
    @JsonKey(name: 'start_pos') required final GamePosition startPos,
  }) = _$InteractableConfigImpl;

  factory _InteractableConfig.fromJson(Map<String, dynamic> json) =
      _$InteractableConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get image; // โหมดเดิม (โจทย์สุ่มชิ้นเดียว) ใช้ is_target — ฉาก sort-all ไม่ต้องใส่
  @override
  @JsonKey(name: 'is_target')
  bool get isTarget; // โหมด sort-all: id ของโซนที่รับชิ้นนี้ (เช่น ขวดพลาสติก → "recycle")
  @override
  @JsonKey(name: 'zone_id')
  String? get zoneId;
  @override
  @JsonKey(name: 'start_pos')
  GamePosition get startPos;

  /// Create a copy of InteractableConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractableConfigImplCopyWith<_$InteractableConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScenarioConfig _$ScenarioConfigFromJson(Map<String, dynamic> json) {
  return _ScenarioConfig.fromJson(json);
}

/// @nodoc
mixin _$ScenarioConfig {
  @JsonKey(name: 'scenario_id')
  String get scenarioId => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get module => throw _privateConstructorUsedError;
  @JsonKey(name: 'title_th')
  String get titleTh => throw _privateConstructorUsedError;
  @JsonKey(name: 'background_image')
  String get backgroundImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'tts_instruction')
  String get ttsInstruction => throw _privateConstructorUsedError;
  @JsonKey(name: 'tts_celebration')
  String get ttsCelebration => throw _privateConstructorUsedError;
  @JsonKey(name: 'tts_hint')
  String get ttsHint => throw _privateConstructorUsedError;
  List<InteractableConfig> get interactables =>
      throw _privateConstructorUsedError; // โหมดเดิม: โซนเดียว (ตะกร้า) — ฉาก sort-all ไม่ใส่ฟิลด์นี้
  @JsonKey(name: 'target_zone')
  TargetZone? get targetZone => throw _privateConstructorUsedError; // โหมด sort-all: มี zones = ต้องลากทุกชิ้นลงโซนของตัวเองจนครบถึงจะจบเกม
  List<DropZoneConfig> get zones =>
      throw _privateConstructorUsedError; // โหมดสุ่มโจทย์บางชิ้น (ใช้คู่กับ zones): สุ่มหยิบแค่ N ชิ้นจากทั้งหมดต่อรอบ
  // เช่น จัดผลไม้สุ่ม 2 ชนิด — ชิ้นนอกโจทย์ลากลงโซนแล้วโดนปฏิเสธ (นับ mistake)
  @JsonKey(name: 'pick_count')
  int? get pickCount => throw _privateConstructorUsedError; // พื้นหลัง cover-fit (รักษาสัดส่วน ไม่ยืด) + พิกัด zones/start_pos เป็น
  // "สัดส่วน 0..1 ของรูปพื้นหลัง" แทน authoring 1920x1080 → โซนล็อกกับภาพจริง
  // ทุกอัตราส่วนจอ (แท็บเล็ต/iPad ไม่ยืด). ไม่ใส่/false = โหมดเดิม (ยืดเต็มจอ)
  @JsonKey(name: 'cover_fit')
  bool get coverFit => throw _privateConstructorUsedError;

  /// Serializes this ScenarioConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioConfigCopyWith<ScenarioConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioConfigCopyWith<$Res> {
  factory $ScenarioConfigCopyWith(
    ScenarioConfig value,
    $Res Function(ScenarioConfig) then,
  ) = _$ScenarioConfigCopyWithImpl<$Res, ScenarioConfig>;
  @useResult
  $Res call({
    @JsonKey(name: 'scenario_id') String scenarioId,
    int version,
    String category,
    String module,
    @JsonKey(name: 'title_th') String titleTh,
    @JsonKey(name: 'background_image') String backgroundImage,
    @JsonKey(name: 'tts_instruction') String ttsInstruction,
    @JsonKey(name: 'tts_celebration') String ttsCelebration,
    @JsonKey(name: 'tts_hint') String ttsHint,
    List<InteractableConfig> interactables,
    @JsonKey(name: 'target_zone') TargetZone? targetZone,
    List<DropZoneConfig> zones,
    @JsonKey(name: 'pick_count') int? pickCount,
    @JsonKey(name: 'cover_fit') bool coverFit,
  });

  $TargetZoneCopyWith<$Res>? get targetZone;
}

/// @nodoc
class _$ScenarioConfigCopyWithImpl<$Res, $Val extends ScenarioConfig>
    implements $ScenarioConfigCopyWith<$Res> {
  _$ScenarioConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scenarioId = null,
    Object? version = null,
    Object? category = null,
    Object? module = null,
    Object? titleTh = null,
    Object? backgroundImage = null,
    Object? ttsInstruction = null,
    Object? ttsCelebration = null,
    Object? ttsHint = null,
    Object? interactables = null,
    Object? targetZone = freezed,
    Object? zones = null,
    Object? pickCount = freezed,
    Object? coverFit = null,
  }) {
    return _then(
      _value.copyWith(
            scenarioId:
                null == scenarioId
                    ? _value.scenarioId
                    : scenarioId // ignore: cast_nullable_to_non_nullable
                        as String,
            version:
                null == version
                    ? _value.version
                    : version // ignore: cast_nullable_to_non_nullable
                        as int,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
            module:
                null == module
                    ? _value.module
                    : module // ignore: cast_nullable_to_non_nullable
                        as String,
            titleTh:
                null == titleTh
                    ? _value.titleTh
                    : titleTh // ignore: cast_nullable_to_non_nullable
                        as String,
            backgroundImage:
                null == backgroundImage
                    ? _value.backgroundImage
                    : backgroundImage // ignore: cast_nullable_to_non_nullable
                        as String,
            ttsInstruction:
                null == ttsInstruction
                    ? _value.ttsInstruction
                    : ttsInstruction // ignore: cast_nullable_to_non_nullable
                        as String,
            ttsCelebration:
                null == ttsCelebration
                    ? _value.ttsCelebration
                    : ttsCelebration // ignore: cast_nullable_to_non_nullable
                        as String,
            ttsHint:
                null == ttsHint
                    ? _value.ttsHint
                    : ttsHint // ignore: cast_nullable_to_non_nullable
                        as String,
            interactables:
                null == interactables
                    ? _value.interactables
                    : interactables // ignore: cast_nullable_to_non_nullable
                        as List<InteractableConfig>,
            targetZone:
                freezed == targetZone
                    ? _value.targetZone
                    : targetZone // ignore: cast_nullable_to_non_nullable
                        as TargetZone?,
            zones:
                null == zones
                    ? _value.zones
                    : zones // ignore: cast_nullable_to_non_nullable
                        as List<DropZoneConfig>,
            pickCount:
                freezed == pickCount
                    ? _value.pickCount
                    : pickCount // ignore: cast_nullable_to_non_nullable
                        as int?,
            coverFit:
                null == coverFit
                    ? _value.coverFit
                    : coverFit // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of ScenarioConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TargetZoneCopyWith<$Res>? get targetZone {
    if (_value.targetZone == null) {
      return null;
    }

    return $TargetZoneCopyWith<$Res>(_value.targetZone!, (value) {
      return _then(_value.copyWith(targetZone: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScenarioConfigImplCopyWith<$Res>
    implements $ScenarioConfigCopyWith<$Res> {
  factory _$$ScenarioConfigImplCopyWith(
    _$ScenarioConfigImpl value,
    $Res Function(_$ScenarioConfigImpl) then,
  ) = __$$ScenarioConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'scenario_id') String scenarioId,
    int version,
    String category,
    String module,
    @JsonKey(name: 'title_th') String titleTh,
    @JsonKey(name: 'background_image') String backgroundImage,
    @JsonKey(name: 'tts_instruction') String ttsInstruction,
    @JsonKey(name: 'tts_celebration') String ttsCelebration,
    @JsonKey(name: 'tts_hint') String ttsHint,
    List<InteractableConfig> interactables,
    @JsonKey(name: 'target_zone') TargetZone? targetZone,
    List<DropZoneConfig> zones,
    @JsonKey(name: 'pick_count') int? pickCount,
    @JsonKey(name: 'cover_fit') bool coverFit,
  });

  @override
  $TargetZoneCopyWith<$Res>? get targetZone;
}

/// @nodoc
class __$$ScenarioConfigImplCopyWithImpl<$Res>
    extends _$ScenarioConfigCopyWithImpl<$Res, _$ScenarioConfigImpl>
    implements _$$ScenarioConfigImplCopyWith<$Res> {
  __$$ScenarioConfigImplCopyWithImpl(
    _$ScenarioConfigImpl _value,
    $Res Function(_$ScenarioConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScenarioConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scenarioId = null,
    Object? version = null,
    Object? category = null,
    Object? module = null,
    Object? titleTh = null,
    Object? backgroundImage = null,
    Object? ttsInstruction = null,
    Object? ttsCelebration = null,
    Object? ttsHint = null,
    Object? interactables = null,
    Object? targetZone = freezed,
    Object? zones = null,
    Object? pickCount = freezed,
    Object? coverFit = null,
  }) {
    return _then(
      _$ScenarioConfigImpl(
        scenarioId:
            null == scenarioId
                ? _value.scenarioId
                : scenarioId // ignore: cast_nullable_to_non_nullable
                    as String,
        version:
            null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                    as int,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
        module:
            null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                    as String,
        titleTh:
            null == titleTh
                ? _value.titleTh
                : titleTh // ignore: cast_nullable_to_non_nullable
                    as String,
        backgroundImage:
            null == backgroundImage
                ? _value.backgroundImage
                : backgroundImage // ignore: cast_nullable_to_non_nullable
                    as String,
        ttsInstruction:
            null == ttsInstruction
                ? _value.ttsInstruction
                : ttsInstruction // ignore: cast_nullable_to_non_nullable
                    as String,
        ttsCelebration:
            null == ttsCelebration
                ? _value.ttsCelebration
                : ttsCelebration // ignore: cast_nullable_to_non_nullable
                    as String,
        ttsHint:
            null == ttsHint
                ? _value.ttsHint
                : ttsHint // ignore: cast_nullable_to_non_nullable
                    as String,
        interactables:
            null == interactables
                ? _value._interactables
                : interactables // ignore: cast_nullable_to_non_nullable
                    as List<InteractableConfig>,
        targetZone:
            freezed == targetZone
                ? _value.targetZone
                : targetZone // ignore: cast_nullable_to_non_nullable
                    as TargetZone?,
        zones:
            null == zones
                ? _value._zones
                : zones // ignore: cast_nullable_to_non_nullable
                    as List<DropZoneConfig>,
        pickCount:
            freezed == pickCount
                ? _value.pickCount
                : pickCount // ignore: cast_nullable_to_non_nullable
                    as int?,
        coverFit:
            null == coverFit
                ? _value.coverFit
                : coverFit // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScenarioConfigImpl implements _ScenarioConfig {
  const _$ScenarioConfigImpl({
    @JsonKey(name: 'scenario_id') required this.scenarioId,
    required this.version,
    required this.category,
    required this.module,
    @JsonKey(name: 'title_th') required this.titleTh,
    @JsonKey(name: 'background_image') required this.backgroundImage,
    @JsonKey(name: 'tts_instruction') required this.ttsInstruction,
    @JsonKey(name: 'tts_celebration') required this.ttsCelebration,
    @JsonKey(name: 'tts_hint') required this.ttsHint,
    required final List<InteractableConfig> interactables,
    @JsonKey(name: 'target_zone') this.targetZone,
    final List<DropZoneConfig> zones = const <DropZoneConfig>[],
    @JsonKey(name: 'pick_count') this.pickCount,
    @JsonKey(name: 'cover_fit') this.coverFit = false,
  }) : _interactables = interactables,
       _zones = zones;

  factory _$ScenarioConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioConfigImplFromJson(json);

  @override
  @JsonKey(name: 'scenario_id')
  final String scenarioId;
  @override
  final int version;
  @override
  final String category;
  @override
  final String module;
  @override
  @JsonKey(name: 'title_th')
  final String titleTh;
  @override
  @JsonKey(name: 'background_image')
  final String backgroundImage;
  @override
  @JsonKey(name: 'tts_instruction')
  final String ttsInstruction;
  @override
  @JsonKey(name: 'tts_celebration')
  final String ttsCelebration;
  @override
  @JsonKey(name: 'tts_hint')
  final String ttsHint;
  final List<InteractableConfig> _interactables;
  @override
  List<InteractableConfig> get interactables {
    if (_interactables is EqualUnmodifiableListView) return _interactables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interactables);
  }

  // โหมดเดิม: โซนเดียว (ตะกร้า) — ฉาก sort-all ไม่ใส่ฟิลด์นี้
  @override
  @JsonKey(name: 'target_zone')
  final TargetZone? targetZone;
  // โหมด sort-all: มี zones = ต้องลากทุกชิ้นลงโซนของตัวเองจนครบถึงจะจบเกม
  final List<DropZoneConfig> _zones;
  // โหมด sort-all: มี zones = ต้องลากทุกชิ้นลงโซนของตัวเองจนครบถึงจะจบเกม
  @override
  @JsonKey()
  List<DropZoneConfig> get zones {
    if (_zones is EqualUnmodifiableListView) return _zones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_zones);
  }

  // โหมดสุ่มโจทย์บางชิ้น (ใช้คู่กับ zones): สุ่มหยิบแค่ N ชิ้นจากทั้งหมดต่อรอบ
  // เช่น จัดผลไม้สุ่ม 2 ชนิด — ชิ้นนอกโจทย์ลากลงโซนแล้วโดนปฏิเสธ (นับ mistake)
  @override
  @JsonKey(name: 'pick_count')
  final int? pickCount;
  // พื้นหลัง cover-fit (รักษาสัดส่วน ไม่ยืด) + พิกัด zones/start_pos เป็น
  // "สัดส่วน 0..1 ของรูปพื้นหลัง" แทน authoring 1920x1080 → โซนล็อกกับภาพจริง
  // ทุกอัตราส่วนจอ (แท็บเล็ต/iPad ไม่ยืด). ไม่ใส่/false = โหมดเดิม (ยืดเต็มจอ)
  @override
  @JsonKey(name: 'cover_fit')
  final bool coverFit;

  @override
  String toString() {
    return 'ScenarioConfig(scenarioId: $scenarioId, version: $version, category: $category, module: $module, titleTh: $titleTh, backgroundImage: $backgroundImage, ttsInstruction: $ttsInstruction, ttsCelebration: $ttsCelebration, ttsHint: $ttsHint, interactables: $interactables, targetZone: $targetZone, zones: $zones, pickCount: $pickCount, coverFit: $coverFit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioConfigImpl &&
            (identical(other.scenarioId, scenarioId) ||
                other.scenarioId == scenarioId) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.titleTh, titleTh) || other.titleTh == titleTh) &&
            (identical(other.backgroundImage, backgroundImage) ||
                other.backgroundImage == backgroundImage) &&
            (identical(other.ttsInstruction, ttsInstruction) ||
                other.ttsInstruction == ttsInstruction) &&
            (identical(other.ttsCelebration, ttsCelebration) ||
                other.ttsCelebration == ttsCelebration) &&
            (identical(other.ttsHint, ttsHint) || other.ttsHint == ttsHint) &&
            const DeepCollectionEquality().equals(
              other._interactables,
              _interactables,
            ) &&
            (identical(other.targetZone, targetZone) ||
                other.targetZone == targetZone) &&
            const DeepCollectionEquality().equals(other._zones, _zones) &&
            (identical(other.pickCount, pickCount) ||
                other.pickCount == pickCount) &&
            (identical(other.coverFit, coverFit) ||
                other.coverFit == coverFit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    scenarioId,
    version,
    category,
    module,
    titleTh,
    backgroundImage,
    ttsInstruction,
    ttsCelebration,
    ttsHint,
    const DeepCollectionEquality().hash(_interactables),
    targetZone,
    const DeepCollectionEquality().hash(_zones),
    pickCount,
    coverFit,
  );

  /// Create a copy of ScenarioConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioConfigImplCopyWith<_$ScenarioConfigImpl> get copyWith =>
      __$$ScenarioConfigImplCopyWithImpl<_$ScenarioConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioConfigImplToJson(this);
  }
}

abstract class _ScenarioConfig implements ScenarioConfig {
  const factory _ScenarioConfig({
    @JsonKey(name: 'scenario_id') required final String scenarioId,
    required final int version,
    required final String category,
    required final String module,
    @JsonKey(name: 'title_th') required final String titleTh,
    @JsonKey(name: 'background_image') required final String backgroundImage,
    @JsonKey(name: 'tts_instruction') required final String ttsInstruction,
    @JsonKey(name: 'tts_celebration') required final String ttsCelebration,
    @JsonKey(name: 'tts_hint') required final String ttsHint,
    required final List<InteractableConfig> interactables,
    @JsonKey(name: 'target_zone') final TargetZone? targetZone,
    final List<DropZoneConfig> zones,
    @JsonKey(name: 'pick_count') final int? pickCount,
    @JsonKey(name: 'cover_fit') final bool coverFit,
  }) = _$ScenarioConfigImpl;

  factory _ScenarioConfig.fromJson(Map<String, dynamic> json) =
      _$ScenarioConfigImpl.fromJson;

  @override
  @JsonKey(name: 'scenario_id')
  String get scenarioId;
  @override
  int get version;
  @override
  String get category;
  @override
  String get module;
  @override
  @JsonKey(name: 'title_th')
  String get titleTh;
  @override
  @JsonKey(name: 'background_image')
  String get backgroundImage;
  @override
  @JsonKey(name: 'tts_instruction')
  String get ttsInstruction;
  @override
  @JsonKey(name: 'tts_celebration')
  String get ttsCelebration;
  @override
  @JsonKey(name: 'tts_hint')
  String get ttsHint;
  @override
  List<InteractableConfig> get interactables; // โหมดเดิม: โซนเดียว (ตะกร้า) — ฉาก sort-all ไม่ใส่ฟิลด์นี้
  @override
  @JsonKey(name: 'target_zone')
  TargetZone? get targetZone; // โหมด sort-all: มี zones = ต้องลากทุกชิ้นลงโซนของตัวเองจนครบถึงจะจบเกม
  @override
  List<DropZoneConfig> get zones; // โหมดสุ่มโจทย์บางชิ้น (ใช้คู่กับ zones): สุ่มหยิบแค่ N ชิ้นจากทั้งหมดต่อรอบ
  // เช่น จัดผลไม้สุ่ม 2 ชนิด — ชิ้นนอกโจทย์ลากลงโซนแล้วโดนปฏิเสธ (นับ mistake)
  @override
  @JsonKey(name: 'pick_count')
  int? get pickCount; // พื้นหลัง cover-fit (รักษาสัดส่วน ไม่ยืด) + พิกัด zones/start_pos เป็น
  // "สัดส่วน 0..1 ของรูปพื้นหลัง" แทน authoring 1920x1080 → โซนล็อกกับภาพจริง
  // ทุกอัตราส่วนจอ (แท็บเล็ต/iPad ไม่ยืด). ไม่ใส่/false = โหมดเดิม (ยืดเต็มจอ)
  @override
  @JsonKey(name: 'cover_fit')
  bool get coverFit;

  /// Create a copy of ScenarioConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioConfigImplCopyWith<_$ScenarioConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScenarioSummary _$ScenarioSummaryFromJson(Map<String, dynamic> json) {
  return _ScenarioSummary.fromJson(json);
}

/// @nodoc
mixin _$ScenarioSummary {
  @JsonKey(name: 'scenario_id')
  String get scenarioId => throw _privateConstructorUsedError;
  @JsonKey(name: 'title_th')
  String get titleTh => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get module => throw _privateConstructorUsedError;
  @JsonKey(name: 'config_url')
  String get configUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String get thumbnailUrl => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  bool get published => throw _privateConstructorUsedError;

  /// Serializes this ScenarioSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioSummaryCopyWith<ScenarioSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioSummaryCopyWith<$Res> {
  factory $ScenarioSummaryCopyWith(
    ScenarioSummary value,
    $Res Function(ScenarioSummary) then,
  ) = _$ScenarioSummaryCopyWithImpl<$Res, ScenarioSummary>;
  @useResult
  $Res call({
    @JsonKey(name: 'scenario_id') String scenarioId,
    @JsonKey(name: 'title_th') String titleTh,
    String category,
    String module,
    @JsonKey(name: 'config_url') String configUrl,
    @JsonKey(name: 'thumbnail_url') String thumbnailUrl,
    int version,
    bool published,
  });
}

/// @nodoc
class _$ScenarioSummaryCopyWithImpl<$Res, $Val extends ScenarioSummary>
    implements $ScenarioSummaryCopyWith<$Res> {
  _$ScenarioSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scenarioId = null,
    Object? titleTh = null,
    Object? category = null,
    Object? module = null,
    Object? configUrl = null,
    Object? thumbnailUrl = null,
    Object? version = null,
    Object? published = null,
  }) {
    return _then(
      _value.copyWith(
            scenarioId:
                null == scenarioId
                    ? _value.scenarioId
                    : scenarioId // ignore: cast_nullable_to_non_nullable
                        as String,
            titleTh:
                null == titleTh
                    ? _value.titleTh
                    : titleTh // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
            module:
                null == module
                    ? _value.module
                    : module // ignore: cast_nullable_to_non_nullable
                        as String,
            configUrl:
                null == configUrl
                    ? _value.configUrl
                    : configUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            thumbnailUrl:
                null == thumbnailUrl
                    ? _value.thumbnailUrl
                    : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            version:
                null == version
                    ? _value.version
                    : version // ignore: cast_nullable_to_non_nullable
                        as int,
            published:
                null == published
                    ? _value.published
                    : published // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScenarioSummaryImplCopyWith<$Res>
    implements $ScenarioSummaryCopyWith<$Res> {
  factory _$$ScenarioSummaryImplCopyWith(
    _$ScenarioSummaryImpl value,
    $Res Function(_$ScenarioSummaryImpl) then,
  ) = __$$ScenarioSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'scenario_id') String scenarioId,
    @JsonKey(name: 'title_th') String titleTh,
    String category,
    String module,
    @JsonKey(name: 'config_url') String configUrl,
    @JsonKey(name: 'thumbnail_url') String thumbnailUrl,
    int version,
    bool published,
  });
}

/// @nodoc
class __$$ScenarioSummaryImplCopyWithImpl<$Res>
    extends _$ScenarioSummaryCopyWithImpl<$Res, _$ScenarioSummaryImpl>
    implements _$$ScenarioSummaryImplCopyWith<$Res> {
  __$$ScenarioSummaryImplCopyWithImpl(
    _$ScenarioSummaryImpl _value,
    $Res Function(_$ScenarioSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScenarioSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scenarioId = null,
    Object? titleTh = null,
    Object? category = null,
    Object? module = null,
    Object? configUrl = null,
    Object? thumbnailUrl = null,
    Object? version = null,
    Object? published = null,
  }) {
    return _then(
      _$ScenarioSummaryImpl(
        scenarioId:
            null == scenarioId
                ? _value.scenarioId
                : scenarioId // ignore: cast_nullable_to_non_nullable
                    as String,
        titleTh:
            null == titleTh
                ? _value.titleTh
                : titleTh // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
        module:
            null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                    as String,
        configUrl:
            null == configUrl
                ? _value.configUrl
                : configUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        thumbnailUrl:
            null == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        version:
            null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                    as int,
        published:
            null == published
                ? _value.published
                : published // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScenarioSummaryImpl implements _ScenarioSummary {
  const _$ScenarioSummaryImpl({
    @JsonKey(name: 'scenario_id') required this.scenarioId,
    @JsonKey(name: 'title_th') required this.titleTh,
    required this.category,
    required this.module,
    @JsonKey(name: 'config_url') required this.configUrl,
    @JsonKey(name: 'thumbnail_url') required this.thumbnailUrl,
    required this.version,
    required this.published,
  });

  factory _$ScenarioSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioSummaryImplFromJson(json);

  @override
  @JsonKey(name: 'scenario_id')
  final String scenarioId;
  @override
  @JsonKey(name: 'title_th')
  final String titleTh;
  @override
  final String category;
  @override
  final String module;
  @override
  @JsonKey(name: 'config_url')
  final String configUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String thumbnailUrl;
  @override
  final int version;
  @override
  final bool published;

  @override
  String toString() {
    return 'ScenarioSummary(scenarioId: $scenarioId, titleTh: $titleTh, category: $category, module: $module, configUrl: $configUrl, thumbnailUrl: $thumbnailUrl, version: $version, published: $published)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioSummaryImpl &&
            (identical(other.scenarioId, scenarioId) ||
                other.scenarioId == scenarioId) &&
            (identical(other.titleTh, titleTh) || other.titleTh == titleTh) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.configUrl, configUrl) ||
                other.configUrl == configUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.published, published) ||
                other.published == published));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    scenarioId,
    titleTh,
    category,
    module,
    configUrl,
    thumbnailUrl,
    version,
    published,
  );

  /// Create a copy of ScenarioSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioSummaryImplCopyWith<_$ScenarioSummaryImpl> get copyWith =>
      __$$ScenarioSummaryImplCopyWithImpl<_$ScenarioSummaryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioSummaryImplToJson(this);
  }
}

abstract class _ScenarioSummary implements ScenarioSummary {
  const factory _ScenarioSummary({
    @JsonKey(name: 'scenario_id') required final String scenarioId,
    @JsonKey(name: 'title_th') required final String titleTh,
    required final String category,
    required final String module,
    @JsonKey(name: 'config_url') required final String configUrl,
    @JsonKey(name: 'thumbnail_url') required final String thumbnailUrl,
    required final int version,
    required final bool published,
  }) = _$ScenarioSummaryImpl;

  factory _ScenarioSummary.fromJson(Map<String, dynamic> json) =
      _$ScenarioSummaryImpl.fromJson;

  @override
  @JsonKey(name: 'scenario_id')
  String get scenarioId;
  @override
  @JsonKey(name: 'title_th')
  String get titleTh;
  @override
  String get category;
  @override
  String get module;
  @override
  @JsonKey(name: 'config_url')
  String get configUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  String get thumbnailUrl;
  @override
  int get version;
  @override
  bool get published;

  /// Create a copy of ScenarioSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioSummaryImplCopyWith<_$ScenarioSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
