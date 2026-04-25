// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MemoryPair _$MemoryPairFromJson(Map<String, dynamic> json) {
  return _MemoryPair.fromJson(json);
}

/// @nodoc
mixin _$MemoryPair {
  String get id => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'tts_name')
  String get ttsName => throw _privateConstructorUsedError;

  /// Serializes this MemoryPair to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoryPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryPairCopyWith<MemoryPair> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryPairCopyWith<$Res> {
  factory $MemoryPairCopyWith(
    MemoryPair value,
    $Res Function(MemoryPair) then,
  ) = _$MemoryPairCopyWithImpl<$Res, MemoryPair>;
  @useResult
  $Res call({
    String id,
    String image,
    @JsonKey(name: 'tts_name') String ttsName,
  });
}

/// @nodoc
class _$MemoryPairCopyWithImpl<$Res, $Val extends MemoryPair>
    implements $MemoryPairCopyWith<$Res> {
  _$MemoryPairCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? image = null, Object? ttsName = null}) {
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
            ttsName:
                null == ttsName
                    ? _value.ttsName
                    : ttsName // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryPairImplCopyWith<$Res>
    implements $MemoryPairCopyWith<$Res> {
  factory _$$MemoryPairImplCopyWith(
    _$MemoryPairImpl value,
    $Res Function(_$MemoryPairImpl) then,
  ) = __$$MemoryPairImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String image,
    @JsonKey(name: 'tts_name') String ttsName,
  });
}

