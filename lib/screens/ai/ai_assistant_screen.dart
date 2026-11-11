import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/companion_avatar.dart';
import '../home/home_dashboard_screen.dart';
import '../radar/radar_screen.dart';

/// Opens the redesigned SHAKTI AI Safety Companion as a bottom sheet modal
void showAiAssistantModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => FractionallySizedBox(
      heightFactor: 0.94,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: AiAssistantScreen(
          isModal: true,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    ),
  );
}

/// Redesigned SHAKTI AI Safety Companion Screen
/// Embodies the refined feminine visual identity: warm ivory/blush surfaces,
/// elegant deep plum typography, muted rose accents, and clear emergency safeguards.
class AiAssistantScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final bool isModal;

  const AiAssistantScreen({
    super.key,
    this.onBack,
    this.isModal = false,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(SafetyProvider safety, [String? preset]) {
    final text = preset ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;

    safety.addAiMessage(text);
    _msgCtrl.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showPrivacyInfoDialog(BuildContext context, SafetyProvider safety) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                safety.strings.isHindi ? 'एआई गोपनीयता एवं स्थानीय निष्पादन' : 'AI Privacy & Local Execution',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.deepPlum),
              ),
            ),
          ],
        ),
        content: Text(
          safety.strings.isHindi
              ? 'वर्तमान प्रोटोटाइप संस्करण में, बातचीत केवल आपके डिवाइस पर स्थानीय रूप से चलती है। कोई व्यक्तिगत डेटा, चैट इतिहास या संवेदनशील स्थान बाह्य सर्वर पर संग्रहीत नहीं किया जाता है।'
              : 'In this prototype version, all conversations run locally inside the mock safety companion state. No personal data, chat logs, or telemetry are transmitted to third-party AI cloud servers.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateSecondary, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              safety.strings.close,
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
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
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.blushSurface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Subtle Feminine Flourish Background (Top organic wave and silhouette)
          if (!isDark)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180,
              child: CustomPaint(
                painter: _FeminineHeaderFlourishPainter(),
              ),
            ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Refined Header Section
                _buildHeader(context, safety, strings, isDark),

                // Privacy / Local Prototype Information Banner
                _buildPrivacyBanner(context, safety, strings, isDark),

                // Scrollable Conversation Area
                Expanded(
                  child: ListView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    children: [
                      // Welcome / Hero Section (Empty state & Introduction)
                      _buildWelcomeCard(safety, strings, isDark),

                      const SizedBox(height: 14),

                      // 2x2 Conversation Starter Suggestion Cards
                      _buildSuggestionCardsGrid(safety, strings, isDark),

                      if (safety.aiMessages.isNotEmpty) ...[
                        const SizedBox(height: 18),

                        // Today Date Separator Badge
                        _buildDateSeparator(strings, isDark),

                        const SizedBox(height: 16),

                        // Chat Messages
                        ...safety.aiMessages.map((msg) => _buildMessageRow(msg, safety, strings, isDark)),
                      ],
                    ],
                  ),
                ),

                // Fixed-Bottom Message Input Area
                _buildMessageComposer(safety, strings, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Refined Header with Trident Emblem, Title, Active Badge, and Overflow Menu
  Widget _buildHeader(BuildContext context, SafetyProvider safety, dynamic strings, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Clean Back / Close Control
              IconButton(
                icon: Icon(
                  widget.isModal ? Icons.keyboard_arrow_down_rounded : Icons.arrow_back_ios_new_rounded,
                  color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                  size: widget.isModal ? 28 : 22,
                ),
                tooltip: strings.back,
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),

              // Distinctive SHAKTI AI Trishula Shield Emblem
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurfaceContainer : const Color(0xFFFDE8EC),
                  border: Border.all(
                    color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(20, 20),
                    painter: _SmallTridentShieldPainter(color: AppColors.primary),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.assistantTitle,
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      strings.assistantSubtitle,
                      style: AppTypography.labelSm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Subtle Online / Active Status Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emeraldSafe,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      strings.assistantActive,
                      style: AppTypography.labelSm.copyWith(
                        color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Three-dots Context Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.deepPlum,
                ),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'clear') {
                    safety.aiMessages.clear();
                    setState(() {});
                  } else if (val == 'lang') {
                    safety.setLanguage(strings.isHindi ? 'en' : 'hi');
                  } else if (val == 'privacy') {
                    _showPrivacyInfoDialog(context, safety);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'lang',
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(strings.isHindi ? 'Switch to English' : 'हिन्दी में बदलें'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'privacy',
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip_outlined, size: 18, color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        Text(strings.isHindi ? 'गोपनीयता सूचना' : 'Privacy Notice'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(strings.isHindi ? 'बातचीत हटाएं' : 'Clear Chat'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Central Elegant Subtitle with Delicate Flourish
          Text(
            strings.assistantTagline,
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF6B4555),
            ),
          ),
          const SizedBox(height: 2),
          CustomPaint(
            size: const Size(80, 4),
            painter: _WaveFlourishPainter(color: isDark ? AppColors.primary : const Color(0xFFE52D5E)),
          ),
        ],
      ),
    );
  }

  /// Privacy and Local Prototype Banner
  Widget _buildPrivacyBanner(BuildContext context, SafetyProvider safety, dynamic strings, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : const Color(0x38B41D26),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10.5,
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
                ),
                children: [
                  TextSpan(
                    text: strings.isHindi ? 'प्रोटोटाइप एआई: ' : 'Prototype AI: ',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  TextSpan(
                    text: strings.isHindi
                        ? 'सत्र केवल इस डिवाइस पर स्थानीय रूप से चलता है।'
                        : 'Queries run locally inside mock safety companion.',
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => _showPrivacyInfoDialog(context, safety),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Welcome Hero Card at top of the conversation
  Widget _buildWelcomeCard(SafetyProvider safety, dynamic strings, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
          width: 1.0,
        ),
        boxShadow: isDark ? null : AppDecorations.feminineCardShadow,
      ),
      child: Row(
        children: [
          // Distinctive Illustrated Companion Avatar
          const CompanionAvatar(size: 64, showSparkle: true),

          const SizedBox(width: 14),

          // Greeting and Prompt
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.assistantHeroTitle,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.assistantHeroSubtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.berryMuted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2x2 Conversation Starter Suggestion Cards
  Widget _buildSuggestionCardsGrid(SafetyProvider safety, dynamic strings, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _suggestionCard(
                icon: Icons.near_me_rounded,
                label: strings.assistantChipRoute,
                onTap: () => _sendMessage(
                  safety,
                  strings.isHindi ? 'क्या मेरा मार्ग सुरक्षित है?' : 'Is my route safe?',
                ),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _suggestionCard(
                icon: Icons.shield_outlined,
                label: strings.assistantChipJourney,
                onTap: () => _sendMessage(
                  safety,
                  strings.isHindi ? 'सुरक्षित यात्रा की योजना बनाएं' : 'Help me plan a safe journey',
                ),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _suggestionCard(
                icon: Icons.directions_walk_rounded,
                label: strings.assistantChipWalk,
                onTap: () => _sendMessage(
                  safety,
                  strings.isHindi ? 'साथ चलें शुरू करें' : 'Start Walk With Me',
                ),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _suggestionCard(
                icon: Icons.emergency_rounded,
                label: strings.assistantChipEmergency,
                onTap: () => _sendMessage(
                  safety,
                  strings.isHindi ? 'आपात स्थिति में क्या करें?' : 'What should I do in an emergency?',
                ),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _suggestionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
              width: 1.0,
            ),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x088C1D40),
                      offset: Offset(0, 3),
                      blurRadius: 10,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkSurfaceContainerHigh : const Color(0xFFFDE8EC),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFFB48598),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Date Separator Badge ("Today")
  Widget _buildDateSeparator(dynamic strings, bool isDark) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceContainer : const Color(0xFFF3E4E8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          strings.isHindi ? 'आज' : 'Today',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkOnSurfaceVariant : const Color(0xFF755160),
          ),
        ),
      ),
    );
  }

  /// Single Chat Message Row (Assistant or User)
  Widget _buildMessageRow(ChatMessage msg, SafetyProvider safety, dynamic strings, bool isDark) {
    final isUser = msg.sender == 'user';
    final hasWalkAction = !isUser && (msg.text.contains('Walk') || msg.text.contains('साथ') || msg.text.contains('timer'));

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.74,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFC8234B),
                      Color(0xFFB41D26),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x24B41D26),
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.text,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.time,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurfaceContainer : const Color(0xFFFDE8EC),
                border: Border.all(color: const Color(0xFFF3DDE3), width: 1),
              ),
              child: const Icon(Icons.person, size: 18, color: Color(0xFFC8234B)),
            ),
          ],
        ),
      );
    }

    // Assistant Message Row
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assistant Avatar Medallion with Sparkle
              const CompanionAvatar(
                size: 34,
                showSparkle: true,
                isShieldVariant: true,
              ),

              const SizedBox(width: 8),

              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.74,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                    ),
                    border: Border.all(
                      color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
                      width: 1.0,
                    ),
                    boxShadow: isDark
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0x0A8C1D40),
                              offset: Offset(0, 3),
                              blurRadius: 10,
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkOnSurface : const Color(0xFF2E1824),
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.time,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.mutedGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Interactive Action Buttons attached to Assistant Message
          if (hasWalkAction) ...[
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // Start Walk With Me Action Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.directions_walk_rounded, size: 16),
                    label: Text(
                      strings.assistantActionWalk,
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                    onPressed: () {
                      if (widget.isModal) Navigator.of(context).pop();
                      // Launch Walk With Me duration sheet
                      showWalkWithMeSheet(context, safety);
                    },
                  ),

                  // View on Map Action Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: Color(0xFFEAA8B8), width: 1.2),
                      backgroundColor: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    icon: const Icon(Icons.location_on_rounded, size: 16),
                    label: Text(
                      strings.assistantActionMap,
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                    onPressed: () {
                      if (widget.isModal) Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RadarScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Fixed-Bottom Message Input Area with Keyboard Resizing Support
  Widget _buildMessageComposer(SafetyProvider safety, dynamic strings, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainerLowest : AppColors.blushSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Sparkle Prompt Button
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurfaceContainerLow : const Color(0xFFFDE8EC),
                border: Border.all(
                  color: isDark ? AppColors.darkOutline : const Color(0xFFF3DDE3),
                  width: 1.0,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.auto_awesome, color: Color(0xFFC8234B), size: 18),
                tooltip: 'Prompt Ideas',
                onPressed: () {
                  _sendMessage(
                    safety,
                    strings.isHindi ? 'क्या मेरा वर्तमान मार्ग सुरक्षित है?' : 'Is my current route secure?',
                  );
                },
              ),
            ),

            const SizedBox(width: 8),

            // Rounded Text Input
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerLow : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? AppColors.darkOutline : const Color(0xFFF0D5DC),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _msgCtrl,
                  onSubmitted: (_) => _sendMessage(safety),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkOnSurface : AppColors.deepPlum,
                    fontSize: 13.5,
                  ),
                  decoration: InputDecoration(
                    hintText: strings.assistantPlaceholder,
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.mutedGrey,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Circular Send Button
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFC8234B),
                    Color(0xFF8A0B2B),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC8234B).withValues(alpha: 0.35),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                tooltip: 'Send',
                onPressed: () => _sendMessage(safety),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small Trident Shield Vector Painter for the header
