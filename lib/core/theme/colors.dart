import 'package:flutter/material.dart';

/// One palette for the whole app.
///
/// The named values are the design system's own hex codes; everything else on
/// this page is derived from them, so retinting is a one-file change.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Design system
  // ---------------------------------------------------------------------------

  /// Primary purple.
  static const Color primary = Color(0xFF6D28D9);

  /// Secondary purple.
  static const Color secondary = Color(0xFF7C3AED);

  /// Accent purple.
  static const Color accentPurple = Color(0xFF9333EA);

  /// Light purple, used behind icons and for tinted panels.
  static const Color lightPurple = Color(0xFFEDE9FE);

  /// The deepest brand surface.
  static const Color backgroundPurple = Color(0xFF5B21B6);

  /// One step darker again, anchoring the hero gradient and the button.
  static const Color deepPurple = Color(0xFF4C1D95);

  /// The wash inside a text field's icon well.
  static const Color fieldWell = Color(0xFFF5F3FF);

  /// The circular badge above "Welcome Back!".
  static const Color badgeWash = Color(0xFFF3E8FF);

  static const Color white = Color(0xFFFFFFFF);

  // Kept as aliases so screens written against the old names still resolve.
  static const Color primaryLight = secondary;
  static const Color primaryDark = backgroundPurple;
  static const Color gradientStart = primary;
  static const Color gradientEnd = accentPurple;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepPurple, backgroundPurple, primary],
  );

  // ---------------------------------------------------------------------------
  // Surfaces and depth
  // ---------------------------------------------------------------------------

  /// The header / hero gradient.
  static const LinearGradient brandGradientRich = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepPurple, backgroundPurple, primary],
    stops: [0.0, 0.55, 1.0],
  );

  /// The primary button's gradient.
  static const LinearGradient buttonGloss = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondary, deepPurple],
  );

  /// Disabled button gradient (kept a gradient so the shape stays consistent).
  static const LinearGradient buttonGlossDisabled = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFCFC4E4), Color(0xFFB4A6CE)],
  );

  /// Subtle full-page background wash, resolving to [background].
  static const LinearGradient pageWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCFBFF), background],
  );

  /// Faint sheen for white cards, so they catch light like glass.
  static const LinearGradient cardSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, Color(0xFFFDFCFF)],
  );

  /// Hairline edge on light surfaces.
  static const Color hairline = Color(0xFFE9D5FF);

  /// The design system's shadow: rgba(109, 40, 217, 0.12).
  static const Color shadowBrand = Color(0x1F6D28D9);

  // Surfaces
  static const Color background = Color(0xFFF7F4FE);
  static const Color surface = white;
  static const Color cardBackground = white;

  /// Purple bar used for section headings.
  static const Color sectionHeader = primary;

  /// Tinted panel used for cards, option tiles and icon wells.
  static const Color tintedPanel = lightPurple;

  static const Color divider = Color(0xFFE9D5FF);

  // Text
  static const Color textPrimary = Color(0xFF1F1147);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color inputText = Color(0xFF374151);
  static const Color textWhite = white;

  // Carousel pagination
  static const Color dotActive = secondary;
  static const Color dotInactive = Color(0xFFD8B4FE);

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

  // Dashboard stat cards — tints of the brand purple.
  static const Color dashboardCard1 = Color(0xFFF5F1FE);
  static const Color dashboardCard2 = lightPurple;
  static const Color dashboardCard3 = Color(0xFFE0D6FB);
  static const Color progressGreen = Color(0xFF8BC34A);
}
