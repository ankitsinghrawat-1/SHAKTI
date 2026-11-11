import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/safety_provider.dart';
import 'screens/auth/secure_login_screen.dart';
import 'screens/emergency/emergency_event_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/guardians/guardians_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/onboarding/app_tutorial_screen.dart';
import 'screens/onboarding/band_onboarding_screen.dart';
import 'screens/onboarding/onboarding_screen_1.dart';
import 'screens/onboarding/onboarding_screen_2.dart';
import 'screens/radar/radar_screen.dart';
import 'screens/settings/app_settings_screen.dart';
import 'screens/settings/emergency_evidence_settings_screen.dart';
import 'screens/developer/developer_diagnostics_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/vault/evidence_vault_screen.dart';
import 'screens/wristband/wristband_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/responsive_frame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShaktiApp());
}

class ShaktiApp extends StatelessWidget {
  const ShaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SafetyProvider()),
      ],
      child: Consumer<SafetyProvider>(
        builder: (context, safety, child) {
          return MaterialApp(
            title: 'SHAKTI - Women Protective Network',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: safety.themeMode,
            builder: (context, child) {
              return ResponsiveFrame(
                showSimulationBanner: true,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/onboarding1': (context) => const OnboardingScreen1(),
              '/onboarding2': (context) => const OnboardingScreen2(),
              '/band-onboard': (context) => const BandOnboardingScreen(),
              '/tutorial': (context) => const AppTutorialScreen(),
              '/login': (context) => const SecureLoginScreen(),
              '/home': (context) => const MainNavigationShell(),
              '/guardians': (context) => const GuardiansScreen(),
              '/radar': (context) => const RadarScreen(),
              '/vault': (context) => const EvidenceVaultScreen(),
              '/wristband': (context) => const WristbandScreen(),
              '/settings': (context) => const AppSettingsScreen(),
              '/emergency-settings': (context) =>
                  const EmergencyEvidenceSettingsScreen(),
              '/emergency-event': (context) => const EmergencyEventScreen(),
              '/feedback': (context) => const CustomerFeedbackScreen(),
              '/developer-diagnostics': (context) =>
                  const DeveloperDiagnosticsScreen(),
            },
          );
        },
      ),
    );
  }
}
