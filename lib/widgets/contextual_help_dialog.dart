import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Elegant floating contextual help card popup anchored near pressed elements
/// Displays:
/// 1) What the icon means
/// 2) What the feature does
/// 3) What happens when tapped
/// Tap outside or close icon dismisses it.
class ContextualHelpDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String meaning;
  final String featureDoes;
  final String whenTapped;
  final String? directActionLabel;
  final VoidCallback? onDirectAction;

  const ContextualHelpDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.meaning,
    required this.featureDoes,
    required this.whenTapped,
    this.directActionLabel,
    this.onDirectAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        constraints: const BoxConstraints(maxWidth: 390),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isDark ? const Color(0x66B41D26) : const Color(0x38B41D26),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              offset: const Offset(0, 16),
              blurRadius: 36,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Color(0x18B41D26),
              offset: Offset(0, 4),
              blurRadius: 18,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 14),
                child: Row(
                  children: [
                    // Icon Badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Contextual Feature Guide',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close guide',
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? AppColors.darkOutline : const Color(0xFFF1F5F9),
              ),

              // Breakdown Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    _buildSectionItem(
                      isDark: isDark,
                      badgeColor: iconColor,
                      icon: Icons.info_outline_rounded,
                      header: 'WHAT THIS ICON MEANS',
                      body: meaning,
                    ),
                    const SizedBox(height: 14),
                    _buildSectionItem(
                      isDark: isDark,
                      badgeColor: AppColors.tertiary,
                      icon: Icons.shield_outlined,
                      header: 'WHAT THIS FEATURE DOES',
                      body: featureDoes,
                    ),
                    const SizedBox(height: 14),
                    _buildSectionItem(
                      isDark: isDark,
                      badgeColor: AppColors.secondary,
                      icon: Icons.touch_app_rounded,
                      header: 'WHAT HAPPENS WHEN TAPPED',
                      body: whenTapped,
                    ),
                  ],
                ),
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                child: Column(
                  children: [
                    if (directActionLabel != null && onDirectAction != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: onDirectAction,
                          icon: const Icon(Icons.bolt, size: 18),
                          label: Text(
                            directActionLabel!,
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 13,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap outside to dismiss',
                          style: AppTypography.labelSm.copyWith(
                            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                            fontSize: 11,
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
    );
  }

  Widget _buildSectionItem({
    required bool isDark,
    required Color badgeColor,
    required IconData icon,
    required String header,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerHigh
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkOutline.withValues(alpha: 0.5)
              : const Color(0xFFEDF2F7),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: badgeColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: AppTypography.labelSm.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: AppTypography.bodySm.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to display the floating contextual help dialog
void showContextualHelpDialog(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color iconColor,
  required String meaning,
  required String featureDoes,
  required String whenTapped,
  String? directActionLabel,
  VoidCallback? onDirectAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: const Color(0x66000000),
    builder: (dialogCtx) => ContextualHelpDialog(
      title: title,
      icon: icon,
      iconColor: iconColor,
      meaning: meaning,
      featureDoes: featureDoes,
      whenTapped: whenTapped,
      directActionLabel: directActionLabel,
      onDirectAction: onDirectAction != null
          ? () {
              Navigator.of(dialogCtx).pop();
              onDirectAction();
            }
          : null,
    ),
  );
}
