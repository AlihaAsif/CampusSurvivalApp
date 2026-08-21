import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../timetable/presentation/timetable_providers.dart';
import '../domain/study_session.dart';
import 'add_session_screen.dart';
import 'study_providers.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final sessionsAsync = ref.watch(studySessionsProvider);
    final progress = ref.watch(subjectProgressProvider);
    final totals = ref.watch(weekTotalsProvider);
    final streak = ref.watch(studyStreakProvider);
    final week = ref.watch(thisWeekSessionsProvider);
    final subjectMap = ref.watch(subjectMapProvider);

    final planned = week.where((session) => !session.done).toList();
    final finished = week.where((session) => session.done).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study planner'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenH,
              bottom: AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This week',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
        const Center(child: Text('Could not load your sessions.')),
        data: (_) {
          if (progress.isEmpty) {
            return _empty(
              theme,
              scheme,
              'No subjects yet',
              'Add subjects in Timetable, then set weekly goals.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              96,
            ),
            children: [
              // ---------- Header ----------
              Card(
                color: scheme.surfaceContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Studied this week',
                                  style:
                                  theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      _hours(totals.done),
                                      style:
                                      theme.textTheme.headlineSmall,
                                    ),
                                    Text(
                                      ' / ${totals.goal} hrs',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (streak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.chip,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 15,
                                    color: scheme.onSecondaryContainer,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$streak day streak',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: scheme.onSecondaryContainer,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: totals.goal == 0
                              ? 0
                              : (totals.done / totals.goal)
                              .clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Weekly goals ----------
              const SizedBox(height: AppSpacing.section),
              Text(
                'WEEKLY GOALS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              ...progress.map((item) {
                return Padding(
                  padding:
                  const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: Card(
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(AppRadius.card),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => _GoalDialog(
                          subjectId: item.subject.id,
                          subjectName: item.subject.name,
                          current: item.goalHours,
                        ),
                      ),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(AppSpacing.cardPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color:
                                    Color(item.subject.colorValue),
                                    borderRadius:
                                    BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    item.subject.name,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                Text(
                                  item.goalHours == 0
                                      ? 'Set a goal'
                                      : '${_hours(item.doneHours)} / '
                                      '${item.goalHours} hrs',
                                  style:
                                  theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            if (item.goalHours > 0) ...[
                              const SizedBox(height: AppSpacing.md),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: item.fraction,
                                  minHeight: 6,
                                  color: item.behind
                                      ? BrandColors.orange
                                      : Color(item.subject.colorValue),
                                  backgroundColor:
                                  scheme.surfaceContainerHighest,
                                ),
                              ),
                              if (item.behind) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Behind schedule — '
                                      '${_hours(item.remainingHours)} hrs left '
                                      'this week.',
                                  style:
                                  theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // ---------- Planned ----------
              const SizedBox(height: AppSpacing.section),
              Text(
                'PLANNED SESSIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              if (planned.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'Nothing planned this week.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ...planned.map(
                      (session) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: AppSpacing.cardGap),
                    child: _SessionCard(
                      session: session,
                      subjectColor:
                      subjectMap[session.subjectId]?.colorValue,
                      subjectCode: subjectMap[session.subjectId]?.code,
                    ),
                  ),
                ),

              // ---------- Completed ----------
              if (finished.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.section),
                Text(
                  'COMPLETED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...finished.map(
                      (session) => Padding(
                    padding:
                    const EdgeInsets.only(bottom: AppSpacing.cardGap),
                    child: _SessionCard(
                      session: session,
                      subjectColor:
                      subjectMap[session.subjectId]?.colorValue,
                      subjectCode: subjectMap[session.subjectId]?.code,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddSessionScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Plan session'),
      ),
    );
  }

  static String _hours(double value) {
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  Widget _empty(
      ThemeData theme,
      ColorScheme scheme,
      String title,
      String message,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------

class _SessionCard extends ConsumerWidget {
  const _SessionCard({
    required this.session,
    required this.subjectColor,
    required this.subjectCode,
  });

  final StudySession session;
  final int? subjectColor;
  final String? subjectCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Opacity(
      opacity: session.done ? 0.55 : 1,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => ref
              .read(studyRepositoryProvider)
              .toggleDone(session.id, !session.done),
          onLongPress: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete session?'),
                content: Text('"${session.title}" will be removed.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await ref
                  .read(studyRepositoryProvider)
                  .deleteSession(session.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Round checkbox — sessions are events, not tasks.
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color:
                    session.done ? scheme.primary : Colors.transparent,
                    border: session.done
                        ? null
                        : Border.all(color: scheme.outline, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: session.done
                      ? Icon(Icons.check, size: 13, color: scheme.onPrimary)
                      : null,
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: session.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (subjectColor != null) ...[
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: Color(subjectColor!),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${subjectCode ?? ''} · ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              _when(session),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _when(StudySession session) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final now = DateTime.now();
    final start = session.startAt;
    final end = session.endAt;

    final sameDay = start.year == now.year &&
        start.month == now.month &&
        start.day == now.day;

    final label = sameDay ? 'Today' : days[start.weekday - 1];

    return '$label, ${_time(start)} – ${_time(end)}';
  }

  String _time(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// ---------------------------------------------------------------

class _GoalDialog extends ConsumerStatefulWidget {
  const _GoalDialog({
    required this.subjectId,
    required this.subjectName,
    required this.current,
  });

  final String subjectId;
  final String subjectName;
  final int current;

  @override
  ConsumerState<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends ConsumerState<_GoalDialog> {
  late int _hours = widget.current == 0 ? 4 : widget.current;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Weekly goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.subjectName,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.remove),
                onPressed: _hours <= 0
                    ? null
                    : () => setState(() => _hours--),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  '$_hours hrs',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.add),
                onPressed: _hours >= 40
                    ? null
                    : () => setState(() => _hours++),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
            setState(() => _saving = true);
            await ref
                .read(studyRepositoryProvider)
                .setGoal(widget.subjectId, _hours);
            if (mounted) Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}