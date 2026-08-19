import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'auth_controller.dart';
import 'auth_providers.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_error_box.dart';
import 'widgets/auth_field.dart';
import 'widgets/auth_link.dart';
import 'widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).signIn(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // When sign in succeeds, close this screen so AuthGate can take over.
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return AuthScaffold(
      title: 'WELCOME BACK',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _emailController,
              hint: 'Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Enter your email';
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            AuthField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscure: !_showPassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if ((value ?? '').isEmpty) return 'Enter your password';
                return null;
              },
              suffix: IconButton(
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: BrandColors.hint,
                ),
                onPressed: () =>
                    setState(() => _showPassword = !_showPassword),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: AuthLink(
                label: 'Forgot password?',
                onPressed: isLoading
                    ? null
                    : () {
                  ref
                      .read(authControllerProvider.notifier)
                      .clearError();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(
                        initialEmail: _emailController.text.trim(),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (state.hasError) ...[
              const SizedBox(height: AppSpacing.sm),
              AuthErrorBox(message: authErrorMessage(state.error!)),
            ],

            const SizedBox(height: AppSpacing.xl),

            AuthButton(
              label: 'Login',
              isLoading: isLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                AuthLink(
                  label: 'Register',
                  onPressed: isLoading
                      ? null
                      : () {
                    ref
                        .read(authControllerProvider.notifier)
                        .clearError();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(fromLogin: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}