class _SmallTridentShieldPainter extends CustomPainter {
  final Color color;

  _SmallTridentShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 32.0;
    canvas.save();
    canvas.scale(scale, scale);

    final p = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shield = Path()
      ..moveTo(16, 3)
      ..lineTo(5, 8.5)
      ..lineTo(5, 17)
      ..cubicTo(5, 24, 10, 28.5, 16, 30.5)
      ..cubicTo(22, 28.5, 27, 24, 27, 17)
      ..lineTo(27, 8.5)
      ..close();

    canvas.drawPath(shield, p);
    canvas.drawLine(const Offset(16, 9), const Offset(16, 23), p);

    final spear = Path()
      ..moveTo(16, 7)
      ..lineTo(18, 11)
      ..lineTo(14, 11)
      ..close();
    canvas.drawPath(spear, Paint()..color = color..style = PaintingStyle.fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wave Flourish Painter for title underline
class _WaveFlourishPainter extends CustomPainter {
  final Color color;

  _WaveFlourishPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height / 2)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height / 2);

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle Feminine Header Flourish Painter (Ribbon curves & silhouette)
class _FeminineHeaderFlourishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft flowing rose ribbon 1
    final ribbonPaint1 = Paint()
      ..color = const Color(0x0EE52D5E)
      ..style = PaintingStyle.fill;

