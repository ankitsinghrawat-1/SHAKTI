import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:video_player/video_player.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';

class EvidenceVaultScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const EvidenceVaultScreen({super.key, this.onBack});

  @override
  State<EvidenceVaultScreen> createState() => _EvidenceVaultScreenState();
}

class _EvidenceVaultScreenState extends State<EvidenceVaultScreen> {
  String? _currentlyPlayingId;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _togglePlay(
    IncidentRecord incident,
    SafetyProvider safety,
  ) async {
    if (_currentlyPlayingId == incident.id) {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() => _currentlyPlayingId = null);
      }

      return;
    }

    await _audioPlayer.stop();
    if (mounted) {
      setState(() => _currentlyPlayingId = incident.id);
    }

    final response = await safety.apiService.getEvidenceDownloadUrl(
      incidentId: incident.id,
      token: safety.authToken,
    );
    final signedUrl = response.data?['signedUrl'] as String?;
    if (!response.isSuccess || signedUrl == null) {
      if (mounted) {
        setState(() => _currentlyPlayingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ?? 'Audio evidence is not available.',
            ),
          ),
        );
      }
      return;
    }

    try {
      await _audioPlayer.play(UrlSource(signedUrl));
    } catch (error) {
      if (mounted) {
        setState(() => _currentlyPlayingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio evidence: $error')),
        );
      }
    }
  }

  Future<void> _openVideo(
    IncidentRecord incident,
    SafetyProvider safety,
  ) async {
    final response = await safety.apiService.getEvidenceDownloadUrl(
      incidentId: incident.id,
      fileType: 'VIDEO',
      token: safety.authToken,
    );
    final signedUrl = response.data?['signedUrl'] as String?;
    if (!response.isSuccess || signedUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ?? 'Video evidence is not available.',
            ),
          ),
        );
      }
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(signedUrl));
    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Video Evidence'),
          content: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  VideoProgressIndicator(controller, allowScrubbing: true),
                  IconButton(
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      await controller.dispose();
    }
  }

  Future<void> _showExportDossier(
    IncidentRecord incident,
    SafetyProvider safety,
  ) async {
    final response = await safety.apiService.getIncidentStatus(
      incidentId: incident.id,
      token: safety.authToken,
    );
    if (!response.isSuccess || response.data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Could not load incident data.'),
          ),
        );
      }
      return;
    }

    final cloudIncident = response.data!['incident'] as Map<String, dynamic>?;
    if (cloudIncident == null) return;
    final manifests = (cloudIncident['evidenceManifests'] as List<dynamic>?) ?? [];
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'SHAKTI Evidence Dossier'),
          pw.Text('Incident ID: ${cloudIncident['id'] ?? incident.id}'),
          pw.Text('Status: ${cloudIncident['status'] ?? incident.status}'),
          pw.Text('Created: ${cloudIncident['createdAt'] ?? incident.timestamp}'),
          pw.Text('Location: ${incident.location}'),
          pw.Text('Receipt: ${cloudIncident['receiptId'] ?? incident.hash}'),
          pw.SizedBox(height: 18),
          pw.Header(level: 1, text: 'Evidence'),
          if (manifests.isEmpty)
            pw.Text('No evidence manifest is registered for this incident.')
          else
            for (final manifest in manifests)
              ...((manifest['items'] as List<dynamic>?) ?? []).map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text(
                    '${item['fileType']} | ${item['fileName']}\n'
                    'SHA-256: ${item['sha256Digest']}\n'
                    'Size: ${item['fileSizeBytes']} bytes',
                  ),
                ),
              ),
        ],
      ),
    );

    try {
      await Printing.layoutPdf(onLayout: (_) => document.save());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not export dossier: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            border: const Border(
              bottom: BorderSide(color: Color(0x12000000), width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            safety.setNavIndex(0);
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          strings.vaultTitle,
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const StatusBadge(
                  label: 'SHA-256 SEALED',
                  type: StatusBadgeType.emerald,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Cryptographic Assurance Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.verified_user, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.isHindi ? 'हार्डवेयर साक्ष्य एन्क्लेव' : 'Hardware Evidence Enclave',
                                style: AppTypography.headlineSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                strings.isHindi ? 'अपरिवर्तनीय ऑडिट ट्रेल' : 'Immutable Audit Trail • Anti-Tamper',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.emeraldSafe,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.isHindi
                        ? 'दबाव में जबरन हटाने से बचाने के लिए साक्ष्य रिकॉर्ड 30 दिनों के लिए लॉक रहते हैं। हटाने के लिए अभिभावक सहमति आवश्यक है।'
                        : 'Audio memos and GPS telemetry are cryptographically sealed with hardware SHA-256 hashes. Single PIN cannot erase logs under coercion.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.slateSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Incident Records Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.isHindi ? 'अभिलेखित घटनाएं एवं साक्ष्य' : 'Sealed Incident Records',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${safety.incidents.length} Secured',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.slateSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Incident Cards
            ...safety.incidents.map((inc) {
              final isPlaying = _currentlyPlayingId == inc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inc.title,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${inc.timestamp} • ${inc.location}',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.slateSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              inc.status,
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Audio Waveform Snippet Player Mockup
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _togglePlay(inc, safety),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isPlaying ? 'Playing Audio Snippet...' : 'Acoustic Enclave Memo',
                                        style: AppTypography.labelSm.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        inc.duration,
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.slateSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Waveform bars simulation
                                  Row(
                                    children: List.generate(24, (i) {
                                      final heights = [6, 12, 18, 14, 22, 16, 8, 14, 20, 12, 8, 18, 22, 14, 10, 16, 20, 14, 8, 12, 18, 10, 6, 4];
                                      final h = heights[i % heights.length].toDouble();
                                      return Expanded(
                                        child: Container(
                                          height: isPlaying ? (h * 1.2).clamp(4, 26) : h,
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: isPlaying
                                                ? AppColors.primary
                                                : AppColors.slateSecondary.withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Hash row & export
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.key, size: 12, color: AppColors.slateSecondary),
                              const SizedBox(width: 4),
                              Text(
                                inc.hash,
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10,
                                  color: AppColors.slateSecondary,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            icon: const Icon(Icons.file_download, size: 14, color: AppColors.primary),
                            label: Text(
                              strings.isHindi ? 'डोजियर' : 'Dossier',
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            onPressed: () => _showExportDossier(inc, safety),
                          ),
                          IconButton(
                            tooltip: 'Open video evidence',
                            icon: const Icon(
                              Icons.videocam,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _openVideo(inc, safety),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
