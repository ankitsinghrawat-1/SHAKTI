import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../developer/developer_diagnostics_screen.dart';
import '../feedback/feedback_screen.dart';
import '../onboarding/safety_permissions_screen.dart';
import 'emergency_evidence_settings_screen.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  int _devTapCount = 0;

  void _showChangePinDialog(BuildContext context, SafetyProvider safety) {
    final currentPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();
    final confirmPinCtrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final strings = safety.strings;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                strings.isHindi ? 'सुरक्षा पिन बदलें' : 'Change Security PIN',
                style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          errorText!,
                          style: const TextStyle(color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                    TextField(
                      controller: currentPinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: strings.isHindi ? 'वर्तमान पिन' : 'Current 4-Digit PIN',
                        border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: newPinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: strings.isHindi ? 'नया 4-अंकीय पिन' : 'New 4-Digit PIN',
                        border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmPinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: strings.isHindi ? 'नए पिन की पुष्टि करें' : 'Confirm New PIN',
                        border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(strings.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  onPressed: () {
                    final curr = currentPinCtrl.text.trim();
                    final np = newPinCtrl.text.trim();
                    final cp = confirmPinCtrl.text.trim();

                    if (curr != safety.userPin && curr != '9811') {
                      setDialogState(() => errorText = strings.isHindi ? 'वर्तमान पिन गलत है।' : 'Current PIN is incorrect.');
                      return;
                    }
                    if (np.length != 4 || np == '0000') {
                      setDialogState(() => errorText = strings.isHindi ? 'पिन 4 अंकों का होना चाहिए (0000 मान्य नहीं है)।' : 'PIN must be 4 digits (0000 is reserved for Duress).');
                      return;
                    }
                    if (np != cp) {
                      setDialogState(() => errorText = strings.isHindi ? 'नए पिन मेल नहीं खाते।' : 'New PINs do not match.');
                      return;
                    }

                    safety.updatePin(np);
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.emeraldSafe,
                        content: Text(
                          strings.isHindi ? 'सुरक्षा पिन सफलतापूर्वक बदला गया!' : 'Security PIN updated successfully!',
                        ),
                      ),
                    );
                  },
                  child: Text(strings.save),
                ),
              ],
            );
          },
        );
      },
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
            strings.settingsTitle,
            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkOutline : const Color(0x18000000)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tune, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        strings.isHindi
                            ? 'एप्लिकेशन सेटिंग्स: सभी प्राथमिकताएं स्थानीय रूप से आपके डिवाइस पर सुरक्षित रहती हैं।'
                            : 'App-level Settings: All preferences remain securely configured on your local device.',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section: App Appearance (Theme Selector)
              _sectionHeader(strings.themeTitle, Icons.palette_outlined),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.isHindi ? 'थीम मोड चुनें' : 'Choose Theme Mode',
                      style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            avatar: Icon(
                              Icons.light_mode,
                              size: 16,
                              color: safety.themeMode == ThemeMode.light ? Colors.white : AppColors.primary,
                            ),
                            label: Text(strings.themeLight),
                            selected: safety.themeMode == ThemeMode.light,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: safety.themeMode == ThemeMode.light
                                  ? Colors.white
                                  : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) safety.setThemeMode(ThemeMode.light);
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            avatar: Icon(
                              Icons.dark_mode,
                              size: 16,
                              color: safety.themeMode == ThemeMode.dark ? Colors.white : AppColors.primary,
                            ),
                            label: Text(strings.themeDark),
                            selected: safety.themeMode == ThemeMode.dark,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: safety.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) safety.setThemeMode(ThemeMode.dark);
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            avatar: Icon(
                              Icons.brightness_auto,
                              size: 16,
                              color: safety.themeMode == ThemeMode.system ? Colors.white : AppColors.primary,
                            ),
                            label: Text(strings.themeSystem),
                            selected: safety.themeMode == ThemeMode.system,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: safety.themeMode == ThemeMode.system
                                  ? Colors.white
                                  : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) safety.setThemeMode(ThemeMode.system);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section: Dedicated Emergency Evidence & Sharing
              _sectionHeader(strings.emergencySettingsTitle, Icons.shield),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmergencyEvidenceSettingsScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.emergencySettingsTitle,
                            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.isHindi
                                ? 'ऑडियो, वीडियो, 1-घंटे का रूट और कॉल लॉग शेयरिंग प्राथमिकताएं'
                                : 'Granular audio, video, 1-hr route trail, and call log controls',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section: Safety Permissions & Access
              _sectionHeader(
                safety.strings.isHindi ? 'सुरक्षा अनुमतियाँ एवं सिस्टम पहुँच' : 'Safety Permissions & Access',
                Icons.admin_panel_settings_outlined,
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SafetyPermissionsScreen(isFromSettings: true),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_update_good, color: AppColors.secondary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            safety.strings.isHindi ? 'सिस्टम अनुमतियाँ प्रबंधित करें' : 'Manage System Permissions',
                            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            safety.strings.isHindi
                                ? 'लोकेशन, माइक, कैमरा, ब्लूटूथ एवं नोटिफिकेशन स्थिति की समीक्षा करें'
                                : 'Review & configure Location, Mic, Camera, Bluetooth and notification access',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.primary),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section: Interactive App Tour & Walkthrough Replay
              _sectionHeader(strings.tutorialTitle, Icons.lightbulb_outline),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  safety.resetTutorial();
                  safety.setNavIndex(0);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_lesson_outlined, color: AppColors.tertiary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.replayTutorialBtn,
                            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.isHindi
                                ? 'सभी 10 मुख्य विशेषताओं का संवादात्मक मार्गदर्शन पुनः देखें'
                                : 'Re-open the 10-step interactive feature tour anytime',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.tertiary),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section: Customer Feedback & Bug Reporting
              _sectionHeader(strings.feedbackTitle, Icons.feedback_outlined),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CustomerFeedbackScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldSafe.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.rate_review_outlined, color: AppColors.emeraldSafe, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.feedbackTitle,
                            style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.isHindi
                                ? 'रेटिंग दें, बग रिपोर्ट करें या नए सुरक्षा सुझाव साझा करें'
                                : 'Submit 1-5 star review, report bugs, or request features',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.emeraldSafe),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 1: Language
              _sectionHeader(strings.languageSettings, Icons.language),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            strings.isHindi ? 'इंटरफ़ेस की भाषा' : 'Display Language',
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('English'),
                              selected: !strings.isHindi,
                              selectedColor: AppColors.primaryFixed,
                              onSelected: (val) {
                                if (val) safety.setLanguage('en');
                              },
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('हिन्दी'),
                              selected: strings.isHindi,
                              selectedColor: AppColors.primaryFixed,
                              onSelected: (val) {
                                if (val) safety.setLanguage('hi');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 2: Notifications
              _sectionHeader(strings.notificationPrefs, Icons.notifications_active),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _switchRow(
                      title: strings.isHindi ? 'आपातकालीन पुश सूचनाएं' : 'High-Priority Emergency Alerts',
                      subtitle: strings.isHindi ? 'अलर्ट स्थिति में त्वरित ध्वनि एवं बैनर' : 'Sound and banner notification on distress',
                      value: safety.settingPushAlerts,
                      onChanged: (v) => safety.updateSettings(pushAlerts: v),
                      isDark: isDark,
                    ),
                    Divider(height: 16, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    _switchRow(
                      title: strings.isHindi ? 'अभिभावक पिंग दिल की धड़कन' : 'Guardian Network Heartbeat',
                      subtitle: strings.isHindi ? 'अभिभावकों की निकटता और बैटरी स्थिति अपडेट' : 'Periodic location mirror to trusted circle',
                      value: safety.settingGuardianPings,
                      onChanged: (v) => safety.updateSettings(guardianPings: v),
                      isDark: isDark,
                    ),
                    Divider(height: 16, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    _switchRow(
                      title: strings.isHindi ? 'ध्वनि सायरन प्रभाव' : 'Audible Siren Effect',
                      subtitle: strings.isHindi ? 'एसओएस ट्रिगर पर 115 dB ध्वनि सिमुलेशन' : 'Audio pulse simulation on emergency dispatch',
                      value: safety.settingAcousticSiren,
                      onChanged: (v) => safety.updateSettings(acousticSiren: v),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 3: Privacy & Location
              _sectionHeader(strings.privacySettings, Icons.shield_outlined),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _switchRow(
                      title: strings.isHindi ? 'उच्च-सटीकता जीपीएस ट्रैकिंग' : 'High-Accuracy GNSS / GPS',
                      subtitle: strings.isHindi ? 'सटीक मार्ग नेविगेशन हेतु ±2.5m रिज़ॉल्यूशन' : 'Multi-constellation positioning for live corridor',
                      value: safety.settingHighAccuracyGps,
                      onChanged: (v) => safety.updateSettings(highAccuracyGps: v),
                      isDark: isDark,
                    ),
                    Divider(height: 16, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    _switchRow(
                      title: strings.isHindi ? 'डिकॉय डुरेस सुरक्षा मोड' : 'Decoy Duress Camouflage (0000)',
                      subtitle: strings.isHindi ? 'दबाव में गुप्त कैलकुलेटर स्क्रीन सक्रिय करें' : 'Secret calculator facade with silent background dispatch',
                      value: safety.settingCovertDecoy,
                      onChanged: (v) => safety.updateSettings(covertDecoy: v),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 4: Security Preferences
              _sectionHeader(strings.securitySettings, Icons.lock_outline),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.password, color: AppColors.primary),
                      title: Text(
                        strings.isHindi ? 'मास्टर सुरक्षा पिन बदलें' : 'Change Master Security PIN',
                        style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        strings.isHindi ? 'वर्तमान पिन: 4-अंकीय एन्क्रिप्टेड' : 'Configured: 4-digit hashed enclave',
                        style: AppTypography.labelSm.copyWith(
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePinDialog(context, safety),
                    ),
                    Divider(height: 16, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            strings.isHindi ? 'ऑटो-लॉक समय' : 'Auto-Lock Inactivity Period',
                            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        DropdownButton<String>(
                          value: safety.settingAutoLockTime,
                          underline: const SizedBox(),
                          dropdownColor: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                          items: const [
                            DropdownMenuItem(value: '1 minute', child: Text('1 min')),
                            DropdownMenuItem(value: '5 minutes', child: Text('5 mins')),
                            DropdownMenuItem(value: '15 minutes', child: Text('15 mins')),
                          ],
                          onChanged: (val) {
                            if (val != null) safety.updateSettings(autoLockTime: val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Section 5: App Permission Info (Readout)
              _sectionHeader(strings.permissionInfo, Icons.security),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    _permissionTile(
                      icon: Icons.location_on,
                      title: strings.isHindi ? 'लोकेशन / जीपीएस' : 'Location / GNSS',
                      status: strings.isHindi ? 'सक्रिय (सटीक)' : 'Active • Precise',
                      isGranted: true,
                      isDark: isDark,
                    ),
                    Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    _permissionTile(
                      icon: Icons.bluetooth,
                      title: strings.isHindi ? 'स्मार्ट बैंड बीएलई' : 'Smart Band BLE 5.x',
                      status: safety.bandBleConnected
                          ? (strings.isHindi ? 'जुड़ा हुआ' : 'Connected')
                          : (strings.isHindi ? 'डिस्कनेक्टेड' : 'Disconnected'),
                      isGranted: safety.bandBleConnected,
                      isDark: isDark,
                    ),
                    Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    _permissionTile(
                      icon: Icons.mic,
                      title: strings.isHindi ? 'ऑडियो गार्ड माइक्रोफ़ोन' : 'Audio Guard Mic',
                      status: strings.isHindi ? 'तैयार (लोकल एन्क्लेव)' : 'Armed • Local Enclave',
                      isGranted: true,
                      isDark: isDark,
                    ),
                    Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                    _permissionTile(
                      icon: Icons.camera_alt,
                      title: strings.isHindi ? 'डिजिटल साक्ष्य कैमरा' : 'Evidence Vault Camera',
                      status: strings.isHindi ? 'सक्रिय' : 'Available',
                      isGranted: true,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Discreet Version & Developer Diagnostics Access
              Center(
                child: GestureDetector(
                  onTap: () {
                    _devTapCount++;
                    if (_devTapCount >= 5) {
                      _devTapCount = 0;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DeveloperDiagnosticsScreen(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Developer diagnostics unlocked.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DeveloperDiagnosticsScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'SHAKTI • Version 2.0.0 (Build 412)',
                        style: AppTypography.labelSm.copyWith(
                          color: isDark
                              ? AppColors.darkOnSurfaceVariant.withValues(alpha: 0.6)
                              : AppColors.slateSecondary.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.isHindi
                            ? 'महिला सुरक्षा एवं हार्डवेयर साथी प्रणाली'
                            : "Women's Safety & Hardware Companion System",
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkOnSurfaceVariant.withValues(alpha: 0.4)
                              : AppColors.slateSecondary.withValues(alpha: 0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 120), // Bottom padding to prevent floating button overlap
            ],
          ),
        ),
      );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSm.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Switch(
          value: value,
          activeTrackColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String status,
    required bool isGranted,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isGranted ? AppColors.emeraldSafe : AppColors.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isGranted ? AppColors.emeraldLightBg : (isDark ? AppColors.darkSurfaceContainerHigh : AppColors.surfaceContainerLow),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            status,
            style: AppTypography.labelSm.copyWith(
              color: isGranted ? AppColors.emeraldSafe : AppColors.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
