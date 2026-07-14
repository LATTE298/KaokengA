import 'dart:async' as async;
import 'dart:math';

import 'package:flame/game.dart';

import '../l10n/tts_strings_th.dart';
import '../models/loaded_scenario_config.dart';
import '../models/scenario_config.dart';
import '../services/haptic_service.dart';
import '../services/sfx_player.dart';
import '../services/tts_service.dart';
import 'background_component.dart';
import 'drop_zone_component.dart';
import 'game_asset_paths.dart';
import 'hint_arrow_component.dart';
import 'interactable_component.dart';
import 'item_tray_component.dart';
import 'success_overlay.dart';

// Root game class for Module A scenarios (spec 04 §DailyLifeGame).
class DailyLifeGame extends FlameGame with HasCollisionDetection {
  DailyLifeGame({
    required LoadedScenarioConfig loadedScenario,
    required this.tts,
    required this.reduceMotion,
    required this.onComplete,
    this.enablePromptTimers = true,
    this.sfx = const NoOpSfxPlayer(),
    Random? random,
  }) : config = loadedScenario.config,
       _placeholderImagePaths = loadedScenario.placeholderImagePaths {
    wantedIds = _pickWanted(random ?? Random());
  }

  final ScenarioConfig config;
  final TtsSpeaker tts;

  /// เสียงเอฟเฟกต์ (เช่น ทิ้งขยะลงถัง) — default เงียบสำหรับเทสต์
  final SfxPlayer sfx;
  final bool reduceMotion;
  final async.FutureOr<void> Function(
    List<GamePosition> dragPath,
    int score,
    int stars,
  )
  onComplete;
  final bool enablePromptTimers;
  final Set<String> _placeholderImagePaths;

  static final Vector2 _authoringSpace = Vector2(1920, 1080);

  // cover-fit transform (ใช้เมื่อ config.coverFit) — คำนวณครั้งเดียวใน onLoad
  double _bgScale = 1;
  Vector2 _bgOffset = Vector2.zero();
  Vector2 _imgSize = Vector2.zero();

  async.Timer? _idleTimer;
  bool _completed = false;

  // ลูกศรใบ้ + ตำแหน่งเหนือของที่ต้องหยิบ (เก็บตอน onLoad จาก interactable ที่ isTarget)
  HintArrowComponent? _hintArrow;
  Vector2? _targetTopPos;

  final List<GamePosition> _dragPath = [];
  final List<InteractableComponent> _items = [];

  // นับครั้งที่วางผิด (spec 1.2 — เกณฑ์คะแนน Module A).
  int mistakeCount = 0;

  /// โหมด "คัดแยกครบทุกชิ้น": ทุก interactable ต้องลงโซนของตัวเอง (zone_id)
  /// ถึงจะจบเกม — ฉากที่ประกาศ zones ใน JSON (แยกขยะ 4 ถัง / ผลไม้ลงถ้วย)
  bool get isSortAll => config.zones.isNotEmpty;

  /// โจทย์สุ่มบางชิ้น (pick_count ใน JSON เช่น ผลไม้สุ่ม 2 จาก 4) —
  /// null = ต้องเก็บทุกชิ้น. เรียงตามลำดับไอเทมใน JSON เพื่อให้ประโยค TTS
  /// ตรง key คลิปใน manifest เสมอ
  late final List<String>? wantedIds;

  int _sortedCount = 0;

  int get _requiredCount => wantedIds?.length ?? config.interactables.length;

  List<String>? _pickWanted(Random random) {
    final pickCount = config.pickCount;
    if (!isSortAll ||
        pickCount == null ||
        pickCount >= config.interactables.length) {
      return null;
    }
    final ids = config.interactables.map((i) => i.id).toList()..shuffle(random);
    final chosen = ids.take(pickCount).toSet();
    // คงลำดับตาม JSON ให้ประโยคโจทย์/คลิปเสียงมีรูปแบบเดียวเสมอ
    return [
      for (final item in config.interactables)
        if (chosen.contains(item.id)) item.id,
    ];
  }

  /// ประโยคสั่งของรอบนี้ — โหมดสุ่มผลไม้ประกอบจากชื่อ 2 ชิ้นที่สุ่มได้
  /// นอกนั้นใช้ประโยคของฉากจาก JSON ตรงๆ
  String get instructionText {
    final wanted = wantedIds;
    if (wanted != null && wanted.length == 2) {
      return ttsFruitPickAsk(
        scenarioItemNameTh(wanted[0]),
        scenarioItemNameTh(wanted[1]),
      );
    }
    return config.ttsInstruction;
  }

