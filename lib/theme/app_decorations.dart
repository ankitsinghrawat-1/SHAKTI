import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized decoration, shadow, radius, and elevation tokens from DESIGN.md
class AppDecorations {
  AppDecorations._();

  // Corner Radii
  static const double radiusSm = 8.0;
  static const double radiusDefault = 16.0;
  static const double radiusMd = 24.0;
  static const double radiusLg = 32.0;
  static const double radiusXl = 48.0;
  static const double radiusFull = 999.0;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brDefault = BorderRadius.all(Radius.circular(radiusDefault));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius brFull = BorderRadius.all(Radius.circular(radiusFull));

  // Neumorphic Dual Shadows (Level 2 Tactile Extrusion)
  static const List<BoxShadow> tactileExtrusion = [
    BoxShadow(
      color: Color(0xE6FFFFFF), // -4px -4px 10px rgba(255, 255, 255, 0.9)
      offset: Offset(-4, -4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0x38A6B4C8), // 4px 4px 12px rgba(166, 180, 200, 0.22)
      offset: Offset(4, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> tactileExtrusionSubtle = [
    BoxShadow(
      color: Color(0xE6FFFFFF),
      offset: Offset(-2, -2),
      blurRadius: 6,
    ),
    BoxShadow(
      color: Color(0x28A6B4C8),
      offset: Offset(2, 2),
      blurRadius: 7,
    ),
  ];

  // Inset / Recessed Shadow illusion
  static const List<BoxShadow> tactileRecessed = [
    BoxShadow(
      color: Color(0x38A6B4C8),
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
  ];

  // Frosted Glass Elevation Shadow (Level 1)
  static const List<BoxShadow> glassElevation = [
    BoxShadow(
      color: Color(0x0E1F2687), // 0 8px 32px 0 rgba(31, 38, 135, 0.05)
      offset: Offset(0, 8),
      blurRadius: 32,
    ),
  ];

  // Refined Feminine Card Shadow (Warm subtle rose shadow)
  static const List<BoxShadow> feminineCardShadow = [
    BoxShadow(
      color: Color(0x0D8C1D40), // subtle plum/rose warm drop
      offset: Offset(0, 6),
      blurRadius: 18,
    ),
    BoxShadow(
      color: Color(0x80FFFFFF),
      offset: Offset(0, -1),
      blurRadius: 4,
    ),
  ];

  // Refined Ambient Warm Gradient
  static const LinearGradient feminineSurfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF7F8),
      Color(0xFFFDECEF),
      Color(0xFFFCE6EC),
    ],
  );

  // SOS Emergency Beacon Glow (Level 3)
  static const List<BoxShadow> sosPulseShadow = [
    BoxShadow(
      color: Color(0x59E02424), // 0 12px 28px rgba(224, 36, 36, 0.35)
      offset: Offset(0, 12),
      blurRadius: 28,
    ),
    BoxShadow(
      color: Color(0x26E02424),
      offset: Offset(0, 0),
      blurRadius: 16,
      spreadRadius: 6,
    ),
  ];

  // Glass Container Decoration
  static BoxDecoration glassCardDecoration({
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Border? border,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.glassWhite,
      borderRadius: borderRadius ?? brLg,
      border: border ??
          Border.all(
            color: AppColors.glassBorder,
            width: 1.0,
          ),
      boxShadow: shadows ?? glassElevation,
    );
  }

  // Neumorphic Pill Decoration
  static BoxDecoration tactilePillDecoration({
    bool pressed = false,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surfaceContainerLowest,
      borderRadius: brFull,
      boxShadow: pressed ? tactileRecessed : tactileExtrusion,
    );
  }
}
