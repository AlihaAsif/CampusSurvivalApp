enum SlotKind { lecture, lab, tutorial }

class ClassSlot {
  final String id;
  final String subjectId;
  final int weekday;     
  final int startMinutes;
  final int endMinutes;
  final String room;
  final SlotKind kind;

  const ClassSlot({
    required this.id,
    required this.subjectId,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    required this.room,
    this.kind = SlotKind.lecture,
  });

  int get durationMinutes => endMinutes - startMinutes;


  static String formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${mins.toString().padLeft(2, '0')}';
  }

  String get timeRange =>
      '${formatTime(startMinutes)} – ${formatTime(endMinutes)}';
}