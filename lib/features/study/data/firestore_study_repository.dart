import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/study_repository.dart';
import '../domain/study_session.dart';

class FirestoreStudyRepository implements StudyRepository {
  FirestoreStudyRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _userDoc.collection('studySessions');

  CollectionReference<Map<String, dynamic>> get _goals =>
      _userDoc.collection('studyGoals');

  // ---------- Sessions ----------

  @override
  Stream<List<StudySession>> watchSessions() {
    return _sessions.orderBy('startAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StudySession(
          id: doc.id,
          subjectId: data['subjectId'] as String? ?? '',
          title: data['title'] as String? ?? '',
          startAt:
          (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          durationMinutes: data['durationMinutes'] as int? ?? 60,
          done: data['done'] as bool? ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<void> addSession(StudySession session) {
    return _sessions.add({
      'subjectId': session.subjectId,
      'title': session.title.trim(),
      'startAt': Timestamp.fromDate(session.startAt),
      'durationMinutes': session.durationMinutes,
      'done': session.done,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleDone(String sessionId, bool done) {
    return _sessions.doc(sessionId).update({'done': done});
  }

  @override
  Future<void> deleteSession(String sessionId) {
    return _sessions.doc(sessionId).delete();
  }

  // ---------- Goals ----------

  @override
  Stream<List<StudyGoal>> watchGoals() {
    return _goals.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudyGoal(
          subjectId: doc.id,
          weeklyHours: doc.data()['weeklyHours'] as int? ?? 0,
        );
      }).toList();
    });
  }

  @override
  Future<void> setGoal(String subjectId, int weeklyHours) {
    // Document id is the subject id, so there is one goal per subject.
    return _goals.doc(subjectId).set({
      'weeklyHours': weeklyHours,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}