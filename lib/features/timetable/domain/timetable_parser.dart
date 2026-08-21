import 'parsed_slot.dart';

/// Turns OCR text into timetable rows.
///
/// A university timetable sheet carries every section, so rows are
/// tagged with the section they belong to and filtered afterwards.
class TimetableParser {
  TimetableParser._();

  static const Map<String, int> _dayWords = {
    'monday': 1, 'mon': 1,
    'tuesday': 2, 'tue': 2, 'tues': 2,
    'wednesday': 3, 'wed': 3,
    'thursday': 4, 'thu': 4, 'thur': 4, 'thurs': 4,
    'friday': 5, 'fri': 5,
    'saturday': 6, 'sat': 6,
  };

  /// "08:30 - 09:50", "8:30-9:50", "08.30 – 09.50"
  static final RegExp _timeRange = RegExp(
    r'(\d{1,2})[:.](\d{2})\s*[-–—to]+\s*(\d{1,2})[:.](\d{2})',
    caseSensitive: false,
  );

  /// Subject codes: "CS-221", "SE 312", "MT201", "CSC312", "CS3001", "CSC-312"
  static final RegExp _subjectCode = RegExp(
    r'\b([A-Z]{2,5})[\s-]?(\d{2,4})\b',
    caseSensitive: false,
  );

  /// "CS-204", "Lab 3", "A-112"
  static final RegExp _room = RegExp(
    r'\b(?:room\s*)?((?:lab|hall)\s*\d{1,2}|[A-Z]{1,3}-\d{2,3})\b',
    caseSensitive: false,
  );


  /// Section label: "FA23-BSE-B", "FA23-BSE-6-B", "SP24 BCS 2 A", "BSE-6B"
  static final RegExp _section = RegExp(
    r'\b(?:(FA|SP|SU)\s?(\d{2})[\s-]?)?([A-Z]{2,4})[\s-]?(\d{1,2})?[\s-]?([A-Z])\b',
    caseSensitive: false,
  );

  /// Every section label found in the sheet, so the student can pick.
  static List<String> findSections(String text) {
    final found = <String>{};

    for (final match in _section.allMatches(text.toUpperCase())) {
      found.add(_normalise(match));
    }

    final list = found.toList()..sort();
    return list;
  }

  static List<ParsedSlot> parse(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final slots = <ParsedSlot>[];

    // A day or section on its own line applies to the rows below it.
    int? currentDay;
    String? currentSection;

    for (final line in lines) {
      final upper = line.toUpperCase();

      final sectionMatch = _section.firstMatch(upper);
      final dayOnLine = _findDay(line);
      final timeMatch = _timeRange.firstMatch(line);

      // Header line — remember it and move on.
      if (timeMatch == null) {
        if (sectionMatch != null) {
          currentSection = _normalise(sectionMatch);
        }
        if (dayOnLine != null) {
          currentDay = dayOnLine;
        }
        continue;
      }

      final startHour = int.parse(timeMatch.group(1)!);
      final startMin = int.parse(timeMatch.group(2)!);
      final endHour = int.parse(timeMatch.group(3)!);
      final endMin = int.parse(timeMatch.group(4)!);

      final codeMatch = _subjectCode.firstMatch(upper);
      final roomMatch = _room.firstMatch(line);

      String? subject;
      if (codeMatch != null) {
        subject = '${codeMatch.group(1)!.toUpperCase()}-${codeMatch.group(2)}';
      } else {
        // Fallback: extract subject text by removing day, time, room, section
        var cleaned = line.replaceAll(_timeRange, '').replaceAll(_room, '');
        if (sectionMatch != null) {
          cleaned = cleaned.replaceAll(sectionMatch.group(0)!, '');
        }
        for (final dayWord in _dayWords.keys) {
          cleaned = cleaned.replaceAll(
            RegExp(r'\b' + dayWord + r'\b', caseSensitive: false),
            '',
          );
        }
        cleaned = cleaned.replaceAll(RegExp(r'[^\w\s\-]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (cleaned.length >= 2) {
          subject = cleaned;
        }
      }

      slots.add(
        ParsedSlot(
          rawText: line,
          section: sectionMatch == null
              ? currentSection
              : _normalise(sectionMatch),
          subjectCode: subject,
          weekday: dayOnLine ?? currentDay,
          startMinutes: _toMinutes(startHour, startMin),
          endMinutes: _toMinutes(endHour, endMin),
          room: roomMatch?.group(1)?.toUpperCase(),
        ),
      );
    }

    return slots;
  }

  /// "FA23 BSE 6 B" -> "FA23-BSE-6-B", "BSE 6 B" -> "BSE-6-B"
  static String _normalise(RegExpMatch match) {
    final session = match.group(1);
    final year = match.group(2);
    final dept = match.group(3);
    final semester = match.group(4);
    final sec = match.group(5);

    final prefix = (session != null && year != null) ? '$session$year-' : '';
    final semStr = semester == null ? '' : '-$semester';
    return '$prefix$dept$semStr-$sec';
  }

  static int? _findDay(String line) {
    final words = line.toLowerCase().split(RegExp(r'[\s,|]+'));
    for (final word in words) {
      final day = _dayWords[word];
      if (day != null) return day;
    }
    return null;
  }

  /// Classes run 8 AM to 6 PM, so "1:30" means 13:30.
  static int _toMinutes(int hour, int minute) {
    var h = hour;
    if (h >= 1 && h <= 7) h += 12;
    return h * 60 + minute;
  }
}