import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/tactile_button.dart';

class GuardiansScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const GuardiansScreen({super.key, this.onBack});

  void _showAddGuardianSheet(BuildContext context, SafetyProvider safety) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+91 98112 ');
    String selectedRole = 'Sister • Tier 1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        safety.strings.isHindi ? 'नया अभिभावक जोड़ें' : 'Add Trusted Guardian',
                        style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: safety.strings.isHindi ? 'पूरा नाम' : 'Full Name',
                      border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: safety.strings.isHindi ? 'मोबाइल नंबर' : 'Phone Number',
                      border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: safety.strings.isHindi ? 'सुरक्षा स्तर एवं संबंध' : 'Safety Tier & Relation',
                      border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Sister • Tier 1',
                        child: Text('Sister • Tier 1 (Immediate Live GPS)'),
                      ),
                      DropdownMenuItem(
                        value: 'Mother • Tier 1',
                        child: Text('Mother • Tier 1 (Immediate Live GPS)'),
                      ),
                      DropdownMenuItem(
                        value: 'Father • Tier 1',
                        child: Text('Father • Tier 1 (Immediate Live GPS)'),
                      ),
                      DropdownMenuItem(
                        value: 'Friend • Tier 2',
                        child: Text('Friend • Tier 2 (SMS Alert & Pin)'),
                      ),
                      DropdownMenuItem(
                        value: 'Mentor / Colleague • Tier 2',
                        child: Text('Colleague • Tier 2 (SMS Alert & Pin)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedRole = val);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: TactileButton(
                      label: safety.strings.isHindi ? 'अभिभावक जोड़ें' : 'Save to Guardian Circle',
                      style: TactileButtonStyle.primaryCrimson,
                      onPressed: () async {
                        if (nameCtrl.text.trim().isNotEmpty) {
                          final added = await safety.addGuardianAsync(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            role: selectedRole,
                          );
                          if (added && context.mounted) {
                            Navigator.of(sheetCtx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primary,
                                content: Text(
                                  safety.strings.isHindi
                                      ? '${nameCtrl.text} को सुरक्षा घेरे में जोड़ा गया।'
                                      : '${nameCtrl.text} added to your live Guardian Circle.',
                                ),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Guardian could not be saved to the backend.'),
                              ),
                            );
                          }
                        }
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

  void _simulateCall(BuildContext context, GuardianModel guardian, SafetyProvider safety) {
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
              child: const Icon(Icons.phone_in_talk, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              safety.strings.isHindi ? 'सिम्युलेटेड वॉयस कॉल' : 'Simulated Voice Call',
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 32,
              backgroundColor: guardian.isEmergencyUnit
                  ? AppColors.secondary
                  : AppColors.primary,
              child: Text(
                guardian.name.split(' ').map((e) => e[0]).take(2).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              guardian.name,
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              guardian.role,
              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Calling over encrypted satellite channel (Prototype)...',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              safety.strings.cancel,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendPing(BuildContext context, GuardianModel guardian, SafetyProvider safety) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Row(
          children: [
            const Icon(Icons.share_location, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                safety.strings.isHindi
                  ? '${guardian.name} को जीपीएस पिंग भेजा गया: स्थान 24 कस्तूरबा गांधी मार्ग सत्यापित।'
                  : 'GPS Ping sent to ${guardian.name}: Telemetry confirmed at 24 Kasturba Gandhi Marg.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          if (onBack != null) {
                            onBack!();
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
                          strings.guardiansTitle,
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
                IconButton(
                  icon: const Icon(Icons.person_add, color: AppColors.primary),
                  tooltip: strings.isHindi ? 'नया जोड़ें' : 'Add Guardian',
                  onPressed: () => _showAddGuardianSheet(context, safety),
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
            // Top Overview Card
            GlassCard(
              padding: const EdgeInsets.all(18),
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
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.hub, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${safety.guardians.length} ${strings.isHindi ? 'सक्रिय अभिभावक' : 'Active Guardians'}',
                                    style: AppTypography.headlineSm.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    strings.isHindi
                                        ? 'तत्काल मेश अलर्ट सक्रिय'
                                        : 'Encrypted Emergency Ring Active',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.emeraldSafe,
                                      fontWeight: FontWeight.w700,
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
                      const StatusBadge(
                        label: 'TIER 1/2/3',
                        type: StatusBadgeType.tertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    strings.isHindi
                        ? 'आपात स्थिति में, टीयर 1 अभिभावकों को 3 सेकंड के भीतर रीयल-टाइम जीपीएस निर्देशांक और 60-सेकंड की लाइव ऑडियो स्ट्रीम मिलती है।'
                        : 'During an SOS trigger, Tier 1 guardians immediately receive continuous GPS telemetry, device battery level, and live microphone stream.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.slateSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Guardian Cards List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.isHindi ? 'अभिभावक सूची' : 'Designated Circle',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${safety.guardians.length} Registered',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.slateSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...safety.guardians.map((guardian) {
              final isEmergency = guardian.isEmergencyUnit;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isEmergency
                                      ? AppColors.secondaryFixed
                                      : AppColors.primaryFixed,
                                  child: Text(
                                    guardian.name.split(' ').map((e) => e[0]).take(2).join(),
                                    style: TextStyle(
                                      color: isEmergency
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              guardian.name,
                                              style: AppTypography.bodyMd.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (guardian.isVerified) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified,
                                                size: 14, color: AppColors.emeraldSafe),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        guardian.role,
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.slateSecondary,
                                          fontSize: 11,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                guardian.distance,
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tertiary,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.battery_std,
                                    size: 13,
                                    color: guardian.battery > 20
                                        ? AppColors.emeraldSafe
                                        : AppColors.secondary,
                                  ),
                                  Text(
                                    '${guardian.battery}%',
                                    style: AppTypography.labelSm.copyWith(
                                      fontSize: 10,
                                      color: AppColors.slateSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0x14000000)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              side: const BorderSide(color: Color(0x22000000)),
                            ),
                            icon: const Icon(Icons.share_location, size: 14, color: AppColors.tertiary),
                            label: Text(
                              strings.isHindi ? 'पिंग भेजें' : 'Live Ping',
                              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => _sendPing(context, guardian, safety),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.phone, size: 14),
                            label: Text(
                              strings.isHindi ? 'कॉल' : 'Call (Mock)',
                              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w800),
                            ),
                            onPressed: () => _simulateCall(context, guardian, safety),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Escalation Architecture Info
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.isHindi ? 'सुरक्षा प्रोटोकॉल एवं सीढ़ी' : 'Escalation Ladder & Policy',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '• Tier 1: Sister & Mother receive push notification & phone call buzzer.\n'
                    '• Tier 2: Secondary contacts pinged if SOS is not acknowledged in 60s.\n'
                    '• Tier 3: Direct integration with Delhi PCR Police CAD network.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.slateSecondary,
                      height: 1.5,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
