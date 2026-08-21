import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/lost_item.dart';
import 'item_detail_screen.dart';
import 'lost_found_providers.dart';
import 'post_item_screen.dart';

class LostFoundScreen extends ConsumerWidget {
  const LostFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final async = ref.watch(lostItemsProvider);
    final list = ref.watch(filteredLostItemsProvider);
    final filter = ref.watch(lostFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lost & found')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
        const Center(child: Text('Could not load items.')),
        data: (_) {
          return Column(
            children: [
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: LostFilter.values.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final value = LostFilter.values[index];
                    return ChoiceChip(
                      label: Text(switch (value) {
                        LostFilter.all => 'All',
                        LostFilter.lost => 'Lost',
                        LostFilter.found => 'Found',
                      }),
                      selected: filter == value,
                      onSelected: (_) {
                        ref.read(lostFilterProvider.notifier).state = value;
                      },
                    );
                  },
                ),
              ),

              Expanded(
                child: list.isEmpty
                    ? _empty(theme, scheme)
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    0,
                    AppSpacing.screenH,
                    96,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.cardGap,
                    mainAxisSpacing: AppSpacing.cardGap,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _ItemCard(item: list[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PostItemScreen()),
        ),
        icon: const Icon(Icons.photo_camera_outlined),
        label: const Text('Post an item'),
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
              Icons.search_outlined,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Nothing reported', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Be the first to post a lost or found item.',
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

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFound = item.kind == LostKind.found;

    return Opacity(
      opacity: item.resolved ? 0.55 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ItemDetailScreen(item: item),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Image ----------
              SizedBox(
                height: 100,
                width: double.infinity,
                child: item.imageUrl != null
                    ? Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: scheme.surfaceContainerHigh,
                      child: const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stack) =>
                      _placeholder(),
                )
                    : _placeholder(),
              ),

              // ---------- Body ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.resolved
                            ? scheme.surfaceContainerHigh
                            : isFound
                            ? const Color(0xFFB4F1CD)
                            : scheme.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        item.resolved
                            ? 'Resolved'
                            : isFound
                            ? 'Found'
                            : 'Lost',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.2,
                          color: item.resolved
                              ? scheme.onSurfaceVariant
                              : isFound
                              ? const Color(0xFF00210F)
                              : scheme.onErrorContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Divider(color: scheme.outlineVariant, height: 1),
                    const SizedBox(height: 6),
                    Text(
                      '${item.postedByName} · ${item.relativeTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
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
    );
  }

 
  Widget _placeholder() {
    final color = Color(item.category.colorValue);

    return Container(
      color: color.withValues(alpha: 0.13),
      child: Center(
        child: Icon(
          switch (item.category) {
            ItemCategory.electronics => Icons.calculate_outlined,
            ItemCategory.bag => Icons.backpack_outlined,
            ItemCategory.card => Icons.badge_outlined,
            ItemCategory.keys => Icons.vpn_key_outlined,
            ItemCategory.bottle => Icons.water_drop_outlined,
            ItemCategory.book => Icons.menu_book_outlined,
            ItemCategory.other => Icons.category_outlined,
          },
          size: 30,
          color: color,
        ),
      ),
    );
  }
}