import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/class_slot.dart';
import '../domain/subject.dart';
import 'add_class_screen.dart';
import 'subjects_screen.dart';
import 'timetable_providers.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late int _selectedDay = _todayWeekday();

  /// Sunday has no classes, so start on Monday.
  int _todayWeekday() {
    final today = DateTime.now().weekday;
    return today == DateTime.sunday ? DateTime.monday : today;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final slotsAsync = ref.watch(classSlotsProvider);
    final subjectMap = ref.watch(subjectMapProvider);
    final daySlots = ref.watch(slotsForDayProvider(_selectedDay));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Subjects',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubjectsScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ---------- Day chips ----------
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH,
                vertical: AppSpacing.sm,
              ),
              itemCount: _dayLabels.length,
              separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final weekday = index + 1;
                final isToday = DateTime.now().weekday == weekday;

                return ChoiceChip(
                  selectedColor: BrandColors.orange,
                  backgroundColor: BrandColors.fieldFill,
                  side: BorderSide(
                    color: _selectedDay == weekday
                        ? BrandColors.orange
                        : BrandColors.navy.withValues(alpha: 0.15),
                  ),
                  label: Text(
                    isToday ? '${_dayLabels[index]} ·' : _dayLabels[index],
                    style: TextStyle(
                      color: _selectedDay == weekday
                          ? Colors.white
                          : BrandColors.navy,
                      fontWeight:
                      _selectedDay == weekday ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  selected: _selectedDay == weekday,
                  onSelected: (_) =>
                      setState(() => _selectedDay = weekday),
                );
              },
            ),
          ),


          Expanded(
            child: slotsAsync.when(
              data: (_) {
                if (daySlots.isEmpty) {
                  return _EmptyDay(day: _dayLabels[_selectedDay - 1]);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.sm,
                    AppSpacing.screenH,
                    96,
                  ),
                  itemCount: daySlots.length,
                  itemBuilder: (context, index) {
                    final slot = daySlots[index];
                    final subject = subjectMap[slot.subjectId];
                    if (subject == null) return const SizedBox.shrink();

                    return Padding(
                      padding:
                      const EdgeInsets.only(bottom: AppSpacing.cardGap),
                      child: _SlotCard(slot: slot, subject: subject),
                    );
                  },
                );
              },
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    'Could not load your timetable.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddClassScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
    );
  }
}



class _SlotCard extends ConsumerWidget {
  const _SlotCard({required this.slot, required this.subject});

  final ClassSlot slot;
  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time gutter
        SizedBox(
          width: 50,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ClassSlot.formatTime(slot.startMinutes),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  ClassSlot.formatTime(slot.endMinutes),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onLongPress: () => _confirmDelete(context, ref),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject.name,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${slot.room} · ${slot.kind.name} · '
                                '${subject.code}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this class?'),
        content: Text(
          '${subject.name} on '
              '${_dayLabels[slot.weekday - 1]} at ${slot.timeRange}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(timetableRepositoryProvider)
          .deleteClassSlot(slot.id);
    }
  }
}


class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.day});

  final String day;

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
            Text(
              'Nothing scheduled',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$day has no classes yet.',
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