enum AttendanceMark { present, absent }

class AttendanceRecord {
  final String id;
  final String subjectId;
  final DateTime date;
  final AttendanceMark mark;

  const AttendanceRecord({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.mark,
  });
}