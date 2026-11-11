import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tactile_button.dart';

class RadarScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const RadarScreen({super.key, this.onBack});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _showRouteGuidance(BuildContext context, SafeHavenModel haven, SafetyProvider safety) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.directions, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        safety.strings.isHindi ? 'सुरक्षित मार्ग मार्गदर्शन' : 'Illuminated Safe Path',
                        style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                haven.name,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                '${haven.address} • ${haven.distance}',
                style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldLightBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emeraldSafe.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: AppColors.emeraldSafe, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '96% Verified Streetlight Illumination • 4 Active CCTV Nodes Enroute',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.emeraldSafe,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _routeStep('1', 'Head North on Kasturba Gandhi Marg', 'Well-lit main corridor with wide sidewalk', true),
              _routeStep('2', 'Turn right toward Outer Circle', 'PCR Patrol Unit #14 stationed at junction', true),
              _routeStep('3', 'Arrive at destination', haven.address, false),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: TactileButton(
                  label: safety.strings.isHindi ? 'नेविगेशन शुरू करें (मॉक)' : 'Start Guided Walk',
                  style: TactileButtonStyle.primaryCrimson,
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text(
                          safety.strings.isHindi
                              ? '${haven.name} के लिए सुरक्षित मार्ग सक्रिय हुआ।'
                              : 'Guided walk active toward ${haven.name}. Guardians notified of destination.',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _routeStep(String num, String title, String desc, bool hasLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Center(
                child: Text(
                  num,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 28,
                color: AppColors.surfaceContainerHigh,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
              Text(
                desc,
                style: AppTypography.labelSm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    final filteredHavens = safety.safeHavens.where((h) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Police' && h.type.contains('Police')) return true;
      if (_selectedFilter == 'Hospitals' && h.type.contains('Hospital')) return true;
      if (_selectedFilter == 'Safe Zones' && h.type.contains('Safe Zone')) return true;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: const Border(
              bottom: BorderSide(color: Color(0x12000000), width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            safety.setNavIndex(0);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          strings.radarScreenTitle,
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const StatusBadge(
                  label: 'RADAR ACTIVE',
                  type: StatusBadgeType.emerald,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reassurance Prototype Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x18000000)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radar, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.isHindi
                          ? 'सुरक्षा रडार सिमुलेशन: सुरक्षित आश्रयों और गश्ती वैन की अनुमानित दूरी दिखाता है।'
                          : 'Radar Simulation: Displays estimated distances to verified havens and police patrol.',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Futuristic Radar Graphic Screen
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emeraldSafe,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Zone 4 • Barakhamba Sector',
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Sweep: 360° • 1km Range',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Radar Visual Canvas
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated Radar Sweeper Painter
                        AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(double.infinity, 220),
                              painter: _RadarCanvasPainter(
                                angle: _radarController.value * 2 * math.pi,
                              ),
                            );
                          },
                        ),

                        // Center User Blip
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ),

                        // Blip 1: Police Station (Top Right)
                        Positioned(
                          top: 45,
                          right: 65,
                          child: _blipPin('Police 250m', AppColors.secondary),
                        ),

                        // Blip 2: Hospital (Bottom Left)
                        Positioned(
                          bottom: 35,
                          left: 55,
                          child: _blipPin('RML 650m', AppColors.tertiary),
                        ),

                        // Blip 3: Safe Zone Metro (Bottom Right)
                        Positioned(
                          bottom: 50,
                          right: 75,
                          child: _blipPin('Metro 300m', AppColors.emeraldSafe),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', strings.isHindi ? 'सभी' : 'All Havens'),
                  const SizedBox(width: 8),
                  _filterChip('Police', strings.isHindi ? 'पुलिस 112' : 'Police 112'),
                  const SizedBox(width: 8),
                  _filterChip('Hospitals', strings.isHindi ? 'अस्पताल' : '24/7 Hospitals'),
                  const SizedBox(width: 8),
                  _filterChip('Safe Zones', strings.isHindi ? 'सुरक्षित क्षेत्र' : 'Safe Zones'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Havens List
            ...filteredHavens.map((haven) {
              final isPolice = haven.type.contains('Police');
              final isHospital = haven.type.contains('Hospital');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isPolice
                                        ? AppColors.secondaryFixed
                                        : (isHospital
                                            ? AppColors.tertiaryFixed
                                            : AppColors.primaryFixed),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPolice
                                        ? Icons.local_police
                                        : (isHospital
                                            ? Icons.local_hospital
                                            : Icons.storefront),
                                    color: isPolice
                                        ? AppColors.secondary
                                        : (isHospital
                                            ? AppColors.tertiary
                                            : AppColors.primary),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        haven.name,
                                        style: AppTypography.bodyMd.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        haven.address,
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.slateSecondary,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                haven.distance,
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (haven.isOpen247)
                                Text(
                                  'Open 24/7',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.emeraldSafe,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0x14000000)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              side: const BorderSide(color: Color(0x22000000)),
                            ),
                            icon: const Icon(Icons.phone, size: 14, color: AppColors.tertiary),
                            label: Text(
                              strings.isHindi ? 'कॉल' : 'Call Haven',
                              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Simulated call to ${haven.name} (Dialer prototype).'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.navigation, size: 14),
                            label: Text(
                              strings.isHindi ? 'सुरक्षित मार्ग' : 'Safe Route',
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => _showRouteGuidance(context, haven, safety),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _blipPin(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          boxShadow: AppDecorations.tactileExtrusionSubtle,
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RadarCanvasPainter extends CustomPainter {
  final double angle;

  _RadarCanvasPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.44;

    final circlePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Range rings (100m, 250m, 500m, 1km)
    canvas.drawCircle(center, maxRadius * 0.25, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.50, circlePaint);
    canvas.drawCircle(center, maxRadius * 0.75, circlePaint);
    canvas.drawCircle(center, maxRadius, circlePaint);

    // Crosshairs
    final crossPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy),
        Offset(center.dx + maxRadius, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius),
        Offset(center.dx, center.dy + maxRadius), crossPaint);

    // Sweep cone
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: FractionalOffset.center,
        startAngle: 0.0,
        endAngle: math.pi / 2,
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.35),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: maxRadius),
      -math.pi / 2,
      math.pi / 2,
      true,
      sweepPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RadarCanvasPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
