import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/safety_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../vault/evidence_vault_screen.dart';

class AlertsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const AlertsScreen({super.key, this.onBack});

  static String localizedHazardType(String type, bool isHindi) {
    if (!isHindi) return type;
    switch (type) {
      case 'Broken Streetlight':
        return 'टूटी स्ट्रीटलाइट';
      case 'Isolated Stretch':
        return 'सुनसान रास्ता';
      case 'Harassment Concern':
        return 'छेड़छाड़ / असुरक्षित क्षेत्र';
      case 'Road Construction Hazard':
        return 'सड़क निर्माण खतरा';
      case 'Other Safety Concern':
        return 'अन्य सुरक्षा समस्या';
      default:
        return type;
    }
  }

  static String localizedSeverity(String severity, bool isHindi) {
    if (!isHindi) return severity.toUpperCase();
    switch (severity.toLowerCase()) {
      case 'high':
        return 'उच्च';
      case 'medium':
        return 'मध्यम';
      case 'low':
        return 'कम';
      default:
        return severity.toUpperCase();
    }
  }

  static String localizedLocation(String location, bool isHindi) {
    if (!isHindi) return location;
    if (location.contains('Janpath Outer Ring Corridor')) {
      return 'जनपथ आउटर रिंग कॉरिडोर';
    } else if (location.contains('Subway Underpass towards Metro Gate 3')) {
      return 'मेट्रो गेट 3 की ओर सबवे अंडरपास';
    } else if (location.contains('Janpath Metro Corridor')) {
      return 'जनपथ मेट्रो कॉरिडोर';
    } else if (location.contains('Barakhamba Crossing')) {
      return 'बाराखंभा क्रॉसिंग';
    } else if (location.contains('Campus Inner Ring')) {
      return 'कैंपस इनर रिंग';
    }
    return location;
  }

  static String localizedTimestamp(String timestamp, bool isHindi) {
    if (!isHindi) return timestamp;
    return timestamp
        .replaceAll('Today', 'आज')
        .replaceAll('Yesterday', 'कल')
        .replaceAll('Just now', 'अभी')
        .replaceAll('Oct', 'अक्टू');
  }

  static String localizedNotes(String notes, bool isHindi) {
    if (!isHindi) return notes;
    if (notes.contains('3 light posts unlit after 21:00.')) {
      return 'रात 9 बजे के बाद 3 लाइट पोस्ट बंद हैं।';
    } else if (notes.contains('Low footfall, security booth unoccupied.')) {
      return 'कम आवाजाही, सुरक्षा बूथ खाली है।';
    }
    return notes;
  }

  static String localizedIncidentTitle(String title, bool isHindi) {
    if (!isHindi) return title;
    switch (title) {
      case 'Walk-With-Me Check-in Completed':
        return 'वॉक-विद-मी चेक-इन पूर्ण';
      case 'Acoustic Monitoring Auto-Session':
        return 'ध्वनिक निगरानी स्वतः-सत्र';
      case 'Simulated SOS Drill Test':
        return 'सिम्युलेटेड एसओएस ड्रिल टेस्ट';
      default:
        return title;
    }
  }

  static String localizedIncidentStatus(String status, bool isHindi) {
    if (!isHindi) return status;
    switch (status) {
      case 'Archived':
        return 'संग्रहीत';
      case 'Verified':
        return 'सत्यापित';
      case 'Logged':
        return 'दर्ज';
      default:
        return status;
    }
  }

  void _showReportIncidentSheet(BuildContext context, SafetyProvider safety) {
    String selectedType = 'Broken Streetlight';
    String selectedSeverity = 'Medium';
    final locationCtrl = TextEditingController(text: 'Janpath Outer Ring Corridor');
    final notesCtrl = TextEditingController();

    // Working Photo Attachment State
    final ImagePicker picker = ImagePicker();
    XFile? pickedPhoto;
    Uint8List? pickedPhotoBytes;
    String? pickedPhotoName;
    int? pickedPhotoSize;

    final hazardTypes = [
      'Broken Streetlight',
      'Isolated Stretch',
      'Harassment Concern',
      'Road Construction Hazard',
      'Other Safety Concern',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isHindi = safety.strings.isHindi;

            Future<void> pickPhoto(ImageSource source) async {
              try {
                final XFile? image = await picker.pickImage(
                  source: source,
                  maxWidth: 1920,
                  maxHeight: 1920,
                  imageQuality: 85,
                );
                if (image == null) return;
                final Uint8List bytes = await image.readAsBytes();
                const maxBytes = 10 * 1024 * 1024; // 10MB
                if (bytes.lengthInBytes > maxBytes) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text(safety.strings.photoSizeExceeded),
                      ),
                    );
                  }
                  return;
                }
                setSheetState(() {
                  pickedPhoto = image;
                  pickedPhotoBytes = bytes;
                  pickedPhotoName = image.name;
                  pickedPhotoSize = bytes.lengthInBytes;
                });
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.slateCharcoal,
                      content: Text('${safety.strings.photoPermissionDenied} ($e)'),
                    ),
                  );
                }
              }
            }

            void showSourcePicker() {
              showModalBottomSheet(
                context: sheetCtx,
                backgroundColor: AppColors.surfaceContainerLowest,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (modalCtx) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            safety.strings.attachPhotoBtn,
                            style: AppTypography.headlineSm.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                            title: Text(safety.strings.takePhotoCamera, style: AppTypography.bodyMd),
                            onTap: () {
                              Navigator.of(modalCtx).pop();
                              pickPhoto(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library, color: AppColors.primary),
                            title: Text(safety.strings.chooseFromGallery, style: AppTypography.bodyMd),
                            onTap: () {
                              Navigator.of(modalCtx).pop();
                              pickPhoto(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.campaign, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              safety.strings.reportHazardTitle,
                              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Hazard Type Dropdown
                    Text(
                      safety.strings.hazardTypeLabel,
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: hazardTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(localizedHazardType(type, isHindi), style: AppTypography.bodyMd),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedType = val);
                        }
                      },
                    ),

                    const SizedBox(height: 14),

                    // Location Input
                    Text(
                      safety.strings.hazardLocationLabel,
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: locationCtrl,
                      decoration: InputDecoration(
                        hintText: isHindi ? 'उदा. जनपथ आउटर रिंग' : 'e.g. Janpath Outer Ring',
                        border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Severity Selector
                    Text(
                      safety.strings.hazardSeverityLabel,
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Low', 'Medium', 'High'].map((sev) {
                        final isSelected = selectedSeverity == sev;
                        Color activeColor;
                        if (sev == 'High') {
                          activeColor = AppColors.primary;
                        } else if (sev == 'Medium') {
                          activeColor = const Color(0xFFD97706);
                        } else {
                          activeColor = AppColors.emeraldSafe;
                        }

                        final displaySev = isHindi
                            ? (sev == 'High' ? 'उच्च' : sev == 'Medium' ? 'मध्यम' : 'कम')
                            : sev;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected ? activeColor : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () => setSheetState(() => selectedSeverity = sev),
                              child: Text(
                                displaySev,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? activeColor : AppColors.slateSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Notes / Description
                    Text(
                      safety.strings.hazardNotesLabel,
                      style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: isHindi ? 'स्थिति का संक्षिप्त विवरण लिखें...' : 'Briefly describe what you observed...',
                        border: const OutlineInputBorder(borderRadius: AppDecorations.brDefault),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Working Photo Attachment Component
                    if (pickedPhotoBytes == null)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: showSourcePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x18000000)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      safety.strings.attachPhotoBtn,
                                      style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      isHindi
                                          ? 'कैमरा या गैलरी से फोटो जोड़ें (अधिकतम 10MB)'
                                          : 'Attach from camera or gallery (Max 10MB)',
                                      style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                isHindi ? 'जोड़ें' : 'Attach',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldLightBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.emeraldSafe.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    pickedPhotoBytes!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.surfaceContainerHigh,
                                      child: const Icon(Icons.broken_image, size: 24, color: AppColors.slateSecondary),
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
                                          const Icon(Icons.check_circle, color: AppColors.emeraldSafe, size: 16),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              safety.strings.photoAttachedLocal,
                                              style: AppTypography.labelSm.copyWith(
                                                color: AppColors.emeraldSafe,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        pickedPhotoName ?? 'hazard_photo.jpg',
                                        style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (pickedPhotoSize != null)
                                        Text(
                                          '${(pickedPhotoSize! / (1024 * 1024)).toStringAsFixed(2)} MB',
                                          style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.refresh, size: 14),
                                  label: Text(
                                    safety.strings.replacePhoto,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: showSourcePicker,
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.delete_outline, size: 14),
                                  label: Text(
                                    safety.strings.removePhoto,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () {
                                    setSheetState(() {
                                      pickedPhoto = null;
                                      pickedPhotoBytes = null;
                                      pickedPhotoName = null;
                                      pickedPhotoSize = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              safety.strings.photoLocalNotice,
                              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Local Simulation Notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x18000000)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.slateSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isHindi
                                  ? 'स्थानीय प्रोटोटाइप सूचना: रिपोर्ट केवल स्थानीय रूप से सहेजी जाती है। आपातकालीन पुलिस को नहीं भेजी जाती।'
                                  : 'Saved locally in prototype - not sent to municipal dispatch.',
                              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        icon: const Icon(Icons.send, size: 16),
                        label: Text(
                          isHindi ? 'रिपोर्ट दर्ज करें (लोकल मॉक)' : 'Submit Report (Local Mock)',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          final loc = locationCtrl.text.trim().isEmpty ? 'Current Corridor' : locationCtrl.text.trim();
                          final notes = notesCtrl.text.trim().isEmpty ? 'No additional notes provided.' : notesCtrl.text.trim();

                          final newReport = SafetyHazardReport(
                            id: 'haz-${DateTime.now().millisecondsSinceEpoch}',
                            type: selectedType,
                            location: loc,
                            severity: selectedSeverity,
                            notes: notes,
                            timestamp: isHindi ? 'अभी' : 'Just now',
                            photoPath: pickedPhoto?.path,
                            photoBytes: pickedPhotoBytes,
                            photoName: pickedPhotoName,
                          );

                          safety.addHazardReport(newReport);
                          Navigator.of(sheetCtx).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.slateCharcoal,
                              content: Text(safety.strings.hazardSavedNotice),
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
      },
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return AppColors.primary;
      case 'medium':
        return const Color(0xFFD97706);
      case 'low':
      default:
        return AppColors.emeraldSafe;
    }
  }

  IconData _hazardIcon(String type) {
    if (type.contains('Streetlight')) return Icons.lightbulb_outline;
    if (type.contains('Isolated')) return Icons.visibility_off_outlined;
    if (type.contains('Harassment')) return Icons.warning_amber_rounded;
    if (type.contains('Construction')) return Icons.construction;
    return Icons.report_problem_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final safety = Provider.of<SafetyProvider>(context);
    final strings = safety.strings;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(strings.alertsTitle, style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert, color: AppColors.primary),
            tooltip: 'Report Concern',
            onPressed: () => _showReportIncidentSheet(context, safety),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.emeraldLightBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.emeraldSafe.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: AppColors.emeraldSafe, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.isHindi ? 'वर्तमान क्षेत्र: सुरक्षित (जोन 4)' : 'Current Corridor: Safe (Zone 4)',
                          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800, color: AppColors.emeraldSafe),
                        ),
                        Text(
                          strings.isHindi ? 'पिछले 48 घंटों में कोई सक्रिय संकट चेतावनी दर्ज नहीं हुई।' : 'No active distress alerts reported within 2km in the last 48 hours.',
                          style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Report Incident Action Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.campaign, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.isHindi ? 'असुरक्षित मार्ग या समस्या की रिपोर्ट करें' : 'Spotted a hazard or dark stretch?',
                          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          strings.isHindi ? 'अन्य महिलाओं के सुरक्षित आवागमन के लिए स्थानीय नोट दर्ज करें।' : 'Annotate route hazards for nearby guardians.',
                          style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () => _showReportIncidentSheet(context, safety),
                    child: Text(
                      strings.isHindi ? 'रिपोर्ट करें' : 'Report',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Community Hazard Reports Section (Phase 11)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    strings.isHindi ? 'समुदाय सुरक्षा रिपोर्टें (स्थानीय प्रोटोटाइप)' : 'Community Safety Reports (Local Prototype)',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.mutedGrey,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${safety.hazardReports.length} ${strings.isHindi ? 'सक्रिय' : 'Active'}',
                    style: AppTypography.labelSm.copyWith(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (safety.hazardReports.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    strings.isHindi ? 'कोई सक्रिय रिपोर्ट दर्ज नहीं है।' : 'No active hazard reports logged.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary),
                  ),
                ),
              )
            else
              ...safety.hazardReports.map((report) {
                final sevColor = _severityColor(report.severity);
                final locType = localizedHazardType(report.type, strings.isHindi);
                final locSev = localizedSeverity(report.severity, strings.isHindi);
                final locLocation = localizedLocation(report.location, strings.isHindi);
                final locTime = localizedTimestamp(report.timestamp, strings.isHindi);
                final locNotes = localizedNotes(report.notes, strings.isHindi);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: sevColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_hazardIcon(report.type), color: sevColor, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          locType,
                                          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: sevColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: sevColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          locSev,
                                          style: TextStyle(
                                            color: sevColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$locLocation • $locTime',
                                    style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (locNotes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              locNotes,
                              style: AppTypography.bodySm.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                        if (report.photoBytes != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x12000000)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.memory(
                                    report.photoBytes!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      width: 44,
                                      height: 44,
                                      color: AppColors.surfaceContainerHigh,
                                      child: const Icon(Icons.broken_image, size: 20, color: AppColors.slateSecondary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.image, size: 14, color: AppColors.emeraldSafe),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              report.photoName ?? (strings.isHindi ? 'संलग्न फोटो' : 'Attached Photo'),
                                              style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        strings.photoLocalNotice,
                                        style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Recent Safety Audit Trail (from incidents)
            Text(
              strings.isHindi ? 'हालिया सुरक्षा लॉग एवं चेक-इन' : 'Recent Safety Logs & Check-ins',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.mutedGrey,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            ...safety.incidents.map((inc) {
              final locIncTitle = localizedIncidentTitle(inc.title, strings.isHindi);
              final locIncStatus = localizedIncidentStatus(inc.status, strings.isHindi);
              final locIncLoc = localizedLocation(inc.location, strings.isHindi);
              final locIncTime = localizedTimestamp(inc.timestamp, strings.isHindi);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: BorderRadius.circular(18),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.history_edu, color: AppColors.primary, size: 20),
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
                                    locIncTitle,
                                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    locIncStatus,
                                    style: AppTypography.labelSm.copyWith(fontSize: 9, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$locIncTime • $locIncLoc',
                              style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              inc.hash,
                              style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: AppColors.mutedGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // Open Evidence Vault Card
            GlassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EvidenceVaultScreen()),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_clock, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.vaultTitle,
                          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          strings.isHindi ? 'अपरिवर्तनीय डिजिटल साक्ष्य और ऑडियो रिकॉर्डिंग देखें' : 'View tamper-proof logs & audio recordings',
                          style: AppTypography.bodySm.copyWith(color: AppColors.slateSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                ],
              ),
            ),

            const SizedBox(height: 120), // Clearance for floating AI assistant and nav bar
          ],
        ),
      ),
    );
  }
}
