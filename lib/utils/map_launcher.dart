import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Central helper for launching Google Maps native app and web directions.
class MapLauncher {
  /// Opens native Google Maps app or web browser centered at the given coordinates.
  static Future<bool> openCoordinates(
    double lat,
    double lng, {
    String? label,
  }) async {
    final encodedLabel = label != null ? Uri.encodeComponent(label) : '';
    // Standard geo URI for native map apps (Google Maps on Android, Apple Maps on iOS)
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');
    // Universal Google Maps web URL fallback
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[MapLauncher] geo URI check error: $e');
    }

    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[MapLauncher] Failed to open Google Maps web URL: $e');
      return false;
    }
  }

  /// Opens turn-by-turn walking directions to a destination in Google Maps.
  static Future<bool> openDirections({
    required double destLat,
    required double destLng,
    String? destName,
  }) async {
    final query = destName != null ? Uri.encodeComponent(destName) : '$destLat,$destLng';
    final navUri = Uri.parse('google.navigation:q=$destLat,$destLng&mode=w');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query&travelmode=walking');

    try {
      if (await canLaunchUrl(navUri)) {
        return await launchUrl(navUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[MapLauncher] nav URI check error: $e');
    }

    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[MapLauncher] Failed to open directions: $e');
      return false;
    }
  }

  /// Searches nearby emergency havens (police stations, hospitals, safe points) around the user.
  static Future<bool> openNearbySearch(
    double lat,
    double lng,
    String query,
  ) async {
    final encoded = Uri.encodeComponent(query);
    final geoUri = Uri.parse('geo:$lat,$lng?q=$encoded');
    final webUri = Uri.parse('https://www.google.com/maps/search/$encoded/@$lat,$lng,15z');

    try {
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[MapLauncher] nearby geo search error: $e');
    }

    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[MapLauncher] Failed to open nearby search: $e');
      return false;
    }
  }

  /// Dials an emergency phone number in native device dialer.
  static Future<bool> dialNumber(String phoneNumber) async {
    final clean = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[MapLauncher] dialNumber error: $e');
    }
    return false;
  }
}
