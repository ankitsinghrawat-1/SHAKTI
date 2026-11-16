import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

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
  String fileReference;
  String checksumSha256;
  final String contentType;
  Uint8List? bytes;
  final String cameraType;
  String syncStatus;

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
    this.contentType = 'application/octet-stream',
    this.bytes,
    this.cameraType = 'None',
    this.syncStatus = 'local_sealed',
  });

  int get fileSizeBytes => bytes?.length ?? 0;
}

class EmergencyMediaService extends ChangeNotifier {
  Timer? _recordingTimer;
  AudioRecorder? _audioRecorder;
  CameraController? _cameraController;
  bool _videoStopRequested = false;
  String? _activeIncidentId;
  String? get activeIncidentId => _activeIncidentId;

  String _activeCamera = 'front';
  String get activeCamera => _activeCamera;

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
    _videoStopRequested = false;
    final now = DateTime.now();
    final startTime = now.toIso8601String();

    if (!audioEnabled) {
      _audioItem = null;
    } else if (!hasMicPermission) {
      debugPrint(
        '[EmergencyMediaService] Microphone permission is not granted; '
        'audio capture was not started.',
      );
      _audioItem = EvidenceItemModel(
        id: 'aud-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.audio,
        status: EvidenceRecordingStatus.permissionRequired,
        startTime: startTime,
        fileReference: 'pending_mic_permission.webm',
        checksumSha256: '',
        contentType: 'audio/webm',
      );
    } else {
      _audioItem = EvidenceItemModel(
        id: 'aud-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.audio,
        status: EvidenceRecordingStatus.recording,
        startTime: startTime,
        fileReference: 'emergency_ambient_$incidentId.webm',
        checksumSha256: '',
        contentType: 'audio/webm',
      );
      unawaited(_startAudioCapture());
    }

    if (!videoEnabled) {
      _frontVideoItem = null;
      _rearVideoItem = null;
    } else {
      _frontVideoItem = EvidenceItemModel(
        id: 'vid-front-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.frontVideo,
        status: hasCameraPermission
            ? EvidenceRecordingStatus.recording
            : EvidenceRecordingStatus.permissionRequired,
        startTime: startTime,
        fileReference: kIsWeb
            ? 'emergency_front_$incidentId.webm'
            : 'emergency_front_$incidentId.mp4',
        checksumSha256: '',
        contentType: kIsWeb ? 'video/webm' : 'video/mp4',
        cameraType: 'Front Camera',
      );
      _rearVideoItem = EvidenceItemModel(
        id: 'vid-rear-$incidentId',
        incidentId: incidentId,
        type: EvidenceRecordingType.rearVideo,
        status: EvidenceRecordingStatus.standby,
        startTime: startTime,
        fileReference: kIsWeb
            ? 'emergency_rear_$incidentId.webm'
            : 'emergency_rear_$incidentId.mp4',
        checksumSha256: '',
        contentType: kIsWeb ? 'video/webm' : 'video/mp4',
        cameraType: 'Rear Camera',
      );
      if (hasCameraPermission) {
        unawaited(_startVideoCapture(EvidenceRecordingType.frontVideo));
      }
    }

