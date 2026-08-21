import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/lost_item.dart';
import 'lost_found_providers.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final uid = ref.watch(authStateProvider).value?.uid;
    final isMine = uid != null && uid == item.postedByUid;
    final isFound = item.kind == LostKind.found;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFound ? 'Found item' : 'Lost item'),
        actions: [
          if (isMine)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete post?'),
                    content: const Text('This cannot be undone.'),
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

                if (confirmed == true && context.mounted) {
                  await ref
                      .read(lostFoundRepositoryProvider)
                      .deleteItem(item.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        children: [
          if (item.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Image.network(
                item.imageUrl!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 240,
                  color: scheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isFound
                      ? const Color(0xFFB4F1CD)
                      : scheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  isFound ? 'Found' : 'Lost',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.2,
                    color: isFound
                        ? const Color(0xFF00210F)
                        : scheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                item.category.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(item.title, style: theme.textTheme.headlineSmall),

          const SizedBox(height: AppSpacing.lg),

          _row(theme, scheme, Icons.place_outlined, item.location),
          _row(theme, scheme, Icons.schedule, item.relativeTime),
          _row(theme, scheme, Icons.person_outline, item.postedByName),

          if (item.contactNote != null &&
              item.contactNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              color: scheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOW TO REACH',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SelectableText(
                      item.contactNote!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (isMine) ...[
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 52,
              child: FilledButton.tonal(
                onPressed: () async {
                  await ref
                      .read(lostFoundRepositoryProvider)
                      .markResolved(item.id, !item.resolved);
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: Text(
                  item.resolved
                      ? 'Mark as still open'
                      : 'Mark as resolved',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
      ThemeData theme,
      ColorScheme scheme,
      IconData icon,
      String text,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}