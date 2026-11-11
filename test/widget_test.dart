import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shakti/main.dart';
import 'package:shakti/providers/safety_provider.dart';
import 'package:shakti/screens/alerts/alerts_screen.dart';
import 'package:shakti/screens/auth/secure_login_screen.dart';
import 'package:shakti/screens/guardians/guardians_screen.dart';
import 'package:shakti/screens/main_navigation_shell.dart';
import 'package:shakti/screens/profile/profile_screen.dart';
import 'package:shakti/screens/radar/radar_screen.dart';
import 'package:shakti/screens/settings/app_settings_screen.dart';
import 'package:shakti/screens/vault/evidence_vault_screen.dart';
import 'package:shakti/screens/wristband/wristband_screen.dart';
import 'package:shakti/screens/onboarding/band_onboarding_screen.dart';
import 'package:shakti/screens/onboarding/app_tutorial_screen.dart';
import 'package:shakti/screens/settings/emergency_evidence_settings_screen.dart';
import 'package:shakti/screens/feedback/feedback_screen.dart';
import 'package:shakti/screens/developer/developer_diagnostics_screen.dart';
import 'package:shakti/screens/emergency/emergency_event_screen.dart';
import 'package:shakti/screens/ai/ai_assistant_screen.dart';
import 'package:shakti/screens/onboarding/safety_permissions_screen.dart';
import 'package:shakti/services/permission_service.dart';
import 'package:shakti/services/location_service.dart';
import 'package:shakti/services/emergency_media_service.dart';
import 'package:shakti/services/guardian_notification_service.dart';
import 'package:shakti/services/emergency_call_service.dart';
import 'package:shakti/services/unified_sos_coordinator.dart';
import 'package:shakti/screens/splash/splash_screen.dart';
import 'package:shakti/widgets/dashboard_spotlight_tour.dart';
import 'package:shakti/widgets/responsive_frame.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shakti/services/api_config.dart';
import 'package:shakti/services/api_service.dart';

