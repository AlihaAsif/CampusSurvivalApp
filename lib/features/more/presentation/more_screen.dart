import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/placeholder_screen.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _open(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlaceholderScreen(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(profileProvider).value;

    final features = [
      _Feature(
        title: 'Attendance',
        subtitle: 'See how many classes you can still miss',
        icon: Icons.pie_chart_outline,
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      _Feature(
        title: 'Study Planner',
        subtitle: 'Weekly hours and planned sessions',
        icon: Icons.menu_book_outlined,
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      _Feature(
        title: 'Announcements',
        subtitle: 'All campus notices in one place',
        icon: Icons.campaign_outlined,
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      ),
      _Feature(
        title: 'Lost & Found',
        subtitle: 'Report or claim items around campus',
        icon: Icons.search_outlined,
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
      ),
      _Feature(
        title: 'Campus Map',
        subtitle: 'Find buildings and get directions',
        icon: Icons.map_outlined,
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      _Feature(
        title: 'AI Assistant',
        subtitle: 'Ask anything about campus',
        icon: Icons.auto_awesome_outlined,
        background: scheme.tertiaryContainer,
        foreground: scheme.onTertiaryContainer,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        children: [

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary,
                    child: Text(
                      (profile?.name ?? '?').characters.first.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? '',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile?.rollNumber ?? ''} · '
                              'Semester ${profile?.semester ?? ''} · '
                              'Section ${profile?.section ?? ''}',
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

          const SizedBox(height: AppSpacing.section),

          Text(
            'FEATURES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...features.map(
                (feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
              child: _FeatureTile(
                feature: feature,
                onTap: () => _open(context, feature.title),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.section),

          Text(
            'ACCOUNT',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text(
                'Sign out',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.error,
                ),
              ),
              onTap: () => ref.read(authRepositoryProvider).signOut(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _Feature {
  const _Feature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color background;
  final Color foreground;
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.onTap});

  final _Feature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: feature.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature.icon,
                  size: 20,
                  color: feature.foreground,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.subtitle,
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
        ),
      ),
    );
  }
}