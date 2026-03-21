import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Space Grotesk – Display & Headlines (Mechanical Voice)
  static TextStyle displayLg = GoogleFonts.spaceGrotesk(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
    letterSpacing: -0.02 * 57,
    height: 1.1,
  );

  static TextStyle displayMd = GoogleFonts.spaceGrotesk(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
    letterSpacing: -0.02 * 45,
    height: 1.15,
  );

  static TextStyle displaySm = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
    letterSpacing: -0.02 * 36,
    height: 1.2,
  );

  static TextStyle headlineLg = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onBackground,
    letterSpacing: -0.02 * 32,
  );

  static TextStyle headlineMd = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: -0.01 * 28,
  );

  static TextStyle headlineSm = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
    letterSpacing: -0.01 * 24,
  );

  static TextStyle titleLg = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static TextStyle titleMd = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  // Manrope – Body & Labels (Functional Voice)
  static TextStyle bodyLg = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle bodyMd = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.5,
  );

  static TextStyle bodySm = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    height: 1.4,
  );

  static TextStyle labelLg = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    letterSpacing: 0.1,
  );

  static TextStyle labelMd = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.1,
  );

  static TextStyle labelSm = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 0.15,
  ).copyWith(
    // All-caps via TextStyle is via text transform in usage
  );

  // Uppercase Label – technical spec look
  static TextStyle labelSmCaps = GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 1.2,
  );
}
