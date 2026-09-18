import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color error;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final Color divider;
  final Color success;
  final Color info;
  final Color warning;

  const AppColorsExtension({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.divider,
    required this.success,
    required this.info,
    required this.warning,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    Color? error,
    Color? textPrimary,
    Color? textSecondary,
    Color? cardColor,
    Color? divider,
    Color? success,
    Color? info,
    Color? warning,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      cardColor: cardColor ?? this.cardColor,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      info: info ?? this.info,
      warning: warning ?? this.warning,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }

    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      error: Color.lerp(error, other.error, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }

  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>() ??
        AppColorsExtension.light;
  }

  // Light theme colors
  static const light = AppColorsExtension(
    primary: Color(0xFF111827),
    secondary: Color(0xFF20B2AA),
    accent: Color(0xFF48D1CC),
    background: Color(0xFFF0F9F9),
    surface: Colors.white,
    error: Color(0xFFB0272F),
    textPrimary: Color(0xFF004D4D),
    textSecondary: Color(0xFF5F7C7C),
    cardColor: Colors.white,
    divider: Color(0xFFB2DFDB),
    success: Color(0xFF00897B),
    info: Color(0xFF26C6DA),
    warning: Color(0xFFFFA726),
  );

  // Dark theme colors
  static const dark = AppColorsExtension(
    primary: Color(0xFF26A69A),
    secondary: Color(0xFF4DB6AC),
    accent: Color(0xFF80CBC4),
    background: Color(0xFF0D1B1B),
    surface: Color(0xFF1B2F2F),
    error: Color(0xFFEF5350),
    textPrimary: Color(0xFFE0F2F1),
    textSecondary: Color(0xFFB2DFDB),
    cardColor: Color(0xFF1B2F2F),
    divider: Color(0xFF2C4A4A),
    success: Color(0xFF00897B),
    info: Color(0xFF26C6DA),
    warning: Color(0xFFFFA726),
  );
}
