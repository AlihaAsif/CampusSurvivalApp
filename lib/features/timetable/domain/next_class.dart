import 'class_slot.dart';

class NextClass {
  const NextClass({
    required this.slot,
    required this.start,
    required this.end,
    required this.isLive,
  });

  final ClassSlot slot;
  final DateTime start;
  final DateTime end;

  /// True when the class is happening right now.
  final bool isLive;

  /// "in 42 min", "in 2 hr 15 min", "in 3 days"
  static String gapText(Duration gap) {
    if (gap.isNegative) return 'now';

    if (gap.inDays > 0) {
      final days = gap.inDays;
      return 'in $days day${days == 1 ? '' : 's'}';
    }
    if (gap.inHours > 0) {
      return 'in ${gap.inHours} hr ${gap.inMinutes % 60} min';
    }
    return 'in ${gap.inMinutes} min';
  }

  /// Searches forward up to 8 days so Saturday evening resolves to
  /// Monday morning.
  static NextClass? find(DateTime now, List<ClassSlot> slots) {
    for (var offset = 0; offset < 8; offset++) {
      final day = now.add(Duration(days: offset));

      final todaySlots =
      slots.where((slot) => slot.weekday == day.weekday).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

      for (final slot in todaySlots) {
        final start = _at(day, slot.startMinutes);
        final end = _at(day, slot.endMinutes);

        if (now.isAfter(start) && now.isBefore(end)) {
          return NextClass(
            slot: slot,
            start: start,
            end: end,
            isLive: true,
          );
        }
        if (start.isAfter(now)) {
          return NextClass(
            slot: slot,
            start: start,
            end: end,
            isLive: false,
          );
        }
      }
    }
    return null;
  }

  static DateTime _at(DateTime day, int minutes) {
    return DateTime(
      day.year,
      day.month,
      day.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }
}