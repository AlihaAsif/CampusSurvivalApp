import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/announcement.dart';
import '../domain/announcement_repository.dart';

class FirestoreAnnouncementRepository implements AnnouncementRepository {
  FirestoreAnnouncementRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _firestore.collection('announcements');

  CollectionReference<Map<String, dynamic>> get _readDocs => _firestore
      .collection('users')
      .doc(_uid)
      .collection('readAnnouncements');

  @override
  Stream<List<Announcement>> watchAnnouncements() {
    return _announcements.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();

        // Fallbacks for title field variants
        final rawTitle = (data['title'] ??
            data['heading'] ??
            data['subject'] ??
            data['name'] ??
            data['header'] ??
            data['topic'])?.toString() ?? '';

        // Fallbacks for body field variants
        final rawBody = (data['body'] ??
            data['content'] ??
            data['message'] ??
            data['description'] ??
            data['text'] ??
            data['details'])?.toString() ?? '';

        // Fallbacks for timestamp field variants
        final rawTimestamp = data['postedAt'] ??
            data['createdAt'] ??
            data['timestamp'] ??
            data['date'] ??
            data['time'];
        final DateTime postedAt = rawTimestamp is Timestamp
            ? rawTimestamp.toDate()
            : (rawTimestamp is String
                ? DateTime.tryParse(rawTimestamp) ?? DateTime.now()
                : DateTime.now());

        final bool isPinned =
            (data['pinned'] ?? data['isPinned'] ?? false) as bool? ?? false;
        final String source = (data['source'] ??
                data['author'] ??
                data['publisher'] ??
                data['from'] ??
                data['category'])?.toString() ??
            'Campus';

        final displayTitle = rawTitle.isNotEmpty
            ? rawTitle
            : (rawBody.isNotEmpty ? rawBody : 'Announcement');

        return Announcement(
          id: doc.id,
          source: source,
          title: displayTitle,
          body: rawBody,
          postedAt: postedAt,
          pinned: isPinned,
        );
      }).toList();

      list.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.postedAt.compareTo(a.postedAt);
      });

      return list;
    });
  }

  @override
  Stream<Set<String>> watchReadIds() {
    return _readDocs.snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }

  @override
  Future<void> markRead(String announcementId) {
    return _readDocs.doc(announcementId).set({
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}