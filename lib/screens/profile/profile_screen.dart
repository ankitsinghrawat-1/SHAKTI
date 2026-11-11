import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tactile_button.dart';
import '../auth/secure_login_screen.dart';
import '../guardians/guardians_screen.dart';
import '../settings/app_settings_screen.dart';
import '../vault/evidence_vault_screen.dart';
import '../feedback/feedback_screen.dart';
import '../onboarding/safety_permissions_screen.dart';
import '../settings/emergency_evidence_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'S';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  void _showEditProfileDialog(BuildContext context, SafetyProvider safety) {
    final nameCtrl = TextEditingController(text: safety.userName);
    final phoneCtrl = TextEditingController(text: safety.userPhone);
    final contactCtrl = TextEditingController(text: safety.emergencyContact);
    final notesCtrl = TextEditingController(text: safety.medicalNotes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      safety.strings.editProfile,
                      style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: safety.strings.isHindi ? 'पूरा नाम' : 'Full Name',
                    border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: safety.strings.isHindi ? 'मोबाइल नंबर' : 'Mobile Number',
                    border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactCtrl,
                  decoration: InputDecoration(
                    labelText: safety.strings.isHindi ? 'प्राथमिक आपातकालीन संपर्क' : 'Primary Emergency Contact',
                    border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    prefixIcon: const Icon(Icons.contact_emergency_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: safety.strings.isHindi ? 'चिकित्सा एवं आपातकालीन नोट' : 'Medical & Emergency Notes',
                    border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    prefixIcon: const Icon(Icons.medical_services_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: TactileButton(
                    label: safety.strings.save,
                    style: TactileButtonStyle.primaryCrimson,
                    onPressed: () {
                      safety.updateProfile(
                        name: nameCtrl.text,
                        phone: phoneCtrl.text,
                        emergencyContact: contactCtrl.text,
                        notes: notesCtrl.text,
                      );
                      Navigator.of(sheetCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.slateCharcoal,
                          content: Text(safety.strings.isHindi ? 'प्रोफ़ाइल विवरण अपडेट किया गया।' : 'Profile details updated.'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMedicalIdDialog(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.medical_services, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(safety.strings.medicalIdShortcut, style: AppTypography.headlineSm),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogDetailRow(safety.strings.isHindi ? 'रक्त समूह' : 'Blood Group', safety.bloodGroup),
            const Divider(height: 16),
            _dialogDetailRow(safety.strings.isHindi ? 'आपातकालीन संपर्क' : 'Emergency Contact', safety.emergencyContact),
            const Divider(height: 16),
            _dialogDetailRow(safety.strings.isHindi ? 'चिकित्सा अलर्ट' : 'Medical Alerts', safety.medicalNotes),
            const Divider(height: 16),
            _dialogDetailRow(safety.strings.isHindi ? 'अंग दाता' : 'Organ Donor', safety.strings.isHindi ? 'पंजीकृत (सेफ़गोव)' : 'Registered (SafeGov)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(safety.strings.done, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showPinSettingsDialog(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(safety.strings.pinSettingsShortcut, style: AppTypography.headlineSm),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safety.strings.isHindi ? 'मास्टर पिन: सक्रिय (9811)' : 'Master PIN: Active (9811)',
              style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              safety.strings.isHindi
                  ? 'पिन डिवाइस के स्थानीय सुरक्षित एन्क्लेव में संग्रहीत है।'
                  : 'PIN is securely stored in device local enclave session.',
              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                safety.strings.isHindi
                    ? 'डुरेस पिन: "0000" पर सेट। 0000 दर्ज करने पर चुपचाप एसओएस भेजते हुए स्क्रीन को कैमूफ्लाज प्लेयर में बदल दिया जाता है।'
                    : 'Duress PIN: Set to "0000". Entering 0000 covertly switches screen to Camouflage player while secretly broadcasting SOS.',
                style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              safety.strings.isHindi
                  ? 'सुरक्षित सत्र सक्रिय • उच्च सुरक्षा हेतु बायोमेट्रिक बायपास निष्क्रिय।'
                  : 'Cryptographic Session Active • Biometric bypass disabled for security.',
              style: AppTypography.labelSm.copyWith(color: AppColors.emeraldSafe, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(safety.strings.done, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.shield_moon, color: AppColors.tertiary),
            const SizedBox(width: 8),
            Text(safety.strings.privacyInfo, style: AppTypography.headlineSm),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safety.strings.isHindi ? 'शून्य डेटा बिक्री गारंटी' : 'Zero Cloud Data Selling Guarantee',
              style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              safety.strings.isHindi
                  ? 'सभी रूट लॉग और आपातकालीन संपर्क स्थानीय सैंडबॉक्स मेमोरी में रहते हैं। ऑडियो केवल एसओएस सक्रिय होने पर ही रिकॉर्ड होता है।'
                  : 'All route logs and emergency contacts are held in local sandbox memory. Audio snippets are only recorded during SOS activation.',
              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
            ),
            const SizedBox(height: 10),
            Text(
              safety.strings.isHindi
                  ? 'सिमुलेशन सूचना: इस प्रोटोटाइप में कोई वास्तविक बाहरी सेल्युलर कॉल, एसएमएस या क्लाउड एपीआई नहीं जुड़े हैं।'
                  : 'Simulation Notice: For this developer prototype, no actual external cellular calls, SMS, or cloud APIs are connected.',
              style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(safety.strings.done, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(safety.strings.logout, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800)),
        content: Text(safety.strings.logoutConfirm, style: AppTypography.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(safety.strings.cancel, style: const TextStyle(color: AppColors.slateSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              safety.logout();
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, anim1, anim2) => const SecureLoginScreen(initialMode: AuthMode.welcome),
                  transitionsBuilder: (context, anim1, anim2, child) => FadeTransition(opacity: anim1, child: child),
                ),
                (route) => false,
              );
            },
            child: Text(safety.strings.logout),
          ),
        ],
      ),
    );
  }

  static Widget _dialogDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSm.copyWith(color: AppColors.mutedGrey)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(strings.profileTitle, style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            GlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar Placeholder with verified ring
                      Stack(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryContainer],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33B41D26),
                                  offset: Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(safety.userName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.emeraldSafe,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              safety.userName,
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+91 ${safety.userPhone}',
                              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  safety.shieldId,
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${strings.bloodGroupPrefix}${safety.bloodGroup}',
                                    style: AppTypography.labelSm.copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0x18000000)),
                  const SizedBox(height: 12),

                  // Profile Completion Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings.profileCompletion, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700)),
                      Text('90%', style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 0.90,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.emeraldSafe),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        side: const BorderSide(color: AppColors.primaryFixed),
                      ),
                      icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                      label: Text(strings.editProfile, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      onPressed: () => _showEditProfileDialog(context, safety),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Shortcuts Header
            Text(
              strings.isHindi ? 'सुरक्षा सेटिंग्स एवं शॉर्टकट' : 'Safety Settings & Shortcuts',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.mutedGrey,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // App Settings Shortcut
            _settingsTile(
              icon: Icons.tune,
              iconColor: AppColors.primary,
              title: strings.isHindi ? 'ऐप वरीयताएँ एवं सेटिंग्स' : 'App Settings & Preferences',
              subtitle: strings.appSettingsSub,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Guardian Circle Shortcut
            _settingsTile(
              icon: Icons.diversity_1,
              iconColor: AppColors.primary,
              title: strings.guardiansShortcut,
              subtitle: strings.guardiansSub,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GuardiansScreen()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Evidence Vault Shortcut
            _settingsTile(
              icon: Icons.lock_clock,
              iconColor: AppColors.primary,
              title: strings.vaultTitle,
              subtitle: strings.vaultSub,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EvidenceVaultScreen()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Medical ID Shortcut
            _settingsTile(
              icon: Icons.medical_services,
              iconColor: AppColors.secondary,
              title: strings.medicalIdShortcut,
              subtitle: strings.isHindi
                  ? 'रक्त समूह ${safety.bloodGroup} • आपातकालीन नोट'
                  : 'Blood Group ${safety.bloodGroup} • Emergency Notes',
              onTap: () => _showMedicalIdDialog(context, safety),
            ),
            const SizedBox(height: 8),

            // PIN Settings Shortcut
            _settingsTile(
              icon: Icons.lock_outline,
              iconColor: AppColors.tertiary,
              title: strings.pinSettingsShortcut,
              subtitle: strings.pinSettingsSub,
              onTap: () => _showPinSettingsDialog(context, safety),
            ),
            const SizedBox(height: 8),

            // Emergency Evidence & Sharing Shortcut
            _settingsTile(
              icon: Icons.shield,
              iconColor: AppColors.primary,
              title: strings.emergencySettingsTitle,
              subtitle: strings.emergencySettingsSub,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmergencyEvidenceSettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 8),

            // System Permissions & Privacy Shortcut
            _settingsTile(
              icon: Icons.security_update_good,
              iconColor: AppColors.secondary,
              title: strings.isHindi ? 'सिस्टम अनुमतियाँ एवं गोपनीयता' : 'System Permissions & Privacy',
              subtitle: strings.isHindi
                  ? 'स्थान, माइक, कैमरा, ब्लूटूथ एवं सूचना अनुमतियाँ प्रबंधित करें'
                  : 'Manage Location, Mic, Camera, Bluetooth, and alerts access',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SafetyPermissionsScreen(isFromSettings: true)),
                );
              },
            ),
            const SizedBox(height: 8),

            // App Tutorial Walkthrough Replay
            _settingsTile(
              icon: Icons.play_lesson_outlined,
              iconColor: AppColors.tertiary,
              title: strings.replayTutorialBtn,
              subtitle: strings.isHindi
                  ? 'डैशबोर्ड पर 5-चरणीय इंटरएक्टिव टूर पुनः देखें'
                  : 'Replay 5-step interactive dashboard tour',
              onTap: () {
                safety.resetTutorial();
                safety.setNavIndex(0);
              },
            ),
            const SizedBox(height: 8),

            // Customer Feedback & Bug Report
            _settingsTile(
              icon: Icons.rate_review_outlined,
              iconColor: AppColors.emeraldSafe,
              title: strings.feedbackTitle,
              subtitle: strings.feedbackSub,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CustomerFeedbackScreen()),
                );
              },
            ),
            const SizedBox(height: 8),

            // Language Selector
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: BorderRadius.circular(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.translate, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strings.languageSettings, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                          Text(strings.isHindi ? 'वर्तमान: हिन्दी' : 'Current: English', style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        _langPill('EN', !strings.isHindi, () => safety.setLanguage('en')),
                        _langPill('हिंदी', strings.isHindi, () => safety.setLanguage('hi')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Notification Preferences
            Text(
              strings.notificationPrefs,
              style: AppTypography.labelSm.copyWith(
                color: AppColors.mutedGrey,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  _switchTile(
                    strings.sosPushAlertsTitle,
                    strings.sosPushAlertsDesc,
                    safety.notifySosPush,
                    (val) => safety.notifySosPush = val,
                  ),
                  const Divider(height: 1, color: Color(0x18000000)),
                  _switchTile(
                    strings.silentVibrationsTitle,
                    strings.silentVibrationsDesc,
                    safety.notifySilent,
                    (val) => safety.notifySilent = val,
                  ),
                  const Divider(height: 1, color: Color(0x18000000)),
                  _switchTile(
                    strings.guardianTelemetryTitle,
                    strings.guardianTelemetryDesc,
                    safety.notifyGuardianTracking,
                    (val) => safety.notifyGuardianTracking = val,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Privacy Info Tile
            _settingsTile(
              icon: Icons.shield_moon,
              iconColor: AppColors.slateSecondary,
              title: strings.privacyInfo,
              subtitle: strings.privacySub,
              onTap: () => _showPrivacyDialog(context, safety),
            ),

            const SizedBox(height: 22),

            // Logout Action
            SizedBox(
              width: double.infinity,
              child: TactileButton(
                label: strings.logout,
                icon: const Icon(Icons.logout, color: Colors.white, size: 18),
                style: TactileButtonStyle.primaryCrimson,
                onPressed: () => _confirmLogout(context, safety),
              ),
            ),

            const SizedBox(height: 120), // Bottom padding for navigation bar and floating AI button
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.slateSecondary),
        ],
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700)),
                    Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 10)),
                  ],
                ),
              ),
              Switch(
                value: value,
                activeTrackColor: AppColors.primary,
                onChanged: (newVal) {
                  setState(() => value = newVal);
                  onChanged(newVal);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _langPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
            ? const [
                BoxShadow(color: Color(0x18000000), offset: Offset(0, 1), blurRadius: 3),
              ]
            : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.slateSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
