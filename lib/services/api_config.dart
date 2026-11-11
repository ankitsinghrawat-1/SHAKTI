import 'package:flutter/foundation.dart';

enum ServerConnectionStatus {
  unknown,
  checking,
  online,
  offline,
}

/// Central configuration for SHAKTI API communications.
/// Supports runtime URL configuration, environment definitions, and standardized headers.
class ApiConfig {
  /// Default base URL pointing to the Node.js Express backend specified in the blueprint.
  /// Can be overridden at build time via `--dart-define=API_BASE_URL=https://your-api.com/api/v1`
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  static String _customBaseUrl = _defaultBaseUrl;

  /// Default base URL getter
  static String get defaultBaseUrl => _defaultBaseUrl;

  /// Current active API base URL.
  static String get baseUrl => _customBaseUrl;

  /// Update the base URL dynamically (e.g. from App Settings for partner testing or local IP access).
  static void setBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    _customBaseUrl = trimmed;
  }

  /// Reset to the default base URL.
  static void resetBaseUrl() {
    _customBaseUrl = _defaultBaseUrl;
  }

  /// Request timeout duration (fail-fast to avoid hanging safety UI).
  static const Duration requestTimeout = Duration(seconds: 5);

  /// Heartbeat/health check timeout.
  static const Duration healthTimeout = Duration(seconds: 3);

  /// Standardized request headers.
  static Map<String, String> buildHeaders({
    String? token,
    String? idempotencyKey,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'X-App-Version': '1.0.0+1',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['X-Idempotency-Key'] = idempotencyKey;
    }

    return headers;
  }
}
