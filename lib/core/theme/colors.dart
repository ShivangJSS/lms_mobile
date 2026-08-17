import 'package:flutter/material.dart';

/// One palette for the whole app, taken from the login screen.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryLight = Color(0xFF9C4DCC);
  static const Color primaryDark = Color(0xFF38006B);

  /// The two ends of the login header gradient, reused for every header.
  static const Color gradientStart = Color(0xFF7B1F86);
  static const Color gradientEnd = Color(0xFF4A0D52);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [gradientStart, gradientEnd],
  );

  // Surfaces — the login page background is the app background everywhere.
  static const Color background = Color(0xFFF5F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Muted purple bar used for section headings.
  static const Color sectionHeader = Color(0xFFC9AFCB);

  /// Tinted panel used for cards and option tiles.
  static const Color tintedPanel = Color(0xFFE7DAEA);

  static const Color divider = Color(0xFFE3DCE8);

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6B6B72);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status
  static const Color accent = Color(0xFF0E9F6E);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF0E9F6E);

  // Assessment screens
  static const Color assessmentAction = accent;
  static const Color assessmentHeader = sectionHeader;
  static const Color optionTile = tintedPanel;
  static const Color optionTileSelected = primary;
  static const Color resultFail = Color(0xFFF4402D);
  static const Color resultPass = accent;

  // Dashboard stat cards — tints of the brand purple rather than the old
  // washed-out teals, so they read as part of the same palette.
  static const Color dashboardCard1 = Color(0xFFF3E7F7);
  static const Color dashboardCard2 = Color(0xFFEBDCF2);
  static const Color dashboardCard3 = Color(0xFFE3D2EC);
  static const Color progressGreen = Color(0xFF8BC34A);
}
