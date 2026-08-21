class StudySession {
  final String id;
  final String subjectId;
  final String title;
  final DateTime startAt;
  final int durationMinutes;
  final bool done;

  const StudySession({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.startAt,
    required this.durationMinutes,
    this.done = false,
  });

  DateTime get endAt => startAt.add(Duration(minutes: durationMinutes));

  double get hours => durationMinutes / 60;
}

class StudyGoal {
  final String subjectId;


  final int weeklyHours;

  const StudyGoal({
    required this.subjectId,
    required this.weeklyHours,
  });
}