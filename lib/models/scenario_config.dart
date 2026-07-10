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

// โซนวางแบบระบุชื่อ สำหรับฉากโหมด "คัดแยกครบทุกชิ้น" (sort-all) — เช่น ถังขยะ
// 4 ใบ หรือถ้วยผลไม้ 1 ใบ. interactable ผูกกับโซนของตัวเองผ่าน zone_id
@freezed
class DropZoneConfig with _$DropZoneConfig {
  const factory DropZoneConfig({
    required String id,
    required double x,
    required double y,
    required double width,
    required double height,
  }) = _DropZoneConfig;

  factory DropZoneConfig.fromJson(Map<String, dynamic> json) =>
      _$DropZoneConfigFromJson(json);
}

@freezed
class InteractableConfig with _$InteractableConfig {
  const factory InteractableConfig({
    required String id,
    required String image,
    // โหมดเดิม (โจทย์สุ่มชิ้นเดียว) ใช้ is_target — ฉาก sort-all ไม่ต้องใส่
    @JsonKey(name: 'is_target') @Default(false) bool isTarget,
    // โหมด sort-all: id ของโซนที่รับชิ้นนี้ (เช่น ขวดพลาสติก → "recycle")
    @JsonKey(name: 'zone_id') String? zoneId,
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
    // โหมดเดิม: โซนเดียว (ตะกร้า) — ฉาก sort-all ไม่ใส่ฟิลด์นี้
    @JsonKey(name: 'target_zone') TargetZone? targetZone,
    // โหมด sort-all: มี zones = ต้องลากทุกชิ้นลงโซนของตัวเองจนครบถึงจะจบเกม
    @Default(<DropZoneConfig>[]) List<DropZoneConfig> zones,
    // โหมดสุ่มโจทย์บางชิ้น (ใช้คู่กับ zones): สุ่มหยิบแค่ N ชิ้นจากทั้งหมดต่อรอบ
    // เช่น จัดผลไม้สุ่ม 2 ชนิด — ชิ้นนอกโจทย์ลากลงโซนแล้วโดนปฏิเสธ (นับ mistake)
    @JsonKey(name: 'pick_count') int? pickCount,
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
