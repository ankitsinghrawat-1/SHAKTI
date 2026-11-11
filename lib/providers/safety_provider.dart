import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/permission_service.dart';
import '../services/location_service.dart';
import '../services/emergency_media_service.dart';
import '../services/guardian_notification_service.dart';
import '../services/emergency_call_service.dart';
import '../services/unified_sos_coordinator.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';

class GuardianModel {
  final String id;
  final String name;
  final String role;
  final int battery;
  final String distance;
  final bool isVerified;
  final bool isEmergencyUnit;

  const GuardianModel({
    required this.id,
    required this.name,
    required this.role,
    required this.battery,
    required this.distance,
    this.isVerified = true,
    this.isEmergencyUnit = false,
  });
}

class SafeHavenModel {
  final String id;
  final String name;
  final String type; // Police, Hospital, Safe Zone, Metro
  final String distance;
  final String address;
  final bool isOpen247;
  final double rating;

  const SafeHavenModel({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.address,
    this.isOpen247 = true,
    this.rating = 4.9,
  });
}

class IncidentRecord {
  final String id;
  final String title;
  final String timestamp;
  final String location;
  final String hash;
  final String duration;
  final String status;

  const IncidentRecord({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.location,
    required this.hash,
    required this.duration,
    required this.status,
  });
}

class SafetyHazardReport {
  final String id;
  final String type;
  final String location;
  final String severity;
  final String notes;
  final String timestamp;
  final String? photoPath;
  final Uint8List? photoBytes;
  final String? photoName;

  const SafetyHazardReport({
    required this.id,
    required this.type,
    required this.location,
    required this.severity,
    required this.notes,
    required this.timestamp,
    this.photoPath,
    this.photoBytes,
    this.photoName,
  });
}

class ChatMessage {
  final String sender; // 'user' or 'ai'
  final String text;
  final String time;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });
}

class LocationBreadcrumb {
  final double latitude;
  final double longitude;
  final String timestamp;
  final String landmark;
  final double accuracy;
  final double speedKmh;

  const LocationBreadcrumb({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.landmark,
    this.accuracy = 2.5,
    this.speedKmh = 4.2,
  });
}

class EmergencyCallRecord {
  final String id;
  final String contactName;
  final String role;
  final String timestamp;
  final String duration;
  final bool isOfficial;

  const EmergencyCallRecord({
    required this.id,
    required this.contactName,
    required this.role,
    required this.timestamp,
    required this.duration,
    this.isOfficial = false,
  });
}

class FeedbackSubmission {
  final String id;
  final int rating;
  final String category;
  final String description;
  final bool hasScreenshot;
  final String timestamp;

  const FeedbackSubmission({
    required this.id,
    required this.rating,
    required this.category,
    required this.description,
    this.hasScreenshot = false,
    required this.timestamp,
  });
}

/// Centralized state and session provider for SHAKTI.
/// Manages local mock authentication, session state, language, app settings, and telemetry.
class SafetyProvider extends ChangeNotifier {
  // Service Modules
  late final PermissionService permissionService;
  late final LocationService locationService;
  late final EmergencyMediaService mediaService;
  late final GuardianNotificationService guardianService;
  late final EmergencyCallService callService;
  late final UnifiedSosCoordinator unifiedSos;
  final ApiService apiService = ApiService();

  // Server Connectivity & Network State (Section 19 Blueprint)
  ServerConnectionStatus _serverConnectionStatus = ServerConnectionStatus.unknown;
  ServerConnectionStatus get serverConnectionStatus => _serverConnectionStatus;
  bool get isServerOnline => _serverConnectionStatus == ServerConnectionStatus.online;

  String? _serverStatusMessage;
  String? get serverStatusMessage => _serverStatusMessage;

  String? _authToken;
  String? get authToken => _authToken;

  SafetyProvider() {
    permissionService = PermissionService();
    locationService = LocationService();
    mediaService = EmergencyMediaService();
    guardianService = GuardianNotificationService();
    callService = EmergencyCallService();
    unifiedSos = UnifiedSosCoordinator(
      permissionService: permissionService,
      locationService: locationService,
      mediaService: mediaService,
      guardianService: guardianService,
      callService: callService,
      apiService: apiService,
    );

    // Forward reactive updates to provider consumers
    permissionService.addListener(notifyListeners);
    locationService.addListener(notifyListeners);
    mediaService.addListener(notifyListeners);
    guardianService.addListener(notifyListeners);
    callService.addListener(notifyListeners);
    unifiedSos.addListener(notifyListeners);

    // Initial server discovery check (non-blocking)
    checkServerHealth();
  }

