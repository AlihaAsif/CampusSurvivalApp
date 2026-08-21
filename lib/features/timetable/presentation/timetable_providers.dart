import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/firestore_timetable_repository.dart';
import '../domain/class_slot.dart';
import '../domain/subject.dart';
import '../domain/timetable_repository.dart';
import '../../../core/time/ticker_provider.dart';
import '../domain/next_class.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return FirestoreTimetableRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final subjectsProvider = StreamProvider<List<Subject>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(timetableRepositoryProvider).watchSubjects();
});

final classSlotsProvider = StreamProvider<List<ClassSlot>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(timetableRepositoryProvider).watchClassSlots();
});


final subjectMapProvider = Provider<Map<String, Subject>>((ref) {
  final subjects = ref.watch(subjectsProvider).value ?? [];
  return {for (final subject in subjects) subject.id: subject};
});


final slotsForDayProvider =
Provider.family<List<ClassSlot>, int>((ref, weekday) {
  final slots = ref.watch(classSlotsProvider).value ?? [];
  return slots.where((slot) => slot.weekday == weekday).toList();
});


final nextClassProvider = Provider<NextClass?>((ref) {
  final slots = ref.watch(classSlotsProvider).value ?? [];
  final now = ref.watch(nowProvider);
  return NextClass.find(now, slots);
});


final todaysClassesProvider = Provider<List<ClassSlot>>((ref) {
  final now = ref.watch(nowProvider);
  return ref.watch(slotsForDayProvider(now.weekday));
});