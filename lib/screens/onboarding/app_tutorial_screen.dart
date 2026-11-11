import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tactile_button.dart';
import '../main_navigation_shell.dart';

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String tag;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.tag,
  });
}

class AppTutorialScreen extends StatefulWidget {
  final bool isReplay;

  const AppTutorialScreen({
    super.key,
    this.isReplay = false,
  });

  @override
  State<AppTutorialScreen> createState() => _AppTutorialScreenState();
}

class _AppTutorialScreenState extends State<AppTutorialScreen> {
  int _currentStepIndex = 0;

  List<TutorialStep> _getSteps(bool isHindi) {
    if (isHindi) {
      return const [
        TutorialStep(
          title: 'केंद्रीय एसओएस पैनिक बटन',
          description: 'आपात स्थिति में 3 सेकंड दबाएं या 3 बार टैप करें। आपके अभिभावकों को तुरंत लाइव लोकेशन और अलर्ट भेजा जाएगा।',
          icon: Icons.emergency,
          iconColor: AppColors.primary,
          tag: 'चरण 1/10 • आपातकालीन सुरक्षा',
        ),
        TutorialStep(
          title: 'साथ चलें (Walk With Me)',
          description: 'रात के समय घर लौटते समय लाइव जीपीएस यात्रा को अपने अभिभावकों के साथ साझा करें।',
          icon: Icons.directions_walk,
          iconColor: AppColors.tertiary,
          tag: 'चरण 2/10 • लाइव यात्रा ट्रैकिंग',
        ),
        TutorialStep(
          title: 'नकली कॉल (Fake Call)',
          description: 'असहज या संदिग्ध परिस्थिति से सुरक्षित बाहर निकलने के लिए एक नकली इनकमिंग कॉल प्राप्त करें।',
          icon: Icons.phone_callback,
          iconColor: AppColors.secondary,
          tag: 'चरण 3/10 • गुप्त युक्ति',
        ),
        TutorialStep(
          title: 'सायरन अलार्म (Siren)',
          description: 'आसपास के लोगों का ध्यान तुरंत आकर्षित करने के लिए फोन पर तेज ध्वनि अलार्म बजाएं।',
          icon: Icons.volume_up,
          iconColor: AppColors.primary,
          tag: 'चरण 4/10 • सतर्कता अलार्म',
        ),
        TutorialStep(
          title: 'कैमूफ्लाज डिकॉय (Camouflage)',
          description: 'स्क्रीन को सामान्य म्यूजिक प्लेयर में बदलें, जबकि पृष्ठभूमि में आपातकालीन सूचनाएं सक्रिय रहती हैं।',
          icon: Icons.visibility_off,
          iconColor: AppColors.slateSecondary,
          tag: 'चरण 5/10 • डुरेस गोपनीयता',
        ),
        TutorialStep(
          title: 'अभिभावक चक्र (Guardian Circle)',
          description: 'टियर 1 और टियर 2 संपर्कों को प्रबंधित करें जिन्हें संकट के समय सबसे पहले सूचित किया जाएगा।',
          icon: Icons.diversity_1,
          iconColor: AppColors.emeraldSafe,
          tag: 'चरण 6/10 • विश्वसनीय नेटवर्क',
        ),
        TutorialStep(
          title: 'सुरक्षा अलर्ट एवं रिपोर्ट',
          description: 'सड़क पर बंद स्ट्रीटलाइट या सुनसान मार्ग की सूचना देकर अन्य महिलाओं को सुरक्षित रखें।',
          icon: Icons.add_alert,
          iconColor: AppColors.primary,
          tag: 'चरण 7/10 • समुदाय सुरक्षा',
        ),
        TutorialStep(
          title: 'शक्ति स्मार्ट बैंड हब',
          description: 'स्मार्ट बैंड बैटरी, स्टैंडअलोन एलटीई और जीएनएसएस लोकेशन स्थिति की लाइव निगरानी करें।',
          icon: Icons.watch,
          iconColor: AppColors.primary,
          tag: 'चरण 8/10 • हार्डवेयर हब',
        ),
        TutorialStep(
          title: 'फ्लोटिंग एआई सुरक्षा सहायक',
          description: 'निचले दाएं कोने पर लाल-सफेद बटन दबाकर किसी भी समय सुरक्षित रास्तों व सहायता की जानकारी लें।',
          icon: Icons.chat_bubble_outline,
          iconColor: AppColors.primary,
          tag: 'चरण 9/10 • एआई साथी',
        ),
        TutorialStep(
          title: 'सेटिंग्स, थीम एवं गोपनीयता',
          description: 'लाइट/डार्क मोड चुनें, 4-अंकीय पिन बदलें, और आपातकालीन साक्ष्य रिकॉर्डिंग को नियंत्रित करें।',
          icon: Icons.tune,
          iconColor: AppColors.tertiary,
          tag: 'चरण 10/10 • नियंत्रण एवं गोपनीयता',
        ),
      ];
    }

    return const [
      TutorialStep(
        title: 'Central SOS Emergency Button',
        description: 'Hold for 3 seconds or triple-tap to instantly dispatch high-priority alerts with live coordinates to your circle.',
        icon: Icons.emergency,
        iconColor: AppColors.primary,
        tag: 'Step 1/10 • Emergency Core',
      ),
      TutorialStep(
        title: 'Walk With Me Journey Beacon',
        description: 'Shares an encrypted real-time transit breadcrumb trail and safety timer with your primary guardians.',
        icon: Icons.directions_walk,
        iconColor: AppColors.tertiary,
        tag: 'Step 2/10 • Active Travel',
      ),
      TutorialStep(
        title: 'Fake Call Decoy',
        description: 'Simulates an authentic incoming telephone call to help you gracefully exit uncomfortable interactions.',
        icon: Icons.phone_callback,
        iconColor: AppColors.secondary,
        tag: 'Step 3/10 • Discreet Tool',
      ),
      TutorialStep(
        title: 'Acoustic Siren Alarm',
        description: 'Sounds a piercing acoustic deterrent alarm through speakers to attract nearby public assistance.',
        icon: Icons.volume_up,
        iconColor: AppColors.primary,
        tag: 'Step 4/10 • Deterrent',
      ),
      TutorialStep(
        title: 'Camouflage Media Decoy',
        description: 'Instantly masks the screen into a harmless music player while quietly preserving active distress monitoring.',
        icon: Icons.visibility_off,
        iconColor: AppColors.slateSecondary,
        tag: 'Step 5/10 • Coercion Defense',
      ),
      TutorialStep(
        title: 'Guardian Circle Network',
        description: 'Organize verified Tier 1 family and Tier 2 contacts with automated battery and proximity telemetry.',
        icon: Icons.diversity_1,
        iconColor: AppColors.emeraldSafe,
        tag: 'Step 6/10 • Trusted Network',
      ),
      TutorialStep(
        title: 'Safety Alerts & Hazard Reports',
        description: 'View active safety corridor audits and log unlit stretches or hazards for fellow women commuters.',
        icon: Icons.add_alert,
        iconColor: AppColors.primary,
        tag: 'Step 7/10 • Community Intelligence',
      ),
      TutorialStep(
        title: 'SHAKTI Band V2 Hardware Hub',
        description: 'Track your wristband fuel gauge, BLE 5.x connection, standalone LTE-M, and GNSS positioning status.',
        icon: Icons.watch,
        iconColor: AppColors.primary,
        tag: 'Step 8/10 • Wearable Integration',
      ),
      TutorialStep(
        title: 'Floating AI Safety Assistant',
        description: 'Tap the circular bottom-right beacon anytime for real-time corridor illumination advice and safe navigation.',
        icon: Icons.chat_bubble_outline,
        iconColor: AppColors.primary,
        tag: 'Step 9/10 • 24/7 Enclave AI',
      ),
      TutorialStep(
        title: 'App Settings & Evidence Privacy',
        description: 'Toggle Light/Dark mode, configure PINs, and set granular audio/video emergency recording preferences.',
        icon: Icons.tune,
        iconColor: AppColors.tertiary,
        tag: 'Step 10/10 • Privacy & Controls',
      ),
    ];
  }

