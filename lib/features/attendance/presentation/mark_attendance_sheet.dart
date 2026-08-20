import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../timetable/domain/class_slot.dart';
import '../../timetable/presentation/timetable_providers.dart';
import '../domain/attendance_record.dart';
import 'attendance_providers.dart';

class MarkAttendanceSheet extends ConsumerWidget {
  const MarkAttendanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final now = DateTime.now();
    final slots = ref.watch(slotsForDayProvider(now.weekday));
    final subjectMap = ref.watch(subjectMapProvider);
    final records = ref.watch(attendanceRecordsProvider).value ?? [];

    // One row per subject, even if it has two classes today.
    final seen = <String>{};
    final todaySubjects = <ClassSlot>[];
    for (final slot in slots) {
      if (seen.add(slot.subjectId)) todaySubjects.add(slot);
    }

    AttendanceMark? markFor(String subjectId) {
      for (final record in records) {
        if (record.subjectId == subjectId &&
            record.date.year == now.year &&
            record.date.month == now.month &&
            record.date.day == now.day) {
          return record.mark;
        }
      }
      return null;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's classes", style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Mark yourself present or absent.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (todaySubjects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xxl,
                ),
                child: Center(
                  child: Text(
                    'No classes scheduled today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...todaySubjects.map((slot) {
                final subject = subjectMap[slot.subjectId];
                if (subject == null) return const SizedBox.shrink();

                final mark = markFor(slot.subjectId);

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.cardGap,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPad),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(subject.colorValue),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${slot.timeRange} · ${slot.room}',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _MarkButton(
                            icon: Icons.check,
                            selected: mark == AttendanceMark.present,
                            color: const Color(0xFF256B48),
                            onTap: () => ref
                                .read(attendanceRepositoryProvider)
                                .mark(
                              subjectId: slot.subjectId,
                              date: now,
                              mark: AttendanceMark.present,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _MarkButton(
                            icon: Icons.close,
                            selected: mark == AttendanceMark.absent,
                            color: scheme.error,
                            onTap: () => ref
                                .read(attendanceRepositoryProvider)
                                .mark(
                              subjectId: slot.subjectId,
                              date: now,
                              mark: AttendanceMark.absent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? color : scheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: selected ? Colors.white : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}