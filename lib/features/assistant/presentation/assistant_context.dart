import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../announcements/presentation/announcement_providers.dart';
import '../../assignments/presentation/assignment_providers.dart';
import '../../attendance/presentation/attendance_providers.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../map/data/campus_places.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../study/presentation/study_providers.dart';
import '../../timetable/domain/next_class.dart';
import '../../timetable/presentation/timetable_providers.dart';

final assistantContextProvider = Provider<String>((ref) {
  final now = DateTime.now();
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final dayName = weekdays[now.weekday - 1];
  final dateStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final buffer = StringBuffer();
  buffer.writeln('DATE: $dateStr ($dayName)');

  // PROFILE
  final profile = ref.watch(profileProvider).value;
  if (profile != null) {
    buffer.writeln(
      'PROFILE: ${profile.name} (${profile.rollNumber}), Sem ${profile.semester}, Sec ${profile.section}',
    );
  }

  // TIMETABLE & NEXT CLASS
  final subjects = ref.watch(subjectsProvider).value ?? [];
  final slots = ref.watch(classSlotsProvider).value ?? [];
  final next = ref.watch(nextClassProvider);

  final subjectMap = {for (var s in subjects) s.id: s.code};

  final timetableParts = <String>[];
  if (next != null) {
    final nextName = subjectMap[next.slot.subjectId] ?? next.slot.subjectId;
    final gapText = NextClass.gapText(next.start.difference(now));
    final roomStr = next.slot.room.isNotEmpty ? 'Room ${next.slot.room}' : 'No Room';
    timetableParts.add(
      'Next class: $nextName $gapText ($roomStr)',
    );
  }
  if (slots.isNotEmpty) {
    final slotSummaries = slots.take(8).map((slot) {
      final code = subjectMap[slot.subjectId] ?? slot.subjectId;
      final day = weekdays[slot.weekday - 1].substring(0, 3);
      final startH = (slot.startMinutes ~/ 60).toString().padLeft(2, '0');
      final startM = (slot.startMinutes % 60).toString().padLeft(2, '0');
      final roomStr = slot.room.isNotEmpty ? slot.room : 'TBA';
      return '$day $startH:$startM $code ($roomStr)';
    });
    timetableParts.add('Slots: ${slotSummaries.join(', ')}');
  }
  if (timetableParts.isNotEmpty) {
    buffer.writeln('TIMETABLE: ${timetableParts.join(' | ')}');
  }

  // ATTENDANCE
  final attList = ref.watch(subjectAttendanceProvider);
  final overallAtt = ref.watch(overallAttendanceProvider);
  if (attList.isNotEmpty) {
    final attSummaries = attList.map((sa) {
      return '${sa.subject.code}: ${sa.attended}/${sa.held} (${sa.percent.toStringAsFixed(0)}%, safe skips: ${sa.safeSkips})';
    });
    buffer.writeln(
      'ATTENDANCE: Overall ${overallAtt.percent.toStringAsFixed(0)}% (${overallAtt.attended}/${overallAtt.held}) | ${attSummaries.join(', ')}',
    );
  }

  // BUDGET & EXPENSES
  final monthSpent = ref.watch(monthTotalProvider);
  final budget = ref.watch(monthlyBudgetProvider).value ?? 25000;
  final daily = ref.watch(dailyAllowanceProvider);
  final weekExp = ref.watch(weekTotalsProvider);
  buffer.writeln(
    'BUDGET: Monthly Budget Rs $budget, Spent Rs $monthSpent, Daily Allowance Rs $daily | Study Goal: ${weekExp.done.toStringAsFixed(1)}/${weekExp.goal} hrs',
  );

  // STUDY PROGRESS
  final studyProgress = ref.watch(subjectProgressProvider);
  if (studyProgress.isNotEmpty) {
    final progSummaries = studyProgress
        .where((sp) => sp.goalHours > 0)
        .map((sp) =>
            '${sp.subject.code}: ${sp.doneHours.toStringAsFixed(1)}/${sp.goalHours}h');
    if (progSummaries.isNotEmpty) {
      buffer.writeln('STUDY: ${progSummaries.join(', ')}');
    }
  }

  // DEADLINES
  final deadlines = ref.watch(upcomingDeadlinesProvider);
  if (deadlines.isNotEmpty) {
    final dlSummaries = deadlines.map((d) {
      final due = '${d.dueAt.month}/${d.dueAt.day}';
      return '${d.title} (due $due)';
    });
    buffer.writeln('DEADLINES: ${dlSummaries.join(', ')}');
  }

  // ANNOUNCEMENTS (top 5)
  final announcements = ref.watch(announcementsProvider).value ?? [];
  if (announcements.isNotEmpty) {
    final topAnnouncements = announcements.take(5).map((a) {
      final src = a.source.isNotEmpty ? ' (${a.source})' : '';
      return '${a.title}$src';
    });
    buffer.writeln('ANNOUNCEMENTS: ${topAnnouncements.join(' | ')}');
  }

  // CAMPUS PLACES
  if (campusPlaces.isNotEmpty) {
    final placeSummaries =
        campusPlaces.map((p) => '${p.name} (${p.category.name})');
    buffer.writeln('CAMPUS PLACES: ${placeSummaries.join(', ')}');
  }

  final contextText = buffer.toString().trim();
  return contextText.length > 2000
      ? contextText.substring(0, 2000)
      : contextText;
});
