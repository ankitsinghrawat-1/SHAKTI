import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Vector-drawn SHAKTI Shield & Trishula (Trident) Medallion matching Stitch
class ShaktiEmblem extends StatefulWidget {
  final double size;
  final bool animatePulse;

  const ShaktiEmblem({
    super.key,
    this.size = 140.0,
    this.animatePulse = true,
  });

  @override
  State<ShaktiEmblem> createState() => _ShaktiEmblemState();
}

class _ShaktiEmblemState extends State<ShaktiEmblem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animatePulse) {
      _controller.repeat();
    }
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
        final angle = _controller.value * 2 * math.pi;

        return SizedBox(
          width: widget.size + 40,
          height: widget.size + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Soft Ambient Pulse Ring
              if (widget.animatePulse) ...[
                Container(
                  width: widget.size + 24,
                  height: widget.size + 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixedDim.withValues(alpha: 0.2),
                  ),
                ),
                Container(
                  width: widget.size + 12,
                  height: widget.size + 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed.withValues(alpha: 0.35),
                  ),
                ),
              ],

              // Tactile Raised Frosted Layer (Medallion)
              Container(
                width: widget.size,
                height: widget.size,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.85),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28A6B4C8),
                      offset: Offset(4, 8),
                      blurRadius: 20,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-4, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFF2F4F7),
                        Color(0xFFE6E8EB),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1EA6B4C8),
                        offset: Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: widget.size * 0.52,
                      height: widget.size * 0.52,
                      child: CustomPaint(
                        painter: _TrishulaShieldPainter(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),

              // Orbiting Micro Beacon
              if (widget.animatePulse)
                Positioned(
                  left: (widget.size + 40) / 2 +
                      ((widget.size + 16) / 2) * math.cos(angle) -
                      5,
                  top: (widget.size + 40) / 2 +
                      ((widget.size + 16) / 2) * math.sin(angle) -
                      5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.radiantCoral,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.radiantCoral.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TrishulaShieldPainter extends CustomPainter {
  final Color color;

  _TrishulaShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate scale from SVG viewport 72 x 72
    final scale = size.width / 72.0;
    canvas.save();
    canvas.scale(scale, scale);

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Shield Path
    final shieldPath = Path()
      ..moveTo(36, 6)
      ..lineTo(14, 16.5)
      ..lineTo(14, 34.5)
      ..cubicTo(14, 49.2, 23.4, 62.8, 36, 66)
      ..cubicTo(48.6, 62.8, 58, 49.2, 58, 34.5)
      ..lineTo(58, 16.5)
      ..close();

    canvas.drawPath(shieldPath, fillPaint);
    canvas.drawPath(shieldPath, strokePaint);

    // Trishula center spear
    final spearLine = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(36, 17), const Offset(36, 51), spearLine);

    // Center spearhead
    final spearHead = Path()
      ..moveTo(36, 14)
      ..lineTo(39.5, 21)
      ..lineTo(32.5, 21)
      ..close();
    canvas.drawPath(spearHead, solidPaint);

    // Left curved prong
    final leftProng = Path()
      ..moveTo(25, 24)
      ..cubicTo(25, 32, 29.5, 37, 36, 37);
    canvas.drawPath(leftProng, strokePaint);

    final leftProngHead = Path()
      ..moveTo(25, 21.5)
      ..lineTo(27.5, 26.5)
      ..lineTo(22.5, 26.5)
      ..close();
    canvas.drawPath(leftProngHead, solidPaint);

    // Right curved prong
    final rightProng = Path()
      ..moveTo(47, 24)
      ..cubicTo(47, 32, 42.5, 37, 36, 37);
    canvas.drawPath(rightProng, strokePaint);

    final rightProngHead = Path()
      ..moveTo(47, 21.5)
      ..lineTo(49.5, 26.5)
      ..lineTo(44.5, 26.5)
      ..close();
    canvas.drawPath(rightProngHead, solidPaint);

    // Central Protective Diamond/Circle Node
    canvas.drawCircle(const Offset(36, 42), 3.0, solidPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrishulaShieldPainter oldDelegate) =>
      oldDelegate.color != color;
}
