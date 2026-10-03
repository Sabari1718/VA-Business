import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessStep3DocumentsScreen extends ConsumerStatefulWidget {
  const BusinessStep3DocumentsScreen({super.key});

  @override
  ConsumerState<BusinessStep3DocumentsScreen> createState() => _BusinessStep3DocumentsScreenState();
}

class _BusinessStep3DocumentsScreenState extends ConsumerState<BusinessStep3DocumentsScreen> {
  Future<void> _pickImage(Function(String name, String path) onPicked) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onPicked(image.name, image.path);
      }
    } catch (e) {
      debugPrint('Error picking document image: $e');
    }
  }

  Widget _buildFieldLabel(String text) {
    final isRequired = text.endsWith('*');
    final label = isRequired ? text.substring(0, text.length - 1).trim() : text;

    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final setupState = ref.watch(businessSetupProvider);
    final setupNotifier = ref.read(businessSetupProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Header (Step 3 active)
              BusinessSetupStepperHeader(
                currentStep: 3,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 3: Legal Document Certificates & Location Photo
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: isMobile ? 20 : 32,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Title with round icon
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description_rounded, size: 17, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Step 3: Legal Document Certificates & Location Photo',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 44),
                      child: Text(
                        'Upload official certificates and a geotagged premises photo to finalize your business registration.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 4 Upload Cards (Photo 2 / Photo 3)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSingleCol = constraints.maxWidth < 600;
                        final isTwoCol = constraints.maxWidth >= 600 && constraints.maxWidth < 950;

                        if (isSingleCol) {
                          return Column(
                            children: [
                              _buildUdyamCard(setupState, setupNotifier),
                              const SizedBox(height: 16),
                              _buildGstCard(setupState, setupNotifier),
                              const SizedBox(height: 16),
                              _buildCinCard(setupState, setupNotifier),
                              const SizedBox(height: 16),
                              _buildGpsCard(setupState, setupNotifier),
                            ],
                          );
                        }

                        if (isTwoCol) {
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildUdyamCard(setupState, setupNotifier)),
                                  const SizedBox(width: 14),
                                  Expanded(child: _buildGstCard(setupState, setupNotifier)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildCinCard(setupState, setupNotifier)),
                                  const SizedBox(width: 14),
                                  Expanded(child: _buildGpsCard(setupState, setupNotifier)),
                                ],
                              ),
                            ],
                          );
                        }

                        // 4 Columns on wide desktop
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildUdyamCard(setupState, setupNotifier)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildGstCard(setupState, setupNotifier)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildCinCard(setupState, setupNotifier)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildGpsCard(setupState, setupNotifier)),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // Bottom Navigation Buttons
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => navNotifier.navigateToStep2(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Step 2'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMedium,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: setupState.isSubmitting
                              ? null
                              : () async {
                                  final success = await setupNotifier.submitStep3Documents();
                                  if (!mounted) return;
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✅ Documents details saved to API!'),
                                        backgroundColor: Color(0xFF10B981),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                  navNotifier.navigateToStep4();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (setupState.isSubmitting) ...[
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                setupState.isSubmitting ? 'Saving to API...' : 'Next: Bank Account',
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUdyamCard(BusinessSetupState state, BusinessSetupController notifier) {
    return _buildDocUploadCard(
      label: 'Udyam Certificate *',
      actionText: 'Upload Udyam PDF/Img',
      subtext: 'PDF, PNG, JPG up to 10MB',
      icon: Icons.upload_file_rounded,
      iconColor: const Color(0xFF2563EB),
      isUploaded: state.isUdyamUploaded,
      fileName: state.udyamFileName ?? 'Buy Land India Log...',
      filePath: state.udyamFilePath,
      onToggleUpload: () => _pickImage((name, path) {
        notifier.updateUdyamFile(name, true, path);
      }),
    );
  }

  Widget _buildGstCard(BusinessSetupState state, BusinessSetupController notifier) {
    return _buildDocUploadCard(
      label: 'GST Certificate *',
      actionText: 'Upload GST Certificate',
      subtext: 'PDF, PNG, JPG up to 10MB',
      icon: Icons.receipt_long_rounded,
      iconColor: const Color(0xFF2563EB),
      isUploaded: state.isGstUploaded,
      fileName: state.gstFileName ?? 'GST_Certificate_2026.pdf',
      filePath: state.gstFilePath,
      onToggleUpload: () => _pickImage((name, path) {
        notifier.updateGstFile(name, true, path);
      }),
    );
  }

  Widget _buildCinCard(BusinessSetupState state, BusinessSetupController notifier) {
    return _buildDocUploadCard(
      label: 'CIN / Incorporation (Optional)',
      actionText: 'Upload CIN Certificate',
      subtext: 'PDF, PNG, JPG up to 10MB',
      icon: Icons.apartment_rounded,
      iconColor: const Color(0xFF7C3AED),
      isUploaded: state.isCinUploaded,
      fileName: state.cinFileName ?? 'CIN_Incorporation.pdf',
      filePath: state.cinFilePath,
      onToggleUpload: () => _pickImage((name, path) {
        notifier.updateCinFile(name, true, path);
      }),
    );
  }

  Widget _buildGpsCard(BusinessSetupState state, BusinessSetupController notifier) {
    return _buildDocUploadCard(
      label: 'Geotagged Store / GPS Photo *',
      actionText: 'Upload Geotagged Photo',
      subtext: 'Photo of business premises with GPS',
      icon: Icons.camera_alt_rounded,
      iconColor: const Color(0xFF0284C7),
      isFilledBg: true,
      isGps: true,
      isUploaded: state.isGpsUploaded,
      fileName: state.gpsFileName ?? 'store_front_geotag.jpg',
      filePath: state.gpsFilePath,
      onToggleUpload: () => _pickImage((name, path) {
        notifier.updateGpsFile(name, true, path);
      }),
    );
  }

  Widget _buildDocUploadCard({
    required String label,
    required String actionText,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required bool isUploaded,
    required String fileName,
    required String? filePath,
    required VoidCallback onToggleUpload,
    bool isGps = false,
    bool isFilledBg = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onToggleUpload,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.white
                  : (isFilledBg ? const Color(0xFFF0F9FF) : const Color(0xFFFAFAFA)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded
                    ? const Color(0xFFBAE6FD)
                    : (isFilledBg ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0)),
                width: 1.2,
              ),
              boxShadow: isUploaded
                  ? const [
                      BoxShadow(
                        color: Color(0x080F172A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: isUploaded
                ? _buildUploadedPreview(fileName, filePath, isGps: isGps)
                : _buildEmptyUploadPrompt(
                    icon: icon,
                    iconColor: iconColor,
                    actionText: actionText,
                    subtext: subtext,
                  ),
          ),
        ),
      ],
    );
  }

  // Exact UI from Photo 3: Thumbnail + "✓ File Uploaded" + filename
  Widget _buildUploadedPreview(String fileName, String? filePath, {bool isGps = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Thumbnail preview container matching Photo 3
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildThumbnailImage(filePath),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 14, color: Color(0xFF16A34A)),
            const SizedBox(width: 4),
            Text(
              isGps ? 'Geotagged Photo Uploaded' : 'File Uploaded',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          fileName,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildThumbnailImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 28),
      );
    }
    if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 28),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_outlined, color: Color(0xFF2563EB), size: 28),
        ),
      );
    }
  }

  Widget _buildEmptyUploadPrompt({
    required IconData icon,
    required Color iconColor,
    required String actionText,
    required String subtext,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 10),
        Text(
          actionText,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtext,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
