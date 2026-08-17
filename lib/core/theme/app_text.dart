import 'package:flutter/material.dart';

import 'colors.dart';

/// Every heading in the app comes from here, so they all share one family,
/// one weight scale and one set of sizes.
///
/// [family] is null on purpose: that resolves to the platform default rather
/// than shipping a font file. Set it to one name and every heading and body
/// style below changes together.
class AppText {
  AppText._();

  static const String? family = null;

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: family,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: family,
    fontSize: 19,
    fontWeight: FontWeight.bold,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  /// Headings that sit on a purple bar or gradient.
  static const TextStyle headingOnColor = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textWhite,
  );

  /// Title inside a section bar — module name, "Topics", "Your Progress".
  /// One size for all of them, so no bar shouts louder than another.
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textWhite,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const TextStyle muted = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
}

/// One button size for the whole app.
///
/// Every primary action — Login, Post Assessment, Next, Submit — uses this
/// height, so no screen has a taller or shorter button than another.
class AppButton {
  AppButton._();

  static const double height = 48;
}

/// One spacing scale, so gaps are consistent instead of ad hoc.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Standard page padding.
  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  /// Standard card padding.
  static const EdgeInsets card = EdgeInsets.all(lg);

  static const double radius = 14;
  static const double radiusLarge = 20;
}