/// @nodoc
class __$$MemoryPairImplCopyWithImpl<$Res>
    extends _$MemoryPairCopyWithImpl<$Res, _$MemoryPairImpl>
    implements _$$MemoryPairImplCopyWith<$Res> {
  __$$MemoryPairImplCopyWithImpl(
    _$MemoryPairImpl _value,
    $Res Function(_$MemoryPairImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? image = null, Object? ttsName = null}) {
    return _then(
      _$MemoryPairImpl(
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
        ttsName:
            null == ttsName
                ? _value.ttsName
                : ttsName // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryPairImpl implements _MemoryPair {
  const _$MemoryPairImpl({
    required this.id,
    required this.image,
    @JsonKey(name: 'tts_name') required this.ttsName,
  });

  factory _$MemoryPairImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryPairImplFromJson(json);

  @override
  final String id;
  @override
  final String image;
  @override
  @JsonKey(name: 'tts_name')
  final String ttsName;

  @override
  String toString() {
    return 'MemoryPair(id: $id, image: $image, ttsName: $ttsName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryPairImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.ttsName, ttsName) || other.ttsName == ttsName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, image, ttsName);

  /// Create a copy of MemoryPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryPairImplCopyWith<_$MemoryPairImpl> get copyWith =>
      __$$MemoryPairImplCopyWithImpl<_$MemoryPairImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryPairImplToJson(this);
  }
}

abstract class _MemoryPair implements MemoryPair {
  const factory _MemoryPair({
    required final String id,
    required final String image,
    @JsonKey(name: 'tts_name') required final String ttsName,
  }) = _$MemoryPairImpl;

  factory _MemoryPair.fromJson(Map<String, dynamic> json) =
      _$MemoryPairImpl.fromJson;

  @override
  String get id;
  @override
  String get image;
  @override
  @JsonKey(name: 'tts_name')
  String get ttsName;

  /// Create a copy of MemoryPair
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryPairImplCopyWith<_$MemoryPairImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MemoryPack _$MemoryPackFromJson(Map<String, dynamic> json) {
  return _MemoryPack.fromJson(json);
}

/// @nodoc
mixin _$MemoryPack {
  @JsonKey(name: 'pack_id')
  String get packId => throw _privateConstructorUsedError;
  @JsonKey(name: 'title_th')
  String get titleTh => throw _privateConstructorUsedError;
  List<MemoryPair> get pairs => throw _privateConstructorUsedError;

  /// Serializes this MemoryPack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MemoryPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryPackCopyWith<MemoryPack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryPackCopyWith<$Res> {
  factory $MemoryPackCopyWith(
    MemoryPack value,
    $Res Function(MemoryPack) then,
  ) = _$MemoryPackCopyWithImpl<$Res, MemoryPack>;
  @useResult
  $Res call({
    @JsonKey(name: 'pack_id') String packId,
    @JsonKey(name: 'title_th') String titleTh,
    List<MemoryPair> pairs,
  });
}

/// @nodoc
class _$MemoryPackCopyWithImpl<$Res, $Val extends MemoryPack>
    implements $MemoryPackCopyWith<$Res> {
  _$MemoryPackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packId = null,
    Object? titleTh = null,
    Object? pairs = null,
  }) {
    return _then(
      _value.copyWith(
            packId:
                null == packId
                    ? _value.packId
                    : packId // ignore: cast_nullable_to_non_nullable
                        as String,
            titleTh:
                null == titleTh
                    ? _value.titleTh
                    : titleTh // ignore: cast_nullable_to_non_nullable
                        as String,
            pairs:
                null == pairs
                    ? _value.pairs
                    : pairs // ignore: cast_nullable_to_non_nullable
                        as List<MemoryPair>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryPackImplCopyWith<$Res>
    implements $MemoryPackCopyWith<$Res> {
  factory _$$MemoryPackImplCopyWith(
    _$MemoryPackImpl value,
    $Res Function(_$MemoryPackImpl) then,
  ) = __$$MemoryPackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pack_id') String packId,
    @JsonKey(name: 'title_th') String titleTh,
    List<MemoryPair> pairs,
  });
}

/// @nodoc
class __$$MemoryPackImplCopyWithImpl<$Res>
    extends _$MemoryPackCopyWithImpl<$Res, _$MemoryPackImpl>
    implements _$$MemoryPackImplCopyWith<$Res> {
  __$$MemoryPackImplCopyWithImpl(
    _$MemoryPackImpl _value,
    $Res Function(_$MemoryPackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packId = null,
    Object? titleTh = null,
    Object? pairs = null,
  }) {
    return _then(
      _$MemoryPackImpl(
        packId:
            null == packId
                ? _value.packId
                : packId // ignore: cast_nullable_to_non_nullable
                    as String,
        titleTh:
            null == titleTh
                ? _value.titleTh
                : titleTh // ignore: cast_nullable_to_non_nullable
                    as String,
        pairs:
            null == pairs
                ? _value._pairs
                : pairs // ignore: cast_nullable_to_non_nullable
                    as List<MemoryPair>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MemoryPackImpl implements _MemoryPack {
  const _$MemoryPackImpl({
    @JsonKey(name: 'pack_id') required this.packId,
    @JsonKey(name: 'title_th') required this.titleTh,
    required final List<MemoryPair> pairs,
  }) : _pairs = pairs;

  factory _$MemoryPackImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemoryPackImplFromJson(json);

  @override
  @JsonKey(name: 'pack_id')
  final String packId;
  @override
  @JsonKey(name: 'title_th')
  final String titleTh;
  final List<MemoryPair> _pairs;
  @override
  List<MemoryPair> get pairs {
    if (_pairs is EqualUnmodifiableListView) return _pairs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pairs);
  }

  @override
  String toString() {
    return 'MemoryPack(packId: $packId, titleTh: $titleTh, pairs: $pairs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryPackImpl &&
            (identical(other.packId, packId) || other.packId == packId) &&
            (identical(other.titleTh, titleTh) || other.titleTh == titleTh) &&
            const DeepCollectionEquality().equals(other._pairs, _pairs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    packId,
    titleTh,
    const DeepCollectionEquality().hash(_pairs),
  );

  /// Create a copy of MemoryPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryPackImplCopyWith<_$MemoryPackImpl> get copyWith =>
      __$$MemoryPackImplCopyWithImpl<_$MemoryPackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemoryPackImplToJson(this);
  }
}

abstract class _MemoryPack implements MemoryPack {
  const factory _MemoryPack({
    @JsonKey(name: 'pack_id') required final String packId,
    @JsonKey(name: 'title_th') required final String titleTh,
    required final List<MemoryPair> pairs,
  }) = _$MemoryPackImpl;

  factory _MemoryPack.fromJson(Map<String, dynamic> json) =
      _$MemoryPackImpl.fromJson;

  @override
  @JsonKey(name: 'pack_id')
  String get packId;
  @override
  @JsonKey(name: 'title_th')
  String get titleTh;
  @override
  List<MemoryPair> get pairs;

  /// Create a copy of MemoryPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryPackImplCopyWith<_$MemoryPackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
