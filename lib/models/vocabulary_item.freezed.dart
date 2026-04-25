// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vocabulary_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VocabularyItem _$VocabularyItemFromJson(Map<String, dynamic> json) {
  return _VocabularyItem.fromJson(json);
}

/// @nodoc
mixin _$VocabularyItem {
  @JsonKey(name: 'item_id')
  String get itemId => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;
  @JsonKey(name: 'tts_word')
  String get ttsWord => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;

  /// Serializes this VocabularyItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VocabularyItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VocabularyItemCopyWith<VocabularyItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VocabularyItemCopyWith<$Res> {
  factory $VocabularyItemCopyWith(
    VocabularyItem value,
    $Res Function(VocabularyItem) then,
  ) = _$VocabularyItemCopyWithImpl<$Res, VocabularyItem>;
  @useResult
  $Res call({
    @JsonKey(name: 'item_id') String itemId,
    String image,
    @JsonKey(name: 'tts_word') String ttsWord,
    String category,
  });
}

/// @nodoc
class _$VocabularyItemCopyWithImpl<$Res, $Val extends VocabularyItem>
    implements $VocabularyItemCopyWith<$Res> {
  _$VocabularyItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VocabularyItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? image = null,
    Object? ttsWord = null,
    Object? category = null,
  }) {
    return _then(
      _value.copyWith(
            itemId:
                null == itemId
                    ? _value.itemId
                    : itemId // ignore: cast_nullable_to_non_nullable
                        as String,
            image:
                null == image
                    ? _value.image
                    : image // ignore: cast_nullable_to_non_nullable
                        as String,
            ttsWord:
                null == ttsWord
                    ? _value.ttsWord
                    : ttsWord // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VocabularyItemImplCopyWith<$Res>
    implements $VocabularyItemCopyWith<$Res> {
  factory _$$VocabularyItemImplCopyWith(
    _$VocabularyItemImpl value,
    $Res Function(_$VocabularyItemImpl) then,
  ) = __$$VocabularyItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'item_id') String itemId,
    String image,
    @JsonKey(name: 'tts_word') String ttsWord,
    String category,
  });
}

/// @nodoc
class __$$VocabularyItemImplCopyWithImpl<$Res>
    extends _$VocabularyItemCopyWithImpl<$Res, _$VocabularyItemImpl>
    implements _$$VocabularyItemImplCopyWith<$Res> {
  __$$VocabularyItemImplCopyWithImpl(
    _$VocabularyItemImpl _value,
    $Res Function(_$VocabularyItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VocabularyItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = null,
    Object? image = null,
    Object? ttsWord = null,
    Object? category = null,
  }) {
    return _then(
      _$VocabularyItemImpl(
        itemId:
            null == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                    as String,
        image:
            null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                    as String,
        ttsWord:
            null == ttsWord
                ? _value.ttsWord
                : ttsWord // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VocabularyItemImpl implements _VocabularyItem {
  const _$VocabularyItemImpl({
    @JsonKey(name: 'item_id') required this.itemId,
    required this.image,
    @JsonKey(name: 'tts_word') required this.ttsWord,
    required this.category,
  });

  factory _$VocabularyItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$VocabularyItemImplFromJson(json);

  @override
  @JsonKey(name: 'item_id')
  final String itemId;
  @override
  final String image;
  @override
  @JsonKey(name: 'tts_word')
  final String ttsWord;
  @override
  final String category;

  @override
  String toString() {
    return 'VocabularyItem(itemId: $itemId, image: $image, ttsWord: $ttsWord, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VocabularyItemImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.ttsWord, ttsWord) || other.ttsWord == ttsWord) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemId, image, ttsWord, category);

  /// Create a copy of VocabularyItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VocabularyItemImplCopyWith<_$VocabularyItemImpl> get copyWith =>
      __$$VocabularyItemImplCopyWithImpl<_$VocabularyItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VocabularyItemImplToJson(this);
  }
}

abstract class _VocabularyItem implements VocabularyItem {
  const factory _VocabularyItem({
    @JsonKey(name: 'item_id') required final String itemId,
    required final String image,
    @JsonKey(name: 'tts_word') required final String ttsWord,
    required final String category,
  }) = _$VocabularyItemImpl;

  factory _VocabularyItem.fromJson(Map<String, dynamic> json) =
      _$VocabularyItemImpl.fromJson;

  @override
  @JsonKey(name: 'item_id')
  String get itemId;
  @override
  String get image;
  @override
  @JsonKey(name: 'tts_word')
  String get ttsWord;
  @override
  String get category;

  /// Create a copy of VocabularyItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VocabularyItemImplCopyWith<_$VocabularyItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
