import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/assignment.dart';
import '../domain/assignment_repository.dart';

class FirestoreAssignmentRepository implements AssignmentRepository {
  FirestoreAssignmentRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('assignments');

  @override
  Stream<List<Assignment>> watchAssignments() {
    return _collection.orderBy('dueAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Assignment(
          id: doc.id,
          subjectId: data['subjectId'] as String? ?? '',
          title: data['title'] as String? ?? '',
          dueAt: (data['dueAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          priority: _toPriority(data['priority'] as String?),
          done: data['done'] as bool? ?? false,
          notes: data['notes'] as String?,
        );
      }).toList();
    });
  }

  @override
  Future<void> addAssignment(Assignment assignment) {
    return _collection.add({
      'subjectId': assignment.subjectId,
      'title': assignment.title.trim(),
      'dueAt': Timestamp.fromDate(assignment.dueAt),
      'priority': assignment.priority.name,
      'done': assignment.done,
      'notes': assignment.notes?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> toggleDone(String assignmentId, bool done) {
    return _collection.doc(assignmentId).update({'done': done});
  }

  @override
  Future<void> deleteAssignment(String assignmentId) {
    return _collection.doc(assignmentId).delete();
  }

  Priority _toPriority(String? value) {
    return Priority.values.firstWhere(
          (priority) => priority.name == value,
      orElse: () => Priority.medium,
    );
  }
}