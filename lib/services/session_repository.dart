import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_record.dart';

abstract class SessionWriter {
  Future<void> writeSession(SessionRecord record);
}

// Writes SessionRecord docs to /sessions/{uid}/records/{sessionId}
// (firestore.rules). Swallows errors so UI never blocks on network; the
// Firestore SDK's offline cache retries when connectivity returns.
class SessionRepository implements SessionWriter {
  SessionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> writeSession(SessionRecord record) async {
    try {
      await _firestore
          .collection('sessions')
          .doc(record.uid)
          .collection('records')
          .doc(record.sessionId)
          .set(record.toJson());
    } catch (e, st) {
      developer.log(
        'SessionRepository.writeSession failed',
        name: 'session',
        error: e,
        stackTrace: st,
      );
    }
  }
}
