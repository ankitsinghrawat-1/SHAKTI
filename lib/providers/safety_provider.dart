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
import '../services/safe_haven_service.dart';

class GuardianModel {
  final String id;
  final String name;
  final String role;
  final String phone;
  final int battery;
  final String distance;
  final bool isVerified;
  final bool isEmergencyUnit;

  const GuardianModel({
    required this.id,
    required this.name,
    required this.role,
    this.phone = '',
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
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String? phone;

  const SafeHavenModel({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.address,
    this.isOpen247 = true,
    this.rating = 4.9,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distanceMeters = 0.0,
    this.phone,
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
      authTokenProvider: () => _authToken,
      guardiansProvider: () => _guardians.map((g) => {
        'id': g.id,
        'name': g.name,
        'role': g.role,
        'phone': g.phone,
        'isOfficial': g.isEmergencyUnit,
      }).toList(),
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

    // Acquire real location and resolve address on startup (non-blocking)
    unawaited(locationService.acquireCurrentLocation().then((loc) {
      if (loc != null) {
        unawaited(refreshNearbyHavens());
      }
    }));
    locationService.startDashboardTracking();
  }

  // Authentication & Registration State
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isRegistered = false;
  bool get isRegistered => _isRegistered;

  // Stored PIN and credentials
  String _userPin = '';
  String get userPin => _userPin;

  String _hashedPin = '';
  String get hashedPin => _hashedPin;

  // User Profile
  String userName = '';
  String userPhone = '';
  String userEmail = '';
  String shieldId = '';
  final String bloodGroup = '';
  String medicalNotes = '';
  String emergencyContact = '';

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

  // Emergency Call History (Manual App-Initiated Logs, Section 4)
  final List<EmergencyCallRecord> _emergencyCallLogs = [
    const EmergencyCallRecord(
      id: 'call-01',
      contactName: 'National Emergency Response (ERSS-112)',
      role: 'Police & Emergency PCR Dispatch',
      timestamp: 'Recent SOS Session',
      duration: '1m 45s • Connected',
      isOfficial: true,
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
        'type': feedback.category,
        'message': feedback.description,
        'category': feedback.category,
        'description': feedback.description,
        'rating': feedback.rating,
        'deviceInfo': {
          'hasScreenshot': feedback.hasScreenshot,
          'clientTimestamp': feedback.timestamp,
        },
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
  final List<GuardianModel> _guardians = [];
  List<GuardianModel> get guardians => List.unmodifiable(_guardians);

  // Safe Havens (Live geospatial data: Google Places / OSM / Regional emergency nodes)
  List<SafeHavenModel> _safeHavens = [];
  List<SafeHavenModel> get safeHavens {
    if (_safeHavens.isNotEmpty) {
      return List.unmodifiable(_safeHavens);
    }

    // Contextual baseline fallback until async geospatial fetch completes
    final area = locationService.currentAddress.isNotEmpty &&
            locationService.currentAddress != 'Acquiring live location...'
        ? locationService.currentAddress
        : 'Emergency Safety Sector';

    return [
      SafeHavenModel(
        id: 'sh_police_1',
        name: strings.isHindi ? 'स्थानीय पीसीआर गश्ती वैन #08' : 'PCR Patrol Unit #08',
        type: 'Police 112',
        distance: '250m',
        address: '$area • Mobile Emergency Beat',
        isOpen247: true,
        rating: 4.9,
        phone: '112',
      ),
      SafeHavenModel(
        id: 'sh_transit_1',
        name: strings.isHindi ? 'सुरक्षित पारगमन व सहायता बूथ' : 'Transit Safety Kiosk',
        type: 'Safe Zone Metro',
        distance: '300m',
        address: '$area • High Illumination Sector',
        isOpen247: true,
        rating: 4.8,
        phone: '1091',
      ),
      SafeHavenModel(
        id: 'sh_police_2',
        name: strings.isHindi ? 'नजदीकी पुलिस सहायता चौकी' : 'Sector Police Post',
        type: 'Police 112',
        distance: '450m',
        address: '$area • 24/7 Security Assistance',
        isOpen247: true,
        rating: 5.0,
        phone: '112',
      ),
      SafeHavenModel(
        id: 'sh_hospital_1',
        name: strings.isHindi ? '24/7 आपातकालीन ट्रामा केंद्र' : '24/7 Emergency Medical Center',
        type: 'Hospital Emergency',
        distance: '650m',
        address: '$area • Trauma & Ambulance Hub',
        isOpen247: true,
        rating: 4.9,
        phone: '108',
      ),
    ];
  }

  bool _isLoadingHavens = false;
  bool get isLoadingHavens => _isLoadingHavens;

  /// Fetches real nearby hospitals, police stations, and safe havens around current GPS coordinates.
  Future<void> refreshNearbyHavens({bool force = false}) async {
    final loc = locationService.currentLocation;
    if (loc == null) return;
    _isLoadingHavens = true;
    notifyListeners();

    try {
      final results = await SafeHavenService.instance.fetchNearbyHavens(
        latitude: loc.latitude,
        longitude: loc.longitude,
        localityHint: locationService.currentAddress,
        forceRefresh: force,
      );
      if (results.isNotEmpty) {
        _safeHavens = results;
      }
    } catch (e) {
      debugPrint('[SafetyProvider] refreshNearbyHavens error: $e');
    } finally {
      _isLoadingHavens = false;
      notifyListeners();
    }
  }

  // Incidents Vault
  final List<IncidentRecord> incidents = [];
  String? _pendingVerificationPhone;
  String? get pendingVerificationPhone => _pendingVerificationPhone;
  String? _demoOtpCode;
  String? get demoOtpCode => _demoOtpCode;

  // Community Hazard Reports (Phase 11)
  final List<SafetyHazardReport> _hazardReports = [];
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
      await loadHazardReportsAsync();
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
      if (res.isSuccess) {
        if (kDebugMode) {
          debugPrint('[SafetyProvider] Hazard report synced to server: ${report.id}');
        }
        unawaited(loadHazardReportsAsync());
      }
    }).catchError((_) {});
  }

  Future<bool> loadHazardReportsAsync() async {
    final lat = locationService.currentLocation?.latitude ?? 28.6139;
    final lng = locationService.currentLocation?.longitude ?? 77.2090;
    final response = await apiService.getNearbyAlerts(
      latitude: lat,
      longitude: lng,
      token: _authToken,
    );
    if (!response.isSuccess || response.data == null) {
      return false;
    }

    final loadedReports = response.data!
        .whereType<Map<String, dynamic>>()
        .map(
          (report) => SafetyHazardReport(
            id: report['id']?.toString() ?? 'haz-cloud',
            type: report['type']?.toString() ?? 'Public Safety Alert',
            location: report['location']?.toString() ?? 'Reported Area',
            severity: report['severity']?.toString() ?? 'Medium',
            notes: report['notes']?.toString() ?? '',
            timestamp: report['timestamp']?.toString() ?? 'Recent',
          ),
        )
        .toList();

    if (loadedReports.isNotEmpty) {
      _hazardReports
        ..clear()
        ..addAll(loadedReports);
      notifyListeners();
    }
    return true;
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
      if (apiRes.data!['verificationRequired'] == true) {
        _pendingVerificationPhone = phone.trim();
        _demoOtpCode = apiRes.data!['demoOtp']?.toString();
        _serverConnectionStatus = ServerConnectionStatus.online;
        _serverStatusMessage = 'Verification code sent to your phone.';
        notifyListeners();
        return false;
      }
      _authToken = apiRes.data!['token']?.toString();
      _serverConnectionStatus = ServerConnectionStatus.online;
      _serverStatusMessage = 'Registered with backend (${ApiConfig.baseUrl})';
      await loadGuardiansAsync();
      await loadIncidentsAsync();
    } else if (apiRes.isOffline) {
      _serverConnectionStatus = ServerConnectionStatus.offline;
      _serverStatusMessage = 'Backend offline. Registered in local profile.';
    } else {
      _serverStatusMessage =
          apiRes.errorMessage ?? 'Registration could not be completed.';
      notifyListeners();
      return false;
    }

    return registerUser(
      name: name,
      phone: phone,
      email: email,
      pin: pin,
      pairBand: pairBand,
    );
  }

  Future<bool> verifyPendingPhone(String code) async {
    final phone = _pendingVerificationPhone;
    if (phone == null) return false;
    final response = await apiService.verifyPhone(phone: phone, code: code);
    if (!response.isSuccess || response.data == null) {
      _serverStatusMessage = response.errorMessage ?? 'Invalid verification code.';
      notifyListeners();
      return false;
    }

    final userData = response.data!['user'] as Map<String, dynamic>?;
    _authToken = response.data!['token']?.toString();
    _pendingVerificationPhone = null;
    _demoOtpCode = null;
    if (userData != null) {
      userName = userData['name']?.toString() ?? userName;
      userPhone = userData['phone']?.toString() ?? phone;
      userEmail = userData['email']?.toString() ?? userEmail;
      shieldId = userData['shieldId']?.toString() ?? shieldId;
    }
    _isRegistered = true;
    _isAuthenticated = true;
    _isCovertMode = false;
    _serverConnectionStatus = ServerConnectionStatus.online;
    await loadGuardiansAsync();
    await loadIncidentsAsync();
    await loadHazardReportsAsync();
    notifyListeners();
    return true;
  }

  void clearPendingVerification() {
    _pendingVerificationPhone = null;
    _demoOtpCode = null;
    notifyListeners();
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

      await loadGuardiansAsync();
      await loadIncidentsAsync();
      await loadHazardReportsAsync();
      _userPin = pin;
      _hashedPin = pin.hashCode.toRadixString(16);
      _isAuthenticated = true;
      _isCovertMode = false;
      notifyListeners();
      return true;
    }

    if (apiRes.statusCode == 403 &&
        apiRes.data?['code'] == 'PHONE_NOT_VERIFIED') {
      _pendingVerificationPhone =
          apiRes.data?['phone']?.toString() ?? identifier.trim();
      _demoOtpCode = apiRes.data?['demoOtp']?.toString();
      _serverConnectionStatus = ServerConnectionStatus.online;
      _serverStatusMessage = 'Phone verification is required before login.';
      notifyListeners();
      return false;
    }

    if (apiRes.isOffline) {
      _serverConnectionStatus = ServerConnectionStatus.offline;
      // Allow offline login for standalone APK demo or local session
      if (_isRegistered && (_userPin == pin || pin == '0000')) {
        _isAuthenticated = true;
        _isCovertMode = pin == '0000';
        _serverStatusMessage = 'Backend offline. Running in local offline mode.';
        notifyListeners();
        return true;
      } else if (pin.length == 4) {
        userName = identifier.contains('@')
            ? identifier.split('@').first
            : 'Demo User';
        userPhone = identifier;
        _userPin = pin;
        _isRegistered = true;
        _isAuthenticated = true;
        _isCovertMode = pin == '0000';
        _serverStatusMessage = 'Backend offline. Local profile active.';
        notifyListeners();
        return true;
      }
    }

    _serverStatusMessage =
        apiRes.errorMessage ?? 'Invalid phone, email or 4-digit PIN.';
    notifyListeners();
    return false;
  }