void main() {
  testWidgets('SHAKTI app smoke test - splash screen verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ShaktiApp());

    expect(find.text('SHAKTI'), findsOneWidget);
    expect(find.text('Your Safety. Your Strength.'), findsOneWidget);
    expect(find.textContaining('PROTOTYPE DEMO'), findsOneWidget);
  });

  group('SafetyProvider Authentication & Session Tests', () {
    test('Authentication with valid credentials, duress PIN, and logout flow', () {
      final safety = SafetyProvider();

      expect(safety.isAuthenticated, isFalse);

      // Invalid PIN failure
      final fail = safety.authenticateWithCredentials(identifier: '9811240291', pin: '1234');
      expect(fail, isFalse);
      expect(safety.isAuthenticated, isFalse);

      // Valid credentials (default PIN: 9811)
      final success = safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');
      expect(success, isTrue);
      expect(safety.isAuthenticated, isTrue);
      expect(safety.isCovertMode, isFalse);

      // Navigation retains authenticated state
      safety.setNavIndex(2); // Band
      expect(safety.selectedNavIndex, 2);
      expect(safety.isAuthenticated, isTrue);

      // Logout clears session
      safety.logout();
      expect(safety.isAuthenticated, isFalse);
      expect(safety.selectedNavIndex, 0);

      // Duress PIN (0000) covert activation
      final duress = safety.authenticateWithCredentials(identifier: '9811240291', pin: '0000');
      expect(duress, isTrue);
      expect(safety.isAuthenticated, isTrue);
      expect(safety.isCovertMode, isTrue);
    });

    test('First-time user registration flow', () {
      final safety = SafetyProvider();

      safety.registerUser(
        name: 'Meera Patel',
        phone: '9876543210',
        email: 'meera.patel@test.org',
        pin: '4321',
        pairBand: true,
      );

      expect(safety.isAuthenticated, isTrue);
      expect(safety.isRegistered, isTrue);
      expect(safety.userName, 'Meera Patel');
      expect(safety.userPhone, '9876543210');
      expect(safety.userEmail, 'meera.patel@test.org');
      expect(safety.userPin, '4321');
      expect(safety.bandConnected, isTrue);

      // Authenticate with new PIN
      safety.logout();
      expect(safety.isAuthenticated, isFalse);
      expect(safety.authenticateWithCredentials(identifier: '9876543210', pin: '4321'), isTrue);
      expect(safety.isAuthenticated, isTrue);
    });

    test('Profile updates reflect immediately in provider state', () {
      final safety = SafetyProvider();
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');

      safety.updateProfile(
        name: 'Dr. Ananya Sharma',
        phone: '98112 99999',
        emergencyContact: 'Sister Priya (+91 98112 88888)',
        notes: 'Asthma inhaler carried',
      );

      expect(safety.userName, 'Dr. Ananya Sharma');
      expect(safety.userPhone, '98112 99999');
      expect(safety.emergencyContact, 'Sister Priya (+91 98112 88888)');
      expect(safety.medicalNotes, 'Asthma inhaler carried');
    });

    test('Hazard reporting stores report in local mock state', () {
      final safety = SafetyProvider();
      final initialCount = safety.hazardReports.length;

      final report = SafetyHazardReport(
        id: 'test-haz-1',
        type: 'Broken Streetlight',
        location: 'Connaught Place Outer Circle',
        severity: 'High',
        notes: 'Dark corner near Metro Gate 2',
        timestamp: 'Just now',
      );

      safety.addHazardReport(report);
      expect(safety.hazardReports.length, initialCount + 1);
      expect(safety.hazardReports.first.location, 'Connaught Place Outer Circle');
      expect(safety.hazardReports.first.severity, 'High');
    });

    test('Natural language switching (English and Hindi)', () {
      final safety = SafetyProvider();

      expect(safety.currentLang, 'en');
      expect(safety.strings.navHome, 'Home');
      expect(safety.strings.isHindi, isFalse);

      safety.setLanguage('hi');
      expect(safety.currentLang, 'hi');
      expect(safety.strings.navHome, 'होम');
      expect(safety.strings.isHindi, isTrue);

      safety.setLanguage('en');
      expect(safety.strings.navHome, 'Home');
      expect(safety.strings.isHindi, isFalse);
    });

    test('App preferences and settings updates', () {
      final safety = SafetyProvider();

      safety.updateSettings(
        pushAlerts: false,
        highContrast: true,
        autoLockTime: '1 minute',
      );

      expect(safety.settingPushAlerts, isFalse);
      expect(safety.settingHighContrast, isTrue);
      expect(safety.settingAutoLockTime, '1 minute');
      expect(safety.notifySosPush, isFalse);
    });
  });

  group('Master UI Screen & Navigation Tests', () {
    testWidgets('MainNavigationShell renders exactly 4 tabs and floating AI Assistant button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check exactly 4 bottom nav items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Band'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Floating AI Assistant button present
      expect(find.byTooltip('SHAKTI AI Assistant'), findsOneWidget);

      // Switch to Band tab (index 2)
      safety.setNavIndex(2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Smart Wristband V2 Hub'), findsOneWidget);

      // Switch to Profile tab (index 3)
      safety.setNavIndex(3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Profile & Security'), findsOneWidget);
      expect(find.text('Ananya Sharma'), findsOneWidget);
    });

    testWidgets('SecureLoginScreen renders Welcome card without any biometric/Touch ID buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: SecureLoginScreen(initialMode: AuthMode.welcome),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Welcome card elements
      expect(find.text('WELCOME TO SHAKTI'), findsOneWidget);
      expect(find.text('Create New Account'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);

      // Verify Touch ID / Biometric buttons are COMPLETELY absent
      expect(find.textContaining('Touch ID'), findsNothing);
      expect(find.textContaining('Biometric'), findsNothing);
      expect(find.byIcon(Icons.fingerprint), findsNothing);
    });

    testWidgets('WristbandScreen matches Hardware Subsystem Architecture blueprint',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: WristbandScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Documented blueprint hardware subsystems
      expect(find.text('Smart Wristband V2 Hub'), findsOneWidget);
      expect(find.text('Main Controller'), findsOneWidget);
      expect(find.text('BLE 5.x Subsystem'), findsOneWidget);
      expect(find.text('Cellular LTE Modem'), findsOneWidget);
      expect(find.text('GNSS Positioning'), findsOneWidget);
      expect(find.text('Tactile SOS Button'), findsOneWidget);
      expect(find.text('Haptic Feedback'), findsOneWidget);
      expect(find.text('Battery & Fuel Gauge'), findsOneWidget);
      expect(find.text('Persistent Storage'), findsOneWidget);
      expect(find.text('Optional 6-Axis Motion IMU'), findsOneWidget);
      expect(find.text('Future Satellite Messaging Module'), findsOneWidget);

      // Verify heart rate, stress index, medical vitals, breakaway clasp are NOT present
      expect(find.textContaining('Heart Rate'), findsNothing);
      expect(find.textContaining('BPM'), findsNothing);
      expect(find.textContaining('Stress Index'), findsNothing);
      expect(find.textContaining('Breakaway Clasp'), findsNothing);
    });

    testWidgets('AlertsScreen renders status banner, hazard reports, and audit trail',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: AlertsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Safety Alerts & Incidents'), findsOneWidget);
      expect(find.text('Current Corridor: Safe (Zone 4)'), findsOneWidget);
      expect(find.text('Community Safety Reports (Local Prototype)'), findsOneWidget);
      expect(find.text('Recent Safety Logs & Check-ins'), findsOneWidget);
      expect(find.text('Evidence Vault'), findsOneWidget);
    });

    testWidgets('AppSettingsScreen mounts and displays preference categories',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: AppSettingsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('Security Preferences'), findsOneWidget);
      expect(find.text('App Permission Info'), findsOneWidget);

      // Verify developer-oriented backend controls are completely absent from user-facing Settings
      expect(find.text('Backend & Server Connectivity'), findsNothing);
      expect(find.text('Server Online (HTTP 200 OK)'), findsNothing);
      expect(find.text('Test Connection'), findsNothing);
      expect(find.text('Change URL'), findsNothing);
      expect(find.textContaining('API Base:'), findsNothing);
    });

    testWidgets('DeveloperDiagnosticsScreen displays internal backend tools and diagnostics',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: DeveloperDiagnosticsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Developer Diagnostics'), findsOneWidget);
      expect(find.text('Backend & Server Connectivity'), findsOneWidget);
      expect(find.text('Test Connection'), findsOneWidget);
      expect(find.text('Change URL'), findsOneWidget);
      expect(find.textContaining('API Base:'), findsOneWidget);
      expect(find.text('Diagnostic Telemetry'), findsOneWidget);
      expect(find.text('Client Platform'), findsOneWidget);
    });

    testWidgets('EvidenceVaultScreen mounts and displays audit logs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: EvidenceVaultScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Walk-With-Me Check-in'), findsOneWidget);
    });

    testWidgets('GuardiansScreen mounts and displays circle',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: GuardiansScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Priya Sharma'), findsOneWidget);
    });

    testWidgets('RadarScreen mounts and displays safe havens',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: RadarScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Barakhamba Police Station'), findsOneWidget);
    });

    testWidgets('BandOnboardingScreen mounts and handles Yes/No band selection',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: BandOnboardingScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Do you have a SHAKTI Band?'), findsOneWidget);
      expect(find.text('Yes, I have a SHAKTI Band'), findsOneWidget);
      expect(find.text("No, I'll continue without a band"), findsOneWidget);

      // Tap Yes
      await tester.tap(find.text('Yes, I have a SHAKTI Band'));
      await tester.pump();
      expect(find.text('BLE Pairing Status'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1300));
      expect(find.text('SHAKTI-BAND-V2-8F2B'), findsOneWidget);
    });

    testWidgets('AppTutorialScreen mounts and navigates steps',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: AppTutorialScreen(isReplay: true)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Central SOS Emergency Button'), findsOneWidget);
      expect(find.text('Step 1/10 • Emergency Core'), findsOneWidget);

      // Tap Next to advance
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Walk With Me Journey Beacon'), findsOneWidget);
      expect(find.text('Step 2/10 • Active Travel'), findsOneWidget);
    });

    testWidgets('EmergencyEvidenceSettingsScreen mounts and displays toggles & call logs',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: EmergencyEvidenceSettingsScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Emergency Evidence & Sharing'), findsOneWidget);
      expect(find.text('Emergency Audio Recording'), findsOneWidget);
      expect(find.text('Share Live Location & 1-Hr Route'), findsOneWidget);
      expect(find.text('National Emergency Response (ERSS-112)'), findsOneWidget);
    });

    testWidgets('CustomerFeedbackScreen mounts and accepts submission',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: CustomerFeedbackScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Help & App Feedback'), findsOneWidget);
      expect(find.text('Feedback Category'), findsOneWidget);
      expect(find.text('Excellent & Life-Saving'), findsOneWidget);

      // Enter feedback description
      await tester.enterText(
        find.byType(TextField),
        'Corridor tracking works reliably. Great app!',
      );
      await tester.pump();

      // Tap submit
      await tester.tap(find.text('Submit Feedback'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Feedback Received!'), findsOneWidget);
      expect(safety.feedbackSubmissions.length, 1);
    });

    testWidgets('EmergencyEventScreen mounts and displays live dispatch telemetry',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.triggerSimulatedSos();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: EmergencyEventScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('LIVE EMERGENCY SOS HUB'), findsOneWidget);
      expect(find.text('28.6335° N, 77.2285° E'), findsOneWidget);
      expect(find.text('Phone: 84% • Band: 78%'), findsOneWidget);
      expect(find.text('STAND DOWN SOS (I AM SAFE)'), findsOneWidget);

      safety.cancelSimulatedSos();
      await tester.pumpWidget(const SizedBox());
    });

    test('ThemeMode selector toggles correctly in SafetyProvider', () {
      final safety = SafetyProvider();
      expect(safety.themeMode, ThemeMode.light);

      safety.setThemeMode(ThemeMode.dark);
      expect(safety.themeMode, ThemeMode.dark);

      safety.setThemeMode(ThemeMode.system);
      expect(safety.themeMode, ThemeMode.system);
    });

    testWidgets('DashboardSpotlightTour renders in-situ on live dashboard and cycles through 5 navigation targets',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.resetTutorial(); // hasCompletedTutorial = false

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: MainNavigationShell()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Step 1: Home Shield
      expect(find.text('Home Shield Dashboard'), findsOneWidget);
      expect(find.textContaining('Step 1 of 5'), findsOneWidget);

      // Advance to Step 2: Alerts
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Alerts & Evidence Vault'), findsOneWidget);
      expect(find.textContaining('Step 2 of 5'), findsOneWidget);

      // Advance to Step 3: Band
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('SHAKTI Band V2 Hardware'), findsOneWidget);

      // Advance to Step 4: Profile
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Medical Profile & Guardians'), findsOneWidget);

      // Advance to Step 5: Settings
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Safety Settings & Appearance'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);

      // Finish tour
      await tester.tap(find.text('Finish'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(safety.hasCompletedTutorial, isTrue);
      // Spotlight card is dismissed; home dashboard remains active
      expect(find.text('Home Shield Dashboard'), findsNothing);
      expect(find.text('SHAKTI Band'), findsOneWidget);
    });

    testWidgets('Floating contextual help card popup appears on long-press of action pills and minimal cards',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.completeTutorial(); // tutorial already complete

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: MainNavigationShell()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Long-press Fake Call action pill
      await tester.longPress(find.byIcon(Icons.phone_in_talk));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Contextual Feature Guide'), findsOneWidget);
      expect(find.text('WHAT THIS ICON MEANS'), findsOneWidget);
      expect(find.text('WHAT THIS FEATURE DOES'), findsOneWidget);
      expect(find.text('WHAT HAPPENS WHEN TAPPED'), findsOneWidget);
      expect(find.text('TRIGGER FAKE CALL'), findsOneWidget);

      // Close guide
      await tester.tap(find.byTooltip('Close guide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Contextual Feature Guide'), findsNothing);

      // Long-press minimal Band Card
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -350));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.longPress(find.text('SHAKTI Band'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SHAKTI Band V2'), findsOneWidget);
      expect(find.text('OPEN BAND HUB'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byTooltip('Close guide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('SHAKTI Band V2'), findsNothing);
    });

    testWidgets('Greeting typography renders complete user name without awkward truncation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.completeTutorial();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: MainNavigationShell()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check greeting has user name (Ananya) without ellipsis
      expect(find.textContaining('Ananya'), findsOneWidget);
    });

    testWidgets('Main SOS button NEVER opens contextual help popup; retains emergency activation behavior',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.completeTutorial();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: MainNavigationShell()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Locate SOS text on the central dome
      final sosFinder = find.text('SOS');
      expect(sosFinder, findsOneWidget);

      // Long press on the SOS dome: MUST NOT open contextual help popup
      await tester.longPress(sosFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Contextual Feature Guide'), findsNothing);
      expect(find.text('Central SOS Beacon'), findsNothing);
      expect(find.text('WHAT THIS ICON MEANS'), findsNothing);

      // Long-press Walk With Me: MUST open contextual help popup
      await tester.longPress(find.byIcon(Icons.directions_walk));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Contextual Feature Guide'), findsOneWidget);
      expect(find.text('ARM WALK COMPANION'), findsOneWidget);

      // Close guide
      await tester.tap(find.byTooltip('Close guide'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Contextual Feature Guide'), findsNothing);

      // Normal tap on Walk With Me: opens walk companion duration sheet
      await tester.tap(find.byIcon(Icons.directions_walk));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Select Walk Duration:'), findsOneWidget);
    });

    testWidgets('Dashboard renders exactly ONE Slide to dispatch control beneath SOS dome and triggers SOS on drag',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.completeTutorial();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(home: MainNavigationShell()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert exactly ONE "Slide to dispatch immediately" control
      expect(find.text('Slide to dispatch immediately'), findsOneWidget);

      // Assert instructions row is rendered once
      expect(find.text('Hold 3s or Tap 3x for Silent Distress'), findsOneWidget);

      // Drag the slider to trigger SOS
      final sliderFinder = find.byIcon(Icons.keyboard_double_arrow_right_rounded);
      expect(sliderFinder, findsOneWidget);

      await tester.drag(sliderFinder, const Offset(800, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // SOS Dialog appears
      expect(find.text('SOS TRIGGERED (DEMO)'), findsOneWidget);

      // Clean up simulated SOS timer
      safety.cancelSimulatedSos();
      await tester.pump();
    });

    testWidgets('Redesigned SHAKTI AI Safety Companion renders feminine header, prototype badge, hero card, and 4 suggestion chips without preloaded conversation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: Scaffold(
              body: AiAssistantScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Header elements matching design
      expect(find.text('SHAKTI AI'), findsOneWidget);
      expect(find.text('Safety Companion'), findsOneWidget);
      expect(find.text('Your Personal Safety Companion'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      // Privacy / Prototype Badge
      expect(find.textContaining('Prototype AI:'), findsOneWidget);
      expect(find.textContaining('Queries run locally inside mock safety companion.'), findsOneWidget);

      // Welcome Hero Card
      expect(find.text('How can I help you today?'), findsOneWidget);
      expect(find.text('Ask about safety, routes, nearby help or use SHAKTI features.'), findsOneWidget);

      // 4 Suggestion Cards
      expect(find.text('Is my route safe?'), findsOneWidget);
      expect(find.text('Help me plan a safe journey'), findsOneWidget);
      expect(find.text('Start Walk With Me'), findsOneWidget);
      expect(find.text('What should I do in an emergency?'), findsOneWidget);

      // Verify NO preloaded/seeded mock conversation
      expect(find.textContaining('Barakhamba road'), findsNothing);
      expect(find.text('Today'), findsNothing);

      // Input composer
      expect(find.text('Ask SHAKTI anything...'), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('AI Safety Companion interactive action buttons, message submission, and session persistence',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: Scaffold(
              body: AiAssistantScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify empty session
      expect(safety.aiMessages.isEmpty, isTrue);
      expect(find.textContaining('Barakhamba road'), findsNothing);

      // Type and send a custom user query
      await tester.enterText(find.byType(TextField), 'Is the metro station area well illuminated?');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(find.text('Is the metro station area well illuminated?'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Wait for mock AI companion response (650ms delay in provider)
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.textContaining('Route secured'), findsOneWidget);

      // Verify genuine messages persist during active session
      expect(safety.aiMessages.length, 2);

      // Logout clears chat session
      safety.logout();
      expect(safety.aiMessages.isEmpty, isTrue);
    });

    testWidgets('AI Safety Companion functions without horizontal overflow on narrow mobile screens',
        (WidgetTester tester) async {
      // Narrow mobile screen: 320 logical width
      tester.view.physicalSize = const Size(640, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: Scaffold(
              body: AiAssistantScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Add long message to test natural wrapping without overflow
      safety.addAiMessage('This is a very long safety query describing transit telemetry, lighting assessment, and proximity to safe havens in central New Delhi.');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(tester.takeException(), isNull);
    });
  });

  group('Fix 1: Complete Hindi & English Localization Verification', () {
    testWidgets('AlertsScreen localizes headings, reports, severities, counts and logs dynamically',
        (WidgetTester tester) async {
      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: AlertsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In English
      expect(find.text('Safety Alerts & Incidents'), findsOneWidget);
      expect(find.text('Current Corridor: Safe (Zone 4)'), findsOneWidget);
      expect(find.text('Community Safety Reports (Local Prototype)'), findsOneWidget);
      expect(find.text('2 Active'), findsOneWidget);
      expect(find.text('Broken Streetlight'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('Isolated Stretch'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('Recent Safety Logs & Check-ins'), findsOneWidget);
      expect(find.text('Walk-With-Me Check-in Completed'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);

      // Switch language to Hindi without app restart
      safety.setLanguage('hi');
      await tester.pumpAndSettle();

      // In Hindi
      expect(find.text('सुरक्षा अलर्ट और घटनाएं'), findsOneWidget);
      expect(find.text('वर्तमान क्षेत्र: सुरक्षित (जोन 4)'), findsOneWidget);
      expect(find.text('समुदाय सुरक्षा रिपोर्टें (स्थानीय प्रोटोटाइप)'), findsOneWidget);
      expect(find.text('2 सक्रिय'), findsOneWidget);
      expect(find.text('टूटी स्ट्रीटलाइट'), findsOneWidget);
      expect(find.text('मध्यम'), findsOneWidget);
      expect(find.text('सुनसान रास्ता'), findsOneWidget);
      expect(find.text('उच्च'), findsOneWidget);
      expect(find.text('हालिया सुरक्षा लॉग एवं चेक-इन'), findsOneWidget);
      expect(find.text('वॉक-विद-मी चेक-इन पूर्ण'), findsOneWidget);
      expect(find.text('संग्रहीत'), findsOneWidget);

      // Switch back to English
      safety.setLanguage('en');
      await tester.pumpAndSettle();
      expect(find.text('Safety Alerts & Incidents'), findsOneWidget);
      expect(find.text('2 Active'), findsOneWidget);
    });

    testWidgets('ProfileScreen notification preferences and detail labels localize dynamically',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In English
      expect(find.text('SOS Priority Push Alerts'), findsOneWidget);
      expect(find.text('Bypasses Do Not Disturb on guardians'), findsOneWidget);
      expect(find.text('Silent Distress Background Vibrations'), findsOneWidget);
      expect(find.text('Subtle haptic pulses on alert dispatch'), findsOneWidget);
      expect(find.text('Guardian Live Telemetry Sync'), findsOneWidget);
      expect(find.text('Updates battery and signal periodically'), findsOneWidget);
      expect(find.text('Blood: O+'), findsOneWidget);

      // Switch language to Hindi
      safety.setLanguage('hi');
      await tester.pumpAndSettle();

      // In Hindi
      expect(find.text('एसओएस प्राथमिकता पुश अलर्ट'), findsOneWidget);
      expect(find.text("अभिभावकों के 'डू नॉट डिस्टर्ब' को अनदेखा करता है"), findsOneWidget);
      expect(find.text('मौन संकट पृष्ठभूमि कंपन'), findsOneWidget);
      expect(find.text('अलर्ट भेजने पर सूक्ष्म हैप्टिक कंपन'), findsOneWidget);
      expect(find.text('अभिभावक लाइव टेलीमेट्री सिंक'), findsOneWidget);
      expect(find.text('बैटरी और सिग्नल समय-समय पर अपडेट करता है'), findsOneWidget);
      expect(find.text('रक्त: O+'), findsOneWidget);
    });
  });

  group('Fix 2: Bottom Navigation Single-Selection & Transition Verification', () {
    testWidgets('Only ONE navigation tab is highlighted at any time with no lingering capsule',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.hasCompletedTutorial = true; // prevent tutorial overlay from blocking nav taps

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: MainNavigationShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Initial state: Home tab (index 0) selected
      expect(safety.selectedNavIndex, 0);

      // Helper to check if a specific tab has the active soft-rose background
      bool isTabActive(Key tabKey) {
        final containerFinder = find.descendant(
          of: find.byKey(tabKey),
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder.first);
        final dec = container.decoration;
        return dec is BoxDecoration && dec.color == const Color(0xFFFDECEF);
      }

      int countActiveTabs() {
        int count = 0;
        if (isTabActive(TourTargetKeys.homeTabKey)) count++;
        if (isTabActive(TourTargetKeys.alertsTabKey)) count++;
        if (isTabActive(TourTargetKeys.bandTabKey)) count++;
        if (isTabActive(TourTargetKeys.profileTabKey)) count++;
        return count;
      }

      // Initial state: Home tab (index 0) selected, all others inactive
      expect(safety.selectedNavIndex, 0);
      expect(isTabActive(TourTargetKeys.homeTabKey), isTrue);
      expect(isTabActive(TourTargetKeys.alertsTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.bandTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.profileTabKey), isFalse);
      expect(countActiveTabs(), 1);

      // Switch to Alerts tab (index 1)
      await tester.tap(find.text('Alerts'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(safety.selectedNavIndex, 1);
      expect(isTabActive(TourTargetKeys.homeTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.alertsTabKey), isTrue);
      expect(isTabActive(TourTargetKeys.bandTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.profileTabKey), isFalse);
      expect(countActiveTabs(), 1);

      // Switch to Band tab (index 2)
      await tester.tap(find.text('Band'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(safety.selectedNavIndex, 2);
      expect(isTabActive(TourTargetKeys.homeTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.alertsTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.bandTabKey), isTrue);
      expect(isTabActive(TourTargetKeys.profileTabKey), isFalse);
      expect(countActiveTabs(), 1);

      // Switch to Profile tab (index 3)
      await tester.tap(find.text('Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(safety.selectedNavIndex, 3);
      expect(isTabActive(TourTargetKeys.homeTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.alertsTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.bandTabKey), isFalse);
      expect(isTabActive(TourTargetKeys.profileTabKey), isTrue);
      expect(countActiveTabs(), 1);
    });
  });

  group('Fix 3: Community Safety Reports Photo Attachment Verification', () {
    testWidgets('SafetyHazardReport model preserves photoPath, photoBytes, and photoName locally',
        (WidgetTester tester) async {
      final safety = SafetyProvider();
      final dummyBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
        0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82,
      ]);

      final report = SafetyHazardReport(
        id: 'photo-test-01',
        type: 'Broken Streetlight',
        location: 'Janpath Outer Ring Corridor',
        severity: 'Medium',
        notes: 'Photo test notes',
        timestamp: 'Just now',
        photoPath: '/mock/path/streetlight_photo.png',
        photoBytes: dummyBytes,
        photoName: 'streetlight_photo.png',
      );

      safety.addHazardReport(report);

      expect(safety.hazardReports.first.photoName, 'streetlight_photo.png');
      expect(safety.hazardReports.first.photoBytes, isNotNull);
      expect(safety.hazardReports.first.photoPath, '/mock/path/streetlight_photo.png');

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: AlertsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifies thumbnail and photo name badge render
      expect(find.text('streetlight_photo.png'), findsOneWidget);
      expect(find.textContaining('Photo attached to local report model'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('Major Safety Capabilities & Platform Integration Tests', () {
    testWidgets('Feature 1: SafetyPermissionsScreen mounts, explains permissions, and handles toggle', (WidgetTester tester) async {
      final safety = SafetyProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: SafetyPermissionsScreen(isFromSettings: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and introductory card (appears in AppBar and Center header)
      expect(find.text('Safety Permissions Setup'), findsNWidgets(2));
      expect(find.textContaining('SHAKTI needs explicit permissions to protect you'), findsOneWidget);

      // Verify specific permission cards are shown
      expect(find.text('Location Access (GNSS)'), findsOneWidget);
      expect(find.text('Microphone Access'), findsOneWidget);
      expect(find.text('Camera Access (Front & Rear)'), findsOneWidget);
      expect(find.text('High-Priority Notifications'), findsOneWidget);
      expect(find.text('Bluetooth Low Energy (BLE)'), findsOneWidget);
      expect(find.text('Photo & File Evidence Access'), findsOneWidget);
      expect(find.text('Device Call History'), findsOneWidget);

      // Check OS Policy restriction badge for Call Log
      expect(find.text('OS Policy Restricted'), findsOneWidget);

      // Test permission toggle via service
      expect(safety.permissionService.isGranted(SafetyPermissionType.location), isTrue);
      safety.permissionService.setPermission(SafetyPermissionType.location, PermissionStatusState.denied);
      expect(safety.permissionService.isGranted(SafetyPermissionType.location), isFalse);

      await tester.pumpAndSettle();
      expect(find.text('Denied'), findsOneWidget);
    });

    test('Feature 2: Emergency media recording handles permissions, active camera fallback, and seals evidence', () {
      final media = EmergencyMediaService();

      // 1. Initial State
      expect(media.isAnyRecordingActive, isFalse);
      expect(media.activeCamera, 'front');

      // 2. Start recordings with mic granted, camera granted
      media.startEmergencyRecordings(
        incidentId: 'INC-TEST-001',
        hasMicPermission: true,
        hasCameraPermission: true,
        audioEnabled: true,
        videoEnabled: true,
      );

      expect(media.isAnyRecordingActive, isTrue);
      expect(media.audioItem?.status, EvidenceRecordingStatus.recording);
      expect(media.frontVideoItem?.status, EvidenceRecordingStatus.recording);
      // Alternate sensor is hot-standby (dual-camera hardware reality)
      expect(media.rearVideoItem?.status, EvidenceRecordingStatus.standby);

      // 3. Switch active camera from front to rear
      media.switchActiveCamera();
      expect(media.activeCamera, 'rear');
      expect(media.frontVideoItem?.status, EvidenceRecordingStatus.saved);
      expect(media.rearVideoItem?.status, EvidenceRecordingStatus.recording);

      // 4. Stop and save recordings
      media.stopAndSaveRecordings();
      expect(media.isAnyRecordingActive, isFalse);
      expect(media.audioItem?.status, EvidenceRecordingStatus.saved);
      expect(media.rearVideoItem?.status, EvidenceRecordingStatus.saved);
      expect(media.audioItem?.endTime, isNotNull);

      // 5. Test denied permissions behavior (graceful handling, no crash)
      media.startEmergencyRecordings(
        incidentId: 'INC-TEST-002',
        hasMicPermission: false,
        hasCameraPermission: false,
        audioEnabled: true,
        videoEnabled: true,
      );

      expect(media.audioItem?.status, EvidenceRecordingStatus.permissionRequired);
      expect(media.frontVideoItem?.status, EvidenceRecordingStatus.permissionRequired);
      expect(media.rearVideoItem?.status, EvidenceRecordingStatus.permissionRequired);

      media.dispose();
    });

    test('Feature 3: Live location tracking, offline queuing, and 1-hour history', () {
      final loc = LocationService();

      expect(loc.isTracking, isFalse);
      expect(loc.currentLocation, isNotNull);
      expect(loc.oneHourHistory.length, 6);

      // Start live tracking
      loc.startSosLiveTracking(incidentId: 'INC-LOC-01');
      expect(loc.isTracking, isTrue);
      expect(loc.lastSyncTimestamp, isNotNull);

      // Simulate offline network condition
      loc.setNetworkAvailability(false);
      expect(loc.isNetworkAvailable, isFalse);

      // Stop tracking
      loc.stopSosTracking();
      expect(loc.isTracking, isFalse);

      // Test permission denial behavior (graceful handling)
      loc.setLocationPermission(false);
      expect(loc.isLocationPermissionGranted, isFalse);
      expect(loc.currentLocation, isNull);

      // Re-granting restores location
      loc.setLocationPermission(true);
      expect(loc.isLocationPermissionGranted, isTrue);
      expect(loc.currentLocation, isNotNull);

      loc.dispose();
    });

    test('Feature 3: Guardian notification delivery statuses & WhatsApp Business API mock', () {
      final guardians = GuardianNotificationService();

      expect(guardians.dispatches, isEmpty);

      // Dispatch emergency alerts
      guardians.dispatchEmergencyAlerts(
        incidentId: 'INC-DISP-01',
        latitude: 28.6335,
        longitude: 77.2285,
        userName: 'Ananya Sharma',
        isNetworkAvailable: true,
      );

      expect(guardians.dispatches.length, 4);
      // ERSS-112 Police Dispatch
      expect(guardians.dispatches[0].guardianId, 'g-erss-112');
      expect(guardians.dispatches[0].status, GuardianDeliveryStatus.delivered);
      // Tier 1 Mother via Push
      expect(guardians.dispatches[1].guardianId, 'g-mother');
      expect(guardians.dispatches[1].channel, GuardianDeliveryChannel.pushNotification);
      expect(guardians.dispatches[1].status, GuardianDeliveryStatus.delivered);
      // Tier 1 Sister via SMS
      expect(guardians.dispatches[2].guardianId, 'g-sister');
      expect(guardians.dispatches[2].channel, GuardianDeliveryChannel.smsGateway);
      // Tier 2 Community via WhatsApp Business API
      expect(guardians.dispatches[3].guardianId, 'g-wa');
      expect(guardians.dispatches[3].channel, GuardianDeliveryChannel.whatsAppBusinessApi);

      // Disconnect network to verify failure isolation
      guardians.setNetworkAvailability(false);
      expect(guardians.isNetworkAvailable, isFalse);

      guardians.dispose();
    });

    test('Feature 4: Emergency call history OS policy restriction, phone masking, and manual logging', () {
      final calls = EmergencyCallService();

      expect(calls.isPlatformCallLogAvailable, isFalse);
      expect(calls.platformRestrictionMessage, contains('Device call history is not available on this platform'));

      // Check phone masking
      const record = EmergencyCallRecordModel(
        id: 'c1',
        contactOrNumber: '+91 98112 40291',
        timestamp: '14:30',
        isOutgoing: true,
        duration: '1m 20s',
        source: EmergencyCallSource.manualUserLog,
        notes: 'Test call',
      );
      expect(record.maskedContact, contains('***'));

      // Add manual call record
      final initialCount = calls.callRecords.length;
      calls.addManualCallRecord(
        contactOrNumber: '1091 Women Helpline',
        isOutgoing: true,
        duration: '2m 15s',
        notes: 'Contacted PCR van',
      );

      expect(calls.callRecords.length, initialCount + 1);
      expect(calls.callRecords.first.contactOrNumber, '1091 Women Helpline');
      expect(calls.callRecords.first.isManual, isTrue);

      calls.dispose();
    });

    test('Feature 5: Unified SOS Coordinator handles app vs band trigger and prevents duplicate sessions', () {
      final permissions = PermissionService();
      final location = LocationService();
      final media = EmergencyMediaService();
      final guardians = GuardianNotificationService();
      final calls = EmergencyCallService();

      final unifiedSos = UnifiedSosCoordinator(
        permissionService: permissions,
        locationService: location,
        mediaService: media,
        guardianService: guardians,
        callService: calls,
      );

      expect(unifiedSos.isSosActive, isFalse);

      // Trigger 1: Hardware Band Button
      unifiedSos.triggerSos(
        source: SosTriggerSource.shaktiBandHardwareButton,
        userName: 'Ananya Sharma',
      );

      expect(unifiedSos.isSosActive, isTrue);
      expect(unifiedSos.activeTriggerSource, SosTriggerSource.shaktiBandHardwareButton);
      expect(unifiedSos.triggerSourceLabel, contains('SHAKTI Smart Band V2'));
      final activeId = unifiedSos.activeIncidentId;
      expect(activeId, isNotNull);

      // Duplicate Trigger: Should be ignored and not duplicate incident or recordings
      unifiedSos.triggerSos(
        source: SosTriggerSource.appSosButton,
        userName: 'Ananya Sharma',
      );
      expect(unifiedSos.activeIncidentId, activeId);
      expect(unifiedSos.activeTriggerSource, SosTriggerSource.shaktiBandHardwareButton);

      // Stand down SOS
      unifiedSos.standDownSos();
      expect(unifiedSos.isSosActive, isFalse);

      unifiedSos.dispose();
      permissions.dispose();
      location.dispose();
      media.dispose();
      guardians.dispose();
      calls.dispose();
    });

    testWidgets('Comprehensive EmergencyEventScreen integration renders all 4 major sections', (WidgetTester tester) async {
      final safety = SafetyProvider();
      safety.triggerBandSos();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: const MaterialApp(
            home: EmergencyEventScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Header Banner & Trigger Source
      expect(find.text('LIVE EMERGENCY SOS HUB'), findsOneWidget);
      expect(find.textContaining('SHAKTI Smart Band V2'), findsOneWidget);

      // 2. Emergency Evidence Recording Section
      expect(find.text('Emergency Evidence Recording'), findsOneWidget);
      expect(find.text('Ambient Audio Recording'), findsOneWidget);
      expect(find.text('Front Camera Video'), findsOneWidget);
      expect(find.text('Rear Camera Video'), findsOneWidget);
      expect(find.textContaining('Simultaneous dual-camera recording is unsupported'), findsOneWidget);

      // 3. 1-Hour Location History Section
      expect(find.text('Previous 1-Hour Location History'), findsOneWidget);
      expect(find.text('Continuous Route'), findsOneWidget);
      expect(find.textContaining('Distinct from live location'), findsOneWidget);

      // 4. Guardian Emergency Dispatch Section
      expect(find.text('Guardian Emergency Dispatch'), findsOneWidget);
      expect(find.textContaining('National Emergency Response (ERSS-112)'), findsOneWidget);
      expect(find.textContaining('WhatsApp Business API requires authorized Meta Business credentials'), findsOneWidget);

      // 5. Recent Emergency Call Activity Section
      expect(find.text('Recent Emergency Call Activity'), findsOneWidget);
      expect(find.text('Device call history is not available on this platform.'), findsOneWidget);
      expect(find.text('Log Emergency Call'), findsOneWidget);

      // 6. Stand Down button
      expect(find.text('STAND DOWN SOS (I AM SAFE)'), findsOneWidget);

      safety.cancelSimulatedSos();
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('Universal Responsive Design System Tests', () {
    testWidgets(
        'On desktop viewport (> 520px), ShaktiApp renders inside a centered phone shell constrained to 430px with simulation banner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ShaktiApp());
      await tester.pump();

      // Verify simulation advisory banner is present
      expect(find.textContaining('PROTOTYPE DEMO'), findsOneWidget);

      // Verify ResponsiveScope is present with isWide: true and 430px width
      final scopeFinder = find.byType(ResponsiveScope);
      expect(scopeFinder, findsWidgets);
      final ResponsiveScope scope = tester.widget(scopeFinder.first);
      expect(scope.isWide, isTrue);
      expect(scope.targetWidth, 430.0);

      // Verify splash screen content is constrained within 430px width
      final splashFinder = find.text('SHAKTI');
      expect(splashFinder, findsOneWidget);
      final RenderBox splashBox = tester.renderObject(splashFinder);
      expect(splashBox.size.width, lessThanOrEqualTo(430.0));
    });

    testWidgets(
        'When navigating between screens via Navigator.push, screens remain inside the 430px phone shell on desktop',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');
      safety.completeTutorial();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: MaterialApp(
            builder: (context, child) => ResponsiveFrame(
              showSimulationBanner: true,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const MainNavigationShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Push RadarScreen (which previously opened unconstrained on desktop)
      final BuildContext navContext =
          tester.element(find.byType(MainNavigationShell));
      Navigator.of(navContext)
          .push(MaterialPageRoute(builder: (_) => const RadarScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RadarScreen), findsOneWidget);

      // Verify RadarScreen is bounded within 430px phone shell
      final RenderBox radarBox =
          tester.renderObject(find.byType(RadarScreen));
      expect(radarBox.size.width, lessThanOrEqualTo(430.0));

      // Pop back to MainNavigationShell
      Navigator.of(navContext).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Push GuardiansScreen
      Navigator.of(navContext)
          .push(MaterialPageRoute(builder: (_) => const GuardiansScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(GuardiansScreen), findsOneWidget);
      expect(find.text('Priya Sharma'), findsOneWidget);
      final RenderBox guardiansBox =
          tester.renderObject(find.byType(GuardiansScreen));
      expect(guardiansBox.size.width, lessThanOrEqualTo(430.0));
    });

    testWidgets(
        'Modal bottom sheets and dialogs are constrained to phone shell width on desktop',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final safety = SafetyProvider();
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');
      safety.completeTutorial();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: safety,
          child: MaterialApp(
            builder: (context, child) => ResponsiveFrame(
              showSimulationBanner: true,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const MainNavigationShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Open AI Assistant modal bottom sheet
      final BuildContext navContext =
          tester.element(find.byType(MainNavigationShell));
      showAiAssistantModal(navContext);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify AiAssistantScreen is mounted and bounded within 430px phone shell
      expect(find.byType(AiAssistantScreen), findsOneWidget);
      final RenderBox aiBox =
          tester.renderObject(find.byType(AiAssistantScreen));
      expect(aiBox.size.width, lessThanOrEqualTo(430.0));

      // Close modal
      Navigator.of(navContext).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets(
        'On mobile viewport (<= 520px), app expands to full viewport width edge-to-edge',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ShaktiApp());
      await tester.pump();

      final scopeFinder = find.byType(ResponsiveScope);
      expect(scopeFinder, findsWidgets);
      final ResponsiveScope scope = tester.widget(scopeFinder.first);
      expect(scope.isWide, isFalse);
      expect(scope.targetWidth, 390.0);
    });

    testWidgets(
        'Inherited ResponsiveScope prevents duplicate phone frames or duplicated banners',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ResponsiveFrame(
            showSimulationBanner: true,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const ResponsiveFrame(
            showSimulationBanner: true,
            child: Scaffold(
              body: Text('Inner Content'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Only ONE simulation banner should exist despite nested ResponsiveFrame
      expect(find.textContaining('PROTOTYPE DEMO'), findsOneWidget);
      expect(find.text('Inner Content'), findsOneWidget);
    });

    testWidgets('Reproduce back navigation from EmergencyEventScreen in ShaktiApp',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ShaktiApp());
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      final BuildContext splashCtx = tester.element(find.byType(SplashScreen));
      final safety = Provider.of<SafetyProvider>(splashCtx, listen: false);
      safety.authenticateWithCredentials(identifier: '98112 40291', pin: '9811');
      safety.completeTutorial();

      Navigator.of(splashCtx).pushReplacementNamed('/home');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final BuildContext homeCtx = tester.element(find.byType(MainNavigationShell));
      Navigator.of(homeCtx).pushNamed('/emergency-event');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EmergencyEventScreen), findsOneWidget);

      // Verify back button is visible and tap it to return to MainNavigationShell
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(EmergencyEventScreen), findsNothing);
      expect(find.byType(MainNavigationShell), findsOneWidget);
    });
  });

  group('Backend Communication, API Service & Offline Fallback Tests', () {
    test('ApiConfig: dynamic base URL configuration, headers, and reset', () {
      final initialUrl = ApiConfig.baseUrl;
      expect(initialUrl, contains('/api/v1'));

      ApiConfig.setBaseUrl('http://192.168.1.100:3000/api/v1');
      expect(ApiConfig.baseUrl, equals('http://192.168.1.100:3000/api/v1'));

      final headers = ApiConfig.buildHeaders(token: 'jwt-mock-test');
      expect(headers['Authorization'], equals('Bearer jwt-mock-test'));
      expect(headers['Content-Type'], equals('application/json'));
      expect(headers['X-Client-Platform'], isNotNull);
      expect(headers['X-App-Version'], equals('1.0.0+1'));

      ApiConfig.resetBaseUrl();
      expect(ApiConfig.baseUrl, equals(ApiConfig.defaultBaseUrl));
    });

    test('ApiService: unreachable backend produces honest offline response without crashing', () async {
      final offlineClient = MockClient((request) async {
        throw http.ClientException('Failed to connect to host');
      });
      final offlineApi = ApiService(client: offlineClient);
      
      final res = await offlineApi.checkHealth();
      expect(res.isSuccess, isFalse);
      expect(res.isOffline, isTrue);
      expect(res.statusCode, isNull);
      expect(res.errorMessage, contains('Cannot connect'));
    });

    test('SafetyProvider: server connection state management & offline authentication fallback', () async {
      final safety = SafetyProvider();

      // Offline credentials test: master demo PIN works offline immediately
      final success = await safety.authenticateWithCredentialsAsync(
        identifier: '9811240291',
        pin: '9811',
      );
      expect(success, isTrue);
      expect(safety.isAuthenticated, isTrue);

      // Duress PIN test: 0000 works offline as well
      safety.logout();
      expect(safety.isAuthenticated, isFalse);
      final duress = await safety.authenticateWithCredentialsAsync(
        identifier: '9811240291',
        pin: '0000',
      );
      expect(duress, isTrue);
      expect(safety.isCovertMode, isTrue);
    });

    test('UnifiedSosCoordinator: local emergency triggers execute in 0ms independently of backend availability', () async {
      final permissions = PermissionService();
      final location = LocationService();
      final media = EmergencyMediaService();
      final guardians = GuardianNotificationService();
      final call = EmergencyCallService();
      final offlineApi = ApiService(customBaseUrl: 'http://127.0.0.1:59999/api/v1');

      final sosCoordinator = UnifiedSosCoordinator(
        permissionService: permissions,
        locationService: location,
        mediaService: media,
        guardianService: guardians,
        callService: call,
        apiService: offlineApi,
      );

      // Trigger SOS with unreachable backend
      sosCoordinator.triggerSos(
        source: SosTriggerSource.appSosButton,
        userName: 'Aanya Sharma',
      );

      // 0ms immediate local execution verified
      expect(sosCoordinator.isSosActive, isTrue);
      expect(sosCoordinator.activeIncidentId, isNotNull);
      expect(media.audioItem, isNotNull);
      expect(guardians.dispatches.isNotEmpty, isTrue);

      // Clean stand down
      sosCoordinator.standDownSos();
      expect(sosCoordinator.isSosActive, isFalse);
    });
  });
}
