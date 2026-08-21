import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../timetable/domain/subject.dart';
import '../../timetable/presentation/timetable_providers.dart';
import '../domain/assignment.dart';
import 'add_assignment_screen.dart';
import 'assignment_providers.dart';
import 'widgets/due_badge.dart';

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final assignmentsAsync = ref.watch(assignmentsProvider);
    final list = ref.watch(filteredAssignmentsProvider);
    final counts = ref.watch(assignmentCountsProvider);
    final filter = ref.watch(assignmentFilterProvider);
    final subjectMap = ref.watch(subjectMapProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: assignmentsAsync.when(
        data: (all) {
          if (all.isEmpty) {
            return const _EmptyState(
              title: 'No assignments yet',
              message: 'Add your first one and deadlines start tracking.',
            );
          }

          return Column(
            children: [
              // ---------- Progress ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.sm,
                  AppSpacing.screenH,
                  0,
                ),
                child: Card(
                  color: BrandColors.navy,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${counts.done} of ${counts.total} submitted',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${counts.total - counts.done} open',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: counts.total == 0
                                ? 0
                                : counts.done / counts.total,
                            minHeight: 6,
                            color: BrandColors.orange,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ---------- Filter chips ----------
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: AssignmentFilter.values.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final value = AssignmentFilter.values[index];
                    final isSelected = filter == value;
                    return ChoiceChip(
                      selectedColor: BrandColors.orange,
                      backgroundColor: BrandColors.fieldFill,
                      side: BorderSide(
                        color: isSelected
                            ? BrandColors.orange
                            : BrandColors.navy.withValues(alpha: 0.15),
                      ),
                      label: Text(
                        _filterLabel(value),
                        style: TextStyle(
                          color: isSelected ? Colors.white : BrandColors.navy,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        ref
                            .read(assignmentFilterProvider.notifier)
                            .state = value;
                      },
                    );
                  },
                ),
              ),

              // ---------- List ----------
              Expanded(
                child: list.isEmpty
                    ? const _EmptyState(
                  title: 'Nothing here',
                  message: 'No assignments match this filter.',
                )
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    0,
                    AppSpacing.screenH,
                    96,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final assignment = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.cardGap,
                      ),
                      child: _AssignmentCard(
                        assignment: assignment,
                        subject: subjectMap[assignment.subjectId],
                        now: now,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load your assignments.'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddAssignmentScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add assignment'),
      ),
    );
  }

  String _filterLabel(AssignmentFilter filter) {
    switch (filter) {
      case AssignmentFilter.all:
        return 'All';
      case AssignmentFilter.overdue:
        return 'Overdue';
      case AssignmentFilter.high:
        return 'High';
      case AssignmentFilter.medium:
        return 'Medium';
      case AssignmentFilter.low:
        return 'Low';
      case AssignmentFilter.done:
        return 'Done';
    }
  }
}

// ---------------------------------------------------------------

class _AssignmentCard extends ConsumerWidget {
  const _AssignmentCard({
    required this.assignment,
    required this.subject,
    required this.now,
  });

  final Assignment assignment;
  final Subject? subject;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final priorityColor = switch (assignment.priority) {
      Priority.high => scheme.error,
      Priority.medium => const Color(0xFF8A5300),
      Priority.low => scheme.outline,
    };

    return Opacity(
      opacity: assignment.done ? 0.55 : 1,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => ref
              .read(assignmentRepositoryProvider)
              .toggleDone(assignment.id, !assignment.done),
          onLongPress: () => _confirmDelete(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: assignment.done
                        ? BrandColors.orange
                        : Colors.transparent,
                    border: assignment.done
                        ? null
                        : Border.all(color: scheme.outline, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: assignment.done
                      ? Icon(
                    Icons.check,
                    size: 14,
                    color: scheme.onPrimary,
                  )
                      : null,
                ),

                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          decoration: assignment.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (subject != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: Color(subject!.colorValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  subject!.code,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          if (!assignment.done)
                            DueBadge(dueAt: assignment.dueAt, now: now),
                          if (!assignment.done)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: scheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.chip,
                                ),
                              ),
                              child: Text(
                                _priorityLabel(assignment.priority),
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: priorityColor,
                                  letterSpacing: 0.2,
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

  String _priorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete assignment?'),
        content: Text('"${assignment.title}" will be removed.'),
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
          .read(assignmentRepositoryProvider)
          .deleteAssignment(assignment.id);
    }
  }
}

// ---------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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