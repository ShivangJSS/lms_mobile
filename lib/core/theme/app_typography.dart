import 'package:flutter/material.dart';

import 'colors.dart';

/// The type scale for the app.
///
/// [family] names Poppins with Inter behind it, but neither font ships with the
/// project yet — there is no `fonts:` section in pubspec.yaml and no .ttf in
/// assets, so both currently resolve to the platform default. Drop the files in,
/// declare them in pubspec.yaml, and every style below picks them up at once.
class AppTypography {
  AppTypography._();

  static const String family = 'Poppins';
  static const List<String> fallback = ['Inter'];

  static const TextStyle portalTitle = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle tagline = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xE6FFFFFF),
  );

  static const TextStyle welcome = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle welcomeSubtitle = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.inputText,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 0.8,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: family,
    fontFamilyFallback: fallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
