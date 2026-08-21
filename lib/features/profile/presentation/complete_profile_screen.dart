import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/widgets/auth_button.dart';
import '../../auth/presentation/widgets/auth_error_box.dart';
import '../../auth/presentation/widgets/auth_field.dart';
import '../../auth/presentation/widgets/auth_link.dart';
import '../../auth/presentation/widgets/auth_scaffold.dart';
import '../domain/user_profile.dart';
import 'profile_providers.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState
    extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rollController = TextEditingController();
  final _semesterController = TextEditingController();
  final _sectionController = TextEditingController();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _rollController.dispose();
    _semesterController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(profileRepositoryProvider).saveProfile(
        UserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          rollNumber: _rollController.text.trim().toUpperCase(),
          semester: int.parse(_semesterController.text.trim()),
          section: _sectionController.text.trim().toUpperCase(),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not save. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'ALMOST THERE',
      showBack: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tell us about your semester so the app can '
                  'track the right classes.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            AuthField(
              controller: _rollController,
              hint: 'Roll number (FA23-BSE-092)',
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'Enter your roll number';
                if (!UserProfile.isValidRollNumber(text)) {
                  return 'Use the format FA23-BSE-092';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            AuthField(
              controller: _semesterController,
              hint: 'Semester (1 - 8)',
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'Enter your semester';
                final number = int.tryParse(text);
                if (number == null) return 'Numbers only';
                if (number < 1 || number > 8) {
                  return 'Must be between 1 and 8';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            AuthField(
              controller: _sectionController,
              hint: 'Section (A, B, C)',
              icon: Icons.group_outlined,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'Enter your section';
                if (text.length > 2) return 'Use a single letter like A or B';
                return null;
              },
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AuthErrorBox(message: _error!),
            ],

            const SizedBox(height: AppSpacing.xl),

            AuthButton(
              label: 'Continue',
              isLoading: _saving,
              onPressed: _save,
            ),

            const SizedBox(height: AppSpacing.md),

            Center(
              child: AuthLink(
                label: 'Sign out',
                onPressed: _saving
                    ? null
                    : () =>
                    ref.read(authControllerProvider.notifier).signOut(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}