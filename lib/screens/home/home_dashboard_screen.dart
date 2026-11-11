import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/contextual_help_dialog.dart';
import '../../widgets/dashboard_spotlight_tour.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shakti_emblem.dart';
import '../../widgets/sos_beacon_button.dart';
import '../../widgets/tactile_button.dart';
import '../ai/ai_assistant_screen.dart';
import '../guardians/guardians_screen.dart';
import '../radar/radar_screen.dart';
import '../settings/app_settings_screen.dart';
import '../emergency/emergency_event_screen.dart';

void showWalkWithMeSheet(BuildContext context, SafetyProvider safety) =>
    HomeDashboardScreen.showWalkWithMeSheet(context, safety);

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _formatLiveDateTime(bool isHindi) {
    final now = DateTime.now();
    final weekdaysEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekdaysHi = ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];
    final monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthsHi = ['जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];

    final weekday = isHindi ? weekdaysHi[now.weekday - 1] : weekdaysEn[now.weekday - 1];
    final month = isHindi ? monthsHi[now.month - 1] : monthsEn[now.month - 1];
    final day = now.day;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$weekday, $day $month • $hour:$minute';
  }

  void _showSosDialog(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context, listen: false);
    safety.triggerSimulatedSos();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Consumer<SafetyProvider>(
          builder: (context, prov, child) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D000000),
                      offset: Offset(0, 16),
                      blurRadius: 36,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryContainer,
                      ),
                      child: const Icon(
                        Icons.warning,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      prov.strings.sosModalTitle,
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prov.sosCountdown > 0
                          ? '${prov.strings.sosModalMsg} (${prov.sosCountdown}s)'
                          : 'Simulated high-priority alert broadcast active.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.slateSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DEMO MODE: No real emergency sirens or GPS calls are made.',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EmergencyEventScreen(),
                            ),
                          );
                        },
                        child: Text(
                          prov.strings.isHindi ? 'लाइव आपातकालीन हब खोलें' : 'OPEN LIVE EMERGENCY HUB',
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          prov.cancelSimulatedSos();
                          Navigator.of(dialogCtx).pop();
                        },
                        child: Text(
                          prov.strings.sosCancelFalse,
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWalkWithMeSheet(BuildContext context, SafetyProvider safety) =>
      showWalkWithMeSheet(context, safety);

  static void showWalkWithMeSheet(BuildContext context, SafetyProvider safety) {
    int minutes = 15;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.directions_walk,
                                color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            safety.strings.actionWalk,
                            style: AppTypography.headlineSm
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    safety.strings.isHindi
                        ? 'अभिभावक आपके चलने की अवधि की निगरानी करेंगे। यदि अवधि समाप्त होने पर आप चेक-इन नहीं करती हैं, तो मौन एसओएस सक्रिय हो जाएगा।'
                        : 'Guardians monitor your walk timer. If you do not check in before the timer expires, silent SOS alerts are automatically dispatched.',
                    style: AppTypography.bodySm
                        .copyWith(color: AppColors.slateSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    safety.strings.isHindi
                        ? 'चलने की अनुमानित अवधि चुनें:'
                        : 'Select Walk Duration:',
                    style: AppTypography.labelMd
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [10, 15, 20, 30].map((m) {
                      final isSel = minutes == m;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => minutes = m),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '$m min',
                                style: TextStyle(
                                  color: isSel ? Colors.white : AppColors.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TactileButton(
                      label: safety.strings.isHindi
                          ? 'साथी शुरू करें (सिम्युलेटेड)'
                          : 'Arm Walk Companion',
                      style: TactileButtonStyle.primaryCrimson,
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primary,
                            content: Text(
                              safety.strings.isHindi
                                  ? '$minutes मिनट का वॉक साथी सक्रिय हुआ। अभिभावक सतर्क हैं।'
                                  : '$minutes-min Walk With Me timer armed. Live coordinates shared with circle.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFakeCallModal(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        bool isConnected = false;
        int callDuration = 0;
        Timer? callTimer;

        return StatefulBuilder(
          builder: (context, setCallState) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: const Color(0xFF0F172A),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                isConnected
                                    ? 'CONNECTED • ENCRYPTED'
                                    : 'INCOMING SECURE CALL',
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () {
                                callTimer?.cancel();
                                Navigator.of(dialogCtx).pop();
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                              child: const Icon(Icons.person,
                                  size: 52, color: Colors.white),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              safety.emergencyContact.split('(').first.trim(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '+91 98112 40292 • Mobile',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isConnected
                                  ? '00:${callDuration.toString().padLeft(2, '0')} (Speak naturally to deter scrutiny)'
                                  : 'Simulated Incoming Call (Decoy)...',
                              style: TextStyle(
                                color: isConnected
                                    ? AppColors.emeraldSafe
                                    : AppColors.tertiary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (!isConnected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      callTimer?.cancel();
                                      Navigator.of(dialogCtx).pop();
                                    },
                                    child: Container(
                                      width: 68,
                                      height: 68,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: const Icon(Icons.call_end,
                                          color: Colors.white, size: 32),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Decline',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setCallState(() {
                                        isConnected = true;
                                        callTimer = Timer.periodic(
                                            const Duration(seconds: 1), (t) {
                                          setCallState(
                                              () => callDuration++);
                                        });
                                      });
                                    },
                                    child: Container(
                                      width: 68,
                                      height: 68,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      child: const Icon(Icons.call,
                                          color: Colors.white, size: 32),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Accept',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _callCircleBtn(Icons.mic_off, 'Mute'),
                                  _callCircleBtn(Icons.dialpad, 'Keypad'),
                                  _callCircleBtn(Icons.volume_up, 'Speaker'),
                                ],
                              ),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: () {
                                  callTimer?.cancel();
                                  Navigator.of(dialogCtx).pop();
                                },
                                child: Container(
                                  width: 68,
                                  height: 68,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: const Icon(Icons.call_end,
                                      color: Colors.white, size: 32),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _callCircleBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showSirenModal(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF7F1D1D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        title: const Row(
          children: [
            Icon(Icons.campaign, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text('ACOUSTIC SIREN ACTIVE',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.warning, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              '105 dB High-Acoustic Alarm Dispatched (Muted for Developer Prototype)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Strobe beacon flashing • GPS coordinates sent to nearby police post.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('DISARM SIREN',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : AppColors.surface.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkOutline : const Color(0x12000000),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const ShaktiEmblem(size: 30, animatePulse: false),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SHAKTI',
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            strings.isHindi ? 'सुरक्षा शील्ड' : 'Home Shield',
                            style: AppTypography.labelSm.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Settings Icon Button
                    GestureDetector(
                      key: TourTargetKeys.settingsKey,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AppSettingsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                          border: isDark ? Border.all(color: AppColors.darkOutline) : null,
                          boxShadow: isDark ? null : AppDecorations.tactileExtrusionSubtle,
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Human outline profile icon
                    GestureDetector(
                      onTap: () => safety.setNavIndex(3),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
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
            // Active SOS Emergency Alert Card (if triggered)
            if (safety.isSosActive) ...[
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmergencyEventScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.isHindi ? 'आपातकालीन एसओएस सक्रिय है!' : 'EMERGENCY SOS IS ACTIVE',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            Text(
                              strings.isHindi ? 'लाइव टेलीमेट्री व रूट इतिहास देखने हेतु टैप करें' : 'Tap to open Live Emergency Hub & Route History',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Top Greeting & Reassurance Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatLiveDateTime(strings.isHindi),
                        style: AppTypography.labelSm.copyWith(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${strings.greetingEvening}, ${safety.userName.isEmpty ? (strings.isHindi ? 'उपयोगकर्ता' : 'Friend') : safety.userName.split(' ').first}',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                            fontSize: 22,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    border: isDark ? Border.all(color: AppColors.darkOutline) : null,
                    boxShadow: isDark ? null : AppDecorations.tactileExtrusionSubtle,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.emeraldSafe,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        strings.statusProtected,
                        style: AppTypography.labelSm.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Ambient Telemetry Bar
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: BorderRadius.circular(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user,
                            size: 18, color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.systemsNominal,
                            style: AppTypography.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.silentReady,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.slateSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tactile Rapid Action Pills Row with Long-Press Floating Contextual Guide
            Row(
              children: [
                _buildActionPill(
                  icon: Icons.directions_walk,
                  color: AppColors.primary,
                  label: strings.actionWalk,
                  tooltip: strings.tooltipWalk,
                  meaning: strings.isHindi
                      ? 'सुरक्षित मार्ग व यात्रा पर्यवेक्षण का प्रतीक।'
                      : 'Walking figure representing active journey supervision.',
                  featureDoes: strings.isHindi
                      ? 'नियत समय की यात्रा की निगरानी करता है। यदि समय समाप्त होने से पहले आप चेक-इन नहीं करती हैं, तो स्वचालित आपातकालीन संदेश भेजा जाता है।'
                      : 'Monitors timed journeys with periodic check-ins. If you do not confirm safety before the countdown expires, silent SOS alerts are automatically dispatched.',
                  whenTapped: strings.isHindi
                      ? 'समय अवधि चयन पत्र खोलता है (10-30 मिनट) जिससे आपके अभिभावक मंडल को लाइव जीपीएस ट्रैकिंग प्राप्त होती है।'
                      : 'Opens the duration picker sheet (10–30 min) to arm the companion and share live GPS telemetry with your guardian circle.',
                  directActionLabel: strings.isHindi ? 'साथी शुरू करें' : 'ARM WALK COMPANION',
                  onTap: () => _showWalkWithMeSheet(context, safety),
                  context: context,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildActionPill(
                  icon: Icons.phone_in_talk,
                  color: AppColors.tertiary,
                  label: strings.actionFakeCall,
                  tooltip: strings.tooltipFakeCall,
                  meaning: strings.isHindi
                      ? 'आने वाली प्राथमिकता टेलीफ़ोन कॉल का प्रतीक।'
                      : 'Telephone handset representing an incoming priority phone call.',
                  featureDoes: strings.isHindi
                      ? 'असहज या संदिग्ध परिस्थिति से शालीनतापूर्वक बाहर निकलने के लिए एक प्रामाणिक इनकमिंग कॉल उत्पन्न करता है।'
                      : 'Triggers a realistic simulated incoming phone call from "Papa / Home" to help you gracefully exit uncomfortable or threatening interactions without raising suspicion.',
                  whenTapped: strings.isHindi
                      ? 'फ़ोन की घंटी बजाता है और स्क्रीन पर उत्तर देने व कॉल काटने के बटन दिखाता है।'
                      : 'Immediately rings your device in full-screen simulated call mode with caller name, audio ringtone, and interactive pick-up/decline buttons.',
                  directActionLabel: strings.isHindi ? 'नकली कॉल चालू करें' : 'TRIGGER FAKE CALL',
                  onTap: () => _showFakeCallModal(context, safety),
                  context: context,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildActionPill(
                  icon: Icons.campaign,
                  color: AppColors.secondary,
                  label: strings.actionSiren,
                  tooltip: strings.tooltipSiren,
                  meaning: strings.isHindi
                      ? 'उच्च-ध्वनि वाले आपातकालीन लाउडस्पीकर का प्रतीक।'
                      : 'Megaphone loudspeaker representing high-decibel acoustic deterrence.',
                  featureDoes: strings.isHindi
                      ? 'आसपास के लोगों का ध्यान आकर्षित करने और आक्रामक तत्वों को दूर भगाने हेतु तेज अलार्म बजाता है।'
                      : 'Dispatches a high-frequency acoustic alarm and strobe beacon to alert bystanders and deter nearby aggressors.',
                  whenTapped: strings.isHindi
                      ? 'सायरन चेतावनी स्क्रीन खोलता है जिसे तुरंत म्यूट व बंद भी किया जा सकता है।'
                      : 'Activates the emergency siren warning interface with immediate disarm controls.',
                  directActionLabel: strings.isHindi ? 'सायरन बजाएं' : 'DISPATCH SIREN',
                  onTap: () => _showSirenModal(context, safety),
                  context: context,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildActionPill(
                  icon: Icons.visibility_off,
                  color: AppColors.onSurfaceVariant,
                  label: strings.actionCamo,
                  tooltip: strings.tooltipCamo,
                  meaning: strings.isHindi
                      ? 'दबाव या खतरे की स्थिति में गुप्त गोपनीयता का प्रतीक।'
                      : 'Masked eye representing covert deception under duress.',
                  featureDoes: strings.isHindi
                      ? 'यदि कोई आपके फ़ोन की जांच करे तो स्क्रीन को तुरंत एक वास्तविक कैलकुलेटर में बदल देता है।'
                      : 'Instantly disguises SHAKTI as an innocent, fully functional calculator app if someone attempts to inspect your phone under duress.',
                  whenTapped: strings.isHindi
                      ? 'कैलकुलेटर स्क्रीन चालू करता है। बाहर आने हेतु अपना सुरक्षा पिन दर्ज करें।'
                      : 'Switches the screen to a working calculator disguise. Enter your secret PIN to safely exit back to SHAKTI.',
                  directActionLabel: strings.isHindi ? 'कैमूफ्लाज चालू करें' : 'ENGAGE CAMOUFLAGE',
                  onTap: () => safety.toggleCovertMode(),
                  context: context,
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Centerpiece SOS Trigger with Tooltip
            Center(
              child: Tooltip(
                message: strings.tooltipSos,
                preferBelow: true,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                child: SosBeaconButton(
                  onTrigger: () => _showSosDialog(context),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Minimal Connected Safeguards (Band V2 & Active Guardians)
            Row(
              children: [
                // Minimal Card A: Smart Band V2
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => safety.setNavIndex(2),
                    onLongPress: () {
                      showContextualHelpDialog(
                        context,
                        title: strings.isHindi ? 'शक्ति स्मार्ट बैंड V2' : 'SHAKTI Band V2',
                        icon: Icons.watch,
                        iconColor: AppColors.primary,
                        meaning: strings.isHindi
                            ? 'जोड़े गए हार्डवेयर स्मार्ट रिस्टबैंड की कनेक्टिविटी स्थिति दर्शाता है।'
                            : 'Hardware status beacon for your paired wearable safety wristband.',
                        featureDoes: strings.isHindi
                            ? 'ब्लूटूथ एलई से जुड़ा रहता है और कलाई पर स्थित दोनों पैनिक स्विच के ट्रिगर की निगरानी करता है।'
                            : 'Monitors Bluetooth LE link strength, internal battery life, and discrete physical dual-switch SOS panic triggers.',
                        whenTapped: strings.isHindi
                            ? 'हार्डवेयर डायग्नोस्टिक्स, पेयरिंग और फर्मवेयर नियंत्रण हेतु बैंड हब खोलता है।'
                            : 'Navigates directly to the Wristband Hub for battery diagnostics, BLE scan, and haptic feedback settings.',
                        directActionLabel: strings.isHindi ? 'बैंड हब खोलें' : 'OPEN BAND HUB',
                        onDirectAction: () => safety.setNavIndex(2),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFFFDE8EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.watch_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.isHindi ? 'स्मार्ट बैंड' : 'SHAKTI Band',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: safety.bandBleConnected
                                          ? AppColors.emeraldSafe
                                          : AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      safety.bandBleConnected
                                          ? '${strings.bandSynced} • ${safety.bandBattery}%'
                                          : (strings.isHindi ? 'ऑफ़लाइन' : 'Standby'),
                                      style: AppTypography.labelSm.copyWith(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: safety.bandBleConnected
                                            ? AppColors.emeraldSafe
                                            : AppColors.secondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Minimal Card B: Active Guardians
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GuardiansScreen(),
                        ),
                      );
                    },
                    onLongPress: () {
                      showContextualHelpDialog(
                        context,
                        title: strings.isHindi ? 'सक्रिय अभिभावक चक्र' : 'Active Guardians',
                        icon: Icons.shield_outlined,
                        iconColor: AppColors.primary,
                        meaning: strings.isHindi
                            ? 'आपके सत्यापित आपातकालीन संपर्कों और पुलिस सहायता नेटवर्क का प्रतीक।'
                            : 'Your verified emergency contact circle and direct response ring.',
                        featureDoes: strings.isHindi
                            ? 'संकट के समय तुरंत एसएमएस, लाइव लोकेशन और स्वचालित वॉयस कॉल अलर्ट प्राप्त करने वाले संपर्कों को बनाए रखता है।'
                            : 'Maintains trusted family contacts and PCR dispatchers who receive immediate SMS coordinates and push notifications when SOS is triggered.',
                        whenTapped: strings.isHindi
                            ? 'अभिभावक संपर्कों को जोड़ने, हटाने और प्राथमिकता तय करने हेतु स्क्रीन खोलता है।'
                            : 'Opens the Guardian Circle screen to manage trusted contacts, view alert rings, and test response times.',
                        directActionLabel: strings.isHindi ? 'अभिभावक देखें' : 'VIEW GUARDIANS',
                        onDirectAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GuardiansScreen(),
                            ),
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFFFDE8EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.group_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.isHindi ? 'अभिभावक' : 'Guardians',
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                strings.isHindi ? '4 संपर्क सक्रिय' : '4 in Safety Ring',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFFB48598),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Live Location & Precision GPS Tile - navigates to RadarScreen
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RadarScreen()),
                );
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFFFDE8EC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.liveCoordinates,
                                    style: AppTypography.labelSm.copyWith(
                                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    strings.currentAddress,
                                    style: AppTypography.bodyMd.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldLightBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          strings.precisionFix,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.emeraldSafe,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Integrated Mini Location Map Texture
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFCBD5E1),
                          Color(0xFFE2E8F0),
                          Color(0xFFCBD5E1),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _MiniMapPainter(),
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 3,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.share_location,
                                    size: 11, color: AppColors.tertiary),
                                const SizedBox(width: 4),
                                Text(
                                  strings.satelliteFix,
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Safety Radar & AI Advisory
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.wb_twilight,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                strings.radarTitle,
                                style: AppTypography.headlineSm.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          strings.radarClear,
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.radarDesc,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.slateSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _advisoryButton(
                          icon: Icons.auto_awesome,
                          color: AppColors.tertiary,
                          label: strings.aiAssistantBtn,
                          onTap: () => showAiAssistantModal(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _advisoryButton(
                          icon: Icons.radar,
                          color: AppColors.primary,
                          label: strings.isHindi ? 'रडार खोलें' : 'Open Radar',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RadarScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120), // Padding for floating nav bar and floating AI assistant
          ],
        ),
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required Color color,
    required String label,
    required String tooltip,
    required String meaning,
    required String featureDoes,
    required String whenTapped,
    String? directActionLabel,
    required VoidCallback onTap,
    required BuildContext context,
    required bool isDark,
  }) {
    return Expanded(
      child: Tooltip(
        message: '$label (Hold for guide)',
        preferBelow: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () {
            showContextualHelpDialog(
              context,
              title: label,
              icon: icon,
              iconColor: color,
              meaning: meaning,
              featureDoes: featureDoes,
              whenTapped: whenTapped,
              directActionLabel: directActionLabel,
              onDirectAction: onTap,
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
                width: 1.0,
              ),
              boxShadow: isDark ? null : AppDecorations.feminineCardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFFFDE8EC),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _advisoryButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppDecorations.tactileExtrusionSubtle,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 3;

    final secondaryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    // Roads
    canvas.drawLine(
        Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), linePaint);
    canvas.drawLine(Offset(size.width * 0.45, 0),
        Offset(size.width * 0.55, size.height), linePaint);

    // Cross streets
    canvas.drawLine(
        Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.65), secondaryPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0),
        Offset(size.width * 0.15, size.height), secondaryPaint);
    canvas.drawLine(Offset(size.width * 0.8, 0),
        Offset(size.width * 0.85, size.height), secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
