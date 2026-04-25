import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocabulary_item.freezed.dart';
part 'vocabulary_item.g.dart';

@freezed
class VocabularyItem with _$VocabularyItem {
  const factory VocabularyItem({
    @JsonKey(name: 'item_id') required String itemId,
    required String image,
    @JsonKey(name: 'tts_word') required String ttsWord,
    required String category,
  }) = _VocabularyItem;

  factory VocabularyItem.fromJson(Map<String, dynamic> json) =>
      _$VocabularyItemFromJson(json);
}
