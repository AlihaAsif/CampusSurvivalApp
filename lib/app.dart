import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'features/auth/presentation/verify_email_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/profile/presentation/complete_profile_screen.dart';
import 'features/profile/presentation/profile_providers.dart';

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

        final profile = ref.watch(profileProvider);

        return profile.when(
          data: (data) {
            if (data == null || !data.isComplete) {
              return const CompleteProfileScreen();
            }
            return const AppShell();
          },
          loading: () => const _Loading(),
          error: (error, stack) => const _Error(),
        );
      },
      loading: () => const _Loading(),
      error: (error, stack) => const _Error(),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Something went wrong.')),
    );
  }
}