    final ribbon1 = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.6)
      ..cubicTo(w * 0.7, h * 0.9, w * 0.3, h * 0.4, 0, h * 0.8)
      ..close();
    canvas.drawPath(ribbon1, ribbonPaint1);

    // Soft flowing rose ribbon 2
    final ribbonPaint2 = Paint()
      ..color = const Color(0x0CE52D5E)
      ..style = PaintingStyle.fill;

    final ribbon2 = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.8)
      ..cubicTo(w * 0.6, h * 0.6, w * 0.4, h * 0.9, 0, h * 0.5)
      ..close();
    canvas.drawPath(ribbon2, ribbonPaint2);

    // Subtle feminine silhouette outline in top right corner
    final silhouettePaint = Paint()
      ..color = const Color(0x1CE52D5E)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final silhouette = Path()
      ..moveTo(w * 0.92, h * 0.15)
      ..cubicTo(w * 0.85, h * 0.12, w * 0.82, h * 0.22, w * 0.84, h * 0.35)
      ..cubicTo(w * 0.81, h * 0.45, w * 0.83, h * 0.55, w * 0.88, h * 0.65)
      ..cubicTo(w * 0.90, h * 0.75, w * 0.96, h * 0.85, w, h * 0.90);
    canvas.drawPath(silhouette, silhouettePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