  void _finishTutorial(BuildContext context, SafetyProvider safety) {
    safety.completeTutorial();
    if (widget.isReplay) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const MainNavigationShell(),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = _getSteps(strings.isHindi);
    final currentStep = steps[_currentStepIndex];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.tutorialTitle,
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => _finishTutorial(context, safety),
            child: Text(
              strings.tutorialSkip,
              style: TextStyle(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: [
              // Step Progress Dots
              Row(
                children: List.generate(steps.length, (index) {
                  final isActive = index == _currentStepIndex;
                  final isPassed = index < _currentStepIndex;
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : isPassed
                                ? AppColors.primaryFixedDim
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(flex: 1),

              // Featured Step Floating Coach Card
              Center(
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentStep.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          currentStep.tag,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: currentStep.iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Animated Large Icon
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.darkSurfaceContainerLowest
                              : AppColors.surfaceContainerLowest,
                          boxShadow: [
                            BoxShadow(
                              color: currentStep.iconColor.withValues(alpha: 0.25),
                              offset: const Offset(0, 8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          currentStep.icon,
                          size: 44,
                          color: currentStep.iconColor,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Step Title
                      Text(
                        currentStep.title,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Step Description (1-2 sentences max)
                      Text(
                        currentStep.description,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                          height: 1.5,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Navigation Buttons
              Row(
                children: [
                  if (_currentStepIndex > 0) ...[
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: () {
                        setState(() => _currentStepIndex--);
                      },
                      child: Text(strings.back),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: TactileButton(
                      label: _currentStepIndex == steps.length - 1
                          ? strings.tutorialFinish
                          : strings.tutorialNext,
                      style: TactileButtonStyle.primaryCrimson,
                      trailingIcon: Icon(
                        _currentStepIndex == steps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        if (_currentStepIndex < steps.length - 1) {
                          setState(() => _currentStepIndex++);
                        } else {
                          _finishTutorial(context, safety);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
