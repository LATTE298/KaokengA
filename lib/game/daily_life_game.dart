import 'dart:async' as async;

import 'package:flame/game.dart';

import '../l10n/tts_strings_th.dart';
import '../models/loaded_scenario_config.dart';
import '../models/scenario_config.dart';
import '../services/haptic_service.dart';
import '../services/tts_service.dart';
import 'background_component.dart';
import 'drop_zone_component.dart';
import 'hint_arrow_component.dart';
import 'interactable_component.dart';
import 'success_overlay.dart';

// Root game class for Module A scenarios (spec 04 §DailyLifeGame).
class DailyLifeGame extends FlameGame with HasCollisionDetection {
  DailyLifeGame({
    required LoadedScenarioConfig loadedScenario,
    required this.tts,
    required this.reduceMotion,
    required this.onComplete,
    this.enablePromptTimers = true,
  }) : config = loadedScenario.config,
       _placeholderImagePaths = loadedScenario.placeholderImagePaths;

  final ScenarioConfig config;
  final TtsSpeaker tts;
  final bool reduceMotion;
  final async.FutureOr<void> Function(
    List<GamePosition> dragPath,
    int score,
    int stars,
  ) onComplete;
  final bool enablePromptTimers;
  final Set<String> _placeholderImagePaths;

  static final Vector2 _authoringSpace = Vector2(1920, 1080);

  async.Timer? _idleTimer;
  bool _completed = false;

  // ลูกศรใบ้ + ตำแหน่งเหนือของที่ต้องหยิบ (เก็บตอน onLoad จาก interactable ที่ isTarget)
  HintArrowComponent? _hintArrow;
  Vector2? _targetTopPos;

  final List<GamePosition> _dragPath = [];

  // นับครั้งที่วางผิด (spec 1.2 — เกณฑ์คะแนน Module A).
  int mistakeCount = 0;

  @override
  Future<void> onLoad() async {
    await add(
      BackgroundComponent(
        imagePath: config.backgroundImage,
        placeholderImagePaths: _placeholderImagePaths,
      ),
    );

    final zone = DropZoneComponent(
      position: _toCanvas(Vector2(config.targetZone.x, config.targetZone.y)),
      size: _toCanvasSize(
        Vector2(config.targetZone.width, config.targetZone.height),
      ),
      onTargetDropped: _handleSuccess,
    );
    await add(zone);

    for (final item in config.interactables) {
      final pos = _toCanvas(Vector2(item.startPos.x, item.startPos.y));
      if (item.isTarget) {
        // เหนือ interactable (สูง 120, anchor กลาง) ขึ้นไปอีกเล็กน้อย
        _targetTopPos = Vector2(pos.x, pos.y - 72);
      }
      await add(
        InteractableComponent(
          config: item,
          position: pos,
          reduceMotion: reduceMotion,
          placeholderImagePaths: _placeholderImagePaths,
          onPathSample: (p) {
            _dragPath.add(GamePosition(x: p.x, y: p.y));
            _resetIdleTimer();
          },
          onMistake: () {
            // เรียกเมื่อวางผิดตำแหน่ง (ไม่ใช่ target zone) แล้วเด้งกลับ
            mistakeCount++;
          },
        ),
      );
    }

    if (enablePromptTimers) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (_completed) return;
        tts.speak(config.ttsInstruction);
      });
      _startIdleTimer();
    }
  }

  @override
  void onRemove() {
    _idleTimer?.cancel();
    tts.cancel();
    super.onRemove();
  }

  Vector2 _toCanvas(Vector2 authoringPoint) {
    return Vector2(
      authoringPoint.x / _authoringSpace.x * size.x,
      authoringPoint.y / _authoringSpace.y * size.y,
    );
  }

  Vector2 _toCanvasSize(Vector2 authoringSize) {
    return Vector2(
      authoringSize.x / _authoringSpace.x * size.x,
      authoringSize.y / _authoringSpace.y * size.y,
    );
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = async.Timer(const Duration(seconds: 8), _onIdle);
  }

  void _resetIdleTimer() {
    // เด็กเริ่มลากแล้ว = เจอของ → เอาลูกศรใบ้ออก
    _removeHintArrow();
    _startIdleTimer();
  }

  void _onIdle() {
    if (_completed) return;
    tts.speak(config.ttsHint);
    _showHintArrow();
    _idleTimer = async.Timer(const Duration(seconds: 15), _onIdle);
  }

  void _showHintArrow() {
    if (_hintArrow != null || _targetTopPos == null || _completed) return;
    final arrow = HintArrowComponent(
      position: _targetTopPos!,
      reduceMotion: reduceMotion,
    );
    _hintArrow = arrow;
    add(arrow);
  }

  void _removeHintArrow() {
    _hintArrow?.removeFromParent();
    _hintArrow = null;
  }

  /// คิดคะแนนจากจำนวนครั้งที่วางผิด (spec 1.2).
  /// ถูกทุกครั้ง=10, ผิด1=8, ผิด2=6, ผิด≥3=4.
  int get score {
    if (mistakeCount == 0) return 10;
    if (mistakeCount == 1) return 8;
    if (mistakeCount == 2) return 6;
    return 4;
  }

  int get starRating {
    switch (score) {
      case 10:
        return 3;
      case 8:
        return 2;
      case 6:
        return 1;
      default:
        return 0;
    }
  }

  Future<void> _handleSuccess(InteractableComponent target) async {
    if (_completed) return;
    _completed = true;
    _idleTimer?.cancel();
    _removeHintArrow();

    HapticService.success();

    final celebration =
        kTtsCelebrations[DateTime.now().millisecondsSinceEpoch %
            kTtsCelebrations.length];
    await tts.speak(celebration);

    await add(SuccessOverlayComponent(gameSize: size));

    await Future<void>.delayed(const Duration(milliseconds: 2500));
    await onComplete(List.unmodifiable(_dragPath), score, starRating);
  }
}