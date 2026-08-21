import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import 'auth_controller.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_error_box.dart';
import 'widgets/auth_field.dart';
import 'widgets/auth_link.dart';
import 'widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController =
  TextEditingController(text: widget.initialEmail);

  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);

    if (!mounted) return;
    if (ok) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: _sent ? 'CHECK YOUR EMAIL' : 'RESET PASSWORD',
      child: _sent ? _buildSent() : _buildForm(state),
    );
  }

  Widget _buildForm(AsyncValue<void> state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the email you signed up with and we will send you a '
                'reset link.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xl),

          AuthField(
            controller: _emailController,
            hint: 'Email',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Enter your email';
              if (!text.contains('@') || !text.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),

          if (state.hasError) ...[
            const SizedBox(height: AppSpacing.lg),
            AuthErrorBox(message: authErrorMessage(state.error!)),
          ],

          const SizedBox(height: AppSpacing.xl),

          AuthButton(
            label: 'Send reset link',
            isLoading: state.isLoading,
            onPressed: _submit,
          ),

          const SizedBox(height: AppSpacing.md),

          Center(
            child: AuthLink(
              label: 'Back to login',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 44,
          color: Colors.white,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'We sent a reset link to ${_emailController.text.trim()}. '
              'Open it to set a new password, then sign in again.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthButton(
          label: 'Back to login',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}