  Future<bool> loadGuardiansAsync() async {
    if (_authToken == null || _authToken!.isEmpty) {
      return false;
    }

    final response = await apiService.getGuardians(token: _authToken);
    if (!response.isSuccess || response.data == null) {
      return false;
    }

    final loadedGuardians = response.data!
        .whereType<Map<String, dynamic>>()
        .map(
          (guardian) => GuardianModel(
            id: guardian['id']?.toString() ?? '',
            name: guardian['name']?.toString() ?? 'Guardian',
            role: guardian['role']?.toString() ?? 'Guardian • Tier 2',
            phone: guardian['phone']?.toString() ?? '',
            battery: 100,
            distance: 'Cloud synchronized',
            isEmergencyUnit: guardian['isOfficial'] == true,
          ),
        )
        .where((guardian) => guardian.id.isNotEmpty)
        .toList();

    _guardians
      ..clear()
      ..addAll(loadedGuardians);
    notifyListeners();
    return true;
  }

  Future<bool> loadIncidentsAsync() async {
    if (_authToken == null || _authToken!.isEmpty) {
      return false;
    }

    final response = await apiService.getIncidents(token: _authToken);
    if (!response.isSuccess || response.data == null) {
      return false;
    }

    final loadedIncidents = response.data!
        .whereType<Map<String, dynamic>>()
        .map((incident) {
          final location = incident['triggerLocation'] as Map<String, dynamic>?;
          final latitude = location?['latitude'];
          final longitude = location?['longitude'];
          final locationText = latitude is num && longitude is num
              ? '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}'
              : 'Location unavailable';
          return IncidentRecord(
            id: incident['id']?.toString() ?? '',
            title: 'Emergency SOS Incident',
            timestamp: incident['createdAt']?.toString() ?? '',
            location: locationText,
            hash: incident['receiptId']?.toString() ?? 'Server sealed',
            duration: 'Cloud recorded',
            status: incident['status']?.toString() ?? 'UNKNOWN',
          );
        })
        .where((incident) => incident.id.isNotEmpty)
        .toList();

    incidents
      ..clear()
      ..addAll(loadedIncidents);
    notifyListeners();
    return true;
  }

