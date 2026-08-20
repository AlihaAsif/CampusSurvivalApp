import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/profile_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider).value;

    final firstName = (profile?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $firstName',
              style: theme.textTheme.titleLarge,
            ),
            Text(
              '${profile?.rollNumber ?? ''} · '
                  'Semester ${profile?.semester ?? ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Announcements',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: const Center(
        child: Text('Dashboard coming in Step 8'),
      ),
    );
  }
}