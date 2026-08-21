import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/firestore_announcement_repository.dart';
import '../domain/announcement.dart';
import '../domain/announcement_repository.dart';

enum AnnouncementFilter { all, unread, pinned }

final announcementRepositoryProvider =
Provider<AnnouncementRepository>((ref) {
  return FirestoreAnnouncementRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final announcementsProvider = StreamProvider<List<Announcement>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(announcementRepositoryProvider).watchAnnouncements();
});

final readIdsProvider = StreamProvider<Set<String>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(<String>{});

  return ref.watch(announcementRepositoryProvider).watchReadIds();
});


final unreadCountProvider = Provider<int>((ref) {
  final all = ref.watch(announcementsProvider).value ?? [];
  final read = ref.watch(readIdsProvider).value ?? <String>{};

  return all.where((item) => !read.contains(item.id)).length;
});

final announcementFilterProvider =
StateProvider<AnnouncementFilter>((ref) => AnnouncementFilter.all);

final filteredAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  final all = ref.watch(announcementsProvider).value ?? [];
  final read = ref.watch(readIdsProvider).value ?? <String>{};
  final filter = ref.watch(announcementFilterProvider);

  return all.where((item) {
    return switch (filter) {
      AnnouncementFilter.all => true,
      AnnouncementFilter.unread => !read.contains(item.id),
      AnnouncementFilter.pinned => item.pinned,
    };
  }).toList();
});