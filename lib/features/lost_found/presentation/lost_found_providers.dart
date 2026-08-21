import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/firestore_lost_found_repository.dart';
import '../domain/lost_found_repository.dart';
import '../domain/lost_item.dart';

enum LostFilter { all, lost, found }

final lostFoundRepositoryProvider = Provider<LostFoundRepository>((ref) {
  return FirestoreLostFoundRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final lostItemsProvider = StreamProvider<List<LostItem>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(lostFoundRepositoryProvider).watchItems();
});

final lostFilterProvider = StateProvider<LostFilter>((ref) => LostFilter.all);

final filteredLostItemsProvider = Provider<List<LostItem>>((ref) {
  final all = ref.watch(lostItemsProvider).value ?? [];
  final filter = ref.watch(lostFilterProvider);

  return all.where((item) {
    return switch (filter) {
      LostFilter.all => true,
      LostFilter.lost => item.kind == LostKind.lost,
      LostFilter.found => item.kind == LostKind.found,
    };
  }).toList();
});