    notifyListeners();
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_audioItem?.status == EvidenceRecordingStatus.recording) {
        _audioItem!.durationSeconds++;
        notifyListeners();
      }
      if (_frontVideoItem?.status == EvidenceRecordingStatus.recording) {
        _frontVideoItem!.durationSeconds++;
        notifyListeners();
      }
      if (_rearVideoItem?.status == EvidenceRecordingStatus.recording) {
        _rearVideoItem!.durationSeconds++;
        notifyListeners();
      }
    });
  }

  Future<void> _startAudioCapture() async {
    final item = _audioItem;
    if (item == null || item.status != EvidenceRecordingStatus.recording) {
      return;
    }

    try {
      final recorder = AudioRecorder();
      if (!await recorder.hasPermission()) {
        item.status = EvidenceRecordingStatus.permissionRequired;
        notifyListeners();
        return;
      }

      _audioRecorder = recorder;
      final outputPath = kIsWeb
          ? 'emergency_ambient_${item.incidentId}.webm'
          : '${(await getTemporaryDirectory()).path}/'
              'emergency_ambient_${item.incidentId}.webm';
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.opus,
          numChannels: 1,
          bitRate: 64000,
        ),
        path: outputPath,
      );
    } catch (error) {
      item.status = EvidenceRecordingStatus.failed;
      item.syncStatus = 'failed';
      debugPrint('[EmergencyMediaService] Audio capture failed: $error');
      notifyListeners();
    }
  }

  void switchActiveCamera() {
    unawaited(_switchActiveCamera());
  }

  Future<void> _startVideoCapture(EvidenceRecordingType type) async {
    final item = type == EvidenceRecordingType.frontVideo
        ? _frontVideoItem
        : _rearVideoItem;
    if (item == null) return;
    if (item.status == EvidenceRecordingStatus.standby) {
      item.status = EvidenceRecordingStatus.recording;
    }

    try {
      final cameras = await availableCameras();
      final direction = type == EvidenceRecordingType.frontVideo
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final matchingCameras = cameras.where(
        (camera) => camera.lensDirection == direction,
      );
      final description =
          matchingCameras.isEmpty ? null : matchingCameras.first;
      if (description == null) {
        item.status = EvidenceRecordingStatus.unavailable;
        notifyListeners();
        return;
      }

      final controller = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (_videoStopRequested ||
          _activeIncidentId != item.incidentId ||
          item.status != EvidenceRecordingStatus.recording) {
        await controller.dispose();
        return;
      }
      _cameraController = controller;
      await controller.startVideoRecording();
      item.status = EvidenceRecordingStatus.recording;
      notifyListeners();
    } catch (error) {
      item.status = EvidenceRecordingStatus.failed;
      item.syncStatus = 'failed';
      debugPrint('[EmergencyMediaService] Video capture failed: $error');
      notifyListeners();
    }
  }

  Future<void> _switchActiveCamera() async {
    final nextType = _activeCamera == 'front'
        ? EvidenceRecordingType.rearVideo
        : EvidenceRecordingType.frontVideo;
    final currentItem = _activeCamera == 'front' ? _frontVideoItem : _rearVideoItem;
    if (currentItem?.status == EvidenceRecordingStatus.recording) {
      await _stopVideoCapture(currentItem!);
    }
    _activeCamera = nextType == EvidenceRecordingType.frontVideo ? 'front' : 'rear';
    await _startVideoCapture(nextType);
  }

  Future<void> _stopVideoCapture(EvidenceItemModel item) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isRecordingVideo) {
      item.status = EvidenceRecordingStatus.failed;
      item.syncStatus = 'failed';
      return;
    }

    final file = await controller.stopVideoRecording();
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      item.status = EvidenceRecordingStatus.failed;
      item.syncStatus = 'failed';
    } else {
      item.bytes = Uint8List.fromList(bytes);
      item.checksumSha256 = sha256.convert(bytes).toString();
      item.status = EvidenceRecordingStatus.saved;
      item.endTime = DateTime.now().toIso8601String();
    }
    await controller.dispose();
    _cameraController = null;
  }

  Future<void> stopAndSaveRecordings() async {
    _recordingTimer?.cancel();
    _videoStopRequested = true;
    final endTime = DateTime.now().toIso8601String();

    if (_audioItem?.status == EvidenceRecordingStatus.recording) {
      final outputPath = await _audioRecorder?.stop();
      _audioRecorder = null;

      final capturedBytes = outputPath == null
          ? Uint8List(0)
          : await XFile(outputPath).readAsBytes();
      debugPrint(
        '[EmergencyMediaService] Captured audio bytes: ${capturedBytes.length}',
      );
      if (capturedBytes.isEmpty) {
        _audioItem!.status = EvidenceRecordingStatus.failed;
        _audioItem!.syncStatus = 'failed';
        debugPrint(
          '[EmergencyMediaService] Audio recorder stopped without captured bytes.',
        );
      } else {
        _audioItem!.bytes = Uint8List.fromList(capturedBytes);
        _audioItem!.checksumSha256 =
            sha256.convert(capturedBytes).toString();
        _audioItem!.status = EvidenceRecordingStatus.saved;
        _audioItem!.endTime = endTime;
      }
    }

    final activeVideo = _activeCamera == 'front'
        ? _frontVideoItem
        : _rearVideoItem;
    if (activeVideo?.status == EvidenceRecordingStatus.recording) {
      await _stopVideoCapture(activeVideo!);
    }

    notifyListeners();
  }

  Future<bool> registerManifestWithApi({
    required ApiService apiService,
    String? token,
  }) async {
    debugPrint(
      '[EmergencyMediaService] Registering evidence for incident '
      '${_activeIncidentId ?? 'none'}',
    );
    if (_activeIncidentId == null) return false;

    final savedItems = [
      _audioItem,
      _frontVideoItem,
      _rearVideoItem,
    ].whereType<EvidenceItemModel>().where(
          (item) => item.status == EvidenceRecordingStatus.saved,
        );

    final items = savedItems.toList();
    if (items.isEmpty) {
      debugPrint(
        '[EmergencyMediaService] No saved evidence items to register. '
        'Audio status: ${_audioItem?.status}, video status: '
        '${_frontVideoItem?.status}/${_rearVideoItem?.status}',
      );
      return true;
    }

    for (final item in items) {
      item.syncStatus = 'sync_pending';
      final bytes = item.bytes;
      if (bytes == null ||
          bytes.isEmpty ||
          !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(item.checksumSha256)) {
        item.syncStatus = 'failed';
        notifyListeners();
        return false;
      }

      final uploadUrl = await apiService.createEvidenceUploadUrl(
        incidentId: _activeIncidentId!,
        fileName: item.fileReference,
        token: token,
      );
      final signedUrl = uploadUrl.data?['signedUrl'] as String?;
      final storagePath = uploadUrl.data?['path'] as String?;
      if (!uploadUrl.isSuccess || signedUrl == null || storagePath == null) {
        item.syncStatus = 'local_sealed';
        debugPrint(
          '[EmergencyMediaService] Upload authorization failed: '
          '${uploadUrl.errorMessage ?? 'invalid upload URL response'}',
        );
        notifyListeners();
        return false;
      }

      final upload = await apiService.uploadEvidenceBytes(
        signedUrl: signedUrl,
        bytes: bytes,
        contentType: item.contentType,
      );
      if (!upload.isSuccess) {
        item.syncStatus = 'local_sealed';
        debugPrint(
          '[EmergencyMediaService] Evidence upload failed: '
          '${upload.errorMessage ?? 'unknown upload error'}',
        );
        notifyListeners();
        return false;
      }
      item.fileReference = storagePath;
      debugPrint(
        '[EmergencyMediaService] Evidence file uploaded to $storagePath',
      );
    }

    final manifestItems = items.map((item) {
      return {
        'fileType': item.type == EvidenceRecordingType.audio ? 'AUDIO' : 'VIDEO',
        'fileName': item.fileReference.split('/').last,
        'fileReference': item.fileReference,
        'sha256Digest': item.checksumSha256,
        'fileSizeBytes': item.fileSizeBytes,
        'capturedAt': item.startTime,
      };
    }).toList();

    final response = await apiService.uploadEvidenceManifest(
      incidentId: _activeIncidentId!,
      evidenceItems: manifestItems,
      token: token,
    );
    debugPrint(
      '[EmergencyMediaService] Manifest response: ${response.statusCode} '
      '${response.isSuccess}',
    );
    final status = response.isSuccess ? 'synced_vault' : 'local_sealed';
    for (final item in items) {
      item.syncStatus = status;
    }
    if (!response.isSuccess) {
      debugPrint(
        '[EmergencyMediaService] Manifest registration failed: '
        '${response.errorMessage ?? 'unknown manifest error'}',
      );
    }
    notifyListeners();
    return response.isSuccess;
  }

  @override
  void dispose() {
    _videoStopRequested = true;
    _recordingTimer?.cancel();
    _audioRecorder?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}
