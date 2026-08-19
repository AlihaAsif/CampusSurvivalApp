import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'auth_controller.dart';
import 'auth_providers.dart';
import 'login_screen.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_error_box.dart';
import 'widgets/auth_field.dart';
import 'widgets/auth_link.dart';
import 'widgets/auth_scaffold.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.fromLogin = false});

  final bool fromLogin;

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return AuthScaffold(
      title: 'CREATE ACCOUNT',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _nameController,
              hint: 'Full name',
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Enter your name';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

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
                final text = value ?? '';
                if (text.isEmpty) return 'Enter a password';
                if (text.length < 6) return 'Use at least 6 characters';
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

            if (state.hasError) ...[
              const SizedBox(height: AppSpacing.lg),
              AuthErrorBox(message: authErrorMessage(state.error!)),
            ],

            const SizedBox(height: AppSpacing.xl),

            AuthButton(
              label: 'Sign up',
              isLoading: isLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already a member?',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                AuthLink(
                  label: 'Login',
                  onPressed: isLoading
                      ? null
                      : () {
                    ref
                        .read(authControllerProvider.notifier)
                        .clearError();
                    if (widget.fromLogin &&
                        Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    }
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