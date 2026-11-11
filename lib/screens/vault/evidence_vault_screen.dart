import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  void _togglePlay(String id) {
    setState(() {
      if (_currentlyPlayingId == id) {
        _currentlyPlayingId = null;
      } else {
        _currentlyPlayingId = id;
      }
    });
  }

  void _showExportDossier(BuildContext context, IncidentRecord inc, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed,
              ),
              child: const Icon(Icons.description, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              safety.strings.isHindi ? 'कानूनी साक्ष्य डोजियर' : 'Police Evidence Dossier',
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x18000000)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DOCUMENT ID: SHAKTI-EV-${inc.id.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('TIMESTAMP: ${inc.timestamp}', style: const TextStyle(fontSize: 11)),
                  Text('LOCATION: ${inc.location}', style: const TextStyle(fontSize: 11)),
                  Text('HASH: ${inc.hash}', style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                  const SizedBox(height: 6),
                  const Text('CHAIN OF CUSTODY: Hardware Enclave Timestamp Validated',
                      style: TextStyle(fontSize: 10, color: AppColors.emeraldSafe, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              safety.strings.isHindi
                  ? 'यह डोजियर दिल्ली पुलिस 112 कंट्रोल रूम और संबंधित जांच अधिकारियों को अग्रेषित करने के लिए तैयार है।'
                  : 'This dossier is digitally sealed for forward submission to Emergency 112 CAD or investigating authorities.',
              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(safety.strings.cancel, style: const TextStyle(color: AppColors.slateSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            icon: const Icon(Icons.share, size: 16),
            label: Text(safety.strings.isHindi ? 'साझा करें (पीडीएफ)' : 'Export PDF (Demo)'),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulated dossier PDF compiled and ready for dispatch.'),
                ),
              );
            },
          ),
        ],
      ),
    );
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
                              onTap: () => _togglePlay(inc.id),
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
                            onPressed: () => _showExportDossier(context, inc, safety),
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
}
