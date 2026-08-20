import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/assignment.dart';

class DueBadge extends StatelessWidget {
  const DueBadge({super.key, required this.dueAt, required this.now});

  final DateTime dueAt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final days = Assignment.daysUntil(dueAt, now);

    late final String label;
    late final Color background;
    late final Color foreground;

    if (days < 0) {
      final n = -days;
      label = n == 1 ? '1 day overdue' : '$n days overdue';
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else if (days == 0) {
      label = 'Due today';
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
    } else if (days == 1) {
      label = 'Due tomorrow';
      background = const Color(0xFFFFDDB3);
      foreground = const Color(0xFF2B1700);
    } else {
      label = '$days days left';
      background = scheme.surfaceContainerHigh;
      foreground = scheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}