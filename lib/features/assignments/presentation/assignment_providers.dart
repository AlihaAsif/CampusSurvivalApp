import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/firestore_assignment_repository.dart';
import '../domain/assignment.dart';
import '../domain/assignment_repository.dart';

enum AssignmentFilter { all, overdue, high, medium, low, done }

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return FirestoreAssignmentRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final assignmentsProvider = StreamProvider<List<Assignment>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(assignmentRepositoryProvider).watchAssignments();
});


final assignmentFilterProvider =
StateProvider<AssignmentFilter>((ref) => AssignmentFilter.all);


final filteredAssignmentsProvider = Provider<List<Assignment>>((ref) {
  final all = ref.watch(assignmentsProvider).value ?? [];
  final filter = ref.watch(assignmentFilterProvider);
  final now = DateTime.now();

  final list = all.where((assignment) {
    switch (filter) {
      case AssignmentFilter.all:
        return true;
      case AssignmentFilter.overdue:
        return assignment.isOverdue(now);
      case AssignmentFilter.high:
        return !assignment.done && assignment.priority == Priority.high;
      case AssignmentFilter.medium:
        return !assignment.done && assignment.priority == Priority.medium;
      case AssignmentFilter.low:
        return !assignment.done && assignment.priority == Priority.low;
      case AssignmentFilter.done:
        return assignment.done;
    }
  }).toList();


  list.sort((a, b) {
    if (a.done != b.done) return a.done ? 1 : -1;
    return a.dueAt.compareTo(b.dueAt);
  });

  return list;
});


final assignmentCountsProvider = Provider<({int done, int total})>((ref) {
  final all = ref.watch(assignmentsProvider).value ?? [];
  final done = all.where((assignment) => assignment.done).length;
  return (done: done, total: all.length);
});


final upcomingDeadlinesProvider = Provider<List<Assignment>>((ref) {
  final all = ref.watch(assignmentsProvider).value ?? [];

  final pending = all.where((item) => !item.done).toList()
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  return pending.take(3).toList();
});