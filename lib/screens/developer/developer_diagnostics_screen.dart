import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../services/api_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';

/// Developer-only diagnostics screen.
/// Intended strictly for internal engineering, QA verification, and partner backend testing.
/// Hidden from ordinary consumer-facing users.
class DeveloperDiagnosticsScreen extends StatefulWidget {
  const DeveloperDiagnosticsScreen({super.key});

  @override
  State<DeveloperDiagnosticsScreen> createState() => _DeveloperDiagnosticsScreenState();
}

class _DeveloperDiagnosticsScreenState extends State<DeveloperDiagnosticsScreen> {
  bool _isTestingConnection = false;

  void _showServerConfigDialog(BuildContext context, SafetyProvider safety) {
    final urlCtrl = TextEditingController(text: ApiConfig.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          safety.strings.isHindi ? 'सर्वर बेस यूआरएल कॉन्फ़िगर करें' : 'Configure Backend Server URL',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safety.strings.isHindi
                  ? 'स्थानीय परीक्षण या भौतिक उपकरण परीक्षण के लिए अपने बैकएंड का पता दर्ज करें (उदा. http://localhost:3000/api/v1 या LAN IP):'
                  : 'Enter the base URL for the Node.js/Express backend service (e.g. http://localhost:3000/api/v1 or LAN IP):',
              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                prefixIcon: Icon(Icons.link, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiConfig.resetBaseUrl();
              Navigator.of(ctx).pop();
              safety.checkServerHealth();
            },
            child: Text(safety.strings.isHindi ? 'डिफ़ॉल्ट रीसेट' : 'Reset Default'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            onPressed: () {
              ApiConfig.setBaseUrl(urlCtrl.text);
              Navigator.of(ctx).pop();
              safety.checkServerHealth();
            },
            child: Text(safety.strings.save),
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
      appBar: AppBar(
        title: Text(
          strings.isHindi ? 'डेवलपर डायग्नोस्टिक्स' : 'Developer Diagnostics',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Health',
            icon: const Icon(Icons.sync),
            onPressed: () => safety.checkServerHealth(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Notice: Internal Tools Only
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.developer_mode, color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'INTERNAL DIAGNOSTIC SUITE\nThis panel is for engineering & backend partner diagnostics. Not visible to end users.',
                      style: TextStyle(
                        color: const Color(0xFF92400E),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Server Status & URL Configuration
            _sectionHeader('Backend & Server Connectivity', Icons.cloud_sync_outlined),
            const SizedBox(height: 8),
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
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: safety.isServerOnline
                                    ? AppColors.emeraldSafe
                                    : (safety.serverConnectionStatus == ServerConnectionStatus.checking
                                        ? AppColors.secondary
                                        : const Color(0xFFD97706)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                safety.isServerOnline
                                    ? 'Server Online (HTTP 200 OK)'
                                    : (safety.serverConnectionStatus == ServerConnectionStatus.checking
                                        ? 'Checking Connection...'
                                        : 'Local Prototype Mode (Offline)'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: safety.isServerOnline
                                      ? AppColors.emeraldSafe
                                      : (safety.serverConnectionStatus == ServerConnectionStatus.checking
                                          ? AppColors.secondary
                                          : const Color(0xFFD97706)),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showServerConfigDialog(context, safety),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text(
                          'Change URL',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'API Base: ${ApiConfig.baseUrl}',
                    style: AppTypography.bodySm.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                    ),
                  ),
                  if (safety.serverStatusMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      safety.serverStatusMessage!,
                      style: TextStyle(
                        fontSize: 11,
                        color: safety.isServerOnline ? AppColors.emeraldSafe : AppColors.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: _isTestingConnection
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 16),
                          label: Text(
                            _isTestingConnection ? 'Testing...' : 'Test Connection',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          onPressed: _isTestingConnection
                              ? null
                              : () async {
                                  setState(() => _isTestingConnection = true);
                                  final messenger = ScaffoldMessenger.of(context);
                                  await safety.retryServerConnection();
                                  if (mounted) {
                                    setState(() => _isTestingConnection = false);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        backgroundColor: safety.isServerOnline
                                            ? AppColors.emeraldSafe
                                            : const Color(0xFFD97706),
                                        content: Text(
                                          safety.isServerOnline
                                              ? 'Server connection verified: HTTP 200 OK'
                                              : 'Server offline: local prototype fallback active.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                      if (safety.locationService.offlineQueue.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          ),
                          icon: const Icon(Icons.upload, size: 16),
                          label: Text(
                            'Flush (${safety.locationService.offlineQueue.length})',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await safety.locationService.syncOfflineQueueWithApi(
                              apiService: safety.apiService,
                              token: safety.authToken,
                            );
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.emeraldSafe,
                                content: Text('Offline queue synced with backend.'),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Section 2: Platform & Session Telemetry
            _sectionHeader('Diagnostic Telemetry', Icons.terminal),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  _telemetryRow('Client Platform', kIsWeb ? 'Flutter Web' : defaultTargetPlatform.name, isDark),
                  Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                  _telemetryRow('App Version', '2.0.0+1 (Blueprint v2.0)', isDark),
                  Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                  _telemetryRow(
                    'Auth Token Status',
                    safety.authToken != null ? 'Active JWT (${safety.authToken!.substring(0, 15)}...)' : 'Local Mock Session',
                    isDark,
                  ),
                  Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                  _telemetryRow(
                    'Active Incident ID',
                    safety.unifiedSos.activeIncidentId ?? 'None (Standby)',
                    isDark,
                  ),
                  Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                  _telemetryRow(
                    'Offline GNSS Points',
                    '${safety.locationService.offlineQueue.length} points in local buffer',
                    isDark,
                  ),
                  Divider(height: 14, color: isDark ? AppColors.darkOutline : AppColors.borderLight),
                  _telemetryRow(
                    'Fail-Fast Timeout',
                    '${ApiConfig.requestTimeout.inSeconds}s (Health: ${ApiConfig.healthTimeout.inSeconds}s)',
                    isDark,
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

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _telemetryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
