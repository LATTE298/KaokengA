import 'dart:async' as async;

import 'package:flame/game.dart';

import '../l10n/tts_strings_th.dart';
import '../models/loaded_scenario_config.dart';
import '../models/scenario_config.dart';
import '../services/haptic_service.dart';
import '../services/tts_service.dart';
import 'background_component.dart';
import 'drop_zone_component.dart';
import 'interactable_component.dart';
import 'success_overlay.dart';

// Root game class for Module A scenarios (spec 04 §DailyLifeGame).
//
// Scenario positions are authored at 1920×1080 and scaled to the device canvas
// via `_toCanvas` (spec 04 §Device Adaptation).
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
  final TtsService tts;
  final bool reduceMotion;
  final async.FutureOr<void> Function(List<GamePosition> dragPath) onComplete;
  final bool enablePromptTimers;
  final Set<String> _placeholderImagePaths;

  static final Vector2 _authoringSpace = Vector2(1920, 1080);

  async.Timer? _idleTimer;
  bool _completed = false;

  final List<GamePosition> _dragPath = [];

  @override
  Future<void> onLoad() async {
    await add(
      BackgroundComponent(
        imagePath: config.backgroundImage,
        placeholderImagePaths: _placeholderImagePaths,
      ),
    );

    // Drop zone is placed first so interactables can detect collisions.
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
        ),
      );
    }

    if (enablePromptTimers) {
      // Fire the instruction TTS once the scene has mounted (spec 03 Flow 1 §7).
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
    _startIdleTimer();
  }

  void _onIdle() {
    if (_completed) return;
    tts.speak(config.ttsHint);
    // After the first 8s prompt, re-prompt every 15s (spec 04 §Idle Timer).
    _idleTimer = async.Timer(const Duration(seconds: 15), _onIdle);
  }

  Future<void> _handleSuccess(InteractableComponent target) async {
    if (_completed) return;
    _completed = true;
    _idleTimer?.cancel();

    HapticService.success();

    final celebration =
        kTtsCelebrations[DateTime.now().millisecondsSinceEpoch %
            kTtsCelebrations.length];
    await tts.speak(celebration);

    await add(SuccessOverlayComponent(gameSize: size));

    // Hold the celebration for 2.5s (spec 03 Flow 1 §9f) before bubbling up.
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    await onComplete(List.unmodifiable(_dragPath));
  }
}
