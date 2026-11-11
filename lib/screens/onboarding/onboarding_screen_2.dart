import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tactile_button.dart';
import '../auth/secure_login_screen.dart';
import '../main_navigation_shell.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  void _navigateToLoginOrHome(BuildContext context, SafetyProvider safety) {
    if (safety.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const MainNavigationShell(),
        ),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const SecureLoginScreen(),
          transitionsBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(anim1),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Header & Global Language Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          strings.isHindi ? 'सुरक्षित 256-बिट प्रोटोकॉल' : 'E2E Encrypted • 256-bit Protocol',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Global Language Switcher
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        _langButton('EN', !strings.isHindi, () => safety.setLanguage('en')),
                        _langButton('हिंदी', strings.isHindi, () => safety.setLanguage('hi')),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Glowing Shield Emblem & Wordmark
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primaryContainer,
                                AppColors.secondary,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.emeraldSafe,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SHAKTI',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'SENTINEL',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.onPrimaryFixed,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Hero Visual Showcase Card
              GlassCard(
                padding: const EdgeInsets.all(18),
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    // Dynamic Graphic Radar Aura with Floating Badges
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.06),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryFixed.withValues(alpha: 0.7),
                            ),
                            child: const Icon(
                              Icons.emergency,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),

                          // Floating Badge 1: 3s Dispatch
                          Positioned(
                            top: 2,
                            left: 0,
                            child: _floatingBadge(
                              label: strings.isHindi ? '3s प्रेषण' : '3s Dispatch Cadence',
                              leading: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emeraldSafe,
                                ),
                              ),
                            ),
                          ),

                          // Floating Badge 2: Police 112 CAD Live
                          Positioned(
                            bottom: 2,
                            left: 2,
                            child: _floatingBadge(
                              label: strings.isHindi ? '112 पुलिस कनेक्ट' : 'Police 112 CAD Live',
                              leading: const Icon(Icons.local_police, size: 12, color: AppColors.tertiary),
                            ),
                          ),

                          // Floating Badge 3: Audio Buffer
                          Positioned(
                            top: 14,
                            right: 0,
                            child: _floatingBadge(
                              label: strings.isHindi ? 'ऑडियो रिकॉर्डिंग' : 'Zero-Latency Audio',
                              leading: const Icon(Icons.graphic_eq, size: 12, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      strings.brandSubtitle,
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      strings.isHindi
                          ? "भारत का विश्वसनीय सुरक्षा नेटवर्क। त्वरित डुरेस अलर्ट, सुरक्षित आश्रय, और 24/7 अभिभावक ट्रैकिंग।"
                          : "India's premier women's protective network. Rapid covert duress dispatches, verified Safe Havens, and 24/7 guardian telemetry.",
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.slateSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Feature Pillars Section (3 Tactile Glass Tiles)
              _featurePillarTile(
                icon: Icons.touch_app,
                iconBg: AppColors.primaryFixed,
                iconColor: AppColors.onPrimaryFixed,
                title: strings.isHindi ? 'शांत और त्वरित एसओएस' : 'Silent & Instant SOS',
                desc: strings.isHindi ? 'हार्डवेयर रिस्टबैंड ट्रिगर और गुप्त ऐप मोड' : 'Hardware wristband trigger & stealth disguise app',
                badgeText: 'COVERT',
              ),
              const SizedBox(height: 8),

              _featurePillarTile(
                icon: Icons.supervised_user_circle,
                iconBg: AppColors.tertiaryFixed,
                iconColor: AppColors.onTertiaryFixed,
                title: strings.isHindi ? 'स्वायत्त अभिभावक चक्र' : 'Autonomous Guardian Ring',
                desc: strings.isHindi ? 'बहु-स्तरीय स्वचालित आपातकालीन अलर्ट रिले' : 'Multi-tier escalation with automated telemetry',
                badgeText: '24/7 RELAY',
              ),
              const SizedBox(height: 8),

              _featurePillarTile(
                icon: Icons.storefront,
                iconBg: AppColors.secondaryFixed,
                iconColor: AppColors.onSecondaryFixed,
                title: strings.isHindi ? 'सत्यापित सुरक्षित आश्रय' : 'Verified Safe Havens',
                desc: strings.isHindi ? 'रोशन मार्ग और खुले सुरक्षित आश्रय केंद्र' : 'Real-time lighted route guidance & open safe zones',
                badgeText: 'PATROLLED',
              ),

              const SizedBox(height: 18),

              // Entry CTA Buttons
              TactileButton(
                label: strings.isHindi ? 'शुरू करें और शील्ड सेटअप करें' : 'Get Started & Setup Shield',
                trailingIcon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                style: TactileButtonStyle.primaryCrimson,
                onPressed: () => _navigateToLoginOrHome(context, safety),
              ),

              const SizedBox(height: 10),

              TactileButton(
                label: strings.isHindi ? 'मौजूदा शील्ड में लॉग इन करें' : 'Log In to Existing Shield',
                style: TactileButtonStyle.secondaryNeumorphic,
                onPressed: () => _navigateToLoginOrHome(context, safety),
              ),

              const SizedBox(height: 12),

              // Reassurance Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 12, color: AppColors.outline),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      strings.isHindi ? 'राष्ट्रीय सुरक्षा मानकों के अनुरूप प्रमाणित • शून्य डेटा बिक्री गारंटी' : 'Certified under National Safety Standards • Zero Data Selling Guarantee',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.mutedGrey,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langButton(String lang, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x18000000),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  )
                ]
              : null,
        ),
        child: Text(
          lang,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.slateSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _floatingBadge({
    required String label,
    required Widget leading,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1EA6B4C8),
            offset: Offset(1, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featurePillarTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
    required String badgeText,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.slateSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.slateSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
