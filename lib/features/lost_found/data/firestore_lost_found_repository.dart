import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/lost_found_repository.dart';
import '../domain/lost_item.dart';

class FirestoreLostFoundRepository implements LostFoundRepository {
  FirestoreLostFoundRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('lostItems');

  @override
  Stream<List<LostItem>> watchItems() {
    return _collection
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
        final data = doc.data();
        return LostItem(
          id: doc.id,
          kind: data['kind'] == 'found' ? LostKind.found : LostKind.lost,
          category: _toCategory(data['category'] as String?),
          title: data['title'] as String? ?? '',
          location: data['location'] as String? ?? '',
          postedAt: (data['postedAt'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          postedByName: data['postedByName'] as String? ?? 'Someone',
          postedByUid: data['postedByUid'] as String? ?? '',
          imageUrl: data['imageUrl'] as String?,
          contactNote: data['contactNote'] as String?,
          resolved: data['resolved'] as bool? ?? false,
        );
      })
          .where((item) => item.shouldShow)
          .toList();
    });
  }

  @override
  Future<void> addItem(LostItem item) {
    return _collection.add({
      'kind': item.kind.name,
      'category': item.category.name,
      'title': item.title.trim(),
      'location': item.location.trim(),
      'postedAt': Timestamp.fromDate(item.postedAt),
      'postedByName': item.postedByName,
      'postedByUid': _auth.currentUser!.uid,
      'imageUrl': item.imageUrl,
      'contactNote': item.contactNote?.trim(),
      'resolved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markResolved(String itemId, bool resolved) {
    return _collection.doc(itemId).update({'resolved': resolved});
  }

  @override
  Future<void> deleteItem(String itemId) {
    return _collection.doc(itemId).delete();
  }

  ItemCategory _toCategory(String? value) {
    return ItemCategory.values.firstWhere(
          (category) => category.name == value,
      orElse: () => ItemCategory.other,
    );
  }
}