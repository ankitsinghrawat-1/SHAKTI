import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// AppTheme configuration for SHAKTI
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        surfaceTint: AppColors.surfaceTint,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.primaryFixedDim,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.displayMobile,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        headlineSmall: AppTypography.headlineSm,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelLg,
        labelMedium: AppTypography.labelMd,
        labelSmall: AppTypography.labelSm,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkSurface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.clearBlue,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: Colors.white,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        surfaceTint: AppColors.primary,
        inverseSurface: AppColors.surface,
        onInverseSurface: AppColors.onSurface,
        inversePrimary: AppColors.primaryFixed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.darkOnSurface),
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: AppColors.darkOnSurface),
        displayMedium: AppTypography.displayMobile.copyWith(color: AppColors.darkOnSurface),
        headlineLarge: AppTypography.headlineLg.copyWith(color: AppColors.darkOnSurface),
        headlineMedium: AppTypography.headlineMd.copyWith(color: AppColors.darkOnSurface),
        headlineSmall: AppTypography.headlineSm.copyWith(color: AppColors.darkOnSurface),
        bodyLarge: AppTypography.bodyLg.copyWith(color: AppColors.darkOnSurface),
        bodyMedium: AppTypography.bodyMd.copyWith(color: AppColors.darkOnSurface),
        bodySmall: AppTypography.bodySm.copyWith(color: AppColors.darkOnSurfaceVariant),
        labelLarge: AppTypography.labelLg.copyWith(color: AppColors.darkOnSurface),
        labelMedium: AppTypography.labelMd.copyWith(color: AppColors.darkOnSurface),
        labelSmall: AppTypography.labelSm.copyWith(color: AppColors.darkOnSurfaceVariant),
      ),
    );
  }
}
