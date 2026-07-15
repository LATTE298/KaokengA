// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GamePositionImpl _$$GamePositionImplFromJson(Map<String, dynamic> json) =>
    _$GamePositionImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$$GamePositionImplToJson(_$GamePositionImpl instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

_$TargetZoneImpl _$$TargetZoneImplFromJson(Map<String, dynamic> json) =>
    _$TargetZoneImpl(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$TargetZoneImplToJson(_$TargetZoneImpl instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

_$DropZoneConfigImpl _$$DropZoneConfigImplFromJson(Map<String, dynamic> json) =>
    _$DropZoneConfigImpl(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$$DropZoneConfigImplToJson(
  _$DropZoneConfigImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'x': instance.x,
  'y': instance.y,
  'width': instance.width,
  'height': instance.height,
};

_$InteractableConfigImpl _$$InteractableConfigImplFromJson(
  Map<String, dynamic> json,
) => _$InteractableConfigImpl(
  id: json['id'] as String,
  image: json['image'] as String,
  isTarget: json['is_target'] as bool? ?? false,
  zoneId: json['zone_id'] as String?,
  startPos: GamePosition.fromJson(json['start_pos'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$InteractableConfigImplToJson(
  _$InteractableConfigImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'image': instance.image,
  'is_target': instance.isTarget,
  'zone_id': instance.zoneId,
  'start_pos': instance.startPos.toJson(),
};

_$ScenarioConfigImpl _$$ScenarioConfigImplFromJson(
  Map<String, dynamic> json,
) => _$ScenarioConfigImpl(
  scenarioId: json['scenario_id'] as String,
  version: (json['version'] as num).toInt(),
  category: json['category'] as String,
  module: json['module'] as String,
  titleTh: json['title_th'] as String,
  backgroundImage: json['background_image'] as String,
  ttsInstruction: json['tts_instruction'] as String,
  ttsCelebration: json['tts_celebration'] as String,
  ttsHint: json['tts_hint'] as String,
  interactables:
      (json['interactables'] as List<dynamic>)
          .map((e) => InteractableConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
  targetZone:
      json['target_zone'] == null
          ? null
          : TargetZone.fromJson(json['target_zone'] as Map<String, dynamic>),
  zones:
      (json['zones'] as List<dynamic>?)
          ?.map((e) => DropZoneConfig.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DropZoneConfig>[],
  pickCount: (json['pick_count'] as num?)?.toInt(),
  coverFit: json['cover_fit'] as bool? ?? false,
  swallowItems: json['swallow_items'] as bool? ?? false,
  shopMode: json['shop_mode'] as bool? ?? false,
  displayCount: (json['display_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ScenarioConfigImplToJson(
  _$ScenarioConfigImpl instance,
) => <String, dynamic>{
  'scenario_id': instance.scenarioId,
  'version': instance.version,
  'category': instance.category,
  'module': instance.module,
  'title_th': instance.titleTh,
  'background_image': instance.backgroundImage,
  'tts_instruction': instance.ttsInstruction,
  'tts_celebration': instance.ttsCelebration,
  'tts_hint': instance.ttsHint,
  'interactables': instance.interactables.map((e) => e.toJson()).toList(),
  'target_zone': instance.targetZone?.toJson(),
  'zones': instance.zones.map((e) => e.toJson()).toList(),
  'pick_count': instance.pickCount,
  'cover_fit': instance.coverFit,
  'swallow_items': instance.swallowItems,
  'shop_mode': instance.shopMode,
  'display_count': instance.displayCount,
};

_$ScenarioSummaryImpl _$$ScenarioSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ScenarioSummaryImpl(
  scenarioId: json['scenario_id'] as String,
  titleTh: json['title_th'] as String,
  category: json['category'] as String,
  module: json['module'] as String,
  configUrl: json['config_url'] as String,
  thumbnailUrl: json['thumbnail_url'] as String,
  version: (json['version'] as num).toInt(),
  published: json['published'] as bool,
);

Map<String, dynamic> _$$ScenarioSummaryImplToJson(
  _$ScenarioSummaryImpl instance,
) => <String, dynamic>{
  'scenario_id': instance.scenarioId,
  'title_th': instance.titleTh,
  'category': instance.category,
  'module': instance.module,
  'config_url': instance.configUrl,
  'thumbnail_url': instance.thumbnailUrl,
  'version': instance.version,
  'published': instance.published,
};
