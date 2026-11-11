import 'package:flutter/material.dart';

/// Centralized color tokens exactly matching Stitch DESIGN.md
class AppColors {
  AppColors._();

  // Feminine Design Language Palette (Part 1)
  // Warm ivory and soft blush primary surfaces
  static const Color warmIvory = Color(0xFFFFFDFD);
  static const Color softBlush = Color(0xFFFFF5F7);
  static const Color blushSurface = Color(0xFFFFF7F8);
  static const Color blushSurfaceLow = Color(0xFFFDECEF);
  static const Color blushSurfaceMedium = Color(0xFFFCE4E9);

  // Muted rose and dusty pink secondary accents
  static const Color mutedRose = Color(0xFFF7D6DE);
  static const Color dustyPink = Color(0xFFEAA8B8);
  static const Color softRoseWell = Color(0xFFFDE8EC);
  static const Color roseBorder = Color(0xFFF3DDE3);
  static const Color roseBorderSubtle = Color(0x38B41D26);

  // Elegant berry & plum for text, icons, and visual emphasis
  static const Color deepPlum = Color(0xFF3D1124);
  static const Color berryDark = Color(0xFF4A122B);
  static const Color berryMuted = Color(0xFF755160);
  static const Color berryAccent = Color(0xFFB41D3C);
  static const Color berryGradientStart = Color(0xFFC8234B);
  static const Color berryGradientEnd = Color(0xFFB41D26);

  // Neutral Environment & Surfaces (Warm Ivory / Soft Blush)
  static const Color surface = Color(0xFFFFF7F8);
  static const Color surfaceDim = Color(0xFFEADBDE);
  static const Color surfaceBright = Color(0xFFFFFDFD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFDECEF);
  static const Color surfaceContainer = Color(0xFFFCE4E9);
  static const Color surfaceContainerHigh = Color(0xFFFADAE1);
  static const Color surfaceContainerHighest = Color(0xFFF7CFD8);
  static const Color surfaceVariant = Color(0xFFFCE4E9);

  // Content & Typography Colors
  static const Color onSurface = Color(0xFF3D1124); // Elegant deep plum
  static const Color onSurfaceVariant = Color(0xFF6B4555); // Secondary mauve-plum
  static const Color outline = Color(0xFF8E706D);
  static const Color outlineVariant = Color(0xFFE3BEBB);
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F4);
  static const Color background = Color(0xFFFFF7F8);
  static const Color onBackground = Color(0xFF3D1124);

  // Typography Contrast specific slate and plum tones
  static const Color slateCharcoal = Color(0xFF2E1824);
  static const Color slateSecondary = Color(0xFF6B4555);
  static const Color mutedGrey = Color(0xFF8E7582);

  // Brand & Critical Action Palette
  // Primary: Brand Crimson
  static const Color primary = Color(0xFFB41D26);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD7383C);
  static const Color onPrimaryContainer = Color(0xFFFFFBFF);
  static const Color primaryFixed = Color(0xFFFFDAD7);
  static const Color primaryFixedDim = Color(0xFFFFB3AE);
  static const Color onPrimaryFixed = Color(0xFF410005);
  static const Color onPrimaryFixedVariant = Color(0xFF930016);
  static const Color surfaceTint = Color(0xFFB72029);

  // Radiant Coral: Standard Non-Emergency CTA Accent
  static const Color radiantCoral = Color(0xFFFA5252);

  // Deep Crimson: Strictly Quarantined for Panic & Emergency SOS
  static const Color deepCrimson = Color(0xFFE02424);
  static const Color secondary = Color(0xFFBB0011);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE22525);
  static const Color onSecondaryContainer = Color(0xFFFFFBFF);
  static const Color secondaryFixed = Color(0xFFFFDAD6);
  static const Color secondaryFixedDim = Color(0xFFFFB4AB);
  static const Color onSecondaryFixed = Color(0xFF410002);
  static const Color onSecondaryFixedVariant = Color(0xFF93000A);

  // Tertiary Accent: Safe-zone waypoints, transit telemetry, verified contacts
  static const Color tertiary = Color(0xFF0058BE);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF2170E4);
  static const Color onTertiaryContainer = Color(0xFFFEFCFF);
  static const Color tertiaryFixed = Color(0xFFD8E2FF);
  static const Color tertiaryFixedDim = Color(0xFFADC6FF);
  static const Color onTertiaryFixed = Color(0xFF001A42);
  static const Color onTertiaryFixedVariant = Color(0xFF004395);
  static const Color clearBlue = Color(0xFF3B82F6);

  // Safe Status & Emerald Accents
  static const Color emeraldSafe = Color(0xFF059669);
  static const Color emeraldGlow = Color(0xFF10B981);
  static const Color emeraldLightBg = Color(0xFFECFDF5);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Frosted Glass Presets
  static const Color glassWhite = Color(0xB8FFFFFF); // rgba(255, 255, 255, 0.72)
  static const Color glassBorder = Color(0xD9FFFFFF); // rgba(255, 255, 255, 0.85)

  // Dark Mode Surface Palette
  static const Color darkSurface = Color(0xFF0F172A); // Deep slate-charcoal
  static const Color darkSurfaceContainerLowest = Color(0xFF1E293B);
  static const Color darkSurfaceContainerLow = Color(0xFF162032);
  static const Color darkSurfaceContainer = Color(0xFF1E293B);
  static const Color darkSurfaceContainerHigh = Color(0xFF334155);
  static const Color darkSurfaceContainerHighest = Color(0xFF475569);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkOnSurfaceVariant = Color(0xFFCBD5E1);
  static const Color darkOutline = Color(0xFF64748B);
  static const Color darkOutlineVariant = Color(0xFF334155);
  static const Color darkGlassBg = Color(0xD91E293B); // rgba(30, 41, 59, 0.85)
  static const Color darkGlassBorder = Color(0x3394A3B8); // rgba(148, 163, 184, 0.20)

  // Border & Divider Light
  static const Color borderLight = Color(0xFFE2E8F0);
}
