import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../services/permission_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shakti_emblem.dart';
import '../../widgets/tactile_button.dart';
import 'band_onboarding_screen.dart';

class SafetyPermissionsScreen extends StatefulWidget {
  final bool isFromSettings;

  const SafetyPermissionsScreen({
    super.key,
    this.isFromSettings = false,
  });

  @override
  State<SafetyPermissionsScreen> createState() => _SafetyPermissionsScreenState();
}

class _SafetyPermissionsScreenState extends State<SafetyPermissionsScreen> {
  void _proceed(BuildContext context, SafetyProvider safety) {
    if (widget.isFromSettings) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const BandOnboardingScreen(),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
        ),
      );
    }
  }

  Color _statusColor(PermissionStatusState status) {
    switch (status) {
      case PermissionStatusState.granted:
        return AppColors.emeraldSafe;
      case PermissionStatusState.denied:
      case PermissionStatusState.permanentlyDenied:
        return AppColors.primary;
      case PermissionStatusState.restrictedByPlatform:
        return AppColors.tertiary;
      case PermissionStatusState.notRequested:
        return AppColors.slateSecondary;
    }
  }

  String _statusLabel(PermissionStatusState status, bool isHindi) {
    switch (status) {
      case PermissionStatusState.granted:
        return isHindi ? 'स्वीकृत' : 'Granted';
      case PermissionStatusState.denied:
        return isHindi ? 'अस्वीकृत' : 'Denied';
      case PermissionStatusState.permanentlyDenied:
        return isHindi ? 'स्थायी अस्वीकृत' : 'Blocked';
      case PermissionStatusState.restrictedByPlatform:
        return isHindi ? 'प्लेटफ़ॉर्म नीति प्रतिबंध' : 'OS Policy Restricted';
      case PermissionStatusState.notRequested:
        return isHindi ? 'अनुरोध नहीं किया' : 'Not Requested';
    }
  }

  IconData _permissionIcon(SafetyPermissionType type) {
    switch (type) {
      case SafetyPermissionType.location:
        return Icons.location_on;
      case SafetyPermissionType.microphone:
        return Icons.mic;
      case SafetyPermissionType.camera:
        return Icons.camera_alt;
      case SafetyPermissionType.notifications:
        return Icons.notifications_active;
      case SafetyPermissionType.bluetooth:
        return Icons.bluetooth;
      case SafetyPermissionType.photoPicker:
        return Icons.photo_library;
      case SafetyPermissionType.callLog:
        return Icons.call;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;
    final isHindi = strings.isHindi;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permissions = safety.permissionService.allPermissions.values.toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      appBar: AppBar(
        title: Text(
          strings.permissionsTitle,
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        leading: widget.isFromSettings
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Shield Banner
            Center(
              child: Column(
                children: [
                  const ShaktiEmblem(size: 64, animatePulse: false),
                  const SizedBox(height: 12),
                  Text(
                    strings.permissionsTitle,
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.permissionsSubtitle,
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Explanatory Permission Cards
            ...permissions.map((perm) {
              final statusColor = _statusColor(perm.status);
              final statusText = _statusLabel(perm.status, isHindi);
              final title = isHindi ? perm.titleHi : perm.titleEn;
              final desc = isHindi ? perm.descHi : perm.descEn;
              final whyNeeded = isHindi ? perm.whyNeededHi : perm.whyNeededEn;
              final limitation = isHindi ? perm.platformLimitationHi : perm.platformLimitationEn;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_permissionIcon(perm.type), color: statusColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: AppTypography.titleSm.copyWith(fontWeight: FontWeight.w800),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  desc,
                                  style: AppTypography.bodySm.copyWith(
                                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Why SHAKTI Needs It Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                whyNeeded,
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateCharcoal,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (limitation != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 12, color: AppColors.slateSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                limitation,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Enable / Toggle Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (perm.type != SafetyPermissionType.callLog)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: perm.isGranted ? AppColors.slateSecondary : AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: Icon(perm.isGranted ? Icons.check : Icons.lock_open, size: 14),
                              label: Text(
                                perm.isGranted
                                    ? (isHindi ? 'सक्षम है (टैप से बदलें)' : 'Granted (Tap to Toggle)')
                                    : (isHindi ? 'अनुमति सक्षम करें' : 'Grant Permission'),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                              onPressed: () {
                                safety.permissionService.togglePermission(perm.type);
                              },
                            )
                          else
                            Text(
                              isHindi
                                  ? '• इन-ऐप मैनुअल कॉल लॉग उपलब्ध'
                                  : '• In-app manual call log available',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.slateSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Optional notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.permOptionalNotice,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11,
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: TactileButton(
                label: widget.isFromSettings
                    ? (isHindi ? 'परिवर्तन सहेजें एवं वापस जाएं' : 'Done & Return to Settings')
                    : strings.permActionContinue,
                style: TactileButtonStyle.primaryCrimson,
                onPressed: () => _proceed(context, safety),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
