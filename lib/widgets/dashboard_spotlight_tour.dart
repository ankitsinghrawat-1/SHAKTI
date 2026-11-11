import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'tactile_button.dart';

/// Static global keys assigned to the 5 essential navigation targets
class TourTargetKeys {
  static final GlobalKey homeTabKey = GlobalKey(debugLabel: 'tour_home_tab');
  static final GlobalKey alertsTabKey = GlobalKey(debugLabel: 'tour_alerts_tab');
  static final GlobalKey bandTabKey = GlobalKey(debugLabel: 'tour_band_tab');
  static final GlobalKey profileTabKey = GlobalKey(debugLabel: 'tour_profile_tab');
  static final GlobalKey settingsKey = GlobalKey(debugLabel: 'tour_settings_key');
}

class TourStepData {
  final GlobalKey targetKey;
  final String tagEn;
  final String tagHi;
  final String titleEn;
  final String titleHi;
  final String descriptionEn;
  final String descriptionHi;
  final IconData icon;
  final Color accentColor;
  final bool isTopTarget;

  const TourStepData({
    required this.targetKey,
    required this.tagEn,
    required this.tagHi,
    required this.titleEn,
    required this.titleHi,
    required this.descriptionEn,
    required this.descriptionHi,
    required this.icon,
    required this.accentColor,
    this.isTopTarget = false,
  });
}

/// In-situ interactive guided tour running directly over the live SHAKTI dashboard.
/// Dims the entire screen with a translucent dark overlay.
/// Highlights only the currently selected UI element with a bright cutout spotlight & pulsating ring.
/// Connects a visual pointer line from the spotlight to a floating explanation card.
class DashboardSpotlightTour extends StatefulWidget {
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final bool isHindi;

  const DashboardSpotlightTour({
    super.key,
    required this.onFinish,
    required this.onSkip,
    this.isHindi = false,
  });

  @override
  State<DashboardSpotlightTour> createState() => _DashboardSpotlightTourState();
}

