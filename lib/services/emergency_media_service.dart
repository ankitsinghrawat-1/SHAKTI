import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

enum EvidenceRecordingType {
  audio,
  frontVideo,
  rearVideo,
}

enum EvidenceRecordingStatus {
  idle,
  recording,
  saved,
  permissionRequired,
  unavailable,
  failed,
  standby,
}

class EvidenceItemModel {
  final String id;
  final String incidentId;
  final EvidenceRecordingType type;
  EvidenceRecordingStatus status;
  final String startTime;
  String? endTime;
  int durationSeconds;
  final String fileReference;
  final String checksumSha256;
  final String cameraType;
  String syncStatus; // 'local_sealed', 'sync_pending', 'synced_vault', 'failed'

  EvidenceItemModel({
    required this.id,
    required this.incidentId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    required this.fileReference,
    required this.checksumSha256,
    this.cameraType = 'None',
    this.syncStatus = 'local_sealed',
  });
}

class EmergencyMediaService extends ChangeNotifier {
  Timer? _recordingTimer;
  String? _activeIncidentId;
  String? get activeIncidentId => _activeIncidentId;

  // Active Camera Selection (due to hardware limitation of simultaneous multi-camera capture)
  // 'front' or 'rear'
  String _activeCamera = 'front';
  String get activeCamera => _activeCamera;

  // Real-time Evidence Items
  EvidenceItemModel? _audioItem;
  EvidenceItemModel? _frontVideoItem;
  EvidenceItemModel? _rearVideoItem;

  EvidenceItemModel? get audioItem => _audioItem;
  EvidenceItemModel? get frontVideoItem => _frontVideoItem;
  EvidenceItemModel? get rearVideoItem => _rearVideoItem;

  bool get isAnyRecordingActive =>
      (_audioItem?.status == EvidenceRecordingStatus.recording) ||
      (_frontVideoItem?.status == EvidenceRecordingStatus.recording) ||
      (_rearVideoItem?.status == EvidenceRecordingStatus.recording);

