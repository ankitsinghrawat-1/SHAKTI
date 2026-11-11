import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum StatusBadgeType {
  emerald,
  primary,
  tertiary,
  neutral,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Widget? leadingIcon;
  final StatusBadgeType type;
  final bool animateDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.leadingIcon,
    this.type = StatusBadgeType.emerald,
    this.animateDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color textColor;

    switch (type) {
      case StatusBadgeType.emerald:
        dotColor = AppColors.emeraldSafe;
        textColor = AppColors.onSurface;
        break;
      case StatusBadgeType.primary:
        dotColor = AppColors.primary;
        textColor = AppColors.primary;
        break;
      case StatusBadgeType.tertiary:
        dotColor = AppColors.tertiary;
        textColor = AppColors.tertiary;
        break;
      case StatusBadgeType.neutral:
        dotColor = AppColors.mutedGrey;
        textColor = AppColors.slateSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18A6B4C8),
            offset: Offset(1, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-1, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 5),
          ] else if (animateDot) ...[
            _PulsingDot(color: dotColor),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.5 + (_controller.value * 0.5)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _controller.value),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
