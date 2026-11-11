import 'package:flutter/foundation.dart';

enum GuardianDeliveryStatus {
  pending,
  sent,
  delivered,
  failed,
}

enum GuardianDeliveryChannel {
  pushNotification,
  smsGateway,
  whatsAppBusinessApi,
}

class GuardianDispatchRecord {
  final String guardianId;
  final String name;
  final String phone;
  final String role;
  GuardianDeliveryStatus status;
  final GuardianDeliveryChannel channel;
  final String dispatchTimestamp;
  final String mapLink;
  String? lastUpdate;
  String? failureReason;
  final bool isOfficialAgency;

  GuardianDispatchRecord({
    required this.guardianId,
    required this.name,
    required this.phone,
    required this.role,
    this.status = GuardianDeliveryStatus.pending,
    required this.channel,
    required this.dispatchTimestamp,
    required this.mapLink,
    this.lastUpdate,
    this.failureReason,
    this.isOfficialAgency = false,
  });
}

class GuardianNotificationService extends ChangeNotifier {
  final List<GuardianDispatchRecord> _dispatches = [];
  List<GuardianDispatchRecord> get dispatches => List.unmodifiable(_dispatches);

  bool _isNetworkAvailable = true;
  bool get isNetworkAvailable => _isNetworkAvailable;

  bool _isServerConfirmed = false;
  bool get isServerConfirmed => _isServerConfirmed;

  void confirmServerReceipt(bool success, {String? details}) {
    _isServerConfirmed = success;
    for (var d in _dispatches) {
      if (success) {
        if (d.status == GuardianDeliveryStatus.pending || d.status == GuardianDeliveryStatus.failed) {
          d.status = GuardianDeliveryStatus.sent;
          d.failureReason = null;
          d.lastUpdate = details ?? 'Server received (HTTP 201) • Dispatched';
        }
      } else {
        if (d.status != GuardianDeliveryStatus.delivered) {
          d.status = GuardianDeliveryStatus.failed;
          d.failureReason = details ?? 'Backend server offline. Queued locally for retry.';
          d.lastUpdate = 'Queued offline • Awaiting server sync';
        }
      }
    }
    notifyListeners();
  }

  void setNetworkAvailability(bool available) {
    _isNetworkAvailable = available;
    if (!available) {
      for (var d in _dispatches) {
        if (d.status == GuardianDeliveryStatus.pending) {
          d.status = GuardianDeliveryStatus.failed;
          d.failureReason = 'Network disconnected. Queued locally for retry.';
        }
      }
    }
    notifyListeners();
  }

  void dispatchEmergencyAlerts({
    required String incidentId,
    required double latitude,
    required double longitude,
    required String userName,
    required bool isNetworkAvailable,
  }) {
    _isNetworkAvailable = isNetworkAvailable;
    _dispatches.clear();

    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final mapLink = 'https://maps.google.com/?q=$latitude,$longitude';

    // 1. National Police ERSS-112 Dispatch
    _dispatches.add(
      GuardianDispatchRecord(
        guardianId: 'g-erss-112',
        name: 'National Emergency Response (ERSS-112)',
        phone: '112',
        role: 'Verified Police Patrol Dispatch',
        status: isNetworkAvailable ? GuardianDeliveryStatus.delivered : GuardianDeliveryStatus.failed,
        channel: GuardianDeliveryChannel.pushNotification,
        dispatchTimestamp: timeStr,
        mapLink: mapLink,
        lastUpdate: isNetworkAvailable ? 'Connected to PCR unit #14' : 'Network failure',
        failureReason: isNetworkAvailable ? null : 'No cell data available.',
        isOfficialAgency: true,
      ),
    );

    // 2. Primary Tier 1 Guardian (Mother)
    _dispatches.add(
      GuardianDispatchRecord(
        guardianId: 'g-mother',
        name: 'Dr. Kavita Sharma',
        phone: '+91 98112 40292',
        role: 'Mother • Tier 1 Primary',
        status: isNetworkAvailable ? GuardianDeliveryStatus.delivered : GuardianDeliveryStatus.failed,
        channel: GuardianDeliveryChannel.pushNotification,
        dispatchTimestamp: timeStr,
        mapLink: mapLink,
        lastUpdate: isNetworkAvailable ? 'Live link opened • En route (2.1km)' : 'Queued offline',
        failureReason: isNetworkAvailable ? null : 'Offline queue active.',
      ),
    );

    // 3. Secondary Tier 1 Guardian (Sister - SMS Gateway)
    _dispatches.add(
      GuardianDispatchRecord(
        guardianId: 'g-sister',
        name: 'Priya Sharma',
        phone: '+91 98112 40293',
        role: 'Sister • Tier 1 Secondary',
        status: isNetworkAvailable ? GuardianDeliveryStatus.sent : GuardianDeliveryStatus.failed,
        channel: GuardianDeliveryChannel.smsGateway,
        dispatchTimestamp: timeStr,
        mapLink: mapLink,
        lastUpdate: isNetworkAvailable ? 'SMS gateway handed off to carrier' : 'SMS gateway offline',
        failureReason: isNetworkAvailable ? null : 'Carrier timeout.',
      ),
    );

    // 4. Community Responders (WhatsApp Business API Mock)
    _dispatches.add(
      GuardianDispatchRecord(
        guardianId: 'g-wa',
        name: 'Rahul Varma (Guardian Circle)',
        phone: '+91 98112 40294',
        role: 'Guardian • Tier 2',
        status: isNetworkAvailable ? GuardianDeliveryStatus.pending : GuardianDeliveryStatus.failed,
        channel: GuardianDeliveryChannel.whatsAppBusinessApi,
        dispatchTimestamp: timeStr,
        mapLink: mapLink,
        lastUpdate: isNetworkAvailable
            ? 'WhatsApp Business API template dispatched (Mock backend)'
            : 'Delivery failed',
        failureReason: isNetworkAvailable ? null : 'Internet connection dropped.',
      ),
    );

    notifyListeners();
  }

  void retryDelivery(String guardianId) {
    final idx = _dispatches.indexWhere((d) => d.guardianId == guardianId);
    if (idx != -1) {
      if (_isNetworkAvailable) {
        _dispatches[idx].status = GuardianDeliveryStatus.sent;
        _dispatches[idx].failureReason = null;
        _dispatches[idx].lastUpdate = 'Retried at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      }
      notifyListeners();
    }
  }

  String formatEmergencyMessagePayload({
    required String userName,
    required double latitude,
    required double longitude,
    required String incidentId,
  }) {
    return 'EMERGENCY SOS: $userName has triggered a high-priority distress alert. '
        'Live GNSS Location: https://maps.google.com/?q=$latitude,$longitude '
        'Incident ID: $incidentId. Dispatched via SHAKTI Safety Network.';
  }
}
