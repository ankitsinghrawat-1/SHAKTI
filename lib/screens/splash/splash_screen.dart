import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shakti_emblem.dart';
import '../../widgets/status_badge.dart';
import '../onboarding/onboarding_screen_1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<String> _enclavePhrases = [
    'Securing Biometric & Cryptographic Enclave...',
    'Connecting Dedicated Satellite Gateway...',
    'Guardian Mesh Sync Completed.',
    'System Armed & Ready.',
  ];

  final List<double> _progressValues = [0.65, 0.82, 0.94, 1.0];

  int _currentStep = 0;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _stepTimer = Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (mounted) {
        setState(() {
          _currentStep = (_currentStep + 1) % _enclavePhrases.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  void _navigateToNext() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const OnboardingScreen1(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Ambient Radial Glow Backdrop Effect
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed.withValues(alpha: 0.4),
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          children: [
                            // Header Subtle Reassurance Badges
                            Row(
                              children: [
                                const Expanded(
                                  child: StatusBadge(
                                    label: 'Encrypted Network Active',
                                    type: StatusBadgeType.emerald,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x18A6B4C8),
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.shield,
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '112 DISPATCH',
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Central Brand Emblem & Medallion
                            GestureDetector(
                              onTap: _navigateToNext,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const ShaktiEmblem(size: 110),
                                  const SizedBox(height: 20),

                                  // Wordmark & Devanagari Touch
                                  Text(
                                    'SHAKTI',
                                    style: AppTypography.displayMobile.copyWith(
                                      letterSpacing: 6.0,
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryFixed.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'शक्ति',
                                            style: AppTypography.headlineSm.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(horizontal: 8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary.withValues(alpha: 0.6),
                                            ),
                                          ),
                                          Text(
                                            "Women's Protective Network",
                                            style: AppTypography.labelSm.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Text(
                                    'Your Safety. Your Strength.',
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.slateSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Bottom Initializing Security Enclave Card
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _enclavePhrases[_currentStep],
                                          style: AppTypography.labelSm.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '100% READY',
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Hardware Progress Bar
                                  Container(
                                    width: double.infinity,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: _progressValues[_currentStep],
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 600),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondaryContainer,
                                              AppColors.primary,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Mini Trust Badges Grid
                            Row(
                              children: [
                                _buildMiniBadge(
                                  icon: Icons.vpn_key,
                                  color: AppColors.tertiary,
                                  label: '256-Bit Key',
                                ),
                                const SizedBox(width: 8),
                                _buildMiniBadge(
                                  icon: Icons.emergency,
                                  color: AppColors.primary,
                                  label: '112 Ready',
                                ),
                                const SizedBox(width: 8),
                                _buildMiniBadge(
                                  icon: Icons.verified_user,
                                  color: AppColors.emeraldSafe,
                                  label: 'SafeGov Verified',
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Skip / Tap to Enter Action
                            GestureDetector(
                              onTap: _navigateToNext,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Enter Prototype Shield',
                                      style: AppTypography.labelMd.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Build Footer
                            Text(
                              'SHAKTI OS v2.4.1 (Build 890) • Prototype Architecture',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.mutedGrey.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12A6B4C8),
              offset: Offset(1, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.slateSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