  // Authentication & Registration State
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isRegistered = true; // Pre-configured with demo account; can be re-registered
  bool get isRegistered => _isRegistered;

  // Stored PIN and credentials
  String _userPin = '9811';
  String get userPin => _userPin;

  String _hashedPin = '9811'.hashCode.toRadixString(16);
  String get hashedPin => _hashedPin;

  // User Profile
  String userName = 'Ananya Sharma';
  String userPhone = '98112 40291';
  String userEmail = 'ananya.sharma@shield.net';
  String shieldId = 'SH-98112-X';
  final String bloodGroup = 'O+';
  String medicalNotes = 'Penicillin Sensitive • Asthmatic inhaler carried';
  String emergencyContact = 'Dr. Kavita Sharma (+91 98112 40292)';

  // App Settings Preferences
  bool settingPushAlerts = true;
  bool settingGuardianPings = true;
  bool settingAcousticSiren = true;
  bool settingHighAccuracyGps = true;
  bool settingCovertDecoy = true;
  bool settingHighContrast = false;
  String settingAutoLockTime = '5 minutes';

  // Notification aliases
  bool get notifySosPush => settingPushAlerts;
  set notifySosPush(bool val) {
    settingPushAlerts = val;
    notifyListeners();
  }

  bool get notifySilent => settingAcousticSiren;
  set notifySilent(bool val) {
    settingAcousticSiren = val;
    notifyListeners();
  }

  bool get notifyGuardianTracking => settingGuardianPings;
  set notifyGuardianTracking(bool val) {
    settingGuardianPings = val;
    notifyListeners();
  }

  // Theme Management (Light, Dark, System Default)
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // Onboarding & Tutorial State (Section 2 & 3)
  bool hasCompletedTutorial = false;
  void completeTutorial() {
    hasCompletedTutorial = true;
    notifyListeners();
  }
  void resetTutorial() {
    hasCompletedTutorial = false;
    notifyListeners();
  }

  // Band Onboarding & Simulated Pairing State (Section 2)
  bool hasShaktiBand = true;
  String bandPairingState = 'idle'; // 'idle', 'scanning', 'discovered', 'connecting', 'paired', 'failed'
  String discoveredBandName = 'SHAKTI-BAND-V2-8F2B';
  String discoveredBandMac = 'E4:65:B8:21:8F:2B (ESP32-S3 BLE 5.x)';

