import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../timetable/domain/subject.dart';
import '../../timetable/presentation/timetable_providers.dart';
import '../data/firestore_study_repository.dart';
import '../domain/study_repository.dart';
import '../domain/study_session.dart';

class SubjectProgress {
  const SubjectProgress({
    required this.subject,
    required this.goalHours,
    required this.doneHours,
  });

  final Subject subject;
  final int goalHours;
  final double doneHours;

  double get fraction =>
      goalHours == 0 ? 0 : (doneHours / goalHours).clamp(0.0, 1.0);

  bool get behind => goalHours > 0 && fraction < 0.4;

  double get remainingHours {
    final left = goalHours - doneHours;
    return left > 0 ? left : 0;
  }
}

final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return FirestoreStudyRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final studySessionsProvider = StreamProvider<List<StudySession>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(studyRepositoryProvider).watchSessions();
});

final studyGoalsProvider = StreamProvider<List<StudyGoal>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(studyRepositoryProvider).watchGoals();
});

/// Monday 00:00 of the current week.
DateTime _weekStart(DateTime now) {
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

/// Sessions that fall inside this week.
final thisWeekSessionsProvider = Provider<List<StudySession>>((ref) {
  final all = ref.watch(studySessionsProvider).value ?? [];
  final start = _weekStart(DateTime.now());
  final end = start.add(const Duration(days: 7));

  return all
      .where((session) =>
  session.startAt.isAfter(start) && session.startAt.isBefore(end))
      .toList();
});

/// Goal vs done hours, one entry per subject.
final subjectProgressProvider = Provider<List<SubjectProgress>>((ref) {
  final subjects = ref.watch(subjectsProvider).value ?? [];
  final goals = ref.watch(studyGoalsProvider).value ?? [];
  final week = ref.watch(thisWeekSessionsProvider);

  return subjects.map((subject) {
    final goal = goals.where((g) => g.subjectId == subject.id).firstOrNull;

    final doneHours = week
        .where((session) => session.subjectId == subject.id && session.done)
        .fold<double>(0, (sum, session) => sum + session.hours);

    return SubjectProgress(
      subject: subject,
      goalHours: goal?.weeklyHours ?? 0,
      doneHours: doneHours,
    );
  }).toList();
});

/// Totals for the header card.
final weekTotalsProvider =
Provider<({double done, int goal})>((ref) {
  final list = ref.watch(subjectProgressProvider);

  final done = list.fold<double>(0, (sum, item) => sum + item.doneHours);
  final goal = list.fold<int>(0, (sum, item) => sum + item.goalHours);

  return (done: done, goal: goal);
});

/// How many days in a row have at least one completed session.
final studyStreakProvider = Provider<int>((ref) {
  final all = ref.watch(studySessionsProvider).value ?? [];
  final doneDays = all
      .where((session) => session.done)
      .map((session) => DateTime(
    session.startAt.year,
    session.startAt.month,
    session.startAt.day,
  ))
      .toSet();

  final now = DateTime.now();
  var day = DateTime(now.year, now.month, now.day);
  var streak = 0;

  // Today does not break the streak if nothing is done yet.
  if (!doneDays.contains(day)) {
    day = day.subtract(const Duration(days: 1));
  }

  while (doneDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }

  return streak;
});