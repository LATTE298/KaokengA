import '../../models/app_types.dart';
import '../../models/memory_pack.dart';
import '../../models/scenario_config.dart';
import '../../models/session_record.dart';
import '../../services/session_repository.dart';

typedef Clock = DateTime Function();
typedef UuidFactory = String Function();

class SessionRecorder {
  const SessionRecorder({
    required SessionWriter repository,
    required String? uid,
    required Clock clock,
    required UuidFactory uuidFactory,
  }) : _repository = repository,
       _uid = uid,
       _clock = clock,
       _uuidFactory = uuidFactory;

  final SessionWriter _repository;
  final String? _uid;
  final Clock _clock;
  final UuidFactory _uuidFactory;

  Future<void> recordDailyLifeCompletion({
    required ScenarioConfig config,
    required DateTime startedAt,
    required List<GamePosition> dragPath,
  }) {
    final uid = _uid;
    if (uid == null) return Future<void>.value();

    final endedAt = _clock().toUtc();
    final targetId = config.interactables.firstWhere((i) => i.isTarget).id;
    final durationMs = endedAt.difference(startedAt).inMilliseconds;
    final record = SessionRecord(
      sessionId: _uuidFactory(),
      uid: uid,
      scenarioId: config.scenarioId,
      module: kModuleDailyLife,
      startedAt: startedAt.toUtc().toIso8601String(),
      endedAt: endedAt.toIso8601String(),
      durationMs: durationMs,
      completed: true,
      dragInteractions: [
        DragInteraction(
          interactionId: _uuidFactory(),
          objectId: targetId,
          wasTarget: true,
          wasSuccessful: true,
          durationMs: durationMs,
          straightnessScore: 0,
          pathPoints: dragPath,
        ),
      ],
    );
    return _repository.writeSession(record);
  }

  Future<void> recordMemoryCompletion({
    required MemoryPack pack,
    required DateTime startedAt,
    required List<MatchEvent> matchEvents,
  }) {
    final uid = _uid;
    if (uid == null) return Future<void>.value();

    final endedAt = _clock().toUtc();
    final totalPairs = pack.pairs.length;
    final record = SessionRecord(
      sessionId: _uuidFactory(),
      uid: uid,
      scenarioId: pack.packId,
      module: kModuleMemory,
      startedAt: startedAt.toUtc().toIso8601String(),
      endedAt: endedAt.toIso8601String(),
      durationMs: endedAt.difference(startedAt).inMilliseconds,
      completed: true,
      pairsMatched: totalPairs,
      totalPairs: totalPairs,
      matchEvents: List.unmodifiable(matchEvents),
    );
    return _repository.writeSession(record);
  }
}
