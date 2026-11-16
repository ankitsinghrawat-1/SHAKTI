import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

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

  bool _isLocationPermissionGranted = false;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;

  bool _isGpsAvailable = false;
  bool get isGpsAvailable => _isGpsAvailable;

  bool _isNetworkAvailable = true;
  bool get isNetworkAvailable => _isNetworkAvailable;

  final List<LocationPointModel> _offlineQueue = [];
  List<LocationPointModel> get offlineQueue => List.unmodifiable(_offlineQueue);

  String? _lastSyncTimestamp;
  String? get lastSyncTimestamp => _lastSyncTimestamp;

  final List<LocationPointModel> _oneHourHistory = [];
  List<LocationPointModel> get oneHourHistory =>
      List.unmodifiable(_oneHourHistory);

  StreamSubscription<Position>? _positionSubscription;

  void setGpsAvailability(bool available) {
    _isGpsAvailable = available;
    notifyListeners();
  }

  void setLocationPermission(bool granted) {
    _isLocationPermissionGranted = granted;
    if (!granted) {
      _currentLocation = null;
    }
    notifyListeners();
  }

  void setNetworkAvailability(bool available) {
    _isNetworkAvailable = available;
    notifyListeners();
  }

  Future<LocationPointModel?> acquireCurrentLocation() async {
    _currentLocation = null;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setGpsAvailability(false);
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setLocationPermission(false);
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: kIsWeb
            ? WebSettings(
                accuracy: LocationAccuracy.high,
                maximumAge: Duration.zero,
              )
            : AndroidSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 5,
                forceLocationManager: false,
                timeLimit: const Duration(seconds: 15),
              ),
      );
      final point = _toPoint(position);
      _isLocationPermissionGranted = true;
      _isGpsAvailable = true;
      _currentLocation = point;
      _addHistoryPoint(point);
      debugPrint(
        '[LocationService] Current GPS fix: '
        '${point.latitude}, ${point.longitude} (±${point.accuracy}m)',
      );
      notifyListeners();
      return point;
    } catch (error) {
      debugPrint('[LocationService] Current location failed: $error');
      _currentLocation = null;
      setGpsAvailability(false);
      return null;
    }
  }

  void startSosLiveTracking({
    required String incidentId,
    ApiService? apiService,
    String? token,
  }) {
    _positionSubscription?.cancel();
    _isTracking = true;
    notifyListeners();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: kIsWeb
          ? WebSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
              maximumAge: Duration.zero,
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
    ).listen(
      (position) {
        final point = _toPoint(position, incidentId: incidentId);
        _currentLocation = point;
        _isLocationPermissionGranted = true;
        _isGpsAvailable = true;
        _addHistoryPoint(point);
        debugPrint(
          '[LocationService] Live GPS fix: '
          '${point.latitude}, ${point.longitude} (±${point.accuracy}m)',
        );
        if (!_isNetworkAvailable || apiService == null) {
          _offlineQueue.add(point);
        } else {
          unawaited(_sendPoint(apiService, point, token));
        }
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('[LocationService] Live location failed: $error');
        _currentLocation = null;
        setGpsAvailability(false);
      },
    );
  }

  Future<void> _sendPoint(
    ApiService apiService,
    LocationPointModel point,
    String? token,
  ) async {
    final incidentId = point.incidentId;
    if (incidentId == null) return;

    final response = await apiService.sendLocationTelemetry(
      incidentId: incidentId,
      locationPoints: [
        {
          'latitude': point.latitude,
          'longitude': point.longitude,
          'accuracy': point.accuracy,
          'speed': point.speedKmh,
          'provider': 'DEVICE_GPS',
          'timestamp': point.timestamp,
        },
      ],
      token: token,
    );
    if (!response.isSuccess) {
      _offlineQueue.add(point);
      notifyListeners();
    }
  }

  LocationPointModel _toPoint(Position position, {String? incidentId}) {
    return LocationPointModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speedKmh: position.speed < 0 ? 0 : position.speed * 3.6,
      landmark: 'Current device location',
      timestamp: position.timestamp.toIso8601String(),
      incidentId: incidentId,
    );
  }

  void _addHistoryPoint(LocationPointModel point) {
    _oneHourHistory.add(point);
    if (_oneHourHistory.length > 360) {
      _oneHourHistory.removeAt(0);
    }
  }

  void syncOfflineQueue() {
    if (_offlineQueue.isEmpty) return;
    _lastSyncTimestamp = DateTime.now().toIso8601String();
    notifyListeners();
  }

  Future<bool> syncOfflineQueueWithApi({
    required ApiService apiService,
    String? incidentId,
    String? token,
  }) async {
    if (_offlineQueue.isEmpty) return true;

    final targetId = incidentId ?? _offlineQueue.first.incidentId;
    if (targetId == null) return false;
    final pointsPayload = _offlineQueue
        .map(
          (point) => {
            'latitude': point.latitude,
            'longitude': point.longitude,
            'accuracy': point.accuracy,
            'speed': point.speedKmh,
            'provider': 'DEVICE_GPS',
            'timestamp': point.timestamp,
          },
        )
        .toList();

    final response = await apiService.sendLocationTelemetry(
      incidentId: targetId,
      locationPoints: pointsPayload,
      token: token,
    );
    if (!response.isSuccess) return false;

    _offlineQueue.clear();
    _lastSyncTimestamp = DateTime.now().toIso8601String();
    notifyListeners();
    return true;
  }

  void stopSosTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
