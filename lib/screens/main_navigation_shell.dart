import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/safety_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/dashboard_spotlight_tour.dart';
import '../widgets/glass_card.dart';
import 'ai/ai_assistant_screen.dart';
import 'alerts/alerts_screen.dart';
import 'home/home_dashboard_screen.dart';
import 'profile/profile_screen.dart';
import 'wristband/wristband_screen.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    // If covert mode is engaged, render the Camouflage Facade
    if (safety.isCovertMode) {
      return _CovertFacade(onExit: () => safety.toggleCovertMode());
    }

    // Exactly 4 tabs as per Phase 9: Home (0), Alerts (1), Band (2), Profile (3)
    final pages = [
      const HomeDashboardScreen(),
      AlertsScreen(onBack: () => safety.setNavIndex(0)),
      WristbandScreen(onBack: () => safety.setNavIndex(0)),
      ProfileScreen(onBack: () => safety.setNavIndex(0)),
    ];

    // Clamp index to safe range
    final activeIndex = safety.selectedNavIndex.clamp(0, pages.length - 1);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        body: Stack(
          children: [
            IndexedStack(
              index: activeIndex,
              children: pages,
            ),

            // Floating Circular AI Assistant Button (Matching Feminine Visual Identity)
            // Positioned above bottom bar on the right side - does NOT obstruct central SOS
            Positioned(
              right: 20,
              bottom: 86,
              child: SafeArea(
                top: false,
                child: Tooltip(
                  message: 'SHAKTI AI Assistant',
                  child: GestureDetector(
                    onTap: () => showAiAssistantModal(context),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Soft Sparkle Accent Top-Right
                        Positioned(
                          top: -4,
                          right: -3,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: const Color(0xFFFFD1DC).withValues(alpha: 0.9),
                          ),
                        ),
                        // Outer Glow
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE52D5E),
                                Color(0xFFC8234B),
                                Color(0xFF9E0B32),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE52D5E).withValues(alpha: 0.42),
                                offset: const Offset(0, 6),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                              const BoxShadow(
                                color: Color(0x20000000),
                                offset: Offset(0, 2),
                                blurRadius: 6,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.smart_toy_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                              Positioned(
                                top: 9,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.emeraldGlow,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Floating Frosted Glass Bottom Navigation Bar (Exactly 4 Tabs)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  borderRadius: BorderRadius.circular(999),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x1F1F2687),
                      offset: Offset(0, 10),
                      blurRadius: 30,
                    ),
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-2, -2),
                      blurRadius: 8,
                    ),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(
                        key: TourTargetKeys.homeTabKey,
                        index: 0,
                        currentIndex: activeIndex,
                        icon: Icons.shield,
                        label: strings.navHome,
                        isDark: isDark,
                        onTap: () => safety.setNavIndex(0),
                      ),
                      _navItem(
                        key: TourTargetKeys.alertsTabKey,
                        index: 1,
                        currentIndex: activeIndex,
                        icon: Icons.notifications,
                        label: strings.navAlerts,
                        hasBadge: true,
                        isDark: isDark,
                        onTap: () => safety.setNavIndex(1),
                      ),
                      _navItem(
                        key: TourTargetKeys.bandTabKey,
                        index: 2,
                        currentIndex: activeIndex,
                        icon: Icons.watch,
                        label: strings.navBand,
                        isDark: isDark,
                        onTap: () => safety.setNavIndex(2),
                      ),
                      _navItem(
                        key: TourTargetKeys.profileTabKey,
                        index: 3,
                        currentIndex: activeIndex,
                        icon: Icons.person_outline,
                        label: strings.navProfile,
                        isDark: isDark,
                        onTap: () => safety.setNavIndex(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // In-situ Onboarding Tour directly on the live dashboard (Phase 10)
            if (!safety.hasCompletedTutorial)
              Positioned.fill(
                child: DashboardSpotlightTour(
                  isHindi: strings.isHindi,
                  onFinish: () => safety.completeTutorial(),
                  onSkip: () => safety.completeTutorial(),
                ),
              ),
          ],
        ),
      );
  }

  Widget _navItem({
    Key? key,
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool hasBadge = false,
    bool isDark = false,
  }) {
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        key: key,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.darkSurfaceContainer : const Color(0xFFFDECEF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isActive ? AppColors.primary : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted),
                  ),
                  if (hasBadge)
                    Positioned(
                      top: -2,
                      right: -3,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppTypography.labelSm.copyWith(
                    color: isActive ? AppColors.primary : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted),
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simulated Covert Facade for Duress Code 0000
class _CovertFacade extends StatefulWidget {
  final VoidCallback onExit;

  const _CovertFacade({required this.onExit});

  @override
  State<_CovertFacade> createState() => _CovertFacadeState();
}

class _CovertFacadeState extends State<_CovertFacade> {
  String _calcDisplay = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onDigit(String d) {
    setState(() {
      if (_calcDisplay == '0' || _shouldResetDisplay) {
        _calcDisplay = d;
        _shouldResetDisplay = false;
      } else {
        _calcDisplay += d;
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      _firstOperand = double.tryParse(_calcDisplay);
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _onEquals() {
    if (_firstOperand != null && _operator != null) {
      final second = double.tryParse(_calcDisplay) ?? 0;
      double result = 0;
      switch (_operator) {
        case '+':
          result = _firstOperand! + second;
          break;
        case '-':
          result = _firstOperand! - second;
          break;
        case '×':
          result = _firstOperand! * second;
          break;
        case '÷':
          result = second != 0 ? _firstOperand! / second : 0;
          break;
      }
      setState(() {
        _calcDisplay = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 2);
        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = true;
      });
    }
  }

  void _onClear() {
    setState(() {
      _calcDisplay = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Secret top unlock bar - 3 taps to disarm covert mode
            GestureDetector(
              onTap: widget.onExit,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 36,
                alignment: Alignment.center,
                color: Colors.transparent,
                child: const Text(
                  '• • •',
                  style: TextStyle(color: Color(0x33FFFFFF), fontSize: 14),
                ),
              ),
            ),

            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _calcDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),

            // Calculator Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _calcRow(['C', '±', '%', '÷'], isTop: true),
                  _calcRow(['7', '8', '9', '×']),
                  _calcRow(['4', '5', '6', '-']),
                  _calcRow(['1', '2', '3', '+']),
                  _calcRow(['0', '.', '='], isBottom: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcRow(List<String> labels, {bool isTop = false, bool isBottom = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: labels.map((lbl) {
          final isOp = ['÷', '×', '-', '+', '='].contains(lbl);
          final isFunc = ['C', '±', '%'].contains(lbl);
          final isZero = lbl == '0';

          return GestureDetector(
            onTap: () {
              if (lbl == 'C') {
                _onClear();
              } else if (lbl == '=') {
                _onEquals();
              } else if (isOp) {
                _onOperator(lbl);
              } else {
                _onDigit(lbl);
              }
            },
            child: Container(
              width: isZero ? 150 : 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isOp
                    ? const Color(0xFFFF9F0A)
                    : isFunc
                        ? const Color(0xFFA5A5A5)
                        : const Color(0xFF333333),
              ),
              child: Center(
                child: Text(
                  lbl,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: isFunc ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
