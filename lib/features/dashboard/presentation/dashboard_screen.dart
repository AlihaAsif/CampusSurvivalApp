import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/time/ticker_provider.dart';
import '../../announcements/presentation/announcement_providers.dart';
import '../../announcements/presentation/announcements_screen.dart';
import '../../assignments/presentation/assignment_providers.dart';
import '../../assignments/presentation/assignments_screen.dart';
import '../../assignments/presentation/widgets/due_badge.dart';
import '../../attendance/presentation/attendance_providers.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../expenses/domain/budget_math.dart';
import '../../expenses/presentation/expense_providers.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../lost_found/presentation/lost_found_screen.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../study/presentation/study_screen.dart';
import '../../timetable/domain/next_class.dart';
import '../../timetable/presentation/timetable_providers.dart';
import '../../timetable/presentation/timetable_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final profile = ref.watch(profileProvider).value;
    final unread = ref.watch(unreadCountProvider);

    final firstName = (profile?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.screenH,
        toolbarHeight: 68,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $firstName',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
            Text(
              '${profile?.rollNumber ?? ''} · '
                  'Semester ${profile?.semester ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Announcements',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementsScreen(),
                  ),
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSpacing.xxl,
        ),
        children: const [
          _NextClassCard(),
          SizedBox(height: AppSpacing.lg),
          _ShortcutGrid(),
          _TodaysClasses(),
          _UpcomingDeadlines(),
          _AtAGlance(),
        ],
      ),
    );
  }
}

// ===============================================================
// Next class
// ===============================================================

class _NextClassCard extends ConsumerWidget {
  const _NextClassCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final next = ref.watch(nextClassProvider);
    final subjectMap = ref.watch(subjectMapProvider);
    final now = ref.watch(nowProvider);

