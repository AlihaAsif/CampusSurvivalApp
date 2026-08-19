import 'package:flutter/material.dart';

const ColorScheme lightScheme = ColorScheme(
  brightness: Brightness.light,

  // Main brand colour — app bar accents, filled buttons, progress bars.
  primary: Color(0xFF3D5AA9),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFDBE1FF),
  onPrimaryContainer: Color(0xFF0B1B4E),

  // Secondary — navigation bar selection pill, tonal buttons.
  secondary: Color(0xFF585E71),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFDDE1F9),
  onSecondaryContainer: Color(0xFF161B2C),

  // Tertiary — accents that need to stand apart, e.g. pinned notices.
  tertiary: Color(0xFF725572),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFDD7FA),
  onTertiaryContainer: Color(0xFF2A122B),

  // Error — overdue assignments, below-75% attendance.
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  // Surfaces — the background and the layers stacked on it.
  surface: Color(0xFFFBF8FF),
  onSurface: Color(0xFF1A1B21),
  onSurfaceVariant: Color(0xFF45464F),
  outline: Color(0xFF767680),
  outlineVariant: Color(0xFFC6C5D0),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF5F2FA),
  surfaceContainer: Color(0xFFEFEDF5),
  surfaceContainerHigh: Color(0xFFE9E7EF),
  surfaceContainerHighest: Color(0xFFE3E1E9),
);