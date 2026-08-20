import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/class_slot.dart';
import '../domain/subject.dart';
import '../domain/timetable_repository.dart';

class FirestoreTimetableRepository implements TimetableRepository {
  FirestoreTimetableRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _subjects =>
      _firestore.collection('users').doc(_uid).collection('subjects');

  CollectionReference<Map<String, dynamic>> get _slots =>
      _firestore.collection('users').doc(_uid).collection('classSlots');



  @override
  Stream<List<Subject>> watchSubjects() {
    return _subjects.orderBy('code').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Subject(
          id: doc.id,
          code: data['code'] as String? ?? '',
          name: data['name'] as String? ?? '',
          colorValue: data['colorValue'] as int? ?? subjectColors.first,
          classesHeld: data['classesHeld'] as int? ?? 0,
          classesAttended: data['classesAttended'] as int? ?? 0,
        );
      }).toList();
    });
  }

  @override
  Future<String> addSubject({
    required String code,
    required String name,
  }) async {
    final existing = await _subjects.get();

    final doc = await _subjects.add({
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      'colorValue': Subject.nextColor(existing.docs.length),
      'classesHeld': 0,
      'classesAttended': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  @override
  Future<void> deleteSubject(String subjectId) async {
    final slots =
    await _slots.where('subjectId', isEqualTo: subjectId).get();

    final batch = _firestore.batch();
    for (final doc in slots.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_subjects.doc(subjectId));

    await batch.commit();
  }


  @override
  Stream<List<ClassSlot>> watchClassSlots() {
    return _slots.snapshots().map((snapshot) {
      final slots = snapshot.docs.map((doc) {
        final data = doc.data();
        return ClassSlot(
          id: doc.id,
          subjectId: data['subjectId'] as String? ?? '',
          weekday: data['weekday'] as int? ?? 1,
          startMinutes: data['startMinutes'] as int? ?? 0,
          endMinutes: data['endMinutes'] as int? ?? 0,
          room: data['room'] as String? ?? '',
          kind: _toKind(data['kind'] as String?),
        );
      }).toList();

      slots.sort((a, b) {
        final byDay = a.weekday.compareTo(b.weekday);
        if (byDay != 0) return byDay;
        return a.startMinutes.compareTo(b.startMinutes);
      });

      return slots;
    });
  }

  @override
  Future<void> addClassSlot(ClassSlot slot) {
    return _slots.add({
      'subjectId': slot.subjectId,
      'weekday': slot.weekday,
      'startMinutes': slot.startMinutes,
      'endMinutes': slot.endMinutes,
      'room': slot.room.trim().toUpperCase(),
      'kind': slot.kind.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteClassSlot(String slotId) {
    return _slots.doc(slotId).delete();
  }

  SlotKind _toKind(String? value) {
    return SlotKind.values.firstWhere(
          (kind) => kind.name == value,
      orElse: () => SlotKind.lecture,
    );
  }
}