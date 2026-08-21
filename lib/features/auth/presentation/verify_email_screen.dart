import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import 'auth_controller.dart';
import 'auth_providers.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_error_box.dart';
import 'widgets/auth_link.dart';
import 'widgets/auth_scaffold.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() =>
      _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldown = 0;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      ref.read(authRepositoryProvider).reloadUser();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).resendVerification();
    if (!mounted) return;
    if (!ref.read(authControllerProvider).hasError) {
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return AuthScaffold(
      title: 'VERIFY EMAIL',
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            size: 44,
            color: Colors.white,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'We sent a verification link to ${widget.email}. '
                'Open it, then come back — this screen updates on its own.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: const Row(
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Waiting for verification…',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (state.hasError) ...[
            const SizedBox(height: AppSpacing.lg),
            AuthErrorBox(message: authErrorMessage(state.error!)),
          ],

          const SizedBox(height: AppSpacing.xl),

          AuthButton(
            label: _cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend email',
            isLoading: isLoading,
            onPressed: _cooldown > 0 ? null : _resend,
          ),

          const SizedBox(height: AppSpacing.md),

          Center(
            child: AuthLink(
              label: 'Use a different account',
              onPressed: isLoading
                  ? null
                  : () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),
        ],
      ),
    );
  }
}