import 'attendance_record.dart';

abstract class AttendanceRepository {
  Stream<List<AttendanceRecord>> watchRecords();
  Future<void> mark({
    required String subjectId,
    required DateTime date,
    required AttendanceMark mark,
  });
  Future<void> deleteRecord(String recordId);
}