  Future<bool> addGuardianAsync({
    required String name,
    required String phone,
    required String role,
  }) async {
    if (_authToken == null || _authToken!.isEmpty) {
      _guardians.add(
        GuardianModel(
          id: 'g_local_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          phone: phone,
          role: role,
          battery: 100,
          distance: 'Local Device Storage',
        ),
      );
      notifyListeners();
      return true;
    }

    final response = await apiService.addGuardian(
      guardianData: {
        'name': name,
        'phone': phone,
        'role': role,
        'priorityTier': role.contains('Tier 1') ? 1 : 2,
        'isOfficial': false,
      },
      token: _authToken,
    );

    if (!response.isSuccess || response.data == null) {
      // Local fallback on server offline
      _guardians.add(
        GuardianModel(
          id: 'g_offline_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          phone: phone,
          role: role,
          battery: 100,
          distance: 'Offline / Pending Sync',
        ),
      );
      notifyListeners();
      return true;
    }

    final guardian = response.data!['guardian'] as Map<String, dynamic>?;
    _guardians.add(
      GuardianModel(
        id: guardian?['id']?.toString() ?? 'g_${DateTime.now().millisecondsSinceEpoch}',
        name: guardian?['name']?.toString() ?? name,
        phone: guardian?['phone']?.toString() ?? phone,
        role: guardian?['role']?.toString() ?? role,
        battery: 100,
        distance: 'Cloud synchronized',
      ),
    );
    notifyListeners();
    return true;
  }

  Future<bool> removeGuardianAsync(String id) async {
    _guardians.removeWhere((g) => g.id == id);
    notifyListeners();

    if (_authToken != null &&
        _authToken!.isNotEmpty &&
        !id.startsWith('g_local') &&
        !id.startsWith('g_offline')) {
      await apiService.deleteGuardian(guardianId: id, token: _authToken);
    }
    return true;
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

    final isPinValid = pin == _userPin;

    final isIdValid = cleanId == cleanPhone || cleanId == cleanShield;

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

  void addGuardian(String name, String role, String distance, {String phone = ''}) {
    _guardians.add(
      GuardianModel(
        id: 'g_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        role: role,
        phone: phone,
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
        reply = 'Alert noted: Nearest emergency haven is active police patrol (~250m). Disarming decoy mode is ready.';
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

  Future<void> cancelSimulatedSos({String? pin, String? reason}) async {
    _countdownTimer?.cancel();
    _isSosActive = false;
    _sosCountdown = 5;
    _safetyStatus = 'Protected';
    notifyListeners();

    await unifiedSos.standDownSos(pin: pin ?? _userPin, reason: reason);
    await loadIncidentsAsync();
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
