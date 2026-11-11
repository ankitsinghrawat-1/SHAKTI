import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

/// Reusable Frosted Glass Card adhering to Level 1 Elevation in DESIGN.md
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? shadows;
  final double blurSigma;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.shadows,
    this.blurSigma = 16.0,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBr = borderRadius ?? AppDecorations.brLg;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkGlassBg : AppColors.glassWhite;
    final defaultBorder = isDark
        ? Border.all(color: AppColors.darkGlassBorder, width: 1.0)
        : Border.all(color: AppColors.glassBorder, width: 1.0);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBr,
        boxShadow: shadows ?? AppDecorations.glassElevation,
      ),
      child: ClipRRect(
        borderRadius: effectiveBr,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor ?? defaultBg,
              borderRadius: effectiveBr,
              border: border ?? defaultBorder,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }
}
