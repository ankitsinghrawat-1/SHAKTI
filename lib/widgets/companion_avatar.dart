import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Vector illustrated avatar for the SHAKTI AI Safety Companion
/// Matches the feminine visual identity from the Stitch design specifications.
class CompanionAvatar extends StatelessWidget {
  final double size;
  final bool showSparkle;
  final bool isShieldVariant;

  const CompanionAvatar({
    super.key,
    this.size = 68.0,
    this.showSparkle = true,
    this.isShieldVariant = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + (showSparkle ? 8 : 0),
      height: size + (showSparkle ? 8 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Outer Soft Glow Ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD1DC),
                  Color(0xFFF9A8BD),
                  Color(0xFFE52D5E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE52D5E).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF0F3),
              ),
              clipBehavior: Clip.antiAlias,
              child: isShieldVariant
                  ? Center(
                      child: CustomPaint(
                        size: Size(size * 0.55, size * 0.55),
                        painter: _CompanionShieldPainter(color: AppColors.primary),
                      ),
                    )
                  : CustomPaint(
                      size: Size(size, size),
                      painter: _CompanionCharacterPainter(),
                    ),
            ),
          ),

          // Sparkle Star ✦ Accent
          if (showSparkle)
            Positioned(
              top: isShieldVariant ? -2 : 0,
              right: isShieldVariant ? -2 : null,
              left: isShieldVariant ? null : -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33E52D5E),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Color(0xFFE52D5E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Detailed vector painter for the safety companion character
class _CompanionCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background soft warm gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF5F7), Color(0xFFFDE4E9)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);

    // 1. Back hair / ponytail silhouette
    final hairPaint = Paint()..color = const Color(0xFF4A1A2C); // Dark plum hair
    final hairPath = Path()
      ..moveTo(w * 0.22, h * 0.45)
      ..cubicTo(w * 0.15, h * 0.25, w * 0.35, h * 0.08, w * 0.55, h * 0.08)
      ..cubicTo(w * 0.78, h * 0.08, w * 0.88, h * 0.25, w * 0.82, h * 0.50)
      ..cubicTo(w * 0.90, h * 0.65, w * 0.92, h * 0.85, w * 0.75, h * 0.95)
      ..cubicTo(w * 0.50, h * 0.95, w * 0.18, h * 0.80, w * 0.22, h * 0.45)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // 2. Neck and Shoulders (SHAKTI pink/white safety uniform jacket)
    final neckPaint = Paint()..color = const Color(0xFFFFD8C7); // Warm skin tone
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.68), width: w * 0.22, height: h * 0.2),
      const Radius.circular(6),
    );
    canvas.drawRRect(neckRect, neckPaint);

    // Jacket (White with pink collar)
    final jacketPaint = Paint()..color = Colors.white;
    final jacketPath = Path()
      ..moveTo(w * 0.18, h)
      ..lineTo(w * 0.35, h * 0.72)
      ..lineTo(w * 0.65, h * 0.72)
      ..lineTo(w * 0.82, h)
      ..close();
    canvas.drawPath(jacketPath, jacketPaint);

    // Collar rose trim
    final collarPaint = Paint()
      ..color = const Color(0xFFE52D5E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.35, h * 0.72), Offset(w * 0.50, h * 0.82), collarPaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.72), Offset(w * 0.50, h * 0.82), collarPaint);

    // Tiny trident emblem on collar
    final emblemPaint = Paint()
      ..color = const Color(0xFFB41D26)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.86), w * 0.035, emblemPaint);

    // 3. Face shape
    final facePaint = Paint()..color = const Color(0xFFFFE3D6); // Warm porcelain skin
    final facePath = Path()
      ..moveTo(w * 0.32, h * 0.36)
      ..cubicTo(w * 0.32, h * 0.22, w * 0.68, h * 0.22, w * 0.68, h * 0.36)
      ..cubicTo(w * 0.68, h * 0.56, w * 0.58, h * 0.68, w * 0.50, h * 0.68)
      ..cubicTo(w * 0.42, h * 0.68, w * 0.32, h * 0.56, w * 0.32, h * 0.36)
      ..close();
    canvas.drawPath(facePath, facePaint);

    // Rosy cheeks
    final blushPaint = Paint()..color = const Color(0x3DF472B6);
    canvas.drawCircle(Offset(w * 0.37, h * 0.50), w * 0.05, blushPaint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.50), w * 0.05, blushPaint);

    // 4. Eyes (Friendly, calm, intelligent)
    final eyePaint = Paint()
      ..color = const Color(0xFF331422)
      ..style = PaintingStyle.fill;
    // Left eye (warm open almond)
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.41, h * 0.43), width: w * 0.07, height: h * 0.07), eyePaint);
    // Right eye
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.59, h * 0.43), width: w * 0.07, height: h * 0.07), eyePaint);

    // Eye catchlights (sparkle)
    final catchPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.425, h * 0.415), w * 0.02, catchPaint);
    canvas.drawCircle(Offset(w * 0.605, h * 0.415), w * 0.02, catchPaint);

    // Soft eyebrows
    final browPaint = Paint()
      ..color = const Color(0xFF5A253A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.37, h * 0.36), Offset(w * 0.44, h * 0.37), browPaint);
    canvas.drawLine(Offset(w * 0.56, h * 0.37), Offset(w * 0.63, h * 0.36), browPaint);

    // Gentle supportive smile
    final smilePaint = Paint()
      ..color = const Color(0xFFB41D3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(w * 0.44, h * 0.56)
      ..quadraticBezierTo(w * 0.50, h * 0.61, w * 0.56, h * 0.56);
    canvas.drawPath(smilePath, smilePaint);

    // 5. Front Hair / bangs
    final frontHairPath = Path()
      ..moveTo(w * 0.30, h * 0.32)
      ..cubicTo(w * 0.35, h * 0.20, w * 0.45, h * 0.22, w * 0.52, h * 0.32)
      ..cubicTo(w * 0.58, h * 0.22, w * 0.68, h * 0.24, w * 0.70, h * 0.34)
      ..cubicTo(w * 0.65, h * 0.20, w * 0.40, h * 0.16, w * 0.30, h * 0.32)
      ..close();
    canvas.drawPath(frontHairPath, hairPaint);

    // 6. Modern Safety Headset with glowing LED ring (as in Stitch reference)
    final bandPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round;
    final headsetPath = Path()
      ..moveTo(w * 0.25, h * 0.40)
      ..cubicTo(w * 0.25, h * 0.10, w * 0.75, h * 0.10, w * 0.75, h * 0.40);
    canvas.drawPath(headsetPath, bandPaint);

    // Headset ear cup (left side prominent)
    final cupPaint = Paint()..color = const Color(0xFFE52D5E);
    canvas.drawCircle(Offset(w * 0.25, h * 0.42), w * 0.09, cupPaint);
    final cupInner = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.25, h * 0.42), w * 0.05, cupInner);

    // Headset microphone boom
    final micPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    final micPath = Path()
      ..moveTo(w * 0.25, h * 0.46)
      ..quadraticBezierTo(w * 0.30, h * 0.58, w * 0.38, h * 0.58);
    canvas.drawPath(micPath, micPaint);
    canvas.drawCircle(Offset(w * 0.39, h * 0.58), w * 0.025, cupPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Trident shield vector painter for assistant message bubbles
class _CompanionShieldPainter extends CustomPainter {
  final Color color;

  _CompanionShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Shield Path
    final shield = Path()
      ..moveTo(24, 4)
      ..lineTo(8, 12)
      ..lineTo(8, 24)
      ..cubicTo(8, 35, 15, 42, 24, 45)
      ..cubicTo(33, 42, 40, 35, 40, 24)
      ..lineTo(40, 12)
      ..close();

    canvas.drawPath(shield, fillPaint);
    canvas.drawPath(shield, strokePaint);

    // Center spear
    canvas.drawLine(const Offset(24, 12), const Offset(24, 34), Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round);

    // Spearhead
    final spearHead = Path()
      ..moveTo(24, 10)
      ..lineTo(27, 15)
      ..lineTo(21, 15)
      ..close();
    canvas.drawPath(spearHead, solidPaint);

    // Prongs
    final prongs = Path()
      ..moveTo(16, 17)
      ..cubicTo(16, 23, 20, 26, 24, 26)
      ..cubicTo(28, 26, 32, 23, 32, 17);
    canvas.drawPath(prongs, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompanionShieldPainter oldDelegate) => oldDelegate.color != color;
}
