import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography definitions using Plus Jakarta Sans matching Stitch DESIGN.md
class AppTypography {
  AppTypography._();

  static const List<String> _devanagariFallbacks = [
    'Noto Sans Devanagari',
    'Kohinoor Devanagari',
    'Devanagari Sangam MN',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif',
  ];

  static const String fontFamily = 'Plus Jakarta Sans';
  static const String _fallbackFamily = 'sans-serif';

  static TextStyle _font({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double? letterSpacing,
    Color color = AppColors.onSurface,
  }) {
    try {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height / fontSize,
        letterSpacing: letterSpacing,
        color: color,
      ).copyWith(
        fontFamilyFallback: _devanagariFallbacks,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: _fallbackFamily,
        fontFamilyFallback: _devanagariFallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height / fontSize,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  // Display Styles
  static TextStyle get display => _font(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 48,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMobile => _font(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 40,
        letterSpacing: -0.3,
      );

  // Headlines
  static TextStyle get headlineLg => _font(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40,
      );

  static TextStyle get headlineLgMobile => _font(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 34,
      );

  static TextStyle get headlineMd => _font(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 30,
      );

  static TextStyle get headlineSm => _font(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 26,
      );

  // Titles
  static TextStyle get titleMd => _font(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 24,
      );

  static TextStyle get titleSm => _font(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20,
      );

  // Body
  static TextStyle get bodyLg => _font(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24,
      );

  static TextStyle get bodyMd => _font(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22,
        color: AppColors.slateSecondary,
      );

  static TextStyle get bodySm => _font(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 18,
        color: AppColors.slateSecondary,
      );

  // Labels & Chips
  static TextStyle get labelLg => _font(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24,
        letterSpacing: 0.2,
      );

  static TextStyle get labelMd => _font(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSm => _font(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 16,
        letterSpacing: 0.3,
      );

  // Material 3 Aliases
  static TextStyle get labelLarge => labelLg;
  static TextStyle get labelMedium => labelMd;
  static TextStyle get labelSmall => labelSm;
  static TextStyle get titleLarge => titleMd;
  static TextStyle get titleMedium => titleMd;
  static TextStyle get titleSmall => titleSm;
  static TextStyle get headlineMedium => headlineMd;
  static TextStyle get headlineSmall => headlineSm;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => bodySm;
}
