import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../study/presentation/study_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../attendance/presentation/attendance_screen.dart';
import '../../../core/navigation/placeholder_screen.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../announcements/presentation/announcement_providers.dart';
import '../../announcements/presentation/announcements_screen.dart';
import '../../lost_found/presentation/lost_found_screen.dart';
import '../../map/presentation/campus_map_screen.dart';
import '../../assistant/presentation/assistant_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  void _open(BuildContext context, String title) {
    final Widget screen = switch (title) {
      'Attendance' => const AttendanceScreen(),
      'Study Planner' => const StudyScreen(),
      'Announcements' => const AnnouncementsScreen(),
      'Lost & Found' => const LostFoundScreen(),
      'Campus Map' => const CampusMapScreen(),
      'AI Assistant' => const AssistantScreen(),
      _ => PlaceholderScreen(title: title),
    };

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(profileProvider).value;
    final unread = ref.watch(unreadCountProvider);

    final features = [
      _Feature(
        title: 'Attendance',
        subtitle: 'See how many classes you can still miss',
        icon: Icons.pie_chart_outline,
        background: BrandColors.orange.withValues(alpha: 0.15),
        foreground: BrandColors.orange,
      ),
      _Feature(
        title: 'Study Planner',
        subtitle: 'Weekly hours and planned sessions',
        icon: Icons.menu_book_outlined,
        background: BrandColors.navy.withValues(alpha: 0.12),
        foreground: BrandColors.navy,
      ),
      _Feature(
        title: 'Announcements',
        subtitle: unread > 0
            ? '$unread unread notice${unread == 1 ? '' : 's'}'
            : 'All campus notices in one place',
        icon: Icons.campaign_outlined,
        background: BrandColors.orange.withValues(alpha: 0.15),
        foreground: BrandColors.orange,
      ),
      _Feature(
        title: 'Lost & Found',
        subtitle: 'Report or claim items around campus',
        icon: Icons.search_outlined,
        background: BrandColors.orange.withValues(alpha: 0.15),
        foreground: BrandColors.orange,
      ),
      _Feature(
        title: 'Campus Map',
        subtitle: 'Find buildings and get directions',
        icon: Icons.map_outlined,
        background: BrandColors.navy.withValues(alpha: 0.12),
        foreground: BrandColors.navy,
      ),
      _Feature(
        title: 'AI Assistant',
        subtitle: 'Ask anything about campus',
        icon: Icons.auto_awesome_outlined,
        background: BrandColors.blue.withValues(alpha: 0.12),
        foreground: BrandColors.blue,
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

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BrandColors.navy, BrandColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: BrandColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: BrandColors.navy,
                      child: Text(
                        (profile?.name ?? '?').characters.first.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${profile?.rollNumber ?? ''} · '
                              'Semester ${profile?.semester ?? ''} · '
                              'Section ${profile?.section ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
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
                'FEATURES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
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
                'ACCOUNT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
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