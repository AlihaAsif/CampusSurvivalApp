import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/class_slot.dart';
import '../domain/parsed_slot.dart';
import 'import_controller.dart';
import 'timetable_providers.dart';

const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class ImportTimetableScreen extends ConsumerWidget {
  const ImportTimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Import timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(importControllerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: switch (state.stage) {
        ImportStage.idle => const _IdleView(),
        ImportStage.pickSection => const _SectionPicker(),
        ImportStage.review => const _ReviewView(),
        ImportStage.error => const _ErrorView(),
        _ => const _ParsingView(),
      },
    );
  }
}

// ===============================================================
// Idle — pick a file or take a photo
// ===============================================================

class _IdleView extends ConsumerWidget {
  const _IdleView();

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final lower = path.toLowerCase();

    final isSupported = lower.endsWith('.pdf') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');

    if (!isSupported) return;

    await ref.read(importControllerProvider.notifier).importFile(
          File(path),
          result.files.single.name,
        );
  }

  Future<void> _takePhoto(WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (picked == null) return;

    await ref.read(importControllerProvider.notifier).importFile(
      File(picked.path),
      'Camera photo',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xxl,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: BrandColors.orange.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: BrandColors.navy.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: BrandColors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  size: 28,
                  color: BrandColors.orange,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Import your timetable',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BrandColors.navy,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Upload the PDF or a photo of the department timetable. '
                    'Campus Survival reads it and builds your week.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => _pickFile(ref),
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text('Choose file'),
                        style: FilledButton.styleFrom(
                          backgroundColor: BrandColors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _takePhoto(ref),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Take photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BrandColors.navy,
                          side: const BorderSide(
                            color: BrandColors.navy,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(
              color: BrandColors.orange.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 8),
                    Text(
                      'FOR BEST RESULTS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: BrandColors.navy,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...[
                  'Photograph one section at a time, not the whole sheet.',
                  'Keep the page flat and well lit.',
                  'Make sure the day names and times are readable.',
                ].map(
                      (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '· ',
                          style: TextStyle(
                            color: BrandColors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            tip,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// Parsing — four step checklist
// ===============================================================

class _ParsingView extends ConsumerWidget {
  const _ParsingView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(importControllerProvider);

    const steps = [
      (ImportStage.reading, 'Reading the file'),
      (ImportStage.finding, 'Finding the timetable grid'),
      (ImportStage.matching, 'Matching subject codes'),
      (ImportStage.building, 'Building your week'),
    ];

    final currentIndex = steps.indexWhere((step) => step.$1 == state.stage);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 19,
                    color: scheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    state.fileName ?? 'File',
                    style: theme.textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.cardGap),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPad),
            child: Column(
              children: List.generate(steps.length, (index) {
                final isDone = index < currentIndex;
                final isActive = index == currentIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Opacity(
                    opacity: index > currentIndex ? 0.4 : 1,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                          height: 15,
                          child: isDone
                              ? const Icon(
                            Icons.check,
                            size: 15,
                            color: Color(0xFF256B48),
                          )
                              : isActive
                              ? const CircularProgressIndicator(
                            strokeWidth: 2,
                          )
                              : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.outlineVariant,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          steps[index].$2,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// Error
// ===============================================================

class _ErrorView extends ConsumerWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(importControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: scheme.onErrorContainer),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      state.errorMessage ?? 'Something went wrong.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onErrorContainer,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Add manually'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () =>
                        ref.read(importControllerProvider.notifier).reset(),
                    child: const Text('Try again'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// Section picker — the sheet holds every section
// ===============================================================

class _SectionPicker extends ConsumerWidget {
  const _SectionPicker();

  /// FA23-BSE-092 plus section "B" gives FA23-BSE-B.
  static String? _guessSection(
      String? rollNumber,
      String? section,
      List<String> available,
      ) {
    if (rollNumber == null || section == null) return null;

    final parts = rollNumber.split('-');
    if (parts.length < 2) return null;

    final candidate = '${parts[0]}-${parts[1]}-${section.toUpperCase()}';

    return available.contains(candidate) ? candidate : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(importControllerProvider);
    final profile = ref.watch(profileProvider).value;

    final guess = _guessSection(
      profile?.rollNumber,
      profile?.section,
      state.sections,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenH),
      children: [
        Text('Which section is yours?', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'This sheet has ${state.sections.length} sections. '
              'Pick yours so only your classes are added.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        ...state.sections.map((section) {
          final count =
              state.allSlots.where((slot) => slot.section == section).length;
          final isGuess = section == guess;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
            child: Card(
              color: isGuess ? scheme.primaryContainer : null,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.card),
                onTap: () => ref
                    .read(importControllerProvider.notifier)
                    .chooseSection(section),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color:
                                isGuess ? scheme.onPrimaryContainer : null,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isGuess
                                  ? '$count classes · looks like yours'
                                  : '$count classes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isGuess
                                    ? scheme.onPrimaryContainer
                                    .withValues(alpha: 0.85)
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: isGuess
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: AppSpacing.md),

        TextButton(
          onPressed: () =>
              ref.read(importControllerProvider.notifier).chooseSection(null),
          child: const Text('Show all sections instead'),
        ),
      ],
    );
  }
}

// ===============================================================
// Review — the student confirms before anything is saved
// ===============================================================

class _ReviewView extends ConsumerStatefulWidget {
  const _ReviewView();

  @override
  ConsumerState<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends ConsumerState<_ReviewView> {
  bool _saving = false;

  Future<void> _save() async {
    final state = ref.read(importControllerProvider);
    final complete = state.slots.where((slot) => slot.isComplete).toList();

    if (complete.isEmpty) return;

    setState(() => _saving = true);

    final repository = ref.read(timetableRepositoryProvider);
    final existing = ref.read(subjectsProvider).value ?? [];

    // Reuse subjects that already exist, create the rest once each.
    final codeToId = <String, String>{
      for (final subject in existing) subject.code: subject.id,
    };

    try {
      for (final slot in complete) {
        final code = slot.subjectCode!;

        var subjectId = codeToId[code];
        if (subjectId == null) {
          subjectId = await repository.addSubject(code: code, name: code);
          codeToId[code] = subjectId;
        }

        await repository.addClassSlot(
          ClassSlot(
            id: '',
            subjectId: subjectId,
            weekday: slot.weekday!,
            startMinutes: slot.startMinutes!,
            endMinutes: slot.endMinutes!,
            room: slot.room ?? 'TBA',
          ),
        );
      }

      if (!mounted) return;

      ref.read(importControllerProvider.notifier).reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${complete.length} classes added. '
              'Rename the subjects from the Subjects screen.'),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _describe(ParsedSlot slot) {
    final parts = <String>[];

    parts.add(
      slot.weekday == null ? 'Day not read' : _dayNames[slot.weekday! - 1],
    );

    if (slot.startMinutes != null && slot.endMinutes != null) {
      parts.add('${ClassSlot.formatTime(slot.startMinutes!)} – '
          '${ClassSlot.formatTime(slot.endMinutes!)}');
    } else {
      parts.add('Time not read');
    }

    parts.add(slot.room ?? 'Room not read');

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(importControllerProvider);

    final slots = state.slots;
    final complete = slots.where((slot) => slot.isComplete).length;
    final allGood = complete == slots.length;

    final days = slots
        .where((slot) => slot.weekday != null)
        .map((slot) => slot.weekday)
        .toSet()
        .length;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenH),
            children: [
              // ---------- Summary banner ----------
              Card(
                color: allGood
                    ? const Color(0xFFB4F1CD)
                    : const Color(0xFFFFDDB3),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Found ${slots.length} classes across '
                            '$days day${days == 1 ? '' : 's'}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: allGood
                              ? const Color(0xFF00210F)
                              : const Color(0xFF2B1700),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        allGood
                            ? 'Everything looks readable. Check it, '
                            'then save.'
                            : '${slots.length - complete} need attention. '
                            'Fix or remove them before saving.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: allGood
                              ? const Color(0xFF00210F)
                              : const Color(0xFF2B1700),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Chosen section ----------
              if (state.chosenSection != null) ...[
                const SizedBox(height: AppSpacing.cardGap),
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () => ref
                        .read(importControllerProvider.notifier)
                        .backToSectionPicker(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.cardPad),
                      child: Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 20,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Section ${state.chosenSection}',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            'Change',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.section),
              Text(
                'DETECTED CLASSES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              ...slots.map((slot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showEditSlotDialog(context, ref, slot),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.cardPad),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          slot.subjectCode ?? 'Subject not read',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            color: slot.subjectCode == null
                                                ? scheme.error
                                                : null,
                                            fontWeight: slot.subjectCode == null
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _describe(slot),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (slot.isComplete)
                              const Icon(
                                Icons.check,
                                size: 18,
                                color: Color(0xFF256B48),
                              )
                            else
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: scheme.error,
                                ),
                                tooltip: 'Remove',
                                onPressed: () => ref
                                    .read(importControllerProvider.notifier)
                                    .removeSlot(slot),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // ---------- Footer ----------
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenH),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => ref
                                    .read(importControllerProvider.notifier)
                                    .reset(),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: (_saving || complete == 0) ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('Save $complete classes'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditSlotDialog(
    BuildContext context,
    WidgetRef ref,
    ParsedSlot slot,
  ) {
    final subjectController =
        TextEditingController(text: slot.subjectCode ?? '');
    final roomController = TextEditingController(text: slot.room ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Class Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Subject Name / Code',
                hintText: 'e.g. CSC312 or Web Engineering',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(
                labelText: 'Room / Lab (optional)',
                hintText: 'e.g. Lab 3 or A-112',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newSub = subjectController.text.trim();
              final newRoom = roomController.text.trim();
              final updated = slot.copyWith(
                subjectCode: newSub.isEmpty ? null : newSub,
                room: newRoom.isEmpty ? null : newRoom,
              );
              ref
                  .read(importControllerProvider.notifier)
                  .updateSlot(slot, updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}