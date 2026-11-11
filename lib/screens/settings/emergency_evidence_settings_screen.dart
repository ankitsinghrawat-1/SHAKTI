import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

class EmergencyEvidenceSettingsScreen extends StatelessWidget {
  const EmergencyEvidenceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.emergencySettingsTitle,
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Privacy Disclosure Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainerLow
                    : AppColors.primaryContainer.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkOutline
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.isHindi ? 'गोपनीयता एवं साक्ष्य सुरक्षा प्रतिज्ञा' : 'Privacy & Evidence Protection Pledge',
                          style: AppTypography.titleMd.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.isHindi
                              ? 'एसओएस सक्रिय होने से पहले कभी भी ऑडियो या वीडियो रिकॉर्ड नहीं किया जाता है। सभी साक्ष्य स्थानीय रूप से एईएस-256 एन्क्रिप्टेड होते हैं और केवल आपके सत्यापित अभिभावकों के साथ ही साझा किए जाते हैं।'
                              : 'Audio and video are NEVER recorded without an explicit SOS trigger or manual emergency action. All captured telemetry is locally AES-256 encrypted before secure guardian dispatch.',
                          style: AppTypography.bodySm.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Capture & Recording Preferences
            Text(
              strings.isHindi ? 'स्वचालित साक्ष्य रिकॉर्डिंग' : 'Automatic Evidence Recording',
              style: AppTypography.titleSm.copyWith(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.emergencyAudioLabel,
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      strings.isHindi
                          ? 'एसओएस पर पृष्ठभूमि में गुप्त 30-सेकंड परिवेशी ऑडियो क्लिप रिकॉर्ड करें'
                          : 'Captures background 30-second high-fidelity ambient audio clips upon SOS trigger',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                    value: safety.settingEmergencyAudio,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    onChanged: (val) {
                      safety.updateEmergencyEvidenceSettings(emergencyAudio: val);
                    },
                  ),
                  Divider(color: isDark ? AppColors.darkOutline : AppColors.borderLight, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.emergencyVideoLabel,
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      strings.isHindi
                          ? 'एसओएस पर फ्रंट/रियर कैमरे से संक्षिप्त सुरक्षा वीडियो रिकॉर्ड करें'
                          : 'Records short safety video snapshot loops using device cameras upon confirmation',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                    value: safety.settingEmergencyVideo,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    onChanged: (val) {
                      safety.updateEmergencyEvidenceSettings(emergencyVideo: val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Guardian Sharing Preferences
            Text(
              strings.isHindi ? 'अभिभावक शेयरिंग नियंत्रण' : 'Guardian Dispatch & Sharing Controls',
              style: AppTypography.titleSm.copyWith(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.shareAudioLabel,
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      strings.isHindi
                          ? 'सत्यापित अभिभावकों को तत्काल ऑडियो स्ट्रीम या क्लिप लिंक भेजें'
                          : 'Sends encrypted audio replay link to Tier 1 verified contacts during alert',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                    value: safety.settingShareAudioWithGuardians,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    onChanged: (val) {
                      safety.updateEmergencyEvidenceSettings(shareAudioWithGuardians: val);
                    },
                  ),
                  Divider(color: isDark ? AppColors.darkOutline : AppColors.borderLight, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.shareVideoLabel,
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      strings.isHindi
                          ? 'अभिभावकों को लाइव स्थिति वीडियो साक्ष्य देखने की अनुमति दें'
                          : 'Permits trusted guardians to stream live video snapshots of the event',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                    value: safety.settingShareVideoWithGuardians,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    onChanged: (val) {
                      safety.updateEmergencyEvidenceSettings(shareVideoWithGuardians: val);
                    },
                  ),
                  Divider(color: isDark ? AppColors.darkOutline : AppColors.borderLight, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.shareLocationLabel,
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      strings.isHindi
                          ? 'आपात स्थिति में पिछले 60 मिनट का ब्रेडक्रम्ब रूट मैप व लाइव पिन भेजें'
                          : 'Transmits past 60-minute breadcrumb trail and high-accuracy live GPS coordinates',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                    value: safety.settingShareLocationRoute,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    onChanged: (val) {
                      safety.updateEmergencyEvidenceSettings(shareLocationRoute: val);
                    },
                  ),
                  Divider(color: isDark ? AppColors.darkOutline : AppColors.borderLight, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.shareBatteryLabel,
                      style: AppTypography.titleMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      strings.isHindi
                          ? 'फोन और स्मार्ट बैंड की शेष बैटरी प्रतिशत साझा करें'
                          : 'Shares real-time phone battery and SHAKTI wristband fuel gauge levels with guardians',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                    value: safety.settingShareBatteryStatus,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.35),
                    onChanged: (val) {
                      safety.updateEmergencyEvidenceSettings(shareBatteryStatus: val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Emergency Call History Log
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.emergencyCallLogsTitle,
                  style: AppTypography.titleSm.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldSafe.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${safety.emergencyCallLogs.length} ${strings.isHindi ? "प्रविष्टियाँ" : "Records"}',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.emeraldSafe,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: safety.emergencyCallLogs.map((log) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceContainerLow
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: log.isOfficial
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.tertiary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            log.isOfficial ? Icons.local_police : Icons.phone_in_talk,
                            color: log.isOfficial ? AppColors.primary : AppColors.tertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.contactName,
                                style: AppTypography.titleSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                log.role,
                                style: AppTypography.bodySm.copyWith(
                                  color: isDark
                                      ? AppColors.darkOnSurfaceVariant
                                      : AppColors.slateSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              log.timestamp,
                              style: AppTypography.labelSm.copyWith(
                                color: isDark
                                    ? AppColors.darkOnSurfaceVariant
                                    : AppColors.slateSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              log.duration,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.emeraldSafe,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),
            // Honest Local Prototype Notice
            Center(
              child: Text(
                strings.isHindi
                    ? '• स्थानीय प्रोटोटाइप: साक्ष्य सेटिंग्स सुरक्षित रूप से डिवाइस पर सहेजी गई हैं।'
                    : '• Local Enclave Prototype: Evidence toggles saved locally to mock safety registry.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 120), // Bottom padding to prevent floating button overlap
          ],
        ),
      ),
    );
  }
}
