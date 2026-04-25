import 'package:freezed_annotation/freezed_annotation.dart';

part 'scenario_config.freezed.dart';
part 'scenario_config.g.dart';

// Position expressed in the authoring-space 1920x1080 (spec 04 §Device Adaptation).
// The Flame engine scales percentages at render time.
@freezed
class GamePosition with _$GamePosition {
  const factory GamePosition({required double x, required double y}) =
      _GamePosition;

  factory GamePosition.fromJson(Map<String, dynamic> json) =>
      _$GamePositionFromJson(json);
}

@freezed
class TargetZone with _$TargetZone {
  const factory TargetZone({
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _TargetZone;

  factory TargetZone.fromJson(Map<String, dynamic> json) =>
      _$TargetZoneFromJson(json);
}

@freezed
class InteractableConfig with _$InteractableConfig {
  const factory InteractableConfig({
    required String id,
    required String image,
    @JsonKey(name: 'is_target') required bool isTarget,
    @JsonKey(name: 'start_pos') required GamePosition startPos,
  }) = _InteractableConfig;

  factory InteractableConfig.fromJson(Map<String, dynamic> json) =>
      _$InteractableConfigFromJson(json);
}

@freezed
class ScenarioConfig with _$ScenarioConfig {
  const factory ScenarioConfig({
    @JsonKey(name: 'scenario_id') required String scenarioId,
    required int version,
    required String category,
    required String module,
    @JsonKey(name: 'title_th') required String titleTh,
    @JsonKey(name: 'background_image') required String backgroundImage,
    @JsonKey(name: 'tts_instruction') required String ttsInstruction,
    @JsonKey(name: 'tts_celebration') required String ttsCelebration,
    @JsonKey(name: 'tts_hint') required String ttsHint,
    required List<InteractableConfig> interactables,
    @JsonKey(name: 'target_zone') required TargetZone targetZone,
  }) = _ScenarioConfig;

  factory ScenarioConfig.fromJson(Map<String, dynamic> json) =>
      _$ScenarioConfigFromJson(json);
}

// Summary loaded from Firestore /content/scenarios (spec 06 §4). Full config
// is fetched lazily from configUrl.
@freezed
class ScenarioSummary with _$ScenarioSummary {
  const factory ScenarioSummary({
    @JsonKey(name: 'scenario_id') required String scenarioId,
    @JsonKey(name: 'title_th') required String titleTh,
    required String category,
    required String module,
    @JsonKey(name: 'config_url') required String configUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    required int version,
    required bool published,
  }) = _ScenarioSummary;

  factory ScenarioSummary.fromJson(Map<String, dynamic> json) =>
      _$ScenarioSummaryFromJson(json);
}
