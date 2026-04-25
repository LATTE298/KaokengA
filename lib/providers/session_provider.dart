import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../features/sessions/session_recorder.dart';
import 'auth_provider.dart';
import '../services/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionWriter>((ref) {
  return SessionRepository(FirebaseFirestore.instance);
});

final clockProvider = Provider<Clock>((ref) => DateTime.now);

final uuidFactoryProvider = Provider<UuidFactory>((ref) => const Uuid().v4);

final activeSessionProvider = Provider.family<ActiveSession, ActiveSessionKey>((
  ref,
  key,
) {
  return ActiveSession(
    sessionId: ref.watch(uuidFactoryProvider)(),
    uid: ref.watch(uidProvider),
    module: key.module,
    contentId: key.contentId,
    startedAt: ref.watch(clockProvider)().toUtc(),
  );
});

final sessionRecorderProvider = Provider<SessionRecorder>((ref) {
  return SessionRecorder(
    repository: ref.watch(sessionRepositoryProvider),
    clock: ref.watch(clockProvider),
    uuidFactory: ref.watch(uuidFactoryProvider),
  );
});
