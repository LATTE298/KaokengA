import '../../models/app_types.dart';
import '../../models/memory_pack.dart';
import '../../models/scenario_config.dart';
import '../../models/session_record.dart';
import '../../services/session_repository.dart';

typedef Clock = DateTime Function();
typedef UuidFactory = String Function();

class ActiveSessionKey {
  const ActiveSessionKey({required this.module, required this.contentId});

  final String module;
  final String contentId;

  @override
  bool operator ==(Object other) {
    return other is ActiveSessionKey &&
        other.module == module &&
        other.contentId == contentId;
  }

  @override
  int get hashCode => Object.hash(module, contentId);
}

class ActiveSession {
  const ActiveSession({
    required this.sessionId,
    required this.uid,
    required this.module,
    required this.contentId,
    required this.startedAt,
  });

  final String sessionId;
  final String? uid;
  final String module;
  final String contentId;
  final DateTime startedAt;
}

class DailyLifeCompletedEvent {
  const DailyLifeCompletedEvent({
    required this.session,
    required this.config,
    required this.dragPath,
  });

  final ActiveSession session;
  final ScenarioConfig config;
  final List<GamePosition> dragPath;
}

class MemoryCompletedEvent {
  const MemoryCompletedEvent({
    required this.session,
    required this.pack,
    required this.matchEvents,
  });

  final ActiveSession session;
  final MemoryPack pack;
  final List<MatchEvent> matchEvents;
}

class SessionRecorder {
  const SessionRecorder({
    required SessionWriter repository,
    required Clock clock,
    required UuidFactory uuidFactory,
  }) : _repository = repository,
       _clock = clock,
       _uuidFactory = uuidFactory;

  final SessionWriter _repository;
  final Clock _clock;
  final UuidFactory _uuidFactory;

  Future<void> recordDailyLifeCompleted(DailyLifeCompletedEvent event) {
    final uid = event.session.uid;
    if (uid == null) return Future<void>.value();

    final endedAt = _clock().toUtc();
    final targetId =
        event.config.interactables.firstWhere((i) => i.isTarget).id;
    final startedAt = event.session.startedAt.toUtc();
    final durationMs = endedAt.difference(startedAt).inMilliseconds;
    final record = SessionRecord(
      sessionId: event.session.sessionId,
      uid: uid,
      scenarioId: event.config.scenarioId,
      module: kModuleDailyLife,
      startedAt: startedAt.toIso8601String(),
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
          pathPoints: event.dragPath,
        ),
      ],
    );
    return _repository.writeSession(record);
  }

  Future<void> recordMemoryCompleted(MemoryCompletedEvent event) {
    final uid = event.session.uid;
    if (uid == null) return Future<void>.value();

    final endedAt = _clock().toUtc();
    final startedAt = event.session.startedAt.toUtc();
    final totalPairs = event.pack.pairs.length;
    final record = SessionRecord(
      sessionId: event.session.sessionId,
      uid: uid,
      scenarioId: event.pack.packId,
      module: kModuleMemory,
      startedAt: startedAt.toIso8601String(),
      endedAt: endedAt.toIso8601String(),
      durationMs: endedAt.difference(startedAt).inMilliseconds,
      completed: true,
      pairsMatched: totalPairs,
      totalPairs: totalPairs,
      matchEvents: List.unmodifiable(event.matchEvents),
    );
    return _repository.writeSession(record);
  }
}
