import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/app_spacing.dart';
import 'package:my_wellness/common/res/app_typography.dart';
import 'package:my_wellness/common/res/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.primaryColor,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.tealExtraLight,
      onPrimaryContainer: AppColors.tealExtraDark,
      secondary: AppColors.secondaryColor,
      onSecondary: AppColors.textOnPrimary,
      tertiary: AppColors.accentColor,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF5FAFA),
      surfaceContainer: Color(0xFFEDF5F5),
      surfaceContainerHigh: Color(0xFFE3EEEE),
      surfaceContainerHighest: Color(0xFFD8E8E8),
      outline: AppColors.dividerColor,
      outlineVariant: AppColors.dividerColor,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      shadow: AppColors.shadowColor,
    );

    return _base(scheme, AppColors.background);
  }

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.tealExtraDark,
      onPrimaryContainer: AppColors.tealExtraLight,
      secondary: AppColors.secondaryColorDark,
      onSecondary: AppColors.textOnPrimary,
      tertiary: AppColors.accentColorDark,
      surface: AppColors.surfaceColorDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      surfaceContainerLowest: Color(0xFF0A1414),
      surfaceContainerLow: Color(0xFF121C1C),
      surfaceContainer: Color(0xFF162424),
      surfaceContainerHigh: Color(0xFF1B2F2F),
      surfaceContainerHighest: Color(0xFF223A3A),
      outline: AppColors.dividerColorDark,
      outlineVariant: AppColors.dividerColorDark,
      error: AppColors.errorDark,
      onError: AppColors.textOnPrimary,
      shadow: AppColors.shadowColorDark,
    );

    return _base(scheme, AppColors.backgroundDark);
  }

  static ThemeData _base(ColorScheme scheme, Color scaffoldBg) {
    final isDark = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: AppTypography.textTheme.bodyMedium?.fontFamily,

      textTheme: AppTypography.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),

      // ── Buttons: one canonical primary button. Flat. ─────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.10),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          elevation: 0,
          textStyle: AppTypography.textTheme.titleMedium,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.10),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTypography.textTheme.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTypography.textTheme.titleMedium,
        ),
      ),

      // ── Inputs: canonical field look ──────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.40),
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.65),
        ),
        floatingLabelStyle: AppTypography.textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: scheme.error,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.3),
        thickness: 1,
        space: AppSpacing.lg,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        insetPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
