// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VocabularyItemImpl _$$VocabularyItemImplFromJson(Map<String, dynamic> json) =>
    _$VocabularyItemImpl(
      itemId: json['item_id'] as String,
      image: json['image'] as String,
      ttsWord: json['tts_word'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$$VocabularyItemImplToJson(
  _$VocabularyItemImpl instance,
) => <String, dynamic>{
  'item_id': instance.itemId,
  'image': instance.image,
  'tts_word': instance.ttsWord,
  'category': instance.category,
};
