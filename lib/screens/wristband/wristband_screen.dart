import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tactile_button.dart';
import '../emergency/emergency_event_screen.dart';

class WristbandScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const WristbandScreen({super.key, this.onBack});

  @override
  State<WristbandScreen> createState() => _WristbandScreenState();
}

class _WristbandScreenState extends State<WristbandScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isTestingHaptic = false;
  int _hapticPulseCount = 0;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  void _triggerHapticTest(SafetyProvider safety) {
    if (_isTestingHaptic) return;

    setState(() {
      _isTestingHaptic = true;
      _hapticPulseCount = 0;
    });

    _hapticTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_hapticPulseCount < 3) {
        setState(() {
          _hapticPulseCount++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTestingHaptic = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(safety.strings.isHindi
                ? 'हैप्टिक कंपन परीक्षण सफल: 3 कंपन पल्स प्राप्त हुए (सिम्युलेटेड)।'
                : 'Haptic feedback test passed: 3 vibration pulses verified (Simulated).'),
            backgroundColor: AppColors.emeraldSafe,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _findMyBand(SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.ring_volume, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              safety.strings.findBandBtn,
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safety.strings.isHindi
                  ? 'ध्वनिक बीकन सक्रिय: प्रोटोटाइप बीएलई सिग्नल 98% शक्ति पर उत्सर्जित हो रहा है।'
                  : 'Acoustic Locator: High-pitch chirp and maximum BLE 5.x ping active.',
              style: AppTypography.bodySm,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bluetooth_audio, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ESP32-S3 Beacon • RSSI -42 dBm • Within 1.5m',
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(safety.strings.isHindi ? 'बीकन बंद करें' : 'Stop Beacon'),
          ),
        ],
      ),
    );
  }

  void _showBlueprintSpecDialog(SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Unified Blueprint Hardware Specs',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _specDetailRow('1. Controller Candidates', 'ESP32-S3 / ESP32-C3 (Prototype)\nnRF52840 (Under Evaluation)'),
              _specDetailRow('2. Bluetooth', 'BLE 5.x Coded PHY (Encrypted Phone Link)'),
              _specDetailRow('3. Cellular Modem', 'LTE-M / NB-IoT with SIM/eSIM'),
              _specDetailRow('4. GNSS', 'Multi-Constellation GPS/GLONASS Fix'),
              _specDetailRow('5. SOS Button', 'Sealed Tactile Dual-Action Switch'),
              _specDetailRow('6. Haptic Alert', 'ERM/LRA Vibration Feedback Motor'),
              _specDetailRow('7. Power System', 'Protected Li-Po + Fuel Gauge (4.12V)'),
              _specDetailRow('8. Storage Queue', 'Local NVRAM Non-Volatile Enclave'),
              _specDetailRow('9. Optional IMU', 'Optional 6-Axis Motion Sensor (Context)'),
              _specDetailRow('10. Future Satellite', 'Optional Planned Satellite Module'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _specDetailRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
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
                            strings.bandHubTitle,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: safety.bandBleConnected ? 'BLE LINKED (MOCK)' : 'OFFLINE',
                    type: safety.bandBleConnected
                        ? StatusBadgeType.emerald
                        : StatusBadgeType.primary,
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
              // Reassurance Prototype Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x18000000)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.isHindi
                            ? 'हार्डवेयर विनिर्देश: प्रोजेक्ट ब्लूप्रिंट के अनुसार। सभी टेलीमेट्री प्रोटोटाइप परीक्षण हेतु सिम्युलेटेड हैं।'
                            : 'Hardware Blueprint: Architectural subsystems as documented. All telemetry simulated for prototype testing.',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Hero Device Card - Following Blueprint
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SHAKTI Band Hardware',
                                style: AppTypography.headlineMd.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ESP32-S3 Candidate • BLE + LTE + GNSS',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.slateSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0x18000000)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.battery_charging_full,
                                  size: 14, color: AppColors.emeraldSafe),
                              const SizedBox(width: 4),
                              Text(
                                '${safety.bandBattery}%',
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emeraldSafe,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Animated Device Emblem
                    Center(
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: safety.bandBleConnected
                                ? AppColors.surfaceContainerLowest
                                : AppColors.surfaceContainerLow,
                            boxShadow: [
                              BoxShadow(
                                color: (safety.bandBleConnected
                                        ? AppColors.primaryFixedDim
                                        : AppColors.slateSecondary)
                                    .withValues(alpha: 0.4),
                                offset: const Offset(0, 8),
                                blurRadius: 24,
                              ),
                            ],
                            border: Border.all(
                              color: safety.bandBleConnected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant,
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.watch,
                                size: 68,
                                color: safety.bandBleConnected
                                    ? AppColors.primary
                                    : AppColors.secondary,
                              ),
                              Positioned(
                                bottom: 18,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: safety.bandBleConnected
                                        ? AppColors.emeraldSafe
                                        : AppColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    safety.bandBleConnected ? 'LINKED' : 'OFFLINE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: safety.bandBleConnected
                                ? AppColors.emeraldSafe
                                : AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            safety.bandBleConnected
                                ? (strings.isHindi
                                    ? 'जुड़ा हुआ: प्रमाणित बीएलई 5.x चैनल'
                                    : 'Connected: Authenticated BLE 5.x Link')
                                : (strings.isHindi ? 'डिस्कनेक्टेड' : 'Not Connected'),
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: safety.bandBleConnected
                                  ? AppColors.onSurface
                                  : AppColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Connect / Disconnect and Find Band Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: const BorderSide(color: Color(0x33000000)),
                            ),
                            icon: Icon(
                              safety.bandBleConnected
                                  ? Icons.bluetooth_disabled
                                  : Icons.bluetooth,
                              size: 18,
                              color: AppColors.onSurface,
                            ),
                            label: Text(
                              safety.bandBleConnected
                                  ? (strings.isHindi ? 'डिस्कनेक्ट' : 'Disconnect')
                                  : (strings.isHindi ? 'पुनः कनेक्ट करें' : 'Reconnect'),
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                safety.bandBleConnected = !safety.bandBleConnected;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.ring_volume, size: 18),
                            label: Text(
                              strings.findBandBtn,
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () => _findMyBand(safety),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Hardware SOS Button Trigger Simulation (Phase 5 / Blueprint V2)
                    TactileButton(
                      label: strings.isHindi
                          ? 'हार्डवेयर एसओएस बटन दबाएं (बैंड ट्रिगर)'
                          : 'PRESS HARDWARE SOS (BAND TRIGGER)',
                      icon: const Icon(Icons.emergency_share, color: Colors.white, size: 18),
                      isFullWidth: true,
                      style: TactileButtonStyle.primaryCrimson,
                      onPressed: () {
                        safety.triggerBandSos();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EmergencyEventScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Standard Subsystems Header (Following Documented Blueprint)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      strings.isHindi ? 'मानक हार्डवेयर सब-सिस्टम' : 'Standard Documented Subsystems',
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showBlueprintSpecDialog(safety),
                    child: Text(
                      strings.isHindi ? 'विवरण देखें' : 'View Specs',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Subsystem Row 1: Controller & BLE
              Row(
                children: [
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.memory,
                      iconColor: AppColors.primary,
                      title: strings.isHindi ? 'मुख्य नियंत्रक' : 'Main Controller',
                      value: 'ESP32-S3',
                      status: strings.isHindi ? 'प्रोटोटाइप उम्मीदवार' : 'Candidate Prototype',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'nRF52840 alternate under review',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.bluetooth,
                      iconColor: AppColors.tertiary,
                      title: strings.isHindi ? 'ब्लूटूथ लिंक' : 'BLE 5.x Subsystem',
                      value: safety.bandBleConnected ? 'Connected' : 'Offline',
                      status: strings.isHindi ? 'सुरक्षित चैनल' : 'Secure Pairing Active',
                      statusColor: safety.bandBleConnected ? AppColors.emeraldSafe : AppColors.secondary,
                      footnote: 'Encrypted phone telemetry',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Subsystem Row 2: Standalone LTE & GNSS
              Row(
                children: [
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.cell_tower,
                      iconColor: AppColors.primary,
                      title: strings.isHindi ? 'सेल्युलर एलटीई' : 'Cellular LTE Modem',
                      value: 'LTE-M / NB-IoT',
                      status: strings.isHindi ? 'स्वतंत्र संचार तैयार' : 'Standalone Ready (Sim)',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'SIM/eSIM independent dispatch',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.gps_fixed,
                      iconColor: AppColors.emeraldSafe,
                      title: strings.isHindi ? 'जीएनएसएस लोकेशन' : 'GNSS Positioning',
                      value: '3D Fix (±2.5m)',
                      status: strings.isHindi ? '4 उपग्रह लॉक' : 'Multi-Constellation Lock',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'GPS + GLONASS hardware fix',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Subsystem Row 3: SOS Tactile Button & Haptic Motor
              Row(
                children: [
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.touch_app,
                      iconColor: AppColors.deepCrimson,
                      title: strings.isHindi ? 'एसओएस हार्डवेयर बटन' : 'Tactile SOS Button',
                      value: 'Sealed Switch',
                      status: strings.isHindi ? 'सशस्त्र एवं सक्रिय' : 'Armed & Monitored',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'Debounce protected trigger',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.vibration,
                      iconColor: AppColors.tertiary,
                      title: strings.isHindi ? 'हैप्टिक मोटर' : 'Haptic Feedback',
                      value: 'ERM / LRA Motor',
                      status: strings.isHindi ? 'कंपन तैयार' : 'Pulse Ready',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'Alert & acknowledge feedback',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Subsystem Row 4: Power System & Persistent Storage
              Row(
                children: [
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.battery_charging_full,
                      iconColor: AppColors.emeraldSafe,
                      title: strings.isHindi ? 'ली-पो बैटरी एवं पावर' : 'Battery & Fuel Gauge',
                      value: '${safety.bandBattery}% • 4.12V',
                      status: strings.isHindi ? 'सुरक्षित सेल सामान्य' : 'Protected Li-Po Normal',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'Onboard charging controller',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _blueprintCard(
                      icon: Icons.storage,
                      iconColor: AppColors.slateSecondary,
                      title: strings.isHindi ? 'एनवीआरएएम स्टोरेज' : 'Persistent Storage',
                      value: '0 Pending',
                      status: strings.isHindi ? 'घटना कतार सिंक' : 'Incident Queue Synced',
                      statusColor: AppColors.emeraldSafe,
                      footnote: 'Monotonic sequence counter',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Optional & Future Subsystems Section (Clearly marked)
              Text(
                strings.isHindi ? 'वैकल्पिक एवं भविष्य के सब-सिस्टम' : 'Optional & Future Subsystems',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              // Optional Subsystem 1: 6-Axis Motion IMU
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.motion_photos_on, size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.optionalImuTitle,
                                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixedDim.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'OPTIONAL SUBSYSTEM',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.isHindi
                          ? 'वैकल्पिक 6-एक्सिस एक्सेलेरोमीटर और जाइरोस्कोप गति और अचानक गिरावट के संदर्भ के लिए। यह एक वैकल्पिक सुविधा है, पुष्ट मानक नहीं।'
                          : 'Optional 6-axis IMU for motion context and fall/impact estimation. Clearly designated as optional in project blueprint.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Future Subsystem 2: Satellite Module
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.satellite_alt, size: 20, color: AppColors.slateSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  strings.futureSatelliteTitle,
                                  style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'FUTURE SUBSYSTEM',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slateSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.isHindi
                          ? 'बिना सेल्युलर कवरेज वाले क्षेत्रों में आपातकालीन संदेश हेतु भावी विस्तारित मॉड्यूल। अभी भौतिक रूप से स्थापित नहीं है।'
                          : 'Future extended subsystem for direct satellite distress messaging in zero-cellular environments. Not installed in baseline prototype.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Hardware Diagnostics Actions
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(22),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.vibration,
                        color: _isTestingHaptic ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.testHapticBtn,
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.isHindi
                                ? 'हैप्टिक कंपन प्रतिक्रिया का अनुकरण करें।'
                                : 'Simulate tactile vibration feedback motor.',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.slateSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 84,
                      child: TactileButton(
                        label: _isTestingHaptic
                            ? '$_hapticPulseCount / 3'
                            : (strings.isHindi ? 'परीक्षण' : 'Test'),
                        style: TactileButtonStyle.primaryCrimson,
                        height: 38,
                        onPressed: () => _triggerHapticTest(safety),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80), // Padding for navigation bar
            ],
          ),
        ),
      );
  }

  Widget _blueprintCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String status,
    required Color statusColor,
    required String footnote,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.tactileExtrusionSubtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: iconColor),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.slateSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSm.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            footnote,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.mutedGrey,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
