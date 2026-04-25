import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_record.dart';

abstract class ActivityLogReader {
  Stream<List<SessionRecord>> watchRecentSessions(
    String uid, {
    required int limit,
  });
}

class ActivityLogRepository implements ActivityLogReader {
  ActivityLogRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<SessionRecord>> watchRecentSessions(
    String uid, {
    required int limit,
  }) {
    return _firestore
        .collection('sessions')
        .doc(uid)
        .collection('records')
        .orderBy('ended_at', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SessionRecord.fromJson(doc.data()))
                  .toList(),
        );
  }
}
