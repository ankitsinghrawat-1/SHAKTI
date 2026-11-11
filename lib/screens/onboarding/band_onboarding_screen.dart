import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tactile_button.dart';
import '../main_navigation_shell.dart';

class BandOnboardingScreen extends StatefulWidget {
  const BandOnboardingScreen({super.key});

  @override
  State<BandOnboardingScreen> createState() => _BandOnboardingScreenState();
}

class _BandOnboardingScreenState extends State<BandOnboardingScreen>
    with SingleTickerProviderStateMixin {
  bool? _hasBandChoice;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _proceedToTutorial(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const MainNavigationShell(),
        transitionsBuilder: (context, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.bandOnboardTitle,
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () {
              safety.skipBandPairing();
              _proceedToTutorial(context);
            },
            child: Text(
              strings.tutorialSkip,
              style: TextStyle(
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Graphic
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.darkSurfaceContainerLowest
                          : AppColors.surfaceContainerLowest,
                      boxShadow: AppDecorations.glassElevation,
                    ),
                    child: const Icon(
                      Icons.watch,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Step Question
            Center(
              child: Text(
                strings.doYouHaveBand,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                strings.isHindi
                    ? 'शक्ति बैंड आपके फोन से जुड़े बिना भी स्वतंत्र रूप से एसओएस भेज सकता है।'
                    : 'The SHAKTI Smart Band V2 enables tactile SOS triggers even without your phone in hand.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Question Options: Yes / No
            if (_hasBandChoice == null) ...[
              _choiceCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.emeraldSafe,
                title: strings.haveBandYes,
                subtitle: strings.isHindi
                    ? 'बीएलई के माध्यम से अभी बैंड को जोड़ें'
                    : 'Pair via Bluetooth Low Energy 5.x now',
                onTap: () {
                  setState(() => _hasBandChoice = true);
                  safety.startBandScan();
                },
              ),
              const SizedBox(height: 12),
              _choiceCard(
                icon: Icons.smartphone,
                iconColor: AppColors.primary,
                title: strings.haveBandNo,
                subtitle: strings.isHindi
                    ? 'केवल स्मार्टफोन सुरक्षा सुविधाओं के साथ जारी रखें'
                    : 'Use app-based safety tools (You can pair a band anytime in Settings)',
                onTap: () {
                  setState(() => _hasBandChoice = false);
                  safety.skipBandPairing();
                  _proceedToTutorial(context);
                },
              ),
            ] else if (_hasBandChoice == true) ...[
              // Pairing Flow Interface
              GlassCard(
                padding: const EdgeInsets.all(18),
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          strings.isHindi ? 'बीएलई युग्मन स्थिति' : 'BLE Pairing Status',
                          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: safety.bandPairingState == 'paired'
                                ? AppColors.emeraldLightBg
                                : AppColors.primaryFixedDim.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            safety.bandPairingState.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: safety.bandPairingState == 'paired'
                                  ? AppColors.emeraldSafe
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.pairingInstructions,
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // State Display
                    if (safety.bandPairingState == 'scanning') ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.isHindi
                                  ? 'निकटवर्ती शक्ति बैंड खोज रहे हैं...'
                                  : 'Scanning for SHAKTI Band V2 (ESP32-S3 BLE)...',
                              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ] else if (safety.bandPairingState == 'discovered') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainerLow
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryFixed,
                              ),
                              child: const Icon(Icons.watch, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    safety.discoveredBandName,
                                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    safety.discoveredBandMac,
                                    style: AppTypography.bodySm.copyWith(
                                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              onPressed: () => safety.connectBand(),
                              child: Text(strings.isHindi ? 'पेयर करें' : 'Pair'),
                            ),
                          ],
                        ),
                      ),
                    ] else if (safety.bandPairingState == 'connecting') ...[
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.emeraldSafe),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              strings.isHindi
                                  ? 'सुरक्षित बीएलई चैनल प्रमाणित हो रहा है...'
                                  : 'Authenticating BLE GATT Session Keys...',
                              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ] else if (safety.bandPairingState == 'paired') ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldLightBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.emeraldSafe.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.emeraldSafe, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.pairingSuccess,
                                    style: AppTypography.labelMd.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.emeraldSafe,
                                    ),
                                  ),
                                  Text(
                                    '${safety.discoveredBandName} • Battery ${safety.bandBattery}% • Standalone LTE Ready',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.slateSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Idle state
                      SizedBox(
                        width: double.infinity,
                        child: TactileButton(
                          label: strings.startScanBtn,
                          icon: const Icon(Icons.bluetooth_searching, color: Colors.white, size: 18),
                          style: TactileButtonStyle.primaryCrimson,
                          onPressed: () => safety.startBandScan(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Action Buttons
                    if (safety.bandPairingState == 'paired') ...[
                      SizedBox(
                        width: double.infinity,
                        child: TactileButton(
                          label: strings.isHindi ? 'ऐप ट्यूटोरियल पर जाएं' : 'Continue to App Tour',
                          style: TactileButtonStyle.primaryCrimson,
                          trailingIcon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          onPressed: () => _proceedToTutorial(context),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                safety.skipBandPairing();
                                _proceedToTutorial(context);
                              },
                              child: Text(strings.skipPairingBtn),
                            ),
                          ),
                          if (safety.bandPairingState == 'discovered' || safety.bandPairingState == 'failed') ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => safety.startBandScan(),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Honest Prototype Disclaimer (Section 2 & 13)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x18000000)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.slateSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.isHindi
                          ? 'प्रोटोटाइप सूचना: ब्राउज़र वातावरण में बीएलई युग्मन सिम्युलेटेड है। वास्तविक नेटिव BLE एंड्रॉइड रिलीज़ में उपलब्ध होगा।'
                          : 'Web Prototype Notice: Bluetooth pairing is simulated in browser preview. Native BLE GATT integration is architected for mobile deployment.',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _choiceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySm.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.slateSecondary),
        ],
      ),
    );
  }
}