class _DashboardSpotlightTourState extends State<DashboardSpotlightTour>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static final List<TourStepData> _steps = [
    TourStepData(
      targetKey: TourTargetKeys.homeTabKey,
      tagEn: 'Step 1 of 5 • Safety Hub',
      tagHi: 'चरण 1/5 • सुरक्षा हब',
      titleEn: 'Home Shield Dashboard',
      titleHi: 'केंद्रीय सुरक्षा शील्ड',
      descriptionEn:
          'Your central emergency command center. Trigger instant SOS distress beacons, monitor live protection status, and launch rapid action tools.',
      descriptionHi:
          'आपका मुख्य सुरक्षा कमांड सेंटर। तुरंत आपातकालीन एसओएस भेजें, सुरक्षा स्थिति देखें और त्वरित एक्शन टूल्स का उपयोग करें।',
      icon: Icons.shield,
      accentColor: AppColors.primary,
      isTopTarget: false,
    ),
    TourStepData(
      targetKey: TourTargetKeys.alertsTabKey,
      tagEn: 'Step 2 of 5 • Community & Audit',
      tagHi: 'चरण 2/5 • समुदाय एवं साक्ष्य',
      titleEn: 'Alerts & Evidence Vault',
      titleHi: 'अलर्ट व डिजिटल साक्ष्य',
      descriptionEn:
          'Real-time community incident warnings, unlit street hazard advisories, and encrypted audit trails recorded during active alerts.',
      descriptionHi:
          'सामुदायिक सुरक्षा चेतावनियाँ, सुनसान मार्ग रिपोर्ट और संकट के समय रिकॉर्ड किए गए डिजिटल साक्ष्य ऑडिट लॉग देखें।',
      icon: Icons.notifications,
      accentColor: AppColors.primary,
      isTopTarget: false,
    ),
    TourStepData(
      targetKey: TourTargetKeys.bandTabKey,
      tagEn: 'Step 3 of 5 • Wearable Hardware',
      tagHi: 'चरण 3/5 • स्मार्ट बैंड हार्डवेयर',
      titleEn: 'SHAKTI Band V2 Hardware',
      titleHi: 'शक्ति स्मार्ट बैंड V2',
      descriptionEn:
          'Pair and inspect your wearable hardware band. Check Bluetooth LE link strength, battery charge, and discrete physical panic triggers.',
      descriptionHi:
          'अपने पहने जाने वाले स्मार्ट बैंड को कनेक्ट व कॉन्फ़िगर करें। ब्लूटूथ कनेक्टिविटी, बैटरी और आपातकालीन स्विच की जांच करें।',
      icon: Icons.watch,
      accentColor: AppColors.tertiary,
      isTopTarget: false,
    ),
    TourStepData(
      targetKey: TourTargetKeys.profileTabKey,
      tagEn: 'Step 4 of 5 • Medical ID & Network',
      tagHi: 'चरण 4/5 • मेडिकल आईडी व संपर्क',
      titleEn: 'Medical Profile & Guardians',
      titleHi: 'मेडिकल प्रोफ़ाइल व अभिभावक',
      descriptionEn:
          'Manage your trusted Guardian Circle contacts, emergency medical history, blood group, and emergency dispatch credentials.',
      descriptionHi:
          'अपने विश्वसनीय अभिभावक संपर्कों, आपातकालीन मेडिकल विवरण, रक्त समूह और आपातकालीन पहचान को प्रबंधित करें।',
      icon: Icons.person_outline,
      accentColor: AppColors.emeraldSafe,
      isTopTarget: false,
    ),
    TourStepData(
      targetKey: TourTargetKeys.settingsKey,
      tagEn: 'Step 5 of 5 • Privacy & Duress',
      tagHi: 'चरण 5/5 • सेटिंग्स व गोपनीयता',
      titleEn: 'Safety Settings & Appearance',
      titleHi: 'सुरक्षा सेटिंग्स व थीम',
      descriptionEn:
          'Toggle Light, Dark, or System theme, configure automatic audio/video evidence sharing, and update your secret duress security PIN.',
      descriptionHi:
          'लाइट या डार्क थीम चुनें, ऑटो ऑडियो/वीडियो साक्ष्य प्रेषण नियंत्रित करें और अपना 4-अंकीय गुप्त सुरक्षा पिन कस्टमाइज़ करें।',
      icon: Icons.settings_outlined,
      accentColor: AppColors.primary,
      isTopTarget: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Refresh layout bounds once rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Rect _calculateTargetRect(GlobalKey targetKey, Size screenSize, bool isTopTarget) {
    final context = targetKey.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final parentBox = this.context.findRenderObject() as RenderBox?;
        if (parentBox != null && parentBox.hasSize) {
          final offset = renderBox.localToGlobal(Offset.zero, ancestor: parentBox);
          return offset & renderBox.size;
        }
        final offset = renderBox.localToGlobal(Offset.zero);
        return offset & renderBox.size;
      }
    }

    // High-fidelity fallback geometric coordinates if unmounted or during testing
    if (isTopTarget) {
      // Top right AppBar settings icon
      return Rect.fromCenter(
        center: Offset(screenSize.width - 50, 48),
        width: 44,
        height: 44,
      );
    } else {
      // Bottom navigation tabs (0 = Home, 1 = Alerts, 2 = Band, 3 = Profile)
      final tabWidth = (screenSize.width - 40) / 4;
      final tabIndex = _currentStepIndex.clamp(0, 3);
      final centerX = 20 + (tabIndex + 0.5) * tabWidth;
      return Rect.fromCenter(
        center: Offset(centerX, screenSize.height - 44),
        width: 48,
        height: 48,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentStep = _steps[_currentStepIndex];
    final isHindi = widget.isHindi;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final targetRect = _calculateTargetRect(currentStep.targetKey, screenSize, currentStep.isTopTarget);

    // Calculate card positioning and pointer line anchor
    final isTop = currentStep.isTopTarget;

    return Stack(
      children: [
        // Spotlight Custom Scrim with Cutout, Pulse Glow, and Connecting Pointer Line
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, _) {
              return CustomPaint(
                painter: _SpotlightOverlayPainter(
                  targetRect: targetRect,
                  pulseValue: _pulseAnimation.value,
                  accentColor: currentStep.accentColor,
                  isTopTarget: isTop,
                  screenSize: screenSize,
                ),
              );
            },
          ),
        ),

        // Floating Explanation Card
        Positioned(
          left: 16,
          right: 16,
          top: isTop ? 96 : null,
          bottom: !isTop ? 86 : null,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: currentStep.accentColor.withValues(alpha: 0.45),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: currentStep.accentColor.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Icon Badge, Step Tag, and Skip Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: currentStep.accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: currentStep.accentColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    currentStep.icon,
                                    color: currentStep.accentColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: currentStep.accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isHindi ? currentStep.tagHi : currentStep.tagEn,
                                      style: AppTypography.labelSm.copyWith(
                                        color: currentStep.accentColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: widget.onSkip,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              isHindi ? 'छोड़ें' : 'Skip',
                              style: AppTypography.labelSm.copyWith(
                                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Step Title
                      Text(
                        isHindi ? currentStep.titleHi : currentStep.titleEn,
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Step Description
                      Text(
                        isHindi ? currentStep.descriptionHi : currentStep.descriptionEn,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 12.5,
                          height: 1.4,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Navigation Controls Row: Back, Step Dots, Next / Finish
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStepIndex > 0)
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _currentStepIndex--);
                              },
                              icon: const Icon(Icons.arrow_back, size: 14),
                              label: Text(
                                isHindi ? 'पीछे' : 'Back',
                                style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            )
                          else
                            const SizedBox(width: 60),

                          // Step indicator dots
                          Row(
                            children: List.generate(_steps.length, (idx) {
                              final isCurrent = idx == _currentStepIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isCurrent ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: isCurrent
                                      ? currentStep.accentColor
                                      : (isDark ? Colors.white24 : Colors.black12),
                                ),
                              );
                            }),
                          ),

                          // Next or Finish Button
                          TactileButton(
                            label: _currentStepIndex == _steps.length - 1
                                ? (isHindi ? 'समाप्त करें' : 'Finish')
                                : (isHindi ? 'आगे बढ़ें' : 'Next'),
                            style: TactileButtonStyle.primaryCrimson,
                            icon: Icon(
                              _currentStepIndex == _steps.length - 1
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              size: 14,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_currentStepIndex < _steps.length - 1) {
                                setState(() => _currentStepIndex++);
                              } else {
                                widget.onFinish();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightOverlayPainter extends CustomPainter {
  final Rect targetRect;
  final double pulseValue;
  final Color accentColor;
  final bool isTopTarget;
  final Size screenSize;

  _SpotlightOverlayPainter({
    required this.targetRect,
    required this.pulseValue,
    required this.accentColor,
    required this.isTopTarget,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Offset.zero & size);

    // Padding around the target element
    final inflatedTarget = targetRect.inflate(6);
    final cutoutRRect = RRect.fromRectAndRadius(
      inflatedTarget,
      const Radius.circular(16),
    );

    final cutoutPath = Path()..addRRect(cutoutRRect);

    // Combine difference to create translucent overlay with a clear spotlight hole
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    final scrimPaint = Paint()..color = const Color(0x9E000000); // ~62% dark translucent overlay
    canvas.drawPath(overlayPath, scrimPaint);

    // Pulsating Glowing Ring around Cutout
    final pulseOffset = 4.0 * pulseValue;
    final pulseRRect = RRect.fromRectAndRadius(
      inflatedTarget.inflate(pulseOffset),
      const Radius.circular(18),
    );

    // Soft blur glow
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.45 * (1.0 - pulseValue * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(pulseRRect, glowPaint);

    // Crisp spotlight accent border
    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawRRect(pulseRRect, ringPaint);

    // Connecting Visual Pointer Line to the Floating Card
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    if (isTopTarget) {
      // Top target (Settings cog): line goes from bottom of cutout down to top of explanation card
      final startPoint = Offset(targetRect.center.dx, inflatedTarget.bottom + pulseOffset);
      final endPoint = Offset(targetRect.center.dx.clamp(40.0, size.width - 40.0), 96.0);

      canvas.drawLine(startPoint, endPoint, linePaint);
      canvas.drawCircle(startPoint, 3.5, dotPaint);
    } else {
      // Bottom targets (Nav items): line goes from top of cutout up to bottom of explanation card
      final startPoint = Offset(targetRect.center.dx, inflatedTarget.top - pulseOffset);
      final endPoint = Offset(targetRect.center.dx.clamp(40.0, size.width - 40.0), size.height - 86.0);

      canvas.drawLine(startPoint, endPoint, linePaint);
      canvas.drawCircle(startPoint, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightOverlayPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isTopTarget != isTopTarget;
  }
}
