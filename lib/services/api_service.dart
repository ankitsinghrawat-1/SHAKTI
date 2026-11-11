import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Typed result envelope for all SHAKTI network operations.
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final int? statusCode;
  final String? errorMessage;
  final bool isOffline;

  const ApiResponse({
    required this.isSuccess,
    this.data,
    this.statusCode,
    this.errorMessage,
    this.isOffline = false,
  });

  factory ApiResponse.success(T data, {int statusCode = 200}) {
    return ApiResponse(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure({
    String? errorMessage,
    int? statusCode,
    bool isOffline = false,
  }) {
    return ApiResponse(
      isSuccess: false,
      errorMessage: errorMessage ?? 'An unexpected network error occurred.',
      statusCode: statusCode,
      isOffline: isOffline,
    );
  }
}

/// Robust, fault-tolerant API Client for the SHAKTI backend.
/// Designed for emergency workflows: never hangs indefinitely, never crashes on network drop,
/// supports idempotency keys, and provides transparent offline detection.
class ApiService {
  final http.Client _client;
  final String? _customBaseUrl;
  final Set<String> _inFlightRequests = {};

  ApiService({http.Client? client, String? customBaseUrl})
      : _client = client ?? http.Client(),
        _customBaseUrl = customBaseUrl;

  String get baseUrl => _customBaseUrl ?? ApiConfig.baseUrl;

  /// Server health check (`GET /health`)
  Future<ApiResponse<Map<String, dynamic>>> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await _client
          .get(uri, headers: ApiConfig.buildHeaders())
          .timeout(ApiConfig.healthTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(body, statusCode: response.statusCode);
      } else {
        return ApiResponse.failure(
          statusCode: response.statusCode,
          errorMessage: 'Backend reported status ${response.statusCode}',
        );
      }
    } on TimeoutException {
      return ApiResponse.failure(
        errorMessage: 'Backend health check timed out. Running in local/offline mode.',
        isOffline: true,
      );
    } catch (e) {
      return ApiResponse.failure(
        errorMessage: 'Cannot connect to backend server ($baseUrl): $e',
        isOffline: true,
      );
    }
  }

  /// User Registration (`POST /auth/register`)
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String phone,
    required String email,
    required String pin,
  }) async {
    return _sendPost(
      endpoint: '/auth/register',
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'pin': pin,
      },
    );
  }

  /// User Login (`POST /auth/login`)
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String identifier,
    required String pin,
  }) async {
    return _sendPost(
      endpoint: '/auth/login',
      body: {
        'identifier': identifier,
        'pin': pin,
      },
    );
  }

  /// Fetch Authenticated User Profile (`GET /auth/me`)
  Future<ApiResponse<Map<String, dynamic>>> getProfile({required String token}) async {
    return _sendGet(endpoint: '/auth/me', token: token);
  }

  /// Fetch Guardian List (`GET /guardians`)
  Future<ApiResponse<List<dynamic>>> getGuardians({String? token}) async {
    final res = await _sendGet(endpoint: '/guardians', token: token);
    if (res.isSuccess && res.data != null) {
      final list = (res.data!['guardians'] as List<dynamic>?) ?? [];
      return ApiResponse.success(list, statusCode: res.statusCode ?? 200);
    }
    return ApiResponse.failure(
      errorMessage: res.errorMessage,
      statusCode: res.statusCode,
      isOffline: res.isOffline,
    );
  }

  /// Add Trusted Guardian (`POST /guardians`)
  Future<ApiResponse<Map<String, dynamic>>> addGuardian({
    required Map<String, dynamic> guardianData,
    String? token,
  }) async {
    return _sendPost(
      endpoint: '/guardians',
      body: guardianData,
      token: token,
    );
  }

  /// Create Emergency Incident (`POST /incidents`)
  /// Uses idempotency key to prevent accidental duplicate dispatches on network retry.
  Future<ApiResponse<Map<String, dynamic>>> createIncident({
    required String incidentId,
    required String source,
    required double latitude,
    required double longitude,
    required String userName,
    String? token,
  }) async {
    return _sendPost(
      endpoint: '/incidents',
      idempotencyKey: incidentId,
      token: token,
      body: {
        'incidentId': incidentId,
        'source': source,
        'latitude': latitude,
        'longitude': longitude,
        'userName': userName,
        'timestamp': DateTime.now().toIso8601String(),
        'severity': 'Urgent',
        'status': 'CREATED',
      },
    );
  }

  /// Fetch Incident Status (`GET /incidents/:id`)
  Future<ApiResponse<Map<String, dynamic>>> getIncidentStatus({
    required String incidentId,
    String? token,
  }) async {
    return _sendGet(endpoint: '/incidents/$incidentId', token: token);
  }

  /// Stream Live Location Telemetry (`POST /incidents/:id/locations`)
  Future<ApiResponse<Map<String, dynamic>>> sendLocationTelemetry({
    required String incidentId,
    required List<Map<String, dynamic>> locationPoints,
    String? token,
  }) async {
    return _sendPost(
      endpoint: '/incidents/$incidentId/locations',
      token: token,
      body: {
        'incidentId': incidentId,
        'points': locationPoints,
        'sentAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Register Evidence Manifest (`POST /evidence/manifest`)
  Future<ApiResponse<Map<String, dynamic>>> uploadEvidenceManifest({
    required String incidentId,
    required List<Map<String, dynamic>> evidenceItems,
    String? token,
  }) async {
    return _sendPost(
      endpoint: '/evidence/manifest',
      idempotencyKey: 'manifest-$incidentId',
      token: token,
      body: {
        'incidentId': incidentId,
        'items': evidenceItems,
        'sealedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Fetch Nearby Public-Safety Alerts (`GET /nearby-alerts`)
  Future<ApiResponse<List<dynamic>>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    double radiusMeters = 2000,
    String? token,
  }) async {
    final query = '?lat=$latitude&lng=$longitude&radius=$radiusMeters';
    final res = await _sendGet(endpoint: '/nearby-alerts$query', token: token);
    if (res.isSuccess && res.data != null) {
      final list = (res.data!['alerts'] as List<dynamic>?) ?? [];
      return ApiResponse.success(list, statusCode: res.statusCode ?? 200);
    }
    return ApiResponse.failure(
      errorMessage: res.errorMessage,
      statusCode: res.statusCode,
      isOffline: res.isOffline,
    );
  }

  /// Submit Community Hazard Report (`POST /reports/hazard`)
  Future<ApiResponse<Map<String, dynamic>>> submitHazardReport({
    required Map<String, dynamic> reportData,
    String? token,
  }) async {
    return _sendPost(
      endpoint: '/reports/hazard',
      body: reportData,
      token: token,
    );
  }

  /// Submit Customer Feedback / Bug Report (`POST /feedback`)
  Future<ApiResponse<Map<String, dynamic>>> submitFeedback({
    required Map<String, dynamic> feedbackData,
    String? token,
  }) async {
    return _sendPost(
      endpoint: '/feedback',
      body: feedbackData,
      token: token,
    );
  }

  // ---------------------------------------------------------------------------
  // Internal HTTP Helpers with Timeout, Deduplication, and Safe Parsing
  // ---------------------------------------------------------------------------

  Future<ApiResponse<Map<String, dynamic>>> _sendGet({
    required String endpoint,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .get(uri, headers: ApiConfig.buildHeaders(token: token))
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.failure(
        errorMessage: 'Request to $endpoint timed out after ${ApiConfig.requestTimeout.inSeconds}s.',
        isOffline: true,
      );
    } catch (e) {
      return ApiResponse.failure(
        errorMessage: 'Network error connecting to $endpoint: $e',
        isOffline: true,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _sendPost({
    required String endpoint,
    required Map<String, dynamic> body,
    String? token,
    String? idempotencyKey,
  }) async {
    final dedupeKey = '$endpoint-${idempotencyKey ?? jsonEncode(body)}';
    if (_inFlightRequests.contains(dedupeKey)) {
      if (kDebugMode) {
        debugPrint('[ApiService] Suppressed duplicate in-flight POST: $dedupeKey');
      }
      return ApiResponse.failure(
        errorMessage: 'A duplicate request is already in-flight.',
      );
    }

    _inFlightRequests.add(dedupeKey);

    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .post(
            uri,
            headers: ApiConfig.buildHeaders(
              token: token,
              idempotencyKey: idempotencyKey,
            ),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.failure(
        errorMessage: 'Request to $endpoint timed out after ${ApiConfig.requestTimeout.inSeconds}s.',
        isOffline: true,
      );
    } catch (e) {
      return ApiResponse.failure(
        errorMessage: 'Network error connecting to $endpoint: $e',
        isOffline: true,
      );
    } finally {
      _inFlightRequests.remove(dedupeKey);
    }
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    try {
      final parsed = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(parsed, statusCode: response.statusCode);
      } else {
        final errorMsg = parsed['error']?.toString() ??
            parsed['message']?.toString() ??
            'Server returned error ${response.statusCode}';
        return ApiResponse.failure(
          statusCode: response.statusCode,
          errorMessage: errorMsg,
        );
      }
    } on FormatException {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        errorMessage: 'Invalid JSON response received from server (${response.statusCode})',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
