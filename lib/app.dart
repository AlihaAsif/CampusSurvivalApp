import 'package:flutter/material.dart';

import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';

class CampusSurvivalApp extends StatelessWidget {
  const CampusSurvivalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Survival',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ThemeCheckScreen(),
    );
  }
}

// ---------------------------------------------------------------
// TEMPORARY. Exists only to prove the theme is applied.
// We delete this class in Step 3 when the real dashboard arrives.
// ---------------------------------------------------------------
class ThemeCheckScreen extends StatelessWidget {
  const ThemeCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Survival')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenH),
        children: [
          _swatch('primary', scheme.primary, scheme.onPrimary),
          _swatch('primaryContainer', scheme.primaryContainer,
              scheme.onPrimaryContainer),
          _swatch('surfaceContainerLow', scheme.surfaceContainerLow,
              scheme.onSurface),
          _swatch('errorContainer', scheme.errorContainer,
              scheme.onErrorContainer),
          const SizedBox(height: AppSpacing.section),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.cardPad),
              child: Text('This Card uses cardTheme — no shadow, radius 12.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _swatch(String name, Color background, Color foreground) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.all(AppSpacing.cardPad),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Text(name, style: TextStyle(color: foreground)),
    );
  }
}