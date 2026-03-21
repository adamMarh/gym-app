import 'package:flutter/material.dart';

/// Kinetic Noir – Electric Brutalism Color System
class AppColors {
  AppColors._();

  // Primary Accent
  static const Color primary = Color(0xFFf28d02); // Lumen Orange
  static const Color primaryContainer = Color(0xFFb36a00);
  static const Color onPrimary = Color(0xFF0e0e0e);
  static const Color onPrimaryContainer = Color(0xFFFFE0B2);

  // Secondary Accent
  static const Color secondary = Color(0xFF9e6d3d); // Electric Bronze
  static const Color secondaryContainer = Color(0xFF4a3010);
  static const Color onSecondary = Color(0xFF0e0e0e);
  static const Color onSecondaryContainer = Color(0xFFD7B896);

  // Surface Hierarchy (stacked obsidian plates)
  static const Color background = Color(0xFF0e0e0e);
  static const Color surfaceContainerLow = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF1a1a1a);
  static const Color surfaceContainerHigh = Color(0xFF202020);
  static const Color surfaceContainerHighest = Color(0xFF262626);
  static const Color surfaceDim = Color(0xFF111111);

  // Text
  static const Color onBackground = Color(0xFFEEEEEE);
  static const Color onSurface = Color(0xFFDDDDDD);
  static const Color onSurfaceVariant = Color(0xFF9E9E9E);

  // Utility
  static const Color outline = Color(0xFF3A3A3A);
  static const Color outlineVariant = Color(0xFF262626);
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  // Glass / Overlay
  static const Color glassNavBar = Color(0xCC131313); // 80% opacity
}
