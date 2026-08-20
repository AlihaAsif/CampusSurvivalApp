import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/profile_repository.dart';
import '../domain/user_profile.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _docFor(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  /// Firestore data -> our model.
  UserProfile? _toProfile(String uid, Map<String, dynamic>? data) {
    if (data == null) return null;
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      rollNumber: data['rollNumber'] as String? ?? '',
      semester: data['semester'] as int? ?? 0,
      section: data['section'] as String? ?? '',
    );
  }

  /// Our model -> Firestore data.
  Map<String, dynamic> _toMap(UserProfile profile) {
    return {
      'name': profile.name,
      'rollNumber': profile.rollNumber,
      'semester': profile.semester,
      'section': profile.section,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _docFor(uid).snapshots().map(
          (snapshot) => _toProfile(uid, snapshot.data()),
    );
  }

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final snapshot = await _docFor(uid).get();
    return _toProfile(uid, snapshot.data());
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _docFor(profile.uid).set(
      _toMap(profile),
      SetOptions(merge: true),
    );
  }
}