    if (next == null) {
      return Card(
        color: scheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text('No classes scheduled', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Add your timetable and this card fills in.',
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

    final subject = subjectMap[next.slot.subjectId];
    if (subject == null) return const SizedBox.shrink();

    final gap = next.isLive
        ? next.end.difference(now)
        : next.start.difference(now);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BrandColors.navy, BrandColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: BrandColors.orange.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.navy.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: next.isLive
                        ? const Color(0xFFB4F1CD)
                        : BrandColors.orange.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        next.isLive ? Icons.sensors_rounded : Icons.schedule,
                        size: 13,
                        color: next.isLive ? const Color(0xFF00210F) : Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        next.isLive ? 'IN CLASS NOW' : 'NEXT CLASS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: next.isLive ? const Color(0xFF00210F) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              subject.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${next.slot.timeRange} · ${next.slot.room} · '
                  '${next.slot.kind.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  next.isLive
                      ? 'Ends ${NextClass.gapText(gap)}'
                      : 'Starts ${NextClass.gapText(gap)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TimetableScreen(),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Full timetable'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// Shortcut grid
// ===============================================================

class _ShortcutGrid extends ConsumerWidget {
  const _ShortcutGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final unread = ref.watch(unreadCountProvider);

    final shortcuts = [
      (
      label: 'Attendance',
      icon: Icons.pie_chart_outline,
      background: scheme.primaryContainer,
      foreground: scheme.onPrimaryContainer,
      badge: 0,
      screen: const AttendanceScreen(),
      ),
      (
      label: 'Study plan',
      icon: Icons.menu_book_outlined,
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
      badge: 0,
      screen: const StudyScreen(),
      ),
      (
      label: 'Notices',
      icon: Icons.campaign_outlined,
      background: scheme.tertiaryContainer,
      foreground: scheme.onTertiaryContainer,
      badge: unread,
      screen: const AnnouncementsScreen(),
      ),
      (
      label: 'Lost & found',
      icon: Icons.search_outlined,
      background: scheme.secondaryContainer,
      foreground: scheme.onSecondaryContainer,
      badge: 0,
      screen: const LostFoundScreen(),
      ),
    ];

    return Row(
      children: shortcuts.map((item) {
        return Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => item.screen),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: item.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          size: 21,
                          color: item.foreground,
                        ),
                      ),
                      if (item.badge > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 17,
                              minHeight: 17,
                            ),
                            padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: Text(
                                '${item.badge}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onError,
                                  fontSize: 10,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ===============================================================
// Today's classes
// ===============================================================

class _TodaysClasses extends ConsumerWidget {
  const _TodaysClasses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final classes = ref.watch(todaysClassesProvider);
    final subjectMap = ref.watch(subjectMapProvider);
    final now = ref.watch(nowProvider);
    final minutesNow = now.hour * 60 + now.minute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Today's classes",
          actionLabel: classes.isEmpty ? null : 'See all',
          onAction: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TimetableScreen()),
          ),
        ),
        if (classes.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    'No classes today',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Good day to clear that overdue report.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...classes.map((slot) {
            final subject = subjectMap[slot.subjectId];
            if (subject == null) return const SizedBox.shrink();

            final isDone = minutesNow >= slot.endMinutes;
            final isLive = minutesNow >= slot.startMinutes &&
                minutesNow < slot.endMinutes;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
              child: Opacity(
                opacity: isDone ? 0.5 : 1,
                child: Card(
                  color: isLive ? scheme.surfaceContainerHigh : null,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPad),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 34,
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
                                '${slot.timeRange} · ${slot.room}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB4F1CD),
                              borderRadius:
                              BorderRadius.circular(AppRadius.chip),
                            ),
                            child: Text(
                              'Now',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF00210F),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        if (isDone)
                          const Icon(
                            Icons.check,
                            size: 17,
                            color: Color(0xFF256B48),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ===============================================================
// Upcoming deadlines
// ===============================================================

class _UpcomingDeadlines extends ConsumerWidget {
  const _UpcomingDeadlines();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final deadlines = ref.watch(upcomingDeadlinesProvider);
    final subjectMap = ref.watch(subjectMapProvider);
    final now = ref.watch(nowProvider);

    if (deadlines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Upcoming deadlines',
          actionLabel: 'See all',
          onAction: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
          ),
        ),
        ...deadlines.map((assignment) {
          final subject = subjectMap[assignment.subjectId];

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AssignmentsScreen(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: subject == null
                              ? scheme.outline
                              : Color(subject.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignment.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subject?.code ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      DueBadge(dueAt: assignment.dueAt, now: now),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ===============================================================
// At a glance
// ===============================================================

class _AtAGlance extends ConsumerWidget {
  const _AtAGlance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final overall = ref.watch(overallAttendanceProvider);
    final subjectList = ref.watch(subjectAttendanceProvider);
    final total = ref.watch(monthTotalProvider);
    final budget = ref.watch(monthlyBudgetProvider).value ?? 25000;
    final allowance = ref.watch(dailyAllowanceProvider);

    final risky =
    subjectList.where((item) => item.recoveryNeeded > 0).toList();
    final left = budget - total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'At a glance'),

        // ---------- Attendance ----------
        if (overall.held > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AttendanceScreen(),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pie_chart_outline,
                              size: 20,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attendance '
                                      '${(overall.percent * 100).toStringAsFixed(1)}%',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  risky.isEmpty
                                      ? 'All subjects above 75%'
                                      : '${risky.length} subject'
                                      '${risky.length == 1 ? '' : 's'} '
                                      'below the 75% line',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      if (risky.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Attend the next '
                                '${risky.first.recoveryNeeded} '
                                '${risky.first.subject.name} classes in a row '
                                'to recover.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onErrorContainer,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ---------- Budget ----------
        if (total > 0)
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExpensesScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPad),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 20,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${BudgetMath.formatPkr(total)} spent',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                left >= 0
                                    ? '${BudgetMath.formatPkr(left)} left · '
                                    '${BudgetMath.formatPkr(allowance)} '
                                    'a day'
                                    : '${BudgetMath.formatPkr(-left)} over '
                                    'budget',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: (total / budget).clamp(0.0, 1.0),
                        minHeight: 6,
                        color: left < 0
                            ? scheme.error
                            : scheme.secondary,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ===============================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.section,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: BrandColors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}