import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  static const Color primary = Color(0xFF6A1B9A); // Purple from screenshots
  static const Color primaryLight = Color(0xFF9C4DCC);
  static const Color primaryDark = Color(0xFF38006B);
  
  static const Color accent = Color(0xFF009688); // Teal/Green from Login button
  static const Color background = Color(0xFFF9F9F9); // Light grayish background
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  
  // Dashboard specific colors
  static const Color dashboardCard1 = Color(0xFFE0F7FA); // Module Completed
  static const Color dashboardCard2 = Color(0xFFE0F2F1); // Average Score
  static const Color dashboardCard3 = Color(0xFFE8F5E9); // Time Invested
  static const Color progressGreen = Color(0xFF8BC34A);
  
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Assessment screens
  static const Color assessmentAction = Color(0xFF0E9F6E); // teal buttons
  static const Color assessmentHeader = Color(0xFFC9AFCB); // muted purple bar
  static const Color optionTile = Color(0xFFE7DAEA); // option pill
  static const Color optionTileSelected = Color(0xFF6A1B9A);
  static const Color resultFail = Color(0xFFF4402D);
  static const Color resultPass = Color(0xFF0E9F6E);
}
