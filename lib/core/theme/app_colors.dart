import 'package:flutter/material.dart';

const ColorScheme lightScheme = ColorScheme(
  brightness: Brightness.light,

  // Primary: Brand Navy Blue
  primary: Color(0xFF1E2E5C),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFE8EEF9),
  onPrimaryContainer: Color(0xFF0D1838),

  // Secondary: Brand Orange (Lighter, warmer shade)
  secondary: Color(0xFFFA7833),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFF0EB),
  onSecondaryContainer: Color(0xFF5A2000),

  // Tertiary: Brand Accent Blue
  tertiary: Color(0xFF3D5AA9),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFE0E7FF),
  onTertiaryContainer: Color(0xFF111E48),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  surface: Color(0xFFFAFAFD),
  onSurface: Color(0xFF1A1C22),
  onSurfaceVariant: Color(0xFF444752),
  outline: Color(0xFF757782),
  outlineVariant: Color(0xFFC5C6D0),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF3F4F8),
  surfaceContainer: Color(0xFFECEEF4),
  surfaceContainerHigh: Color(0xFFE4E7F0),
  surfaceContainerHighest: Color(0xFFDCDFE8),
);

/// Brand colours taken from the app logo.
class BrandColors {
  BrandColors._();

  static const Color orange = Color(0xFFFA7833);
  static const Color navy = Color(0xFF1E2E5C);
  static const Color blue = Color(0xFF3D5AA9);

  static const Color fieldFill = Color(0xFFF2F2F5);
  static const Color hint = Color(0xFF8A8A93);
  static const Color muted = Color(0xFF6B6B73);
}