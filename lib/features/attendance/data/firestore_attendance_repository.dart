import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/attendance_record.dart';
import '../domain/attendance_repository.dart';

class FirestoreAttendanceRepository implements AttendanceRepository {
  FirestoreAttendanceRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('users')
      .doc(_uid)
      .collection('attendanceRecords');

  /// One record per subject per day: "subjectId_2026-08-20".
  String _docId(String subjectId, DateTime date) {
    final day = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return '${subjectId}_$day';
  }

  @override
  Stream<List<AttendanceRecord>> watchRecords() {
    return _collection.snapshots().map((snapshot) {
      final records = snapshot.docs.map((doc) {
        final data = doc.data();
        return AttendanceRecord(
          id: doc.id,
          subjectId: data['subjectId'] as String? ?? '',
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          mark: data['mark'] == 'absent'
              ? AttendanceMark.absent
              : AttendanceMark.present,
        );
      }).toList();

      records.sort((a, b) => a.date.compareTo(b.date));
      return records;
    });
  }

  @override
  Future<void> mark({
    required String subjectId,
    required DateTime date,
    required AttendanceMark mark,
  }) {
    final day = DateTime(date.year, date.month, date.day);

    return _collection.doc(_docId(subjectId, day)).set({
      'subjectId': subjectId,
      'date': Timestamp.fromDate(day),
      'mark': mark.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteRecord(String recordId) {
    return _collection.doc(recordId).delete();
  }
}