  void startBandScan() {
    bandPairingState = 'scanning';
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1200), () {
      bandPairingState = 'discovered';
      notifyListeners();
    });
  }

  void connectBand() {
    bandPairingState = 'connecting';
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1400), () {
      bandPairingState = 'paired';
      hasShaktiBand = true;
      bandBleConnected = true;
      notifyListeners();
    });
  }

  void skipBandPairing() {
    hasShaktiBand = false;
    bandBleConnected = false;
    bandPairingState = 'idle';
    notifyListeners();
  }

  // Emergency Evidence & Sharing Settings (Section 4)
  bool settingEmergencyAudio = true;
  bool settingEmergencyVideo = true;
  bool settingShareAudioWithGuardians = true;
  bool settingShareVideoWithGuardians = true;
  bool settingShareLocationRoute = true;
  bool settingShareBatteryStatus = true;

  void updateEmergencyEvidenceSettings({
    bool? emergencyAudio,
    bool? emergencyVideo,
    bool? shareAudioWithGuardians,
    bool? shareVideoWithGuardians,
    bool? shareLocationRoute,
    bool? shareBatteryStatus,
  }) {
    if (emergencyAudio != null) settingEmergencyAudio = emergencyAudio;
    if (emergencyVideo != null) settingEmergencyVideo = emergencyVideo;
    if (shareAudioWithGuardians != null) settingShareAudioWithGuardians = shareAudioWithGuardians;
    if (shareVideoWithGuardians != null) settingShareVideoWithGuardians = shareVideoWithGuardians;
    if (shareLocationRoute != null) settingShareLocationRoute = shareLocationRoute;
    if (shareBatteryStatus != null) settingShareBatteryStatus = shareBatteryStatus;
    notifyListeners();
  }

  // One-Hour Location History (6 breadcrumbs over last 60 minutes)
  final List<LocationBreadcrumb> _oneHourRoute = [
    const LocationBreadcrumb(
      latitude: 28.6289,
      longitude: 77.2185,
      timestamp: '14:24 (60m ago)',
      landmark: 'Janpath Metro Station (Gate 2)',
      accuracy: 2.1,
      speedKmh: 4.5,
    ),
    const LocationBreadcrumb(
      latitude: 28.6298,
      longitude: 77.2210,
      timestamp: '14:38 (46m ago)',
      landmark: 'Tolstoy Marg Junction',
      accuracy: 2.3,
      speedKmh: 4.8,
    ),
    const LocationBreadcrumb(
      latitude: 28.6305,
      longitude: 77.2235,
      timestamp: '14:50 (34m ago)',
      landmark: 'K.G. Marg Illuminated Transit Crossing',
      accuracy: 2.0,
      speedKmh: 4.2,
    ),
    const LocationBreadcrumb(
      latitude: 28.6318,
      longitude: 77.2258,
      timestamp: '15:05 (19m ago)',
      landmark: 'Barakhamba Road Commercial Arcade',
      accuracy: 2.4,
      speedKmh: 3.9,
    ),
    const LocationBreadcrumb(
      latitude: 28.6327,
      longitude: 77.2272,
      timestamp: '15:15 (9m ago)',
      landmark: 'Statesman House Safe Zone Entry',
      accuracy: 2.2,
      speedKmh: 4.1,
    ),
    const LocationBreadcrumb(
      latitude: 28.6335,
      longitude: 77.2285,
      timestamp: '15:24 (Live)',
      landmark: 'Barakhamba Safe Corridor (Current)',
      accuracy: 1.8,
      speedKmh: 0.0,
    ),
  ];
  List<LocationBreadcrumb> get oneHourRoute => List.unmodifiable(_oneHourRoute);

  // Emergency Call History (Manual App-Initiated Logs, Section 4)
  final List<EmergencyCallRecord> _emergencyCallLogs = [
    const EmergencyCallRecord(
      id: 'call-01',
      contactName: 'National Emergency Response (ERSS-112)',
      role: 'Police & Emergency PCR Dispatch',
      timestamp: 'Today, 14:32',
      duration: '1m 45s • Connected',
      isOfficial: true,
    ),
    const EmergencyCallRecord(
      id: 'call-02',
      contactName: 'Dr. Kavita Sharma',
      role: 'Mother • Tier 1 Primary Guardian',
      timestamp: 'Yesterday, 22:41',
      duration: '42s • Completed',
      isOfficial: false,
    ),
    const EmergencyCallRecord(
      id: 'call-03',
      contactName: 'Priya Sharma',
      role: 'Sister • Tier 1 Guardian',
      timestamp: '08 Nov, 19:15',
      duration: '2m 10s • Completed',
      isOfficial: false,
    ),
  ];
  List<EmergencyCallRecord> get emergencyCallLogs => List.unmodifiable(_emergencyCallLogs);

  // Customer Feedback & Bug Reports (Section 11)
  final List<FeedbackSubmission> _feedbackSubmissions = [];
  List<FeedbackSubmission> get feedbackSubmissions => List.unmodifiable(_feedbackSubmissions);

  void submitFeedback(FeedbackSubmission feedback) {
    _feedbackSubmissions.insert(0, feedback);
    notifyListeners();

    // Background network sync
    apiService.submitFeedback(
      feedbackData: {
        'id': feedback.id,
        'rating': feedback.rating,
        'category': feedback.category,
        'description': feedback.description,
        'hasScreenshot': feedback.hasScreenshot,
        'timestamp': feedback.timestamp,
      },
      token: _authToken,
    ).then((res) {
      if (res.isSuccess && kDebugMode) {
        debugPrint('[SafetyProvider] Feedback synced to backend: ${feedback.id}');
      }
    }).catchError((_) {});
  }

  // System status
  String _safetyStatus = 'Protected';
  String get safetyStatus => _safetyStatus;

  // 4 Main Tabs: 0: Home, 1: Alerts, 2: Band, 3: Profile
  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  String _currentLang = 'en';
  String get currentLang => _currentLang;
  AppStrings get strings => AppStrings(_currentLang);

  bool _isCovertMode = false;
  bool get isCovertMode => _isCovertMode;

  bool _isSosActive = false;
  bool get isSosActive => _isSosActive;

  int _sosCountdown = 5;
  int get sosCountdown => _sosCountdown;
  Timer? _countdownTimer;

  // Hardware Blueprint Subsystems (ESP32-Class Candidate, BLE, LTE, GNSS, SOS, Haptic, Power, NVRAM)
  String bandControllerName = 'ESP32-S3 (Candidate Architecture)';
  String bandAlternativeController = 'nRF52840 (Evaluation Candidate)';
  bool bandBleConnected = true;
  bool get bandConnected => bandBleConnected;
  String bandBleStatus = 'Connected • Authenticated BLE 5.x Channel';
  bool bandLteActive = true;
  String bandLteSignal = '4G LTE-M Standalone Ready (Simulated)';
  bool bandGnssLocked = true;
  String bandGnssStatus = '3D Fix Acquired (GPS + GLONASS ±2.5m)';
  bool bandSosArmed = true;
  String bandSosButtonStatus = 'Sealed Dual-Action Tactile Armed';
  bool bandHapticActive = true;
  int bandBattery = 94;
  String bandBatteryVoltage = '4.12V • Protected Li-Po Fuel Gauge';
  int bandIncidentQueueCount = 0;
  String bandStorageStatus = 'NVRAM Queue Synced (0 Pending)';

  // Optional / Future Subsystems (Clearly labeled)
  bool bandOptionalImuArmed = true;
  String bandOptionalImuStatus = 'Optional 6-Axis IMU (Motion Context Ready)';
  bool bandOptionalSatelliteInstalled = false;
  String bandOptionalSatelliteStatus = 'Future Satellite Module (Not Installed)';

  // Guardians list
  final List<GuardianModel> _guardians = [
    const GuardianModel(
      id: 'g1',
      name: 'Priya Sharma',
      role: 'Sister • Tier 1',
      battery: 92,
      distance: '450m away',
    ),
    const GuardianModel(
      id: 'g2',
      name: 'Dr. Kavita Sharma',
      role: 'Mother • Tier 1',
      battery: 84,
      distance: '2.1km away',
    ),
    const GuardianModel(
      id: 'g3',
      name: 'Rahul Varma',
      role: 'Guardian • Tier 2',
      battery: 90,
      distance: 'Connaught Place',
    ),
    const GuardianModel(
      id: 'g4',
      name: 'Delhi PCR Unit #14',
      role: 'Verified Police Patrol',
      battery: 100,
      distance: '250m away',
      isEmergencyUnit: true,
    ),
  ];
  List<GuardianModel> get guardians => List.unmodifiable(_guardians);

  // Safe Havens
  final List<SafeHavenModel> safeHavens = const [
    SafeHavenModel(
      id: 'h1',
      name: 'Barakhamba Police Station',
      type: 'Police 112',
      distance: '250m away',
      address: 'Barakhamba Road, Connaught Place',
      isOpen247: true,
    ),
    SafeHavenModel(
      id: 'h2',
      name: 'RML Emergency Hospital',
      type: '24/7 Hospital',
      distance: '650m away',
      address: 'Baba Kharak Singh Marg',
      isOpen247: true,
    ),
    SafeHavenModel(
      id: 'h3',
      name: 'Rajiv Chowk Metro Security Post',
      type: 'Safe Zone',
      distance: '300m away',
      address: 'Gate 2, Inner Circle',
      isOpen247: true,
    ),
    SafeHavenModel(
      id: 'h4',
      name: 'Apollo 24/7 Pharmacy & Clinic',
      type: 'Safe Zone',
      distance: '180m away',
      address: 'Kasturba Gandhi Marg',
      isOpen247: true,
    ),
  ];

  // Incidents Vault
  final List<IncidentRecord> incidents = const [
    IncidentRecord(
      id: 'inc-01',
      title: 'Walk-With-Me Check-in Completed',
      timestamp: 'Today, 20:15',
      location: 'Janpath Metro Corridor',
      hash: 'sha256:7f83b165...9b82',
      duration: '18 mins • Safe',
      status: 'Archived',
    ),
    IncidentRecord(
      id: 'inc-02',
      title: 'Acoustic Monitoring Auto-Session',
      timestamp: 'Yesterday, 22:40',
      location: 'Barakhamba Crossing',
      hash: 'sha256:4a38c219...3f10',
      duration: '45 secs • Decoy',
      status: 'Verified',
    ),
    IncidentRecord(
      id: 'inc-03',
      title: 'Simulated SOS Drill Test',
      timestamp: '18 Oct, 14:10',
      location: 'Campus Inner Ring',
      hash: 'sha256:9c12e841...d720',
      duration: '05 secs • Drill',
      status: 'Logged',
    ),
  ];

  // Community Hazard Reports (Phase 11)
  final List<SafetyHazardReport> _hazardReports = [
    const SafetyHazardReport(
      id: 'haz-01',
      type: 'Broken Streetlight',
      location: 'Janpath Outer Ring Corridor',
      severity: 'Medium',
      notes: '3 light posts unlit after 21:00.',
      timestamp: 'Today, 19:40',
    ),
    const SafetyHazardReport(
      id: 'haz-02',
      type: 'Isolated Stretch',
      location: 'Subway Underpass towards Metro Gate 3',
      severity: 'High',
      notes: 'Low footfall, security booth unoccupied.',
      timestamp: 'Yesterday, 21:15',
    ),
  ];
  List<SafetyHazardReport> get hazardReports => List.unmodifiable(_hazardReports);

  Future<void> checkServerHealth() async {
    _serverConnectionStatus = ServerConnectionStatus.checking;
    notifyListeners();

    final res = await apiService.checkHealth();
    if (res.isSuccess) {
      _serverConnectionStatus = ServerConnectionStatus.online;
      _serverStatusMessage = 'Connected to ${ApiConfig.baseUrl}';
      locationService.setNetworkAvailability(true);
      guardianService.setNetworkAvailability(true);
    } else {
      _serverConnectionStatus = ServerConnectionStatus.offline;
      _serverStatusMessage = res.errorMessage ?? 'Server unreachable. Running in offline/prototype mode.';
      locationService.setNetworkAvailability(false);
      guardianService.setNetworkAvailability(false);
    }
    notifyListeners();
  }

  Future<bool> retryServerConnection() async {
    await checkServerHealth();
    if (isServerOnline) {
      await locationService.syncOfflineQueueWithApi(
        apiService: apiService,
        token: _authToken,
      );
    }
    return isServerOnline;
  }

  void addHazardReport(SafetyHazardReport report) {
    _hazardReports.insert(0, report);
    notifyListeners();

    // Background network sync
    apiService.submitHazardReport(
      reportData: {
        'id': report.id,
        'type': report.type,
        'location': report.location,
        'severity': report.severity,
        'notes': report.notes,
        'timestamp': report.timestamp,
        'photoName': report.photoName,
      },
      token: _authToken,
    ).then((res) {
      if (res.isSuccess && kDebugMode) {
        debugPrint('[SafetyProvider] Hazard report synced to server: ${report.id}');
      }
    }).catchError((_) {});
  }

  // AI Assistant Chat Messages (Floating Assistant)
  final List<ChatMessage> aiMessages = [];

  // -------------------------------------------------------------
  // Authentication & Registration Methods (Phase 2 & 4)
  // -------------------------------------------------------------

  /// Async First-time User Registration with Backend Sync & Offline Fallback
  Future<bool> registerUserAsync({
    required String name,
    required String phone,
    required String email,
    required String pin,
    bool pairBand = true,
  }) async {
    final apiRes = await apiService.register(
      name: name,
      phone: phone,
      email: email,
      pin: pin,
    );

    if (apiRes.isSuccess && apiRes.data != null) {
      _authToken = apiRes.data!['token']?.toString();
      _serverConnectionStatus = ServerConnectionStatus.online;
      _serverStatusMessage = 'Registered with backend (${ApiConfig.baseUrl})';
    } else if (apiRes.isOffline) {
      _serverConnectionStatus = ServerConnectionStatus.offline;
      _serverStatusMessage = 'Backend offline. Registered in local profile.';
    }

    return registerUser(
      name: name,
      phone: phone,
      email: email,
      pin: pin,
      pairBand: pairBand,
    );
  }

  /// First-time User Registration (Synchronous immediate execution)
  bool registerUser({
    required String name,
    required String phone,
    required String email,
    required String pin,
    bool pairBand = true,
  }) {
    if (name.trim().isEmpty || phone.trim().isEmpty || pin.length != 4) {
      return false;
    }
    userName = name.trim();
    userPhone = phone.trim();
    userEmail = email.trim().isEmpty ? '$userName@shield.net' : email.trim();
    _userPin = pin;
    _hashedPin = pin.hashCode.toRadixString(16);
    shieldId = 'SH-${phone.replaceAll(RegExp(r'\D'), '').padRight(5, '0').substring(0, 5)}-X';
    _isRegistered = true;
    _isAuthenticated = true;
    _isCovertMode = false;
    bandBleConnected = pairBand;
    aiMessages.clear();
    notifyListeners();
    return true;
  }

  /// Async Returning User Login with Backend Token Exchange & Local Fallback
  Future<bool> authenticateWithCredentialsAsync({
    required String identifier,
    required String pin,
  }) async {
    final apiRes = await apiService.login(identifier: identifier, pin: pin);

    if (apiRes.isSuccess && apiRes.data != null) {
      _authToken = apiRes.data!['token']?.toString();
      _serverConnectionStatus = ServerConnectionStatus.online;
      _serverStatusMessage = 'Authenticated with backend (${ApiConfig.baseUrl})';

      if (apiRes.data!['isCovertMode'] == true || pin == '0000') {
        _isCovertMode = true;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }

      final userData = apiRes.data!['user'] as Map<String, dynamic>?;
      if (userData != null) {
        if (userData['name'] != null) userName = userData['name'].toString();
        if (userData['phone'] != null) userPhone = userData['phone'].toString();
        if (userData['email'] != null) userEmail = userData['email'].toString();
        if (userData['shieldId'] != null) shieldId = userData['shieldId'].toString();
      }

      _userPin = pin;
      _hashedPin = pin.hashCode.toRadixString(16);
      _isAuthenticated = true;
      _isCovertMode = false;
      notifyListeners();
      return true;
    }

    // Safety-critical resilience: if backend is offline or fails to respond,
    // seamlessly fall back to local offline authentication so the user is never locked out.
    final localAuth = authenticateWithCredentials(identifier: identifier, pin: pin);
    if (localAuth) {
      _serverConnectionStatus = apiRes.isOffline ? ServerConnectionStatus.offline : ServerConnectionStatus.unknown;
      _serverStatusMessage = apiRes.isOffline
          ? 'Backend unreachable. Authenticated via local offline profile.'
          : 'Server sync unavailable (${apiRes.errorMessage ?? "code ${apiRes.statusCode}"}). Authenticated locally.';
      return true;
    }

    return false;
  }

  /// Returning User Login (Synchronous immediate check)
  bool authenticateWithCredentials({
    required String identifier,
    required String pin,
  }) {
    final cleanId = identifier.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final cleanPhone = userPhone.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    final cleanShield = shieldId.replaceAll(RegExp(r'\s+'), '').toLowerCase();

    // Duress PIN Check (0000 triggers covert decoy mode)
    if (pin == '0000') {
      _isCovertMode = true;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    // Verify PIN length
    if (pin.length != 4) return false;

    // Verify PIN matches current registered PIN or default demo PIN '9811'
    final isPinValid = (pin == _userPin || pin == '9811');

    // Verify Identifier matches or accept demo match
    final isIdValid = cleanId.isEmpty ||
        cleanId == cleanPhone ||
        cleanId.contains('9811') ||
        cleanId == cleanShield ||
        cleanId.contains('shield') ||
        cleanId.contains('ananya');

    if (isPinValid && isIdValid) {
      _hashedPin = pin.hashCode.toRadixString(16);
      _isAuthenticated = true;
      _isCovertMode = false;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Legacy helper for test compatibility
  bool authenticateWithPin(String pin) {
    return authenticateWithCredentials(identifier: userPhone, pin: pin);
  }

  /// Update Master PIN
  void updatePin(String newPin) {
    if (newPin.length == 4 && newPin != '0000') {
      _userPin = newPin;
      _hashedPin = newPin.hashCode.toRadixString(16);
      notifyListeners();
    }
  }

  /// Reset registration to test first-time onboarding
  void resetRegistration() {
    _isRegistered = false;
    _isAuthenticated = false;
    userName = '';
    userPhone = '';
    _userPin = '';
    aiMessages.clear();
    notifyListeners();
  }

  /// Safe Logout
  void logout() {
    _isAuthenticated = false;
    _selectedNavIndex = 0;
    _isSosActive = false;
    _isCovertMode = false;
    aiMessages.clear();
    notifyListeners();
  }

  /// Update Profile
  void updateProfile({
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? emergencyContact,
  }) {
    if (name != null && name.trim().isNotEmpty) userName = name.trim();
    if (phone != null && phone.trim().isNotEmpty) userPhone = phone.trim();
    if (email != null && email.trim().isNotEmpty) userEmail = email.trim();
    if (notes != null && notes.trim().isNotEmpty) medicalNotes = notes.trim();
    if (emergencyContact != null && emergencyContact.trim().isNotEmpty) {
      this.emergencyContact = emergencyContact.trim();
    }
    notifyListeners();
  }

  /// Update App Preferences
  void updateSettings({
    bool? pushAlerts,
    bool? guardianPings,
    bool? acousticSiren,
    bool? highAccuracyGps,
    bool? covertDecoy,
    bool? highContrast,
    String? autoLockTime,
  }) {
    if (pushAlerts != null) settingPushAlerts = pushAlerts;
    if (guardianPings != null) settingGuardianPings = guardianPings;
    if (acousticSiren != null) settingAcousticSiren = acousticSiren;
    if (highAccuracyGps != null) settingHighAccuracyGps = highAccuracyGps;
    if (covertDecoy != null) settingCovertDecoy = covertDecoy;
    if (highContrast != null) settingHighContrast = highContrast;
    if (autoLockTime != null) settingAutoLockTime = autoLockTime;
    notifyListeners();
  }

  void addGuardian(String name, String role, String distance) {
    _guardians.add(
      GuardianModel(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        role: role,
        battery: 100,
        distance: distance,
      ),
    );
    notifyListeners();
  }

  void addAiMessage(String text) {
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    aiMessages.add(
      ChatMessage(
        sender: 'user',
        text: text,
        time: timeStr,
      ),
    );
    notifyListeners();

    // Simulated local AI safety companion response
    Future.delayed(const Duration(milliseconds: 650), () {
      String reply = 'SHAKTI Companion: Route secured. All 4 guardians are active on your live telemetry.';
      final lower = text.toLowerCase();
      if (lower.contains('walk') || lower.contains('साथ')) {
        reply = 'Walk-With-Me: Safety check-in interval set. If unconfirmed, silent distress alerts your circle.';
      } else if (lower.contains('suspicious') || lower.contains('पीछे') || lower.contains('danger')) {
        reply = 'Alert noted: Nearest safe haven is Barakhamba Police Station (250m). Disarming decoy mode is ready.';
      } else if (lower.contains('fake') || lower.contains('कॉल')) {
        reply = 'Fake Call: Simulated incoming call ready in quick actions. Tap to launch conversation decoy.';
      } else if (lower.contains('helpline') || lower.contains('नंबर') || lower.contains('112')) {
        reply = 'Emergency Numbers: 112 (National Emergency), 1091 (Women Helpline), 181 (Women in Distress).';
      }

      aiMessages.add(
        ChatMessage(
          sender: 'ai',
          text: reply,
          time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        ),
      );
      notifyListeners();
    });
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _currentLang = lang;
    notifyListeners();
  }

  void toggleCovertMode() {
    _isCovertMode = !_isCovertMode;
    notifyListeners();
  }

  void triggerSimulatedSos({SosTriggerSource source = SosTriggerSource.appSosButton}) {
    _isSosActive = true;
    _safetyStatus = 'SOS ACTIVE (SIMULATED)';
    _sosCountdown = 5;
    unifiedSos.triggerSos(
      source: source,
      userName: userName,
      audioEnabled: settingEmergencyAudio,
      videoEnabled: settingEmergencyVideo,
    );
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sosCountdown > 0) {
        _sosCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void triggerBandSos() {
    triggerSimulatedSos(source: SosTriggerSource.shaktiBandHardwareButton);
  }

  void cancelSimulatedSos() {
    _countdownTimer?.cancel();
    _isSosActive = false;
    _sosCountdown = 5;
    _safetyStatus = 'Protected';
    unifiedSos.standDownSos();
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    permissionService.removeListener(notifyListeners);
    locationService.removeListener(notifyListeners);
    mediaService.removeListener(notifyListeners);
    guardianService.removeListener(notifyListeners);
    callService.removeListener(notifyListeners);
    unifiedSos.removeListener(notifyListeners);
    unifiedSos.dispose();
    locationService.dispose();
    mediaService.dispose();
    guardianService.dispose();
    apiService.dispose();
    super.dispose();
  }
}
