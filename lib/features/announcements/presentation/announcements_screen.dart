import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/announcement.dart';
import 'announcement_providers.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState
    extends ConsumerState<AnnouncementsScreen> {
  String? _openId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final async = ref.watch(announcementsProvider);
    final list = ref.watch(filteredAnnouncementsProvider);
    final read = ref.watch(readIdsProvider).value ?? <String>{};
    final filter = ref.watch(announcementFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: BrandColors.orange),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              'Could not load announcements.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        data: (_) {
          return Column(
            children: [
              // ---------- Filter chips ----------
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: AnnouncementFilter.values.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final value = AnnouncementFilter.values[index];
                    final isSelected = filter == value;
                    return ChoiceChip(
                      label: Text(
                        _label(value),
                        style: TextStyle(
                          color: isSelected ? Colors.white : BrandColors.navy,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: BrandColors.orange,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? BrandColors.orange
                            : BrandColors.orange.withValues(alpha: 0.3),
                      ),
                      onSelected: (_) {
                        ref
                            .read(announcementFilterProvider.notifier)
                            .state = value;
                      },
                    );
                  },
                ),
              ),

              Expanded(
                child: list.isEmpty
                    ? _empty(theme, scheme, filter)
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.xs,
                    AppSpacing.screenH,
                    AppSpacing.xxl,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.cardGap,
                      ),
                      child: _AnnouncementCard(
                        announcement: item,
                        isUnread: !read.contains(item.id),
                        isOpen: _openId == item.id,
                        onTap: () {
                          setState(() {
                            _openId =
                            _openId == item.id ? null : item.id;
                          });
                          if (!read.contains(item.id)) {
                            ref
                                .read(announcementRepositoryProvider)
                                .markRead(item.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _label(AnnouncementFilter filter) {
    return switch (filter) {
      AnnouncementFilter.all => 'All',
      AnnouncementFilter.unread => 'Unread',
      AnnouncementFilter.pinned => 'Pinned',
    };
  }

  Widget _empty(
      ThemeData theme,
      ColorScheme scheme,
      AnnouncementFilter filter,
      ) {
    final (title, message) = switch (filter) {
      AnnouncementFilter.unread => (
      'All caught up',
      'Nothing unread right now.'
      ),
      AnnouncementFilter.pinned => (
      'Nothing pinned',
      'Important notices will show up here.'
      ),
      AnnouncementFilter.all => (
      'No announcements',
      'Campus notices will appear here.'
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: BrandColors.orange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.campaign_outlined,
                size: 40,
                color: BrandColors.orange,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: BrandColors.navy,
              ),
            ),
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

// ---------------------------------------------------------------

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.isUnread,
    required this.isOpen,
    required this.onTap,
  });

  final Announcement announcement;
  final bool isUnread;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(
          color: announcement.pinned
              ? BrandColors.orange.withValues(alpha: 0.5)
              : BrandColors.orange.withValues(alpha: 0.2),
          width: announcement.pinned ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: announcement.pinned
                      ? BrandColors.orange.withValues(alpha: 0.15)
                      : BrandColors.navy.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  announcement.pinned
                      ? Icons.push_pin_rounded
                      : Icons.campaign_outlined,
                  size: 19,
                  color: announcement.pinned
                      ? BrandColors.orange
                      : BrandColors.navy,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            announcement.source,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: BrandColors.navy,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: BrandColors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          announcement.relativeTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      announcement.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight:
                            isUnread ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),

                    if (announcement.body.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: isOpen
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: announcement.paragraphs
                                    .map(
                                      (paragraph) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacing.sm,
                                        ),
                                        child: Text(
                                          paragraph,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.55,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              )
                            : Text(
                                announcement.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}