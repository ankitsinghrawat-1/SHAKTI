import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_strings.dart';
import '../../providers/safety_provider.dart';
import '../../services/emergency_media_service.dart';
import '../../services/guardian_notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tactile_button.dart';
import '../settings/emergency_evidence_settings_screen.dart';
import '../vault/evidence_vault_screen.dart';

class EmergencyEventScreen extends StatefulWidget {
  const EmergencyEventScreen({super.key});

  @override
  State<EmergencyEventScreen> createState() => _EmergencyEventScreenState();
}

class _EmergencyEventScreenState extends State<EmergencyEventScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _showCancelConfirmation(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          safety.strings.isHindi ? 'एसओएस अलर्ट समाप्त करें?' : 'Stand Down Emergency SOS?',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          safety.strings.isHindi
              ? 'क्या आप सुरक्षित हैं? एसओएस समाप्त करने से आपके अभिभावकों को सुरक्षित स्थिति की सूचना भेजी जाएगी और साक्ष्य वॉल्ट में सील कर दिया जाएगा।'
              : 'Confirm you are safe. Standing down will send a safe resolution alert to your circle and seal captured recordings in the Evidence Vault.',
          style: AppTypography.bodySm.copyWith(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              safety.strings.isHindi ? 'जारी रखें' : 'Keep Active',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldSafe,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            onPressed: () {
              safety.cancelSimulatedSos();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(safety.strings.isHindi
                      ? 'एसओएस समाप्त किया गया। स्थिति: सुरक्षित।'
                      : 'SOS Stood Down. Evidence sealed and guardians notified of safe resolution.'),
                  backgroundColor: AppColors.emeraldSafe,
                ),
              );
            },
            child: Text(
              safety.strings.isHindi ? 'हाँ, मैं सुरक्षित हूँ' : "Yes, I'm Safe",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualCallLogDialog(BuildContext context, SafetyProvider safety) {
    final contactCtrl = TextEditingController(text: '112 Emergency');
    final durationCtrl = TextEditingController(text: 'Connected • 1m 20s');
    final notesCtrl = TextEditingController(text: 'Reported location to PCR operator');
    bool isOutgoing = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.add_call, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  safety.strings.manualCallLogTitle,
                  style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safety.strings.isHindi
                      ? 'गोपनीयता नीति प्रतिबंधों के कारण, कृपया आपातकालीन कॉल विवरण यहाँ दर्ज करें:'
                      : 'Due to platform privacy restrictions, enter emergency call details here:',
                  style: AppTypography.bodySm.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactCtrl,
                  decoration: InputDecoration(
                    labelText: safety.strings.callNumberPrompt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(safety.strings.isHindi ? 'आउटगोइंग' : 'Outgoing'),
                      selected: isOutgoing,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isOutgoing ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (val) => setDialogState(() => isOutgoing = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(safety.strings.isHindi ? 'इनकमिंग' : 'Incoming'),
                      selected: !isOutgoing,
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: !isOutgoing ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      onSelected: (val) => setDialogState(() => isOutgoing = false),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: durationCtrl,
                  decoration: InputDecoration(
                    labelText: safety.strings.isHindi ? 'कॉल अवधि' : 'Call Duration',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: safety.strings.callDurationPrompt,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(safety.strings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              onPressed: () {
                safety.callService.addManualCallRecord(
                  contactOrNumber: contactCtrl.text,
                  isOutgoing: isOutgoing,
                  duration: durationCtrl.text,
                  notes: notesCtrl.text,
                );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.emeraldSafe,
                    content: Text(safety.strings.isHindi
                        ? 'आपातकालीन कॉल लॉग सफलतापूर्वक जोड़ा गया।'
                        : 'Emergency call entry logged successfully.'),
                  ),
                );
              },
              child: Text(safety.strings.save),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSeconds(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color _recordingStatusColor(EvidenceRecordingStatus status) {
    switch (status) {
      case EvidenceRecordingStatus.recording:
        return AppColors.primary;
      case EvidenceRecordingStatus.saved:
        return AppColors.emeraldSafe;
      case EvidenceRecordingStatus.standby:
        return AppColors.tertiary;
      case EvidenceRecordingStatus.permissionRequired:
        return AppColors.secondary;
      case EvidenceRecordingStatus.unavailable:
      case EvidenceRecordingStatus.failed:
      case EvidenceRecordingStatus.idle:
        return AppColors.slateSecondary;
    }
  }

  String _recordingStatusLabel(EvidenceRecordingStatus status, AppStrings strings) {
    switch (status) {
      case EvidenceRecordingStatus.recording:
        return strings.recStatusRecording;
      case EvidenceRecordingStatus.saved:
        return strings.recStatusSaved;
      case EvidenceRecordingStatus.standby:
        return strings.recStatusStandby;
      case EvidenceRecordingStatus.permissionRequired:
        return strings.recStatusPermRequired;
      case EvidenceRecordingStatus.unavailable:
        return strings.recStatusUnavailable;
      case EvidenceRecordingStatus.failed:
        return strings.recStatusFailed;
      case EvidenceRecordingStatus.idle:
        return 'Idle';
    }
  }

  Color _deliveryColor(GuardianDeliveryStatus status) {
    switch (status) {
      case GuardianDeliveryStatus.delivered:
        return AppColors.emeraldSafe;
      case GuardianDeliveryStatus.sent:
        return AppColors.tertiary;
      case GuardianDeliveryStatus.pending:
        return AppColors.secondary;
      case GuardianDeliveryStatus.failed:
        return AppColors.primary;
    }
  }

  String _deliveryLabel(GuardianDeliveryStatus status, AppStrings strings) {
    switch (status) {
      case GuardianDeliveryStatus.delivered:
        return strings.deliveryDelivered;
      case GuardianDeliveryStatus.sent:
        return strings.deliverySent;
      case GuardianDeliveryStatus.pending:
        return strings.deliveryPending;
      case GuardianDeliveryStatus.failed:
        return strings.deliveryFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unifiedSos = safety.unifiedSos;
    final media = safety.mediaService;
    final locService = safety.locationService;
    final guardians = safety.guardianService;
    final calls = safety.callService;

    final incidentId = unifiedSos.activeIncidentId ?? 'SOS-ACTIVE';
    final triggerLabel = unifiedSos.triggerSourceLabel;
    final durationStr = _formatSeconds(unifiedSos.sosDurationSeconds);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Safe exit lifecycle: screen-level animation controller stopped,
        // background SOS operations and evidence recordings continue uninterrupted.
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: strings.isHindi ? 'वापस' : 'Back',
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            },
          ),
        title: Row(
          children: [
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings.isHindi ? 'लाइव आपातकालीन हब' : 'LIVE EMERGENCY SOS HUB',
                style: AppTypography.titleMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: strings.emergencySettingsTitle,
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EmergencyEvidenceSettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: strings.vaultTitle,
            icon: const Icon(Icons.lock_clock),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EvidenceVaultScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Alert Banner with Incident ID & Trigger Source
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          incidentId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DURATION: $durationStr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.isHindi
                        ? 'अभिभावकों एवं आपातकालीन नियंत्रण कक्ष को लाइव अलर्ट सक्रिय'
                        : 'Emergency broadcast dispatched to Tier 1 Guardians & ERSS-112',
                    style: AppTypography.headlineSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.sensors, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Trigger Source: $triggerLabel',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Server Receipt & Network Synchronization Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: guardians.isServerConfirmed
                            ? const Color(0xFF34D399).withValues(alpha: 0.6)
                            : const Color(0xFFFBBF24).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          guardians.isServerConfirmed ? Icons.cloud_done : Icons.cloud_queue,
                          color: guardians.isServerConfirmed ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            guardians.isServerConfirmed
                                ? (strings.isHindi
                                    ? 'सर्वर प्राप्त (HTTP 201) • सुरक्षित पुष्टि'
                                    : 'Server Received (HTTP 201) • Dispatched')
                                : (strings.isHindi
                                    ? 'स्थानीय आपातकालीन मोड • सर्वर सिंक प्रतीक्षारत'
                                    : 'Local Emergency Mode • Queued for server sync'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!guardians.isServerConfirmed)
                          GestureDetector(
                            onTap: () {
                              unifiedSos.retryBackendDispatch(
                                lat: locService.currentLocation?.latitude,
                                lng: locService.currentLocation?.longitude,
                                userName: safety.userName,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(strings.isHindi
                                      ? 'सर्वर सिंक पुनः प्रयास किया जा रहा है...'
                                      : 'Retrying server dispatch...'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                strings.isHindi ? 'पुनः प्रयास' : 'Retry Sync',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Live Telemetry Bar (GNSS Fix, Network & Power)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              locService.isLocationPermissionGranted ? Icons.gps_fixed : Icons.gps_off,
                              color: locService.isLocationPermissionGranted ? AppColors.primary : AppColors.mutedGrey,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'GNSS TELEMETRY',
                                style: AppTypography.labelSm.copyWith(
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (locService.isLocationPermissionGranted && locService.currentLocation != null) ...[
                          Text(
                            '${locService.currentLocation!.latitude.toStringAsFixed(4)}° N, ${locService.currentLocation!.longitude.toStringAsFixed(4)}° E',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          Text(
                            '±${locService.currentLocation!.accuracy}m • GPS+GLONASS',
                            style: const TextStyle(color: AppColors.emeraldSafe, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ] else ...[
                          Text(
                            strings.locationPermissionDenied,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.battery_charging_full,
                              color: AppColors.emeraldSafe,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'POWER STATUS',
                                style: AppTypography.labelSm.copyWith(
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Phone: 84% • Band: 78%',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          locService.offlineQueue.isNotEmpty
                              ? '${locService.offlineQueue.length} points queued offline'
                              : 'MAX17048 Fuel Gauge Active',
                          style: TextStyle(
                            color: locService.offlineQueue.isNotEmpty
                                ? AppColors.primary
                                : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ============================================================
            // FEATURE 2: EMERGENCY EVIDENCE RECORDING (AUDIO & VIDEO)
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.evidenceRecordingTitle,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'SHA-256 SEALED',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 1. Ambient Audio Card
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _recordingStatusColor(media.audioItem?.status ?? EvidenceRecordingStatus.idle).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      color: _recordingStatusColor(media.audioItem?.status ?? EvidenceRecordingStatus.idle),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                strings.audioEvidenceCard,
                                style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _recordingStatusColor(media.audioItem?.status ?? EvidenceRecordingStatus.idle).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _recordingStatusLabel(media.audioItem?.status ?? EvidenceRecordingStatus.idle, strings),
                                style: TextStyle(
                                  color: _recordingStatusColor(media.audioItem?.status ?? EvidenceRecordingStatus.idle),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          media.audioItem != null
                              ? 'Started: ${media.audioItem!.startTime} • Duration: ${_formatSeconds(media.audioItem!.durationSeconds)}'
                              : 'Audio recording disabled in settings',
                          style: AppTypography.bodySm.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (media.audioItem != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'File: ${media.audioItem!.fileReference}',
                            style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.mutedGrey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Front Camera Video Card
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _recordingStatusColor(media.frontVideoItem?.status ?? EvidenceRecordingStatus.idle).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_front,
                      color: _recordingStatusColor(media.frontVideoItem?.status ?? EvidenceRecordingStatus.idle),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                strings.frontCameraCard,
                                style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _recordingStatusColor(media.frontVideoItem?.status ?? EvidenceRecordingStatus.idle).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _recordingStatusLabel(media.frontVideoItem?.status ?? EvidenceRecordingStatus.idle, strings),
                                style: TextStyle(
                                  color: _recordingStatusColor(media.frontVideoItem?.status ?? EvidenceRecordingStatus.idle),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          media.frontVideoItem != null
                              ? '${media.frontVideoItem!.cameraType} • ${_formatSeconds(media.frontVideoItem!.durationSeconds)}'
                              : 'Video disabled in settings',
                          style: AppTypography.bodySm.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (media.activeCamera != 'front' && media.frontVideoItem != null)
                    TextButton(
                      onPressed: () => media.switchActiveCamera(),
                      child: Text(
                        strings.isHindi ? 'सक्रिय करें' : 'Switch',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. Rear Camera Video Card
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _recordingStatusColor(media.rearVideoItem?.status ?? EvidenceRecordingStatus.idle).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_rear,
                      color: _recordingStatusColor(media.rearVideoItem?.status ?? EvidenceRecordingStatus.idle),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                strings.rearCameraCard,
                                style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _recordingStatusColor(media.rearVideoItem?.status ?? EvidenceRecordingStatus.idle).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _recordingStatusLabel(media.rearVideoItem?.status ?? EvidenceRecordingStatus.idle, strings),
                                style: TextStyle(
                                  color: _recordingStatusColor(media.rearVideoItem?.status ?? EvidenceRecordingStatus.idle),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          media.rearVideoItem != null
                              ? '${media.rearVideoItem!.cameraType} • ${_formatSeconds(media.rearVideoItem!.durationSeconds)}'
                              : 'Video disabled in settings',
                          style: AppTypography.bodySm.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (media.activeCamera != 'rear' && media.rearVideoItem != null)
                    TextButton(
                      onPressed: () => media.switchActiveCamera(),
                      child: Text(
                        strings.isHindi ? 'सक्रिय करें' : 'Switch',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Camera Switcher Action & Hardware Limitation Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.dualCameraNotice,
                          style: TextStyle(
                            color: isDark ? AppColors.darkOnSurface : const Color(0xFF92400E),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: const BorderSide(color: Color(0xFFD97706)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.flip_camera_ios, size: 14, color: Color(0xFFD97706)),
                      label: Text(
                        media.activeCamera == 'front'
                            ? (strings.isHindi ? 'रियर कैमरा पर बदलें' : 'Switch to Rear Camera')
                            : (strings.isHindi ? 'फ्रंट कैमरा पर बदलें' : 'Switch to Front Camera'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                      ),
                      onPressed: () => media.switchActiveCamera(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ============================================================
            // FEATURE 3: PREVIOUS 1-HOUR LOCATION HISTORY
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.routeHistorySection,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: locService.isLocationPermissionGranted
                        ? AppColors.emeraldSafe.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    locService.isLocationPermissionGranted
                        ? strings.routeCompleteBadge
                        : strings.routeGapsBadge,
                    style: AppTypography.labelSm.copyWith(
                      color: locService.isLocationPermissionGranted
                          ? AppColors.emeraldSafe
                          : AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              strings.routeHistoryDistinction,
              style: AppTypography.labelSm.copyWith(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),

            if (!locService.isLocationPermissionGranted) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFFDECEF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.routeHistoryUnavailable,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: locService.oneHourHistory.reversed.map((crumb) {
                    final isCurrent = crumb.timestamp.contains('Live') || crumb.timestamp.contains('Just');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrent ? AppColors.primary : AppColors.emeraldSafe,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 28,
                                color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        crumb.landmark,
                                        style: AppTypography.titleSm.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isCurrent ? AppColors.primary : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      crumb.timestamp,
                                      style: AppTypography.labelSm.copyWith(
                                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${crumb.latitude.toStringAsFixed(4)}°N, ${crumb.longitude.toStringAsFixed(4)}°E • Acc: ±${crumb.accuracy}m',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 22),

            // ============================================================
            // FEATURE 3: GUARDIAN EMERGENCY DISPATCH (WITH STATUSES)
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.guardianDeliverySection,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Text(
                  '${guardians.dispatches.length} RESCUERS',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: guardians.dispatches.map((disp) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: disp.isOfficialAgency
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.emeraldSafe.withValues(alpha: 0.15),
                            child: Icon(
                              disp.isOfficialAgency ? Icons.local_police : Icons.person,
                              size: 20,
                              color: disp.isOfficialAgency ? AppColors.primary : AppColors.emeraldSafe,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(disp.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                Text(
                                  '${disp.role} • ${disp.phone}',
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                if (disp.failureReason != null)
                                  Text(
                                    disp.failureReason!,
                                    style: const TextStyle(color: AppColors.primary, fontSize: 10),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _deliveryColor(disp.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _deliveryLabel(disp.status, strings),
                              style: TextStyle(
                                color: _deliveryColor(disp.status),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // WhatsApp Business API simulation notice
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkOutline : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.emeraldSafe),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.whatsAppMockNotice,
                      style: TextStyle(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ============================================================
            // FEATURE 4: RECENT EMERGENCY CALL ACTIVITY
            // ============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.callActivitySection,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: Text(
                    strings.addManualCallBtn,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  onPressed: () => _showManualCallLogDialog(context, safety),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Platform Policy Limitation Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.darkOutline : const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phonelink_lock, color: AppColors.slateSecondary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.callPlatformRestricted,
                      style: TextStyle(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Manual Call Records List
            GlassCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: calls.callRecords.map((call) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: call.isOutgoing
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : AppColors.emeraldSafe.withValues(alpha: 0.12),
                          child: Icon(
                            call.isOutgoing ? Icons.call_made : Icons.call_received,
                            size: 16,
                            color: call.isOutgoing ? AppColors.primary : AppColors.emeraldSafe,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                call.maskedContact,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              Text(
                                '${call.notes} • ${call.duration}',
                                style: TextStyle(
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          call.timestamp,
                          style: TextStyle(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            // Stand Down SOS Button
            TactileButton(
              label: strings.isHindi ? 'एसओएस समाप्त करें (मैं सुरक्षित हूँ)' : 'STAND DOWN SOS (I AM SAFE)',
              icon: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 18),
              isFullWidth: true,
              style: TactileButtonStyle.emerald,
              onPressed: () => _showCancelConfirmation(context, safety),
            ),
            const SizedBox(height: 12),

            Center(
              child: Text(
                strings.isHindi
                    ? '• सिम्युलेटेड अभ्यास: कोई वास्तविक आपातकालीन कॉल या पुलिस प्रेषण नहीं किया गया है।'
                    : '• Enclave Simulation: Safe testing sandbox. No live external 112 calls or cell towers triggered.',
                style: AppTypography.bodySm.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    ),
  );
}
}
