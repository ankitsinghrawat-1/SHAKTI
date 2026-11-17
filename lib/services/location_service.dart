import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_service.dart';

class LocationPointModel {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speedKmh;
  final String landmark;
  final String timestamp;
  final String? incidentId;
  final String provider;

  const LocationPointModel({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.speedKmh = 0.0,
    required this.landmark,
    required this.timestamp,
    this.incidentId,
    this.provider = 'DEVICE_GPS',
  });
}

class LocationService extends ChangeNotifier {
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  LocationPointModel? _currentLocation;
  LocationPointModel? get currentLocation => _currentLocation;

  String _currentAddress = 'Acquiring live location...';
  String get currentAddress => _currentAddress;

  bool _isAcquiring = false;
  bool get isAcquiring => _isAcquiring;

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
  StreamSubscription<Position>? _dashboardPositionSubscription;
  double? _lastGeocodedLat;
  double? _lastGeocodedLng;
  DateTime? _lastGeocodeTime;

  /// Continuous passive location tracking for Home Dashboard.
  /// Updates location in real-time as the user moves (1m threshold).
  void startDashboardTracking() {
    if (_dashboardPositionSubscription != null) return;
    try {
      _dashboardPositionSubscription = Geolocator.getPositionStream(
        locationSettings: kIsWeb
            ? const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 1,
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 1, // trigger updates every 1 meter movement
              ),
      ).listen(
        (position) {
          final point = _toPoint(position, provider: 'LIVE_STREAM_GNSS');
          _currentLocation = point;
          _isLocationPermissionGranted = true;
          _isGpsAvailable = true;
          _addHistoryPoint(point);
          notifyListeners();
          unawaited(_reverseGeocode(position.latitude, position.longitude));
        },
        onError: (Object error) {
          debugPrint('[LocationService] Dashboard stream error: $error');
        },
      );
    } catch (e) {
      debugPrint('[LocationService] Error starting dashboard tracking: $e');
    }
  }

  void stopDashboardTracking() {
    _dashboardPositionSubscription?.cancel();
    _dashboardPositionSubscription = null;
  }

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

  /// Multi-tier location acquisition:
  /// 1. Instant Last Known Position (<100ms)
  /// 2. High Accuracy GNSS Satellite Fix
  /// 3. Medium Accuracy Wi-Fi / Cell Triangulation
  /// 4. Google Maps Geolocation / IP Geolocation API Fallback (Indoors)
  /// 5. Google Maps / OpenStreetMap Reverse Geocoding to real street address
  Future<LocationPointModel?> acquireCurrentLocation({bool forceRefresh = false}) async {
    if (_isAcquiring && !forceRefresh) {
      return _currentLocation;
    }
    _isAcquiring = true;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final hasPermission = permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
      _isLocationPermissionGranted = hasPermission;
      notifyListeners();

      if (hasPermission && serviceEnabled) {
        // Step 1: Instant Last Known Position (<100ms immediate UI display)
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            final point = _toPoint(lastKnown, provider: 'CACHED_LAST_KNOWN');
            _currentLocation = point;
            _isGpsAvailable = true;
            _addHistoryPoint(point);
            notifyListeners();
            unawaited(_reverseGeocode(lastKnown.latitude, lastKnown.longitude));
          }
        } catch (e) {
          debugPrint('[LocationService] Last known position read error: $e');
        }

        // Step 2: High Accuracy GNSS Fix
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: kIsWeb
                ? WebSettings(
                    accuracy: LocationAccuracy.high,
                    maximumAge: Duration.zero,
                  )
                : AndroidSettings(
                    accuracy: LocationAccuracy.high,
                    distanceFilter: 3,
                    forceLocationManager: false,
                    timeLimit: const Duration(seconds: 8),
                  ),
          );
          final point = _toPoint(position, provider: 'HIGH_ACCURACY_GNSS');
          _currentLocation = point;
          _isGpsAvailable = true;
          _addHistoryPoint(point);
          _isAcquiring = false;
          notifyListeners();
          unawaited(_reverseGeocode(position.latitude, position.longitude));
          return point;
        } catch (error) {
          debugPrint('[LocationService] High accuracy GPS timed out/failed: $error');
        }

        // Step 3: Medium Accuracy Wi-Fi / Cell Triangulation
        try {
          final fallbackPos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 6),
            ),
          );
          final point = _toPoint(fallbackPos, provider: 'NETWORK_WIFI');
          _currentLocation = point;
          _isGpsAvailable = true;
          _addHistoryPoint(point);
          _isAcquiring = false;
          notifyListeners();
          unawaited(_reverseGeocode(fallbackPos.latitude, fallbackPos.longitude));
          return point;
        } catch (error) {
          debugPrint('[LocationService] Network position failed: $error');
        }
      }

      // Step 4: Network / Google Maps Geolocation API Fallback (Indoors or No GPS)
      if (_currentLocation == null) {
        final apiPoint = await _fetchIpOrGoogleGeolocation();
        if (apiPoint != null) {
          _currentLocation = apiPoint;
          _isGpsAvailable = true;
          _addHistoryPoint(apiPoint);
          _isAcquiring = false;
          notifyListeners();
          unawaited(_reverseGeocode(apiPoint.latitude, apiPoint.longitude));
          return apiPoint;
        }
      }

      _isAcquiring = false;
      notifyListeners();
      return _currentLocation;
    } catch (e) {
      debugPrint('[LocationService] acquireCurrentLocation global error: $e');
      _isAcquiring = false;
      notifyListeners();
      return _currentLocation;
    }
  }

  /// Reverse Geocode coordinates to human-readable street/city landmark.
  /// Uses Google Maps Geocoding API if key configured, otherwise OpenStreetMap Nominatim.
  Future<void> _reverseGeocode(double lat, double lng) async {
    // Avoid hammering geocoding APIs if user hasn't moved at least 25m or 20s elapsed
    if (_lastGeocodedLat != null && _lastGeocodedLng != null && _lastGeocodeTime != null) {
      final elapsed = DateTime.now().difference(_lastGeocodeTime!).inSeconds;
      final dist = Geolocator.distanceBetween(_lastGeocodedLat!, _lastGeocodedLng!, lat, lng);
      if (dist < 25 && elapsed < 20) return;
    }
    _lastGeocodedLat = lat;
    _lastGeocodedLng = lng;
    _lastGeocodeTime = DateTime.now();

    try {
      // 1. Google Maps Geocoding API (if key provided)
      final googleKey = ApiConfig.googleMapsApiKey;
      if (googleKey != null && googleKey.isNotEmpty) {
        final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleKey',
        );
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final results = data['results'] as List<dynamic>?;
          if (results != null && results.isNotEmpty) {
            final formatted = results.first['formatted_address'] as String?;
            if (formatted != null && formatted.isNotEmpty) {
              _currentAddress = formatted;
              notifyListeners();
              return;
            }
          }
        }
      }

      // 2. OpenStreetMap Nominatim Reverse Geocoding (Free, instant, no key needed)
      final nominatimUri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        nominatimUri,
        headers: {'User-Agent': 'SHAKTI-Safety-App/2.0 (contact: support@shakti.safety)'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final parts = <String>[];
          final locality = address['suburb'] ??
              address['neighbourhood'] ??
              address['residential'] ??
              address['road'];
          final city = address['city'] ??
              address['town'] ??
              address['county'] ??
              address['state_district'];
          final state = address['state'];
          if (locality != null) parts.add(locality.toString());
          if (city != null) parts.add(city.toString());
          if (state != null) parts.add(state.toString());

          if (parts.isNotEmpty) {
            _currentAddress = parts.join(', ');
            notifyListeners();
            return;
          }
        }
        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          _currentAddress = displayName.split(',').take(3).join(',').trim();
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('[LocationService] Reverse geocode error: $e');
    }
  }

  /// Geolocation fallback via Google Geolocation or Free IP API
  Future<LocationPointModel?> _fetchIpOrGoogleGeolocation() async {
    try {
      // 1. Google Geolocation API
      final googleKey = ApiConfig.googleMapsApiKey;
      if (googleKey != null && googleKey.isNotEmpty) {
        final uri = Uri.parse(
          'https://www.googleapis.com/geolocation/v1/geolocate?key=$googleKey',
        );
        final res = await http.post(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          final loc = data['location'] as Map<String, dynamic>?;
          if (loc != null) {
            final lat = (loc['lat'] as num).toDouble();
            final lng = (loc['lng'] as num).toDouble();
            final accuracy = (data['accuracy'] as num?)?.toDouble() ?? 35.0;
            return LocationPointModel(
              latitude: lat,
              longitude: lng,
              accuracy: accuracy,
              landmark: 'Google Geolocation Network',
              timestamp: DateTime.now().toIso8601String(),
              provider: 'GOOGLE_GEOLOCATION_API',
            );
          }
        }
      }

      // 2. Free IP Geolocation API
      final ipUri = Uri.parse('http://ip-api.com/json');
      final res = await http.get(ipUri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          final lat = (data['lat'] as num).toDouble();
          final lon = (data['lon'] as num).toDouble();
          final city = data['city']?.toString() ?? 'Nearby Area';
          final region = data['regionName']?.toString() ?? '';
          _currentAddress = region.isNotEmpty ? '$city, $region' : city;
          return LocationPointModel(
            latitude: lat,
            longitude: lon,
            accuracy: 45.0,
            landmark: _currentAddress,
            timestamp: DateTime.now().toIso8601String(),
            provider: 'NETWORK_IP_API',
          );
        }
      }
    } catch (e) {
      debugPrint('[LocationService] IP Geolocation fallback error: $e');
    }
    return null;
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
              distanceFilter: 3,
              maximumAge: Duration.zero,
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 3,
            ),
    ).listen(
      (position) {
        final point = _toPoint(position, incidentId: incidentId, provider: 'LIVE_STREAM_GNSS');
        _currentLocation = point;
        _isLocationPermissionGranted = true;
        _isGpsAvailable = true;
        _addHistoryPoint(point);
        debugPrint(
          '[LocationService] Live GPS fix: '
          '${point.latitude}, ${point.longitude} (±${point.accuracy}m)',
        );
        unawaited(_reverseGeocode(point.latitude, point.longitude));
        if (!_isNetworkAvailable || apiService == null) {
          _offlineQueue.add(point);
        } else {
          unawaited(_sendPoint(apiService, point, token));
        }
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('[LocationService] Live location stream error: $error');
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
          'provider': point.provider,
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

  LocationPointModel _toPoint(Position position, {String? incidentId, String provider = 'DEVICE_GPS'}) {
    return LocationPointModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speedKmh: position.speed < 0 ? 0 : position.speed * 3.6,
      landmark: _currentAddress,
      timestamp: position.timestamp.toIso8601String(),
      incidentId: incidentId,
      provider: provider,
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
            'provider': point.provider,
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
    _dashboardPositionSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}
