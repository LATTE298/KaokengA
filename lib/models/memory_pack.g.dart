// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_pack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoryPairImpl _$$MemoryPairImplFromJson(Map<String, dynamic> json) =>
    _$MemoryPairImpl(
      id: json['id'] as String,
      image: json['image'] as String,
      ttsName: json['tts_name'] as String,
    );

Map<String, dynamic> _$$MemoryPairImplToJson(_$MemoryPairImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'tts_name': instance.ttsName,
    };

_$MemoryPackImpl _$$MemoryPackImplFromJson(Map<String, dynamic> json) =>
    _$MemoryPackImpl(
      packId: json['pack_id'] as String,
      titleTh: json['title_th'] as String,
      pairs:
          (json['pairs'] as List<dynamic>)
              .map((e) => MemoryPair.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$MemoryPackImplToJson(_$MemoryPackImpl instance) =>
    <String, dynamic>{
      'pack_id': instance.packId,
      'title_th': instance.titleTh,
      'pairs': instance.pairs.map((e) => e.toJson()).toList(),
    };
