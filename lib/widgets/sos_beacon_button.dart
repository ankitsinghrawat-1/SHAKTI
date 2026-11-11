import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/safety_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Centerpiece SOS button with 3-second long-press ring, triple shockwave pulse,
/// triple-tap fallback, and tremor-safe slide-to-dispatch.
class SosBeaconButton extends StatefulWidget {
  final VoidCallback onTrigger;

  const SosBeaconButton({
    super.key,
    required this.onTrigger,
  });

  @override
  State<SosBeaconButton> createState() => _SosBeaconButtonState();
}

class _SosBeaconButtonState extends State<SosBeaconButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _holdController;

  int _tapCount = 0;
  Timer? _tapResetTimer;
  double _slidePosition = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _holdController.reset();
        widget.onTrigger();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    _tapResetTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    _tapCount++;
    _tapResetTimer?.cancel();
    _tapResetTimer = Timer(const Duration(milliseconds: 1000), () {
      _tapCount = 0;
    });

    if (_tapCount >= 3) {
      _tapCount = 0;
      widget.onTrigger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SafetyProvider? safety;
    try {
      safety = Provider.of<SafetyProvider>(context, listen: true);
    } catch (_) {}
    final strings = safety?.strings;

    return Column(
      children: [
        // Pulsing Rings & Circular SOS Dome
        SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Radial Halo
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryContainer.withValues(alpha: 0.08),
                ),
              ),

              // Animated Outward Ripple Ring
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 190 + (_pulseController.value * 45),
                    height: 190 + (_pulseController.value * 45),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary
                            .withValues(alpha: 0.3 * (1.0 - _pulseController.value)),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

              // Concave Neumorphic Cradle
              Container(
                width: 192,
                height: 192,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerLow,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-6, -6),
                      blurRadius: 14,
                    ),
                    BoxShadow(
                      color: Color(0x59A6B4C8),
                      offset: Offset(6, 6),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),

              // Animated Radial Progress Arc for Hold
              AnimatedBuilder(
                animation: _holdController,
                builder: (context, child) {
                  return SizedBox(
                    width: 188,
                    height: 188,
                    child: CustomPaint(
                      painter: _ArcProgressPainter(
                        progress: _holdController.value,
                        color: AppColors.deepCrimson,
                      ),
                    ),
                  );
                },
              ),

              // High-Urgency Convex Tactile Dome Button
              GestureDetector(
                onTapDown: (_) => _holdController.forward(),
                onTapUp: (_) {
                  _holdController.reverse();
                  _onTap();
                },
                onTapCancel: () => _holdController.reverse(),
                child: Container(
                  width: 156,
                  height: 156,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE82F34),
                        Color(0xFFB41D26),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x99FFFFFF),
                        offset: Offset(-4, -4),
                        blurRadius: 12,
                      ),
                      BoxShadow(
                        color: Color(0x73B41D26),
                        offset: Offset(0, 14),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emergency,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SOS',
                        style: AppTypography.displayMobile.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PRESS 3s',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primaryFixed,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tactical Instruction
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.touch_app_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings?.sosHoldPrompt ?? 'Hold 3s or Tap 3x for Silent Distress',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    strings?.isHindi == true
                        ? '4 अभिभावकों और नजदीकी सुरक्षा इकाइयों को सतर्क करता है'
                        : 'Alerts 4 guardians & nearby safe units',
                    style: AppTypography.labelSm.copyWith(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Tremor-Safe Slide Alternative Bar
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final maxDelta = math.max(0.0, trackWidth - 54);

            return Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFFDECEF),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Animated Track Fill
                  Container(
                    width: math.max(48.0, _slidePosition + 46),
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),

                  // Center Label
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 44),
                      child: Text(
                        strings?.sosSlidePrompt ?? 'Slide to dispatch immediately',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Draggable Thumb
                  Positioned(
                    left: _slidePosition,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (!mounted) return;
                        setState(() {
                          _slidePosition += details.delta.dx;
                          if (_slidePosition < 0) _slidePosition = 0;
                          if (_slidePosition > maxDelta) _slidePosition = maxDelta;
                        });
                      },
                      onHorizontalDragEnd: (_) {
                        if (!mounted) return;
                        if (_slidePosition >= maxDelta * 0.88) {
                          setState(() => _slidePosition = 0);
                          widget.onTrigger();
                        } else {
                          setState(() => _slidePosition = 0);
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x18B41D26),
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6.0) / 2;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
