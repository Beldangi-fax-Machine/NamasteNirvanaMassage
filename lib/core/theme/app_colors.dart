import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF8B7355);
  static const Color primaryDark = Color(0xFF6B5544);
  static const Color primaryLight = Color(0xFFA89078);

  // Secondary Colors
  static const Color secondary = Color(0xFFD4C5B5);
  static const Color secondaryLight = Color(0xFFE8DFD3);

  // Accent Colors
  static const Color accent = Color(0xFF6B8E23);
  static const Color accentLight = Color(0xFF8FB339);

  // Neutral Colors
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFF5F0E8);
  static const Color inputBackground = Color(0xFFF5F2EF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2A26);
  static const Color textSecondary = Color(0xFF5A5651);
  static const Color textMuted = Color(0xFF8A8580);
  static const Color textLight = Color(0xFFB0ABA5);

  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // UI Colors
  static const Color divider = Color(0xFFE0DCD8);
  static const Color border = Color(0xFFD4D0CC);
  static const Color shadow = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient creamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cream, secondary],
  );
}
