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
  final List<Map<String, dynamic>> Function()? guardiansProvider;

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
  Future<void>? _incidentPreparationFuture;

  UnifiedSosCoordinator({
    required this.permissionService,
    required this.locationService,
    required this.mediaService,
    required this.guardianService,
    required this.callService,
    this.apiService,
    this.authTokenProvider,
    this.guardiansProvider,
  });

  /// Unified emergency execution workflow
  /// Works identically for App button and Band hardware trigger
  Future<void> triggerSos({
    required SosTriggerSource source,
    required String userName,
    bool audioEnabled = true,
    bool videoEnabled = true,
  }) async {
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
    // 2. Audio & Video Evidence Recording (Independent)
    final hasMicPerm = permissionService.isGranted(SafetyPermissionType.microphone);
    final hasCamPerm = permissionService.isGranted(SafetyPermissionType.camera);
    mediaService.startEmergencyRecordings(
      incidentId: _activeIncidentId!,
      hasMicPermission: hasMicPerm,
      hasCameraPermission: hasCamPerm,
      audioEnabled: audioEnabled,
      videoEnabled: videoEnabled,
    );

    // 3. Acquire an actual device/browser location and dispatch the incident.
    _incidentPreparationFuture = _prepareIncidentDispatch(
      incidentId: _activeIncidentId!,
      source: source.name,
      userName: userName,
    );
    await _incidentPreparationFuture!;

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

  }

  Future<void> _prepareIncidentDispatch({
    required String incidentId,
    required String source,
    required String userName,
  }) async {
    final locPoint = await locationService.acquireCurrentLocation();
    locationService.startSosLiveTracking(
      incidentId: incidentId,
      apiService: apiService,
      token: authTokenProvider?.call(),
    );

    final lat = locPoint?.latitude ?? 0.0;
    final lng = locPoint?.longitude ?? 0.0;
    guardianService.dispatchEmergencyAlerts(
      incidentId: incidentId,
      latitude: lat,
      longitude: lng,
      userName: userName,
      isNetworkAvailable: locationService.isNetworkAvailable,
      customGuardians: guardiansProvider?.call(),
    );

    if (apiService != null) {
      await _dispatchIncidentToBackend(
        incidentId: incidentId,
        source: source,
        lat: locPoint?.latitude,
        lng: locPoint?.longitude,
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
    _incidentPreparationFuture = _dispatchIncidentToBackend(
      incidentId: _activeIncidentId!,
      source: (_activeTriggerSource ?? SosTriggerSource.appSosButton).name,
      lat: lat ?? locationService.currentLocation?.latitude,
      lng: lng ?? locationService.currentLocation?.longitude,
      userName: userName ?? 'User',
    );
  }

  Future<void> _dispatchIncidentToBackend({
    required String incidentId,
    required String source,
    required double? lat,
    required double? lng,
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

  Future<void> standDownSos({String? pin, String? reason}) async {
    final incidentToResolve = _activeIncidentId;
    debugPrint(
      '[UnifiedSosCoordinator] Standing down incident $incidentToResolve',
    );
    _isSosActive = false;
    _incidentDurationTimer?.cancel();

    // 1. Stop location tracking
    locationService.stopSosTracking();

    // 2. Stop and seal media recordings in Evidence Vault
    await mediaService.stopAndSaveRecordings();
    final preparation = _incidentPreparationFuture;
    if (preparation != null) {
      await preparation;
    }
    debugPrint('[UnifiedSosCoordinator] Media recordings stopped');
    if (apiService != null) {
      final token = authTokenProvider?.call();
      final registered = await mediaService.registerManifestWithApi(
        apiService: apiService!,
        token: token,
      );
      if (!registered) {
        debugPrint(
          '[UnifiedSosCoordinator] Evidence registration failed for '
          'incident $incidentToResolve',
        );
      }

      // 3. Formally resolve the incident on the backend cloud
      if (incidentToResolve != null && pin != null && pin.isNotEmpty) {
        final resolveRes = await apiService!.resolveIncident(
          incidentId: incidentToResolve,
          pin: pin,
          reason: reason ?? 'Emergency stood down safely by user',
          token: token,
        );
        debugPrint(
          '[UnifiedSosCoordinator] Backend incident resolve: '
          '${resolveRes.statusCode} ${resolveRes.isSuccess}',
        );
      }
    }

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
