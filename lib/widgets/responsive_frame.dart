import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Inherited scope indicating that an ancestor widget is already rendering
/// inside a [ResponsiveFrame]. This prevents duplicate phone frames,
/// nested bezels, or multiple simulation banners.
class ResponsiveScope extends InheritedWidget {
  final bool isWide;
  final double targetWidth;
  final double targetHeight;

  const ResponsiveScope({
    super.key,
    required this.isWide,
    required this.targetWidth,
    required this.targetHeight,
    required super.child,
  });

  static ResponsiveScope? of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<ResponsiveScope>();
  }

  @override
  bool updateShouldNotify(ResponsiveScope oldWidget) {
    return isWide != oldWidget.isWide ||
        targetWidth != oldWidget.targetWidth ||
        targetHeight != oldWidget.targetHeight;
  }
}

/// Wraps pages (or the entire MaterialApp Navigator) in a phone-sized container
/// when viewed on web desktop/tablet, while filling the full viewport on mobile screens.
///
/// Architecture Note:
/// Uses synchronous [MediaQuery] sizing in [build] rather than [LayoutBuilder].
/// Root-level [LayoutBuilder] widgets inside MaterialApp.builder defer building
/// to the render layout phase (performLayout), which locks mutations and causes
/// 'RenderLayoutBuilder was mutated in _RenderLayoutBuilder.performLayout' crashes
/// when routes pop, controllers update, or child animations tick during page transitions.
class ResponsiveFrame extends StatelessWidget {
  final Widget child;
  final bool showSimulationBanner;

  const ResponsiveFrame({
    super.key,
    required this.child,
    this.showSimulationBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    // If already nested inside a ResponsiveFrame, do not create a double frame.
    // Use findAncestorWidgetOfExactType instead of dependOnInheritedWidgetOfExactType
    // to avoid creating an invalidating dependency subscription during layout transitions.
    if (context.findAncestorWidgetOfExactType<ResponsiveScope>() != null) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Mobile vs Desktop viewport determination
    final isWide = screenWidth > 520 && screenHeight >= 500;

    Widget content = child;

    if (showSimulationBanner) {
      content = Column(
        children: [
          // Subtle persistent simulation advisory banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBEB), // Soft amber
              border: Border(
                bottom: BorderSide(color: Color(0xFFFDE68A), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 13, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'PROTOTYPE DEMO: Simulated environment. No real emergency dispatches or GPS calls are made.',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      );
    }

    if (!isWide) {
      return ResponsiveScope(
        isWide: false,
        targetWidth: screenWidth,
        targetHeight: screenHeight,
        child: SizedBox.expand(
          child: Material(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            child: SafeArea(
              top: false,
              bottom: false,
              child: content,
            ),
          ),
        ),
      );
    }

    // Desktop shell sizing:
    // Width: capped at 430px (iPhone 14/15/16 Pro Max standard), minus horizontal breathing room
    final targetWidth = math.min(430.0, screenWidth - 24.0);

    // Height: responsive vertical clamping avoiding overflow on smaller laptop screens
    final verticalMargin = screenHeight > 960
        ? 32.0
        : (screenHeight > 750 ? 20.0 : 8.0);
    final targetHeight = (screenHeight - (verticalMargin * 2)).clamp(460.0, 932.0);

    // Subtle surrounding background complementing the feminine SHAKTI theme
    final outerBg = isDark ? const Color(0xFF140E12) : const Color(0xFFECE7EB);

    // Phone bezel color
    final bezelBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.15), width: 3)
        : Border.all(color: const Color(0xFFD6C8CE), width: 3);

    final scopedMediaQuery = mediaQuery.copyWith(
      size: Size(targetWidth, targetHeight),
    );

    return ResponsiveScope(
      isWide: true,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      child: SizedBox.expand(
        child: ColoredBox(
          color: outerBg,
          child: Center(
            child: Container(
              width: targetWidth,
              height: targetHeight,
              margin: EdgeInsets.symmetric(
                vertical: verticalMargin,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(44),
                border: bezelBorder,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                    offset: const Offset(0, 18),
                    blurRadius: 40,
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(
                data: scopedMediaQuery,
                child: Material(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
