import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../timetable/domain/subject.dart';
import '../../timetable/presentation/timetable_providers.dart';
import '../data/firestore_attendance_repository.dart';
import '../domain/attendance_math.dart';
import '../domain/attendance_record.dart';
import '../domain/attendance_repository.dart';

class SubjectAttendance {
  const SubjectAttendance({
    required this.subject,
    required this.held,
    required this.attended,
    required this.marks,
  });

  final Subject subject;
  final int held;
  final int attended;

  /// True = present, false = absent. In date order.
  final List<bool> marks;

  int get missed => held - attended;
  double get percent => AttendanceMath.percent(attended, held);
  int get safeSkips => AttendanceMath.safeSkips(attended, held);
  int get recoveryNeeded => AttendanceMath.recoveryNeeded(attended, held);
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return FirestoreAttendanceRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final attendanceRecordsProvider =
StreamProvider<List<AttendanceRecord>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(attendanceRepositoryProvider).watchRecords();
});


final subjectAttendanceProvider = Provider<List<SubjectAttendance>>((ref) {
  final subjects = ref.watch(subjectsProvider).value ?? [];
  final records = ref.watch(attendanceRecordsProvider).value ?? [];

  return subjects.map((subject) {
    final own = records
        .where((record) => record.subjectId == subject.id)
        .toList();

    final marks = own
        .map((record) => record.mark == AttendanceMark.present)
        .toList();

    return SubjectAttendance(
      subject: subject,
      held: own.length,
      attended: marks.where((present) => present).length,
      marks: marks,
    );
  }).toList();
});


final overallAttendanceProvider =
Provider<({int held, int attended, double percent})>((ref) {
  final list = ref.watch(subjectAttendanceProvider);

  final held = list.fold<int>(0, (sum, item) => sum + item.held);
  final attended = list.fold<int>(0, (sum, item) => sum + item.attended);

  return (
  held: held,
  attended: attended,
  percent: AttendanceMath.percent(attended, held),
  );
});

final unmarkedTodayProvider = Provider<List<String>>((ref) {
  final now = DateTime.now();
  final slots = ref.watch(slotsForDayProvider(now.weekday));
  final records = ref.watch(attendanceRecordsProvider).value ?? [];

  final markedToday = records
      .where((record) =>
  record.date.year == now.year &&
      record.date.month == now.month &&
      record.date.day == now.day)
      .map((record) => record.subjectId)
      .toSet();

  return slots
      .map((slot) => slot.subjectId)
      .toSet()
      .where((subjectId) => !markedToday.contains(subjectId))
      .toList();
});