  @override
  Future<void> onLoad() async {
    // cover-fit: คำนวณ scale/offset จากขนาดรูปจริง เพื่อวางโซน/ไอเทมให้ล็อกกับภาพ
    if (config.coverFit) {
      final image = await images.load(flameImageKey(config.backgroundImage));
      _imgSize = Vector2(image.width.toDouble(), image.height.toDouble());
      _bgScale = max(size.x / _imgSize.x, size.y / _imgSize.y);
      _bgOffset = (size - _imgSize * _bgScale) / 2;
    }

    await add(
      BackgroundComponent(
        imagePath: config.backgroundImage,
        placeholderImagePaths: _placeholderImagePaths,
        coverFit: config.coverFit,
      ),
    );

    if (isSortAll) {
      // โซนตามภาพพื้นหลัง (ถัง/ถ้วยวาดอยู่ในภาพแล้ว) — ไม่วาดกรอบทับ
      final wanted = wantedIds?.toSet();
      for (final zone in config.zones) {
        await add(
          DropZoneComponent(
            position: _toCanvas(Vector2(zone.x, zone.y)),
            size: _toCanvasSize(Vector2(zone.width, zone.height)),
            zoneId: zone.id,
            visible: false,
            wantedIds: wanted,
            swallowItems: config.swallowItems,
            onItemAccepted: _handleItemSorted,
          ),
        );
      }
    } else {
      final target = config.targetZone!;
      final zone = DropZoneComponent(
        position: _toCanvas(Vector2(target.x, target.y)),
        size: _toCanvasSize(Vector2(target.width, target.height)),
        onItemAccepted: _handleSuccess,
      );
      await add(zone);
    }

    // ขนาดไอเทม: coverFit อิง viewport ให้พอดีแถวล่างจอทุกอัตราส่วน (จอเตี้ยก็ไม่ล้น),
    // sort-all เดิมอิงความสูงจอ, โหมดโจทย์ชิ้นเดียวคง 120 (spec 04)
    final n = config.interactables.length;
    final double itemSize;
    if (config.coverFit) {
      itemSize = min(size.x * 0.13, size.y * 0.19).clamp(56.0, 135.0);
    } else if (isSortAll) {
      itemSize = (size.y * 0.20).clamp(100.0, 170.0);
    } else {
      itemSize = 120.0;
    }

    // coverFit: จัดไอเทมเป็นแถวชิดขอบล่าง "จอ" (viewport) — ไม่ผูกกับการครอปรูป จึง
    // เห็นเต็มเสมอแม้จอเตี้ย/กว้างมาก. นอกนั้นวางตาม start_pos จาก JSON
    final List<Vector2> itemPositions;
    if (config.coverFit) {
      final gap = itemSize * 0.35;
      final totalW = n * itemSize + (n - 1) * gap;
      final startX = (size.x - totalW) / 2;
      final centerY = size.y * 0.96 - itemSize / 2;
      itemPositions = [
        for (var i = 0; i < n; i++)
          Vector2(startX + itemSize / 2 + i * (itemSize + gap), centerY),
      ];
    } else {
      itemPositions = [
        for (final item in config.interactables)
          _toCanvas(Vector2(item.startPos.x, item.startPos.y)),
      ];
    }

    if (isSortAll) {
      await add(_buildTray(itemSize, itemPositions));
    }

    for (var i = 0; i < n; i++) {
      final item = config.interactables[i];
      final pos = itemPositions[i];
      if (item.isTarget) {
        // เหนือ interactable (anchor กลาง) ขึ้นไปอีกเล็กน้อย
        _targetTopPos = Vector2(pos.x, pos.y - itemSize * 0.6 - 12);
      }
      final component = InteractableComponent(
        config: item,
        position: pos,
        reduceMotion: reduceMotion,
        placeholderImagePaths: _placeholderImagePaths,
        displaySize: itemSize,
        showCard: isSortAll,
        entryDelay: isSortAll ? i * 0.07 : 0,
        onPathSample: (p) {
          _dragPath.add(GamePosition(x: p.x, y: p.y));
          _resetIdleTimer();
        },
        onMistake: () {
          // เรียกเมื่อวางผิดตำแหน่ง (ผิดถัง/นอกโจทย์/นอกโซน) แล้วเด้งกลับ
          mistakeCount++;
          if (_completed) return;
          sfx.play(kSfxWrong); // เสียงผิดนุ่มๆ ทุกโหมด (รวมฉากเซเว่น)
          // โหมด sort-all บอกนุ่มๆ ให้ลองใหม่ด้วยเสียงพูด (โหมดเดิมเงียบตามเดิม)
          if (isSortAll) tts.speak(kTtsQuizRetry);
        },
      );
      _items.add(component);
      await add(component);
    }

    if (enablePromptTimers) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (_completed) return;
        tts.speak(instructionText);
      });
      _startIdleTimer();
    }
  }

  /// ถาดรองแถวไอเทมด้านล่าง — ครอบตำแหน่งของทุกชิ้น + ระยะหายใจ
  ItemTrayComponent _buildTray(double itemSize, List<Vector2> positions) {
    final xs = [for (final p in positions) p.x]..sort();
    final ys = [for (final p in positions) p.y]..sort();
    final padX = itemSize * 0.85;
    final padY = itemSize * 0.68;
    final left = xs.first - padX;
    final right = xs.last + padX;
    return ItemTrayComponent(
      position: Vector2(left, ys.first - padY),
      size: Vector2(right - left, (ys.last - ys.first) + padY * 2),
    );
  }

  /// โหมด sort-all: ชิ้นลงโซนถูกต้อง 1 ชิ้น — ชมสั้นๆ ระหว่างทาง แล้วปิดเกม
  /// เมื่อครบตามโจทย์ (ชิ้นสุดท้ายไม่ชมซ้อน ปล่อยให้เสียงฉลองใหญ่พูดแทน)
  void _handleItemSorted(InteractableComponent item) {
    if (_completed) return;
    _sortedCount++;
    _resetIdleTimer();
    // เสียง "วางถูก" ทุกชิ้น (คนละช่องกับเสียงพูด ไม่ตัดกัน): ฉากทิ้งขยะใช้เสียง
    // ดูดลงถังตามธีม ฉากอื่นใช้เสียงถูกทั่วไป
    sfx.play(config.swallowItems ? kSfxTrashDrop : kSfxRight);
    if (_sortedCount >= _requiredCount) {
      _handleSuccess(item);
      return;
    }
    HapticService.memoryMatch();
    tts.speak(kTtsQuizCorrect);
  }

  @override
  void onRemove() {
    _idleTimer?.cancel();
    tts.cancel();
    super.onRemove();
  }

  // แปลงพิกัดฉาก → พิกัดจอ. coverFit: อินพุตเป็น "สัดส่วน 0..1 ของรูป" แล้วแมพผ่าน
  // transform เดียวกับพื้นหลัง (โซน/ไอเทมล็อกกับภาพ). ปกติ: authoring 1920x1080 ยืดเต็มจอ
  Vector2 _toCanvas(Vector2 point) {
    if (config.coverFit) {
      return _bgOffset +
          Vector2(
            point.x * _imgSize.x * _bgScale,
            point.y * _imgSize.y * _bgScale,
          );
    }
    return Vector2(
      point.x / _authoringSpace.x * size.x,
      point.y / _authoringSpace.y * size.y,
    );
  }

  Vector2 _toCanvasSize(Vector2 sizeInput) {
    if (config.coverFit) {
      return Vector2(
        sizeInput.x * _imgSize.x * _bgScale,
        sizeInput.y * _imgSize.y * _bgScale,
      );
    }
    return Vector2(
      sizeInput.x / _authoringSpace.x * size.x,
      sizeInput.y / _authoringSpace.y * size.y,
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
    // โหมดสุ่มโจทย์: ทวนประโยคโจทย์เดิม (ใบ้ที่ตรงที่สุด) — โหมดอื่นใช้ hint ฉาก
    tts.speak(wantedIds != null ? instructionText : config.ttsHint);
    _showHintArrow();
    _idleTimer = async.Timer(const Duration(seconds: 15), _onIdle);
  }

  void _showHintArrow() {
    if (_hintArrow != null || _completed) return;
    // โหมด sort-all: ชี้ชิ้นแรกในโจทย์ที่ยังไม่ได้เก็บ (ตำแหน่งปัจจุบัน)
    Vector2? arrowPos = _targetTopPos;
    if (isSortAll) {
      for (final item in _items) {
        final inScope = wantedIds?.contains(item.config.id) ?? true;
        if (!item.settled && inScope) {
          arrowPos = Vector2(item.position.x, item.position.y - 72);
          break;
        }
      }
    }
    if (arrowPos == null) return;
    final arrow = HintArrowComponent(
      position: arrowPos,
      reduceMotion: reduceMotion,
    );
    _hintArrow = arrow;
    add(arrow);
  }

  void _removeHintArrow() {
    _hintArrow?.removeFromParent();
    _hintArrow = null;
  }

  /// คะแนนเชิงบวก (feedback ครู 2026-07-13): ผิดได้ถึง 6 ครั้งยังเต็ม 10 (3 ดาว)
  /// จากนั้นค่อยลด — ผิด 7-8=8(2ดาว), 9-11=6(1ดาว), ≥12=4(0ดาว)
  int get score {
    if (mistakeCount <= 6) return 10;
    if (mistakeCount <= 8) return 8;
    if (mistakeCount <= 11) return 6;
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

    // เสียงฉลองจบด่าน (Kaokeng_congrat) — เล่นพร้อมเอฟเฟกต์ confetti วงกลมฟ้า-เหลือง
    sfx.play(kSfxCongrat);
    await add(SuccessOverlayComponent(gameSize: size));

    await Future<void>.delayed(const Duration(milliseconds: 2500));
    await onComplete(List.unmodifiable(_dragPath), score, starRating);
  }
}
