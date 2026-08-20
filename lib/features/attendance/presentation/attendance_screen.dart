import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import 'attendance_providers.dart';
import 'mark_attendance_sheet.dart';
import 'widgets/threshold_bar.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String? _openSubjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final list = ref.watch(subjectAttendanceProvider);
    final overall = ref.watch(overallAttendanceProvider);
    final unmarked = ref.watch(unmarkedTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
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
                '75% required',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      body: list.isEmpty
          ? _empty(theme, scheme)
          : ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          96,
        ),
        children: [
          // ---------- Overall ----------
          Card(
            color: scheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${(overall.percent * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'overall · ${overall.attended} of '
                              '${overall.held} classes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ThresholdBar(
                    value: overall.percent,
                    color: scheme.primary,
                    threshold: 0.75,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The marker shows the 75% requirement.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (unmarked.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.cardGap),
            Card(
              color: scheme.primaryContainer,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: _openSheet,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Row(
                    children: [
                      Icon(
                        Icons.how_to_reg_outlined,
                        color: scheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          '${unmarked.length} class'
                              '${unmarked.length == 1 ? '' : 'es'} '
                              'not marked today',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: scheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.section),
          Text(
            'BY SUBJECT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...list.map((item) {
            final isOpen = _openSubjectId == item.subject.id;

            final Color statusColor;
            final String statusLabel;
            final String verdict;
            final Color statusBg;
            final Color statusFg;

            if (item.recoveryNeeded > 0) {
              statusColor = scheme.error;
              statusBg = scheme.errorContainer;
              statusFg = scheme.onErrorContainer;
              statusLabel = 'Below 75%';
              verdict =
              'Attend ${item.recoveryNeeded} in a row to recover';
            } else if (item.safeSkips == 0) {
              statusColor = const Color(0xFF8A5300);
              statusBg = const Color(0xFFFFDDB3);
              statusFg = const Color(0xFF2B1700);
              statusLabel = 'Cutting it close';
              verdict = 'No classes left to spare';
            } else {
              statusColor = const Color(0xFF256B48);
              statusBg = const Color(0xFFB4F1CD);
              statusFg = const Color(0xFF00210F);
              statusLabel = 'Safe';
              verdict = '${item.safeSkips} class'
                  '${item.safeSkips == 1 ? '' : 'es'} '
                  'can still be missed';
            }

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.cardGap,
              ),
              child: Card(
                child: InkWell(
                  borderRadius:
                  BorderRadius.circular(AppRadius.card),
                  onTap: () => setState(() {
                    _openSubjectId =
                    isOpen ? null : item.subject.id;
                  }),
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
                              height: 36,
                              decoration: BoxDecoration(
                                color:
                                Color(item.subject.colorValue),
                                borderRadius:
                                BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.subject.name,
                                    style:
                                    theme.textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.subject.code} · '
                                        '${item.attended}/${item.held} '
                                        'attended',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color:
                                      scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(item.percent * 100).round()}%',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),
                        ThresholdBar(
                          value: item.percent,
                          color: statusColor,
                          threshold: 0.75,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius:
                                BorderRadius.circular(
                                  AppRadius.chip,
                                ),
                              ),
                              child: Text(
                                statusLabel,
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: statusFg,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                verdict,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ---------- Expanded detail ----------
                        AnimatedSize(
                          duration:
                          const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: isOpen
                              ? Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: AppSpacing.md,
                              ),
                              Divider(
                                color: scheme.outlineVariant,
                                height: 1,
                              ),
                              const SizedBox(
                                height: AppSpacing.md,
                              ),
                              _detailRow(theme, scheme,
                                  'Classes held', '${item.held}'),
                              _detailRow(theme, scheme,
                                  'Attended', '${item.attended}'),
                              _detailRow(
                                theme,
                                scheme,
                                'Missed',
                                '${item.missed}',
                                valueColor: scheme.error,
                              ),
                              const SizedBox(
                                height: AppSpacing.md,
                              ),
                              if (item.marks.isNotEmpty) ...[
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children:
                                  item.marks.map((present) {
                                    return Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: present
                                            ? Color(item.subject
                                            .colorValue)
                                            .withValues(
                                            alpha: 0.8)
                                            : Colors.transparent,
                                        border: present
                                            ? null
                                            : Border.all(
                                          color: scheme
                                              .error,
                                          width: 1.5,
                                        ),
                                        borderRadius:
                                        BorderRadius
                                            .circular(4),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(
                                  height: AppSpacing.sm,
                                ),
                                Text(
                                  'Filled squares are classes '
                                      'attended, outlined squares '
                                      'are missed.',
                                  style: theme
                                      .textTheme.bodySmall
                                      ?.copyWith(
                                    color: scheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          )
                              : const SizedBox(
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSheet,
        icon: const Icon(Icons.how_to_reg_outlined),
        label: const Text('Mark today'),
      ),
    );
  }

  void _openSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const MarkAttendanceSheet(),
    );
  }

  Widget _detailRow(
      ThemeData theme,
      ColorScheme scheme,
      String label,
      String value, {
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _empty(ThemeData theme, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No subjects yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add subjects in Timetable and attendance starts tracking.',
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