import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_strings.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/tactile_button.dart';

class CustomerFeedbackScreen extends StatefulWidget {
  const CustomerFeedbackScreen({super.key});

  @override
  State<CustomerFeedbackScreen> createState() => _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends State<CustomerFeedbackScreen> {
  int _rating = 5;
  String _selectedCategory = 'Suggestion';
  final TextEditingController _descriptionController = TextEditingController();
  bool _hasAttachedScreenshot = false;
  String? _errorMessage;
  bool _isSubmitted = false;

  final List<String> _categories = [
    'Suggestion',
    'Bug Report',
    'Hardware / Band Issue',
    'Emergency Feature Request',
    'General Experience',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String _getRatingText(int rating, bool isHindi) {
    if (isHindi) {
      switch (rating) {
        case 1:
          return 'सुधार की आवश्यकता';
        case 2:
          return 'साधारण';
        case 3:
          return 'संतोषजनक';
        case 4:
          return 'बहुत अच्छा';
        case 5:
        default:
          return 'उत्कृष्ट एवं जीवन-रक्षक';
      }
    } else {
      switch (rating) {
        case 1:
          return 'Needs Improvement';
        case 2:
          return 'Fair';
        case 3:
          return 'Good';
        case 4:
          return 'Very Good';
        case 5:
        default:
          return 'Excellent & Life-Saving';
      }
    }
  }

  void _handleSubmit(SafetyProvider safety) {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = safety.strings.isHindi
            ? 'कृपया अपनी प्रतिक्रिया या समस्या का संक्षिप्त विवरण लिखें।'
            : 'Please enter a brief description of your feedback or bug.';
      });
      return;
    }

    final feedback = FeedbackSubmission(
      id: 'fb-${DateTime.now().millisecondsSinceEpoch}',
      rating: _rating,
      category: _selectedCategory,
      description: text,
      hasScreenshot: _hasAttachedScreenshot,
      timestamp: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    );

    safety.submitFeedback(feedback);

    setState(() {
      _isSubmitted = true;
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(safety.strings.isHindi
            ? 'धन्यवाद! आपकी प्रतिक्रिया शक्ति कोर सुरक्षा टीम को प्राप्त हो गई है।'
            : 'Thank you! Your feedback has been logged with the SHAKTI engineering team.'),
        backgroundColor: AppColors.emeraldSafe,
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
          strings.feedbackTitle,
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: _isSubmitted
            ? _buildSuccessView(context, strings, isDark)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header intro
                  Text(
                    strings.isHindi
                        ? 'शक्ति ऐप एवं स्मार्ट बैंड को बेहतर बनाने में हमारी सहायता करें'
                        : 'Help us enhance SHAKTI personal safety & wristband resilience',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.isHindi
                        ? 'आपकी सुरक्षा और उपयोगकर्ता अनुभव हमारी सर्वोच्च प्राथमिकता है। अपने सुझाव या तकनीकी समस्याएं साझा करें।'
                        : 'Your safety experience drives our continuous improvements. Report issues, recommend features, or describe app performance.',
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rating Section
                  Text(
                    strings.ratingLabel,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            return IconButton(
                              iconSize: 34,
                              onPressed: () => setState(() => _rating = star),
                              icon: Icon(
                                star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                                color: star <= _rating ? Colors.amber : (isDark ? AppColors.darkOutline : Colors.grey.shade400),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _getRatingText(_rating, strings.isHindi),
                          style: AppTypography.titleSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selection
                  Text(
                    strings.categoryLabel,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final selected = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceContainerLow
                            : AppColors.surfaceContainerLowest,
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : (isDark ? AppColors.darkOutline : AppColors.borderLight),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    strings.descriptionLabel,
                    style: AppTypography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: strings.isHindi
                          ? 'उदाहरण: रात में वॉक विद मी ट्रैकर सहज रूप से अपडेट हुआ, किंतु सायरन की ध्वनि को और तेज किया जाना चाहिए...'
                          : 'e.g. During Walk With Me, the corridor tracking worked reliably, but I would like a quicker shortcut to siren...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceContainerLow
                          : AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkOutline : AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Optional Screenshot Attachment Simulator
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        _hasAttachedScreenshot = !_hasAttachedScreenshot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _hasAttachedScreenshot
                            ? AppColors.emeraldSafe.withValues(alpha: 0.12)
                            : (isDark
                                ? AppColors.darkSurfaceContainerLow
                                : AppColors.surfaceContainerLowest),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _hasAttachedScreenshot
                              ? AppColors.emeraldSafe
                              : (isDark ? AppColors.darkOutline : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasAttachedScreenshot
                                ? Icons.check_circle_rounded
                                : Icons.add_photo_alternate_outlined,
                            color: _hasAttachedScreenshot
                                ? AppColors.emeraldSafe
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hasAttachedScreenshot
                                      ? (strings.isHindi
                                          ? 'स्क्रीनशॉट संलग्न: shakti_audit_capture.png'
                                          : 'Screenshot Attached: shakti_audit_capture.png')
                                      : strings.attachScreenshotLabel,
                                  style: AppTypography.titleSm.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _hasAttachedScreenshot
                                        ? AppColors.emeraldSafe
                                        : (isDark ? AppColors.darkOnSurface : AppColors.onSurface),
                                  ),
                                ),
                                Text(
                                  strings.isHindi
                                      ? 'सिम्युलेटेड स्क्रीन अटैचमेंट'
                                      : 'Simulated diagnostic screenshot capture',
                                  style: AppTypography.bodySm.copyWith(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkOnSurfaceVariant
                                        : AppColors.slateSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _hasAttachedScreenshot
                                ? (strings.isHindi ? 'हटाएं' : 'Remove')
                                : (strings.isHindi ? 'जोड़ें' : 'Attach'),
                            style: AppTypography.labelSm.copyWith(
                              color: _hasAttachedScreenshot
                                  ? AppColors.primary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  TactileButton(
                    label: strings.submitFeedbackBtn,
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    isFullWidth: true,
                    onPressed: () => _handleSubmit(safety),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      strings.isHindi
                          ? '• स्थानीय प्रोटोटाइप: प्रतिक्रिया डिवाइस में सुरक्षित रूप से रिकॉर्ड की जाती है।'
                          : '• Enclave Prototype: Feedback stored locally in mock incident telemetry.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120), // Bottom padding to prevent floating button overlap
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, AppStrings strings, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.emeraldSafe.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.emeraldSafe,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.isHindi ? 'प्रतिक्रिया दर्ज की गई!' : 'Feedback Received!',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkOnSurface : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                strings.isHindi
                    ? 'आपकी प्रतिक्रिया हमारे सुरक्षा प्रोटोकॉल को और सुदृढ़ बनाने में सहायता करेगी।'
                    : 'Your valuable insights directly fortify SHAKTI emergency resilience and guardian response protocols.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.slateSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),
            TactileButton(
              label: strings.isHindi ? 'वापस जाएं' : 'Return to Settings',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
