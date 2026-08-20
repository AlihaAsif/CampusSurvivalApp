import 'package:flutter/material.dart' show DateUtils;

enum Priority { high, medium, low }

class Assignment {
  final String id;
  final String subjectId;
  final String title;
  final DateTime dueAt;
  final Priority priority;
  final bool done;
  final String? notes;

  const Assignment({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.dueAt,
    this.priority = Priority.medium,
    this.done = false,
    this.notes,
  });


  static int daysUntil(DateTime due, DateTime now) {
    return DateUtils.dateOnly(due)
        .difference(DateUtils.dateOnly(now))
        .inDays;
  }

  int daysLeft(DateTime now) => daysUntil(dueAt, now);

  bool isOverdue(DateTime now) => !done && daysLeft(now) < 0;
}