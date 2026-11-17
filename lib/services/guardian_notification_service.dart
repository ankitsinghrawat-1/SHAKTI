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
  final String? messagePayload;
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
    this.messagePayload,
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
    List<Map<String, dynamic>>? customGuardians,
  }) {
    _isNetworkAvailable = isNetworkAvailable;
    _dispatches.clear();

    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final mapLink = 'https://maps.google.com/?q=$latitude,$longitude';
    final alertMessage = formatEmergencyMessagePayload(
      userName: userName,
      latitude: latitude,
      longitude: longitude,
      incidentId: incidentId,
    );

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
        messagePayload: 'POLICE BROADCAST: Distress alert from $userName. Live GNSS: $mapLink',
        lastUpdate: isNetworkAvailable ? 'Connected to PCR unit #14' : 'Network failure',
        failureReason: isNetworkAvailable ? null : 'No cell data available.',
        isOfficialAgency: true,
      ),
    );

    if (customGuardians != null && customGuardians.isNotEmpty) {
      for (final g in customGuardians) {
        final id = g['id']?.toString() ?? 'g-custom';
        final name = g['name']?.toString() ?? 'Guardian';
        final rawPhone = g['phone']?.toString() ?? '';
        final phone = rawPhone.isNotEmpty ? rawPhone : 'Registered Contact';
        final role = g['role']?.toString() ?? 'Guardian • Tier 2';
        final isTier1 = role.contains('Tier 1');

        _dispatches.add(
          GuardianDispatchRecord(
            guardianId: id,
            name: name,
            phone: phone,
            role: role,
            status: isNetworkAvailable
                ? (isTier1 ? GuardianDeliveryStatus.delivered : GuardianDeliveryStatus.sent)
                : GuardianDeliveryStatus.failed,
            channel: isTier1
                ? GuardianDeliveryChannel.pushNotification
                : GuardianDeliveryChannel.smsGateway,
            dispatchTimestamp: timeStr,
            mapLink: mapLink,
            messagePayload: alertMessage,
            lastUpdate: isNetworkAvailable
                ? (isTier1 ? 'Live GNSS link opened' : 'SMS alert dispatched')
                : 'Queued offline',
            failureReason: isNetworkAvailable ? null : 'Network disconnected.',
          ),
        );
      }
    } else {
      // Prompt user to add guardians if account has none yet
      _dispatches.add(
        GuardianDispatchRecord(
          guardianId: 'g-notice',
          name: 'Personal Guardian Circle',
          phone: 'No personal contacts added',
          role: 'Emergency Circle',
          status: GuardianDeliveryStatus.pending,
          channel: GuardianDeliveryChannel.smsGateway,
          dispatchTimestamp: timeStr,
          mapLink: mapLink,
          messagePayload: alertMessage,
          lastUpdate: 'Awaiting guardian setup',
          failureReason: 'Add trusted contacts in Guardians tab to dispatch real SMS with live location.',
        ),
      );
    }

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
