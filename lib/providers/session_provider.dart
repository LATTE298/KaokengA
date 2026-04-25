import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../features/sessions/session_recorder.dart';
import 'auth_provider.dart';
import '../services/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(FirebaseFirestore.instance);
});

final sessionRecorderProvider = Provider<SessionRecorder>((ref) {
  return SessionRecorder(
    repository: ref.watch(sessionRepositoryProvider),
    uid: ref.watch(uidProvider),
    clock: DateTime.now,
    uuidFactory: const Uuid().v4,
  );
});
