import 'package:flutter/material.dart';
import 'app_typography.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,
      textTheme: AppTypography.textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: lightScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: lightScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: lightScheme.secondaryContainer,
        height: 74,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}