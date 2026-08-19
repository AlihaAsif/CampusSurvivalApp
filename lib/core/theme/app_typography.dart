import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 1.25,
      fontFeatures: _tabular,
    ),

    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 1.25,
    ),

    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),

    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),

    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),

    bodySmall: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),

    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),

    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),
  );

  static TextStyle tabular(TextStyle base) {
    return base.copyWith(fontFeatures: _tabular);
  }
}