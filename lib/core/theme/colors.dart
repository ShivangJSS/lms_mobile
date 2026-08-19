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

  // ---------------------------------------------------------------------------
  // Glossy / depth tokens — shared "glossy finish" language used across every
  // screen. See AppGloss (core/theme/glossy.dart) for the decoration recipes.
  // ---------------------------------------------------------------------------

  /// Richer three-stop brand gradient for headers and hero surfaces. Reads as
  /// lit from the top-left, which is what gives headers their glossy sheen.
  static const LinearGradient brandGradientRich = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A), Color(0xFF3F0A57)],
    stops: [0.0, 0.55, 1.0],
  );

  /// Top-lit gradient for glossy primary buttons.
  static const LinearGradient buttonGloss = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA145C7), Color(0xFF6A1B9A)],
  );

  /// Disabled button gradient (kept a gradient so the shape stays consistent).
  static const LinearGradient buttonGlossDisabled = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC9C0D1), Color(0xFFB4A9BF)],
  );

  /// Subtle full-page background wash, replacing the flat [background].
  static const LinearGradient pageWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBF8FD), Color(0xFFEFE7F5)],
  );

  /// Faint diagonal sheen for white cards, so they catch light like glass.
  static const LinearGradient cardSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF7F1FB)],
  );

  /// Hairline edge on light surfaces.
  static const Color hairline = Color(0xFFEADFF1);

  /// Brand-tinted shadow colour used by the AppGloss shadow recipes.
  static const Color shadowBrand = Color(0x1A4A0D52);

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
