import 'package:flutter/foundation.dart';

enum EmergencyCallSource {
  systemCallLog,
  manualUserLog,
}

class EmergencyCallRecordModel {
  final String id;
  final String contactOrNumber;
  final String timestamp;
  final bool isOutgoing;
  final String duration;
  final EmergencyCallSource source;
  final String notes;

  const EmergencyCallRecordModel({
    required this.id,
    required this.contactOrNumber,
    required this.timestamp,
    required this.isOutgoing,
    required this.duration,
    required this.source,
    required this.notes,
  });

  bool get isManual => source == EmergencyCallSource.manualUserLog;

  /// Returns masked phone number for privacy protection (e.g. +91 98112 ***91)
  String get maskedContact {
    if (!contactOrNumber.contains(RegExp(r'\d{5,}'))) {
      return contactOrNumber; // e.g. "Mother" or "ERSS-112"
    }
    final digits = contactOrNumber.trim();
    if (digits.length <= 4) return digits;
    final prefix = digits.substring(0, digits.length - 4);
    final suffix = digits.substring(digits.length - 2);
    return '${prefix.substring(0, (prefix.length / 2).ceil())}***$suffix';
  }
}

class EmergencyCallService extends ChangeNotifier {
  // Mobile platform investigation:
  // - iOS: Private Apple sandbox prevents reading native cellular call records.
  // - Android: READ_CALL_LOG is heavily restricted by Google Play developer policies.
  // - Web: Browser sandbox has no dialer access.
  final bool _isPlatformCallLogAvailable = false;
  bool get isPlatformCallLogAvailable => _isPlatformCallLogAvailable;

  String get platformRestrictionMessage =>
      'Device call history is not available on this platform due to operating system privacy policies.';

  final List<EmergencyCallRecordModel> _callRecords = [
    const EmergencyCallRecordModel(
      id: 'call-manual-01',
      contactOrNumber: 'National Emergency Response (112)',
      timestamp: 'Today, 14:32 (During SOS)',
      isOutgoing: true,
      duration: '1m 45s',
      source: EmergencyCallSource.manualUserLog,
      notes: 'Dialed PCR Police Patrol',
    ),
    const EmergencyCallRecordModel(
      id: 'call-manual-02',
      contactOrNumber: 'Dr. Kavita Sharma (Mother)',
      timestamp: 'Yesterday, 22:41',
      isOutgoing: false,
      duration: '42s',
      source: EmergencyCallSource.manualUserLog,
      notes: 'Incoming check-in call',
    ),
  ];

  List<EmergencyCallRecordModel> get callRecords => List.unmodifiable(_callRecords);

  void addManualCallRecord({
    required String contactOrNumber,
    required bool isOutgoing,
    required String duration,
    required String notes,
  }) {
    final now = DateTime.now();
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final newRecord = EmergencyCallRecordModel(
      id: 'call-manual-${DateTime.now().millisecondsSinceEpoch}',
      contactOrNumber: contactOrNumber.trim().isEmpty ? '112 Emergency' : contactOrNumber.trim(),
      timestamp: 'Today, $timeStr (Manual Log)',
      isOutgoing: isOutgoing,
      duration: duration.trim().isEmpty ? 'Connected' : duration.trim(),
      source: EmergencyCallSource.manualUserLog,
      notes: notes.trim().isEmpty ? 'Emergency check-in' : notes.trim(),
    );

    _callRecords.insert(0, newRecord);
    notifyListeners();
  }
}