  void startEmergencyRecordings({
    required String incidentId,
    required bool hasMicPermission,
    required bool hasCameraPermission,
    required bool audioEnabled,
    required bool videoEnabled,
  }) {
    _activeIncidentId = incidentId;
    final now = DateTime.now();
    final startTimeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    // 1. Audio Recording Initialization
    if (!audioEnabled) {
      _audioItem = null;
    } else if (!hasMicPermission) {
      _audioItem = EvidenceItemModel(
        id: 'aud-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.audio,
        status: EvidenceRecordingStatus.permissionRequired,
        startTime: startTimeStr,
        fileReference: 'pending_mic_permission.aac',
        checksumSha256: 'unhashed_pending',
      );
    } else {
      _audioItem = EvidenceItemModel(
        id: 'aud-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.audio,
        status: EvidenceRecordingStatus.recording,
        startTime: startTimeStr,
        fileReference: 'emergency_ambient_$incidentId.aac',
        checksumSha256: 'sha256:8f9a2e3...b71c',
      );
    }

    // 2. Video Recording Initialization
    if (!videoEnabled) {
      _frontVideoItem = null;
      _rearVideoItem = null;
    } else if (!hasCameraPermission) {
      _frontVideoItem = EvidenceItemModel(
        id: 'vid-front-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.frontVideo,
        status: EvidenceRecordingStatus.permissionRequired,
        startTime: startTimeStr,
        fileReference: 'pending_camera_permission.mp4',
        checksumSha256: 'unhashed_pending',
        cameraType: 'Front TrueDepth Sensor',
      );
      _rearVideoItem = EvidenceItemModel(
        id: 'vid-rear-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.rearVideo,
        status: EvidenceRecordingStatus.permissionRequired,
        startTime: startTimeStr,
        fileReference: 'pending_camera_permission.mp4',
        checksumSha256: 'unhashed_pending',
        cameraType: 'Rear Wide Sensor',
      );
    } else {
      // Hardware reality: Simultaneous front and rear camera recording is unsupported on most mobile chipsets and Web
      if (_activeCamera == 'front') {
        _frontVideoItem = EvidenceItemModel(
          id: 'vid-front-$incidentId',
          incidentId: incidentId,
          type: EvidenceRecordingType.frontVideo,
          status: EvidenceRecordingStatus.recording,
          startTime: startTimeStr,
          fileReference: 'emergency_front_$incidentId.mp4',
          checksumSha256: 'sha256:3d4e5f6...a89b',
          cameraType: 'Front Camera (Active Stream)',
        );
        _rearVideoItem = EvidenceItemModel(
          id: 'vid-rear-$incidentId',
          incidentId: incidentId,
          type: EvidenceRecordingType.rearVideo,
          status: EvidenceRecordingStatus.standby,
          startTime: startTimeStr,
          fileReference: 'rear_standby.mp4',
          checksumSha256: 'standby',
          cameraType: 'Rear Camera (Standby)',
        );
      } else {
        _frontVideoItem = EvidenceItemModel(
          id: 'vid-front-$incidentId',
          incidentId: incidentId,
          type: EvidenceRecordingType.frontVideo,
          status: EvidenceRecordingStatus.standby,
          startTime: startTimeStr,
          fileReference: 'front_standby.mp4',
          checksumSha256: 'standby',
          cameraType: 'Front Camera (Standby)',
        );
        _rearVideoItem = EvidenceItemModel(
          id: 'vid-rear-$incidentId',
          incidentId: incidentId,
          type: EvidenceRecordingType.rearVideo,
          status: EvidenceRecordingStatus.recording,
          startTime: startTimeStr,
          fileReference: 'emergency_rear_$incidentId.mp4',
          checksumSha256: 'sha256:7c8d9e0...f12a',
          cameraType: 'Rear Camera (Active Stream)',
        );
      }
    }

    notifyListeners();

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool anyIncremented = false;
      if (_audioItem?.status == EvidenceRecordingStatus.recording) {
        _audioItem!.durationSeconds++;
        anyIncremented = true;
      }
      if (_frontVideoItem?.status == EvidenceRecordingStatus.recording) {
        _frontVideoItem!.durationSeconds++;
        anyIncremented = true;
      }
      if (_rearVideoItem?.status == EvidenceRecordingStatus.recording) {
        _rearVideoItem!.durationSeconds++;
        anyIncremented = true;
      }
      if (anyIncremented) {
        notifyListeners();
      }
    });
  }

  void switchActiveCamera() {
    if (_frontVideoItem == null || _rearVideoItem == null) return;

    if (_activeCamera == 'front') {
      _activeCamera = 'rear';
      if (_frontVideoItem!.status == EvidenceRecordingStatus.recording) {
        _frontVideoItem!.status = EvidenceRecordingStatus.saved;
      }
      _rearVideoItem!.status = EvidenceRecordingStatus.recording;
    } else {
      _activeCamera = 'front';
      if (_rearVideoItem!.status == EvidenceRecordingStatus.recording) {
        _rearVideoItem!.status = EvidenceRecordingStatus.saved;
      }
      _frontVideoItem!.status = EvidenceRecordingStatus.recording;
    }
    notifyListeners();
  }

  void stopAndSaveRecordings() {
    _recordingTimer?.cancel();
    final now = DateTime.now();
    final endTimeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    if (_audioItem?.status == EvidenceRecordingStatus.recording) {
      _audioItem!.status = EvidenceRecordingStatus.saved;
      _audioItem!.endTime = endTimeStr;
    }
    if (_frontVideoItem?.status == EvidenceRecordingStatus.recording) {
      _frontVideoItem!.status = EvidenceRecordingStatus.saved;
      _frontVideoItem!.endTime = endTimeStr;
    }
    if (_rearVideoItem?.status == EvidenceRecordingStatus.recording) {
      _rearVideoItem!.status = EvidenceRecordingStatus.saved;
      _rearVideoItem!.endTime = endTimeStr;
    }

    notifyListeners();
  }

  /// Registers evidence items and SHA-256 checksums with the backend Evidence Vault.
  Future<bool> registerManifestWithApi({
    required ApiService apiService,
    String? token,
  }) async {
    if (_activeIncidentId == null) return false;

    final items = <Map<String, dynamic>>[];
    for (final item in [_audioItem, _frontVideoItem, _rearVideoItem]) {
      if (item != null && item.status == EvidenceRecordingStatus.saved) {
        item.syncStatus = 'sync_pending';
        items.add({
          'id': item.id,
          'type': item.type.name,
          'fileReference': item.fileReference,
          'checksumSha256': item.checksumSha256,
          'durationSeconds': item.durationSeconds,
          'cameraType': item.cameraType,
          'startTime': item.startTime,
          'endTime': item.endTime,
        });
      }
    }

    if (items.isEmpty) return true;
    notifyListeners();

    final res = await apiService.uploadEvidenceManifest(
      incidentId: _activeIncidentId!,
      evidenceItems: items,
      token: token,
    );

    final newStatus = res.isSuccess ? 'synced_vault' : 'local_sealed';
    for (final item in [_audioItem, _frontVideoItem, _rearVideoItem]) {
      if (item != null && item.syncStatus == 'sync_pending') {
        item.syncStatus = newStatus;
      }
    }
    notifyListeners();
    return res.isSuccess;
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }
}
