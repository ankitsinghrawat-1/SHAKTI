import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'permission_service.dart';
import 'location_service.dart';
import 'emergency_media_service.dart';
import 'guardian_notification_service.dart';
import 'emergency_call_service.dart';

enum SosTriggerSource {
  appSosButton,
  appSlideToDispatch,
  shaktiBandHardwareButton,
}

class UnifiedSosCoordinator extends ChangeNotifier {
  final PermissionService permissionService;
  final LocationService locationService;
  final EmergencyMediaService mediaService;
  final GuardianNotificationService guardianService;
  final EmergencyCallService callService;
  final ApiService? apiService;
  final String? Function()? authTokenProvider;

  bool _isSosActive = false;
  bool get isSosActive => _isSosActive;

  String? _activeIncidentId;
  String? get activeIncidentId => _activeIncidentId;

  SosTriggerSource? _activeTriggerSource;
  SosTriggerSource? get activeTriggerSource => _activeTriggerSource;

  String? _activationTimestamp;
  String? get activationTimestamp => _activationTimestamp;

  int _sosDurationSeconds = 0;
  int get sosDurationSeconds => _sosDurationSeconds;
  Timer? _incidentDurationTimer;

  UnifiedSosCoordinator({
    required this.permissionService,
    required this.locationService,
    required this.mediaService,
    required this.guardianService,
    required this.callService,
    this.apiService,
    this.authTokenProvider,
  });

  /// Unified emergency execution workflow
  /// Works identically for App button and Band hardware trigger
  void triggerSos({
    required SosTriggerSource source,
    required String userName,
    bool audioEnabled = true,
    bool videoEnabled = true,
  }) {
    // Prevent duplicate triggers from duplicating sessions or recordings
    if (_isSosActive) {
      return;
    }

    _isSosActive = true;
    _activeTriggerSource = source;
    final now = DateTime.now();
    _activationTimestamp =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _activeIncidentId = 'SOS-${now.millisecondsSinceEpoch}';
    _sosDurationSeconds = 0;

    // 1. Live Location Tracking (Independent)
    final hasLocPerm = permissionService.isGranted(SafetyPermissionType.location);
    locationService.setLocationPermission(hasLocPerm);
    locationService.startSosLiveTracking(incidentId: _activeIncidentId!);

    // 2. Guardian Notifications (Independent)
    final locPoint = locationService.currentLocation;
    final lat = locPoint?.latitude ?? 28.6335;
    final lng = locPoint?.longitude ?? 77.2285;
    guardianService.dispatchEmergencyAlerts(
      incidentId: _activeIncidentId!,
      latitude: lat,
      longitude: lng,
      userName: userName,
      isNetworkAvailable: locationService.isNetworkAvailable,
    );

    // 3. Audio & Video Evidence Recording (Independent)
    final hasMicPerm = permissionService.isGranted(SafetyPermissionType.microphone);
    final hasCamPerm = permissionService.isGranted(SafetyPermissionType.camera);
    mediaService.startEmergencyRecordings(
      incidentId: _activeIncidentId!,
      hasMicPermission: hasMicPerm,
      hasCameraPermission: hasCamPerm,
      audioEnabled: audioEnabled,
      videoEnabled: videoEnabled,
    );

    // 4. Incident Duration Timer
    _incidentDurationTimer?.cancel();
    _incidentDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isSosActive) {
        timer.cancel();
        return;
      }
      _sosDurationSeconds++;
      notifyListeners();
    });

    notifyListeners();

    // 5. Asynchronous Backend Dispatch (Non-blocking: Never delays emergency actions)
    if (apiService != null) {
      _dispatchIncidentToBackend(
        incidentId: _activeIncidentId!,
        source: source.name,
        lat: lat,
        lng: lng,
        userName: userName,
      );
    }
  }

  void retryBackendDispatch({
    double? lat,
    double? lng,
    String? userName,
  }) {
    if (apiService == null || _activeIncidentId == null) return;
    _dispatchIncidentToBackend(
      incidentId: _activeIncidentId!,
      source: (_activeTriggerSource ?? SosTriggerSource.appSosButton).name,
      lat: lat ?? locationService.currentLocation?.latitude ?? 28.6139,
      lng: lng ?? locationService.currentLocation?.longitude ?? 77.2090,
      userName: userName ?? 'User',
    );
  }

  void _dispatchIncidentToBackend({
    required String incidentId,
    required String source,
    required double lat,
    required double lng,
    required String userName,
  }) async {
    try {
      final res = await apiService!.createIncident(
        incidentId: incidentId,
        source: source,
        latitude: lat,
        longitude: lng,
        userName: userName,
        token: authTokenProvider?.call(),
      );

      if (res.isSuccess) {
        guardianService.confirmServerReceipt(
          true,
          details: 'Server received (HTTP ${res.statusCode}) • Dispatched',
        );
      } else {
        guardianService.confirmServerReceipt(
          false,
          details: res.errorMessage,
        );
      }
    } catch (e) {
      guardianService.confirmServerReceipt(
        false,
        details: 'Network dispatch error: $e',
      );
    }
  }

  void standDownSos() {
    _isSosActive = false;
    _incidentDurationTimer?.cancel();

    // 1. Stop location tracking
    locationService.stopSosTracking();

    // 2. Stop and seal media recordings in Evidence Vault
    mediaService.stopAndSaveRecordings();

    notifyListeners();
  }

  String get triggerSourceLabel {
    switch (_activeTriggerSource) {
      case SosTriggerSource.shaktiBandHardwareButton:
        return 'SHAKTI Smart Band V2 (Tactile Hardware Trigger)';
      case SosTriggerSource.appSlideToDispatch:
        return 'SHAKTI App (Slide to Dispatch Control)';
      case SosTriggerSource.appSosButton:
      default:
        return 'SHAKTI App (Primary Panic Beacon)';
    }
  }

  @override
  void dispose() {
    _incidentDurationTimer?.cancel();
    super.dispose();
  }
}
