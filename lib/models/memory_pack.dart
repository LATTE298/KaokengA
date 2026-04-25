import 'package:freezed_annotation/freezed_annotation.dart';

part 'memory_pack.freezed.dart';
part 'memory_pack.g.dart';

@freezed
class MemoryPair with _$MemoryPair {
  const factory MemoryPair({
    required String id,
    required String image,
    @JsonKey(name: 'tts_name') required String ttsName,
  }) = _MemoryPair;

  factory MemoryPair.fromJson(Map<String, dynamic> json) =>
      _$MemoryPairFromJson(json);
}

@freezed
class MemoryPack with _$MemoryPack {
  const factory MemoryPack({
    @JsonKey(name: 'pack_id') required String packId,
    @JsonKey(name: 'title_th') required String titleTh,
    required List<MemoryPair> pairs,
  }) = _MemoryPack;

  factory MemoryPack.fromJson(Map<String, dynamic> json) =>
      _$MemoryPackFromJson(json);
}
