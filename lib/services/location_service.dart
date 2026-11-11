import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class LocationPointModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speedKmh;
  final String landmark;
  final String timestamp;
  final String? incidentId;

  const LocationPointModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.speedKmh = 0.0,
    required this.landmark,
    required this.timestamp,
    this.incidentId,
  });
}

class LocationService extends ChangeNotifier {
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  LocationPointModel? _currentLocation;
  LocationPointModel? get currentLocation => _currentLocation;

  bool _isLocationPermissionGranted = true;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;

  bool _isGpsAvailable = true;
  bool get isGpsAvailable => _isGpsAvailable;
  void setGpsAvailability(bool available) {
    _isGpsAvailable = available;
    notifyListeners();
  }

  bool _isNetworkAvailable = true;
  bool get isNetworkAvailable => _isNetworkAvailable;

  final List<LocationPointModel> _offlineQueue = [];
  List<LocationPointModel> get offlineQueue => List.unmodifiable(_offlineQueue);

  String? _lastSyncTimestamp;
  String? get lastSyncTimestamp => _lastSyncTimestamp;

  Timer? _liveTrackingTimer;

  // 1-Hour Location History State
  bool _locationHistoryEnabled = true;
  bool get locationHistoryEnabled => _locationHistoryEnabled;

  final List<LocationPointModel> _oneHourHistory = [
    const LocationPointModel(
      latitude: 28.6289,
      longitude: 77.2185,
      accuracy: 2.1,
      speedKmh: 4.5,
      landmark: 'Janpath Metro Station (Gate 2)',
      timestamp: '14:24 (60m ago)',
    ),
    const LocationPointModel(
      latitude: 28.6298,
      longitude: 77.2210,
      accuracy: 2.3,
      speedKmh: 4.8,
      landmark: 'Tolstoy Marg Junction',
      timestamp: '14:38 (46m ago)',
    ),
    const LocationPointModel(
      latitude: 28.6305,
      longitude: 77.2235,
      accuracy: 2.0,
      speedKmh: 4.2,
      landmark: 'K.G. Marg Illuminated Transit Crossing',
      timestamp: '14:50 (34m ago)',
    ),
    const LocationPointModel(
      latitude: 28.6318,
      longitude: 77.2258,
      accuracy: 2.4,
      speedKmh: 3.9,
      landmark: 'Barakhamba Road Commercial Arcade',
      timestamp: '15:05 (19m ago)',
    ),
    const LocationPointModel(
      latitude: 28.6327,
      longitude: 77.2272,
      accuracy: 2.2,
      speedKmh: 4.1,
      landmark: 'Statesman House Safe Zone Entry',
      timestamp: '15:15 (9m ago)',
    ),
    const LocationPointModel(
      latitude: 28.6335,
      longitude: 77.2285,
      accuracy: 1.8,
      speedKmh: 0.0,
      landmark: 'Barakhamba Safe Corridor (Current)',
      timestamp: '15:24 (Live)',
    ),
  ];

  List<LocationPointModel> get oneHourHistory => List.unmodifiable(_oneHourHistory);

  LocationService() {
    // Initial live point
    _currentLocation = const LocationPointModel(
      latitude: 28.6335,
      longitude: 77.2285,
      accuracy: 1.8,
      speedKmh: 0.0,
      landmark: 'Barakhamba Safe Corridor (Current)',
      timestamp: 'Just now',
    );
  }

  void setLocationPermission(bool granted) {
    _isLocationPermissionGranted = granted;
    if (!granted) {
      _currentLocation = null;
    } else {
      _currentLocation ??= const LocationPointModel(
        latitude: 28.6335,
        longitude: 77.2285,
        accuracy: 1.8,
        speedKmh: 0.0,
        landmark: 'Barakhamba Safe Corridor',
        timestamp: 'Just now',
      );
    }
    notifyListeners();
  }

  void setNetworkAvailability(bool available) {
    _isNetworkAvailable = available;
    if (available && _offlineQueue.isNotEmpty) {
      syncOfflineQueue();
    }
    notifyListeners();
  }

  void setLocationHistoryEnabled(bool enabled) {
    _locationHistoryEnabled = enabled;
    notifyListeners();
  }

  void startSosLiveTracking({required String incidentId}) {
    if (!_isLocationPermissionGranted) {
      _isTracking = false;
      notifyListeners();
      return;
    }

    _isTracking = true;
    _lastSyncTimestamp = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';
    notifyListeners();

    _liveTrackingTimer?.cancel();
    // 30-second periodic live telemetry update interval as requested
    _liveTrackingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }
      _recordPeriodicPoint(incidentId);
    });
  }

  void _recordPeriodicPoint(String incidentId) {
    if (!_isLocationPermissionGranted) return;

    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final newPoint = LocationPointModel(
      latitude: 28.6335 + (now.second % 5) * 0.0001,
      longitude: 77.2285 + (now.second % 5) * 0.0001,
      accuracy: 1.8,
      landmark: 'Barakhamba Safe Corridor',
      timestamp: timeStr,
      incidentId: incidentId,
    );

    _currentLocation = newPoint;

    if (!_isNetworkAvailable) {
      _offlineQueue.add(newPoint);
    } else {
      _lastSyncTimestamp = '$timeStr:${now.second.toString().padLeft(2, '0')}';
    }
    notifyListeners();
  }

  void syncOfflineQueue() {
    if (_offlineQueue.isEmpty) return;
    _offlineQueue.clear();
    _lastSyncTimestamp = 'Synced ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    notifyListeners();
  }

  /// Flushes pending offline coordinates to the backend incident stream.
  Future<bool> syncOfflineQueueWithApi({
    required ApiService apiService,
    String? incidentId,
    String? token,
  }) async {
    if (_offlineQueue.isEmpty) return true;

    final targetId = incidentId ?? _offlineQueue.first.incidentId ?? 'SOS-OFFLINE';
    final pointsPayload = _offlineQueue.map((pt) => {
      'latitude': pt.latitude,
      'longitude': pt.longitude,
      'accuracy': pt.accuracy,
      'speedKmh': pt.speedKmh,
      'landmark': pt.landmark,
      'timestamp': pt.timestamp,
      'incidentId': pt.incidentId ?? targetId,
    }).toList();

    final res = await apiService.sendLocationTelemetry(
      incidentId: targetId,
      locationPoints: pointsPayload,
      token: token,
    );

    if (res.isSuccess) {
      _offlineQueue.clear();
      _lastSyncTimestamp = 'Server Synced ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      notifyListeners();
      return true;
    }
    return false;
  }

  void stopSosTracking() {
    _isTracking = false;
    _liveTrackingTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _liveTrackingTimer?.cancel();
    super.dispose();
  }
}
