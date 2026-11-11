import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_typography.dart';

enum TactileButtonStyle {
  primaryCoral,
  primaryCrimson,
  secondaryNeumorphic,
  subtlePill,
  emerald,
}

/// Tactile Button with soft Neumorphism and micro-pressed feedback
class TactileButton extends StatefulWidget {
  final String label;
  final Widget? icon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;
  final TactileButtonStyle style;
  final double height;
  final double? width;
  final bool isFullWidth;
  final bool isLoading;

  const TactileButton({
    super.key,
    required this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.style = TactileButtonStyle.primaryCoral,
    this.height = 54.0,
    this.width,
    this.isFullWidth = false,
    this.isLoading = false,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    List<BoxShadow> shadows;
    Border? border;

    switch (widget.style) {
      case TactileButtonStyle.primaryCoral:
        bgColor = AppColors.radiantCoral;
        textColor = Colors.white;
        shadows = _isPressed
            ? [
                const BoxShadow(
                  color: Color(0x33FA5252),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                )
              ]
            : [
                const BoxShadow(
                  color: Color(0x4DFA5252), // 0 6px 16px rgba(250, 82, 82, 0.3)
                  offset: Offset(0, 6),
                  blurRadius: 16,
                )
              ];
        break;

      case TactileButtonStyle.primaryCrimson:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        shadows = _isPressed
            ? [
                const BoxShadow(
                  color: Color(0x33B41D26),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                )
              ]
            : [
                const BoxShadow(
                  color: Color(0x59B41D26),
                  offset: Offset(0, 8),
                  blurRadius: 20,
                )
              ];
        break;

      case TactileButtonStyle.secondaryNeumorphic:
        bgColor = AppColors.surfaceContainerLowest;
        textColor = AppColors.slateCharcoal;
        shadows = _isPressed
            ? AppDecorations.tactileRecessed
            : AppDecorations.tactileExtrusion;
        border = Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1);
        break;

      case TactileButtonStyle.subtlePill:
        bgColor = AppColors.surfaceContainerLow;
        textColor = AppColors.onSurface;
        shadows = _isPressed
            ? AppDecorations.tactileRecessed
            : AppDecorations.tactileExtrusionSubtle;
        break;

      case TactileButtonStyle.emerald:
        bgColor = AppColors.emeraldSafe;
        textColor = Colors.white;
        shadows = _isPressed
            ? [
                const BoxShadow(
                  color: Color(0x33059669),
                  offset: Offset(0, 2),
                  blurRadius: 6,
                )
              ]
            : [
                const BoxShadow(
                  color: Color(0x4D059669),
                  offset: Offset(0, 6),
                  blurRadius: 16,
                )
              ];
        break;
    }

    final effectiveWidth = widget.isFullWidth ? double.infinity : widget.width;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onPressed != null
            ? (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          width: effectiveWidth,
          padding: EdgeInsets.symmetric(horizontal: effectiveWidth != null ? 10 : 20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppDecorations.brFull,
            border: border,
            boxShadow: shadows,
          ),
          child: Row(
            mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    style: AppTypography.labelLg.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (widget.trailingIcon != null && !widget.isLoading) ...[
                const SizedBox(width: 8),
                widget.trailingIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
