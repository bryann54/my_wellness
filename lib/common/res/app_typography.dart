import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Strict typography scale. Inter is the only font in this app.
/// No decorative fonts. No per-widget font swaps.
abstract final class AppTypography {
  static TextTheme get textTheme => TextTheme(
    // Display — used only on splash/onboarding hero titles
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.4,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.3,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.2,
    ),

    // Headline — screen titles
    headlineLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),

    // Title — section headers, button labels
    titleLarge: GoogleFonts.inter(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),

    // Body — copy
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.45,
    ),

    // Label — overlines, helper text
    labelLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
  );
}
