/// One row detected in the timetable image, before the student
/// confirms it. Fields can be missing — parsing is never perfect.
class ParsedSlot {
  final String rawText;
  final String? section;
  final String? subjectCode;
  final int? weekday;
  final int? startMinutes;
  final int? endMinutes;
  final String? room;

  const ParsedSlot({
    required this.rawText,
    this.section,
    this.subjectCode,
    this.weekday,
    this.startMinutes,
    this.endMinutes,
    this.room,
  });

  bool get isComplete =>
      subjectCode != null &&
          weekday != null &&
          startMinutes != null &&
          endMinutes != null;

  List<String> get missingFields => [
    if (subjectCode == null) 'subject',
    if (weekday == null) 'day',
    if (startMinutes == null || endMinutes == null) 'time',
    if (room == null) 'room',
  ];

  ParsedSlot copyWith({
    String? section,
    String? subjectCode,
    int? weekday,
    int? startMinutes,
    int? endMinutes,
    String? room,
  }) {
    return ParsedSlot(
      rawText: rawText,
      section: section ?? this.section,
      subjectCode: subjectCode ?? this.subjectCode,
      weekday: weekday ?? this.weekday,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      room: room ?? this.room,
    );
  }
}