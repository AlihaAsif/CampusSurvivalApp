import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/auth/presentation/verify_email_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';

class CampusSurvivalApp extends StatelessWidget {
  const CampusSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Survival',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const WelcomeScreen();
        if (!user.emailVerified) {
          return VerifyEmailScreen(email: user.email);
        }
        return const TempHomeScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const Scaffold(
        body: Center(child: Text('Something went wrong.')),
      ),
    );
  }
}

// TEMPORARY — replaced by the real dashboard in Step 6.
class TempHomeScreen extends ConsumerWidget {
  const TempHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Survival')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user?.displayName ?? ''),
            Text(user?.email ?? ''),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  ref.read(authRepositoryProvider).signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}