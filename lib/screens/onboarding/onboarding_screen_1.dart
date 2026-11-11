import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shakti_emblem.dart';
import '../../widgets/tactile_button.dart';
import '../auth/secure_login_screen.dart';
import 'onboarding_screen_2.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  final PageController _pageController = PageController();
  int _currentSlide = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSlideChanged(int index) {
    setState(() {
      _currentSlide = index;
    });
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  void _goToRegistration() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) =>
            const SecureLoginScreen(initialMode: AuthMode.register),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) =>
            const SecureLoginScreen(initialMode: AuthMode.login),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
      ),
    );
  }

  void _goToOnboarding2() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const OnboardingScreen2(),
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

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    final List<Map<String, dynamic>> slides = [
      {
        'step': strings.slide1Step,
        'icon': Icons.emergency,
        'title': strings.slide1Title,
        'desc': strings.slide1Desc,
        'pills': [
          {'icon': Icons.radio_button_checked, 'text': strings.pillPanic},
          {'icon': Icons.watch, 'text': strings.pillBand},
          {'icon': Icons.mic, 'text': strings.pillAudio},
        ],
      },
      {
        'step': strings.slide2Step,
        'icon': Icons.diversity_1,
        'title': strings.slide2Title,
        'desc': strings.slide2Desc,
        'pills': [
          {'icon': Icons.share_location, 'text': strings.pillMesh},
          {'icon': Icons.battery_charging_full, 'text': strings.pillTelemetry},
          {'icon': Icons.security, 'text': strings.pillCircle},
        ],
      },
      {
        'step': strings.slide3Step,
        'icon': Icons.radar,
        'title': strings.slide3Title,
        'desc': strings.slide3Desc,
        'pills': [
          {'icon': Icons.lightbulb, 'text': strings.pillLights},
          {'icon': Icons.hearing, 'text': strings.pillAcoustic},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Brand Header with Quick Language Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const ShaktiEmblem(size: 34, animatePulse: false),
                      const SizedBox(width: 8),
                      Text(
                        'SHAKTI',
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  // Language Toggle
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        _langChip('EN', !strings.isHindi, () => safety.setLanguage('en')),
                        _langChip('हिंदी', strings.isHindi, () => safety.setLanguage('hi')),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Subtitle
              Center(
                child: Column(
                  children: [
                    Text(
                      strings.brandSubtitle,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.slateSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Interactive 3-Step Feature Preview Glass Card with Swipable PageView
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  children: [
                    // Swipeable PageView Container
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onSlideChanged,
                        physics: const BouncingScrollPhysics(),
                        itemCount: slides.length,
                        itemBuilder: (context, index) {
                          final slide = slides[index];
                          return SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryFixed,
                                      ),
                                      child: Icon(
                                        slide['icon'] as IconData,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        slide['step'] as String,
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.slateSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                Text(
                                  slide['title'] as String,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Text(
                                  slide['desc'] as String,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.slateSecondary,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),

                                // Feature Pill Row
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: (slide['pills'] as List<Map<String, dynamic>>).map((p) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(p['icon'] as IconData, size: 13, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            p['text'] as String,
                                            style: AppTypography.labelSm.copyWith(
                                              fontSize: 10,
                                              color: AppColors.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(height: 1, color: Color(0x18000000)),
                    const SizedBox(height: 12),

                    // Controls: Interactive Dots and Left/Right Arrows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots
                        Row(
                          children: List.generate(slides.length, (i) {
                            final isActive = i == _currentSlide;
                            return GestureDetector(
                              onTap: () => _animateToPage(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: isActive ? 22 : 8,
                                height: 7,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Arrows
                        Row(
                          children: [
                            _circleNavButton(
                              icon: Icons.arrow_back,
                              onTap: () {
                                if (_currentSlide > 0) {
                                  _animateToPage(_currentSlide - 1);
                                } else {
                                  _animateToPage(slides.length - 1);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            _circleNavButton(
                              icon: Icons.arrow_forward,
                              onTap: () {
                                if (_currentSlide < slides.length - 1) {
                                  _animateToPage(_currentSlide + 1);
                                } else {
                                  _animateToPage(0);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Pass Gateway (Authenticates ONCE into session)
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.isHindi ? 'सुरक्षा शील्ड में प्रवेश' : 'Get Started with SHAKTI',
                                style: AppTypography.headlineSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.isHindi
                                    ? 'नया खाता बनाएं या पंजीकृत विवरण से साइन इन करें।'
                                    : 'Create a new account or sign in with your credentials.',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.slateSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                strings.verified,
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Choice 1: Create New Account (First-time user)
                    SizedBox(
                      width: double.infinity,
                      child: TactileButton(
                        label: strings.createAccountBtn,
                        trailingIcon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 18),
                        style: TactileButtonStyle.primaryCrimson,
                        height: 50,
                        onPressed: _goToRegistration,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Choice 2: Already Have an Account? Sign In (Returning user)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        onPressed: _goToLogin,
                        child: Text(
                          strings.alreadyHaveAccount,
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Navigation to full overview screen
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                        label: Text(
                          strings.isHindi ? 'शील्ड संरचना और सुरक्षा विवरण देखें' : 'View Full Shield Architecture & Pillars',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: _goToOnboarding2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langChip(String label, bool isSelected, VoidCallback onTap) {
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
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.slateSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _circleNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceContainerLow,
          boxShadow: const [
            BoxShadow(
              color: Color(0x18A6B4C8),
              offset: Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.onSurface),
      ),
    );
  }
}
