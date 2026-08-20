import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/class_slot.dart';
import 'timetable_providers.dart';

const _dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class AddClassScreen extends ConsumerStatefulWidget {
  const AddClassScreen({super.key});

  @override
  ConsumerState<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends ConsumerState<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();

  String? _subjectId;
  int _weekday = DateTime.monday;
  SlotKind _kind = SlotKind.lecture;
  TimeOfDay _start = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _end = const TimeOfDay(hour: 9, minute: 50);

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _start = picked;
        // Keep the end time after the start time.
        if (_toMinutes(_end) <= _toMinutes(picked)) {
          _end = TimeOfDay(
            hour: (picked.hour + 1) % 24,
            minute: picked.minute,
          );
        }
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_subjectId == null) {
      setState(() => _error = 'Choose a subject first.');
      return;
    }
    if (_toMinutes(_end) <= _toMinutes(_start)) {
      setState(() => _error = 'End time must be after the start time.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(timetableRepositoryProvider).addClassSlot(
        ClassSlot(
          id: '',
          subjectId: _subjectId!,
          weekday: _weekday,
          startMinutes: _toMinutes(_start),
          endMinutes: _toMinutes(_end),
          room: _roomController.text,
          kind: _kind,
        ),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subjects = ref.watch(subjectsProvider).value ?? [];

    // If the chosen subject was deleted elsewhere, clear the selection.
    if (_subjectId != null &&
        !subjects.any((subject) => subject.id == _subjectId)) {
      _subjectId = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add class')),
      body: subjects.isEmpty
          ? const _NoSubjects()
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenH),
          children: [
            // ---------- Subject ----------
            DropdownButtonFormField<String>(
              value: _subjectId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject.id,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(subject.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${subject.code} — ${subject.name}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _subjectId = value),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---------- Day ----------
            DropdownButtonFormField<int>(
              value: _weekday,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(),
              ),
              items: List.generate(6, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_dayNames[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) setState(() => _weekday = value);
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---------- Times ----------
            Row(
              children: [
                Expanded(
                  child: _TimeButton(
                    label: 'Starts',
                    time: _start,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TimeButton(
                    label: 'Ends',
                    time: _end,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---------- Room ----------
            TextFormField(
              controller: _roomController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Room',
                hintText: 'CS-204',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Enter the room';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---------- Kind ----------
            SegmentedButton<SlotKind>(
              segments: const [
                ButtonSegment(
                  value: SlotKind.lecture,
                  label: Text('Lecture'),
                ),
                ButtonSegment(
                  value: SlotKind.lab,
                  label: Text('Lab'),
                ),
                ButtonSegment(
                  value: SlotKind.tutorial,
                  label: Text('Tutorial'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) =>
                  setState(() => _kind = selection.first),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius:
                  BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: scheme.onErrorContainer,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Save class'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              time.format(context),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------

class _NoSubjects extends StatelessWidget {
  const _NoSubjects();

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
            Icon(
              Icons.menu_book_outlined,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No subjects yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add a subject first, then schedule its classes.',
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