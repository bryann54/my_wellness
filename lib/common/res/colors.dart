// lib/core/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light
  static const Color primaryColor = Color(0xFF008080);
  static const Color secondaryColor = Color(0xFF20B2AA);
  static const Color accentColor = Color(0xFF48D1CC);
  static const Color background = Color(0xFFF0F9F9);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB0272F);
  static const Color textPrimary = Color(0xFF004D4D);
  static const Color textSecondary = Color(0xFF5F7C7C);
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFB2DFDB);
  static const Color shadowColor = Color(0x1A008080);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color cardLight = Color(0xFFF0F0F0);
  static const Color riskColor = Color(0xFF124F5D);
  static const Color actionColor = Color(0xFFF56E5E);
  static const Color betterColor = Color(0xFF08B9C1);
  static const Color buttonColor = Color.fromARGB(255, 1, 3, 58);

  // Semantic
  static const Color success = Color(0xFF32BF7D);
  static const Color info = Color(0xFF26C6DA);
  static const Color warning = Color(0xFFFFA726);

  // Gradients
  static const LinearGradient lightButtonGradient = LinearGradient(
    colors: [Color(0xFF00695C), Color(0xFF20B2AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00796B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealAccentGradient = LinearGradient(
    colors: [Color(0xFF48D1CC), Color(0xFF7FDBDA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Split backgrounds
  static const Color visualDarkBackgroundHalf = Color(0xFF1A1A1A);
  static const Color visualLightBackgroundHalf = Colors.white;

  // Dark
  static const Color primaryColorDark = Color(0xFF26A69A);
  static const Color secondaryColorDark = Color(0xFF4DB6AC);
  static const Color accentColorDark = Color(0xFF80CBC4);
  static const Color backgroundDark = Color(0xFF0D1B1B);
  static const Color surfaceColorDark = Color(0xFF1B2F2F);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color textPrimaryDark = Color(0xFFE0F2F1);
  static const Color textSecondaryDark = Color(0xFFB2DFDB);
  static const Color cardColorDark = Color(0xFF1B2F2F);
  static const Color dividerColorDark = Color(0xFF2C4A4A);
  static const Color shadowColorDark = Color(0x3D000000);
  static const Color textLight = Color(0xFF6C7C7C);
  static const Color textLightDark = Color(0xFFADB5BD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const LinearGradient darkButtonGradient = LinearGradient(
    colors: [Color(0xFF00796B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Teal ramp
  static const Color tealExtraLight = Color(0xFFE0F2F1);
  static const Color tealLight = Color(0xFFB2DFDB);
  static const Color tealMedium = Color(0xFF4DB6AC);
  static const Color tealDark = Color(0xFF00796B);
  static const Color tealExtraDark = Color(0xFF004D40);

  // Neutrals
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color lightBackgroundColor = Color(0xFFFAFAFA);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color lightCardColor = Colors.white;

  // Spacing
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 32.0;
  static const double cardPadding = 24.0;
  static const double elementSpacing = 20.0;
  static const double largeElementSpacing = 24.0;

  // Sizes
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 50.0;

  // Animations
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration splashDelay = Duration(milliseconds: 500);
}
