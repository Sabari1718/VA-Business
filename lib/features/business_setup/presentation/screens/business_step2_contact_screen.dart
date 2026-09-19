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

class BusinessStep2ContactScreen extends ConsumerStatefulWidget {
  const BusinessStep2ContactScreen({super.key});

  @override
  ConsumerState<BusinessStep2ContactScreen> createState() => _BusinessStep2ContactScreenState();
}

class _BusinessStep2ContactScreenState extends ConsumerState<BusinessStep2ContactScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessSetupProvider);
    _emailController = TextEditingController(text: state.primaryEmail);
    _phoneController = TextEditingController(text: state.phoneNumber);
    _websiteController = TextEditingController(text: state.websiteUrl);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(String name, String path) onPicked) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onPicked(image.name, image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildPreviewImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.image, size: 50, color: Color(0xFF2563EB));
    }
    if (kIsWeb) {
      return Image.network(
        path,
        height: 54,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, size: 50, color: Color(0xFF2563EB)),
      );
    } else {
      return Image.file(
        File(path),
        height: 54,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, size: 50, color: Color(0xFF2563EB)),
      );
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
      maxLines: 2,
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
              // Stepper Header
              BusinessSetupStepperHeader(
                currentStep: 2,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 2: Company Contact & Brand Identity
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
                    // Card Title
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_in_talk, size: 17, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Step 2: Company Contact & Brand Identity',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Inputs Row (Email, Phone, Website)
                    if (isMobile) ...[
                      _buildEmailField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildPhoneField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildWebsiteField(setupNotifier),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildEmailField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPhoneField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildWebsiteField(setupNotifier)),
                        ],
                      ),

                    const SizedBox(height: 32),

                    // Upload Boxes Row (Logo & Favicon)
                    if (isMobile) ...[
                      _buildUploadBox(
                        title: 'Company Logo',
                        actionText: 'Upload Main Logo',
                        subtext: 'PNG, JPG, SVG up to 5MB',
                        icon: Icons.cloud_upload_outlined,
                        iconColor: const Color(0xFF2563EB),
                        fileName: setupState.companyLogoName,
                        filePath: setupState.companyLogoPath,
                        changeLabel: 'Logo',
                        onUpload: () => _pickImage((name, path) {
                          setupNotifier.updateCompanyLogo(name, path);
                        }),
                        onRemove: () {
                          setupNotifier.updateCompanyLogo(null, null);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildUploadBox(
                        title: 'Company Icon / Favicon',
                        actionText: 'Upload App Icon',
                        subtext: 'Square aspect ratio (1:1)',
                        icon: Icons.image_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        fileName: setupState.companyIconName,
                        filePath: setupState.companyIconPath,
                        changeLabel: 'Icon',
                        onUpload: () => _pickImage((name, path) {
                          setupNotifier.updateCompanyIcon(name, path);
                        }),
                        onRemove: () {
                          setupNotifier.updateCompanyIcon(null, null);
                        },
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildUploadBox(
                              title: 'Company Logo',
                              actionText: 'Upload Main Logo',
                              subtext: 'PNG, JPG, SVG up to 5MB',
                              icon: Icons.cloud_upload_outlined,
                              iconColor: const Color(0xFF2563EB),
                              fileName: setupState.companyLogoName,
                              filePath: setupState.companyLogoPath,
                              changeLabel: 'Logo',
                              onUpload: () => _pickImage((name, path) {
                                setupNotifier.updateCompanyLogo(name, path);
                              }),
                              onRemove: () {
                                setupNotifier.updateCompanyLogo(null, null);
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildUploadBox(
                              title: 'Company Icon / Favicon',
                              actionText: 'Upload App Icon',
                              subtext: 'Square aspect ratio (1:1)',
                              icon: Icons.image_outlined,
                              iconColor: const Color(0xFF7C3AED),
                              fileName: setupState.companyIconName,
                              filePath: setupState.companyIconPath,
                              changeLabel: 'Icon',
                              onUpload: () => _pickImage((name, path) {
                                setupNotifier.updateCompanyIcon(name, path);
                              }),
                              onRemove: () {
                                setupNotifier.updateCompanyIcon(null, null);
                              },
                            ),
                          ),
                        ],
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
                          onPressed: () => navNotifier.navigateToLocationStep(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Step 1'),
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
                          onPressed: () {
                            navNotifier.navigateToStep3();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 18 : 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Next: Upload Documents',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 16, color: Colors.white),
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

  Widget _buildEmailField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Primary Email Address *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          onChanged: (val) => setupNotifier.updatePrimaryEmail(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.textMuted),
            hintText: 'contact@mycompany.com',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Phone Number *'),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: AppColors.surfaceBorder),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: const Text(
                '+91',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (val) => setupNotifier.updatePhoneNumber(val),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: '9876543210',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: AppColors.surfaceBorder),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: AppColors.surfaceBorder),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebsiteField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Company Website URL'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _websiteController,
          onChanged: (val) => setupNotifier.updateWebsiteUrl(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.language_rounded, size: 18, color: AppColors.textMuted),
            hintText: 'https://www.mycompany.com',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox({
    required String title,
    required String actionText,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required String? fileName,
    required String? filePath,
    required String changeLabel,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    final isUploaded = (filePath != null && filePath.isNotEmpty) || (fileName != null && fileName.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(title),
        const SizedBox(height: 8),
        InkWell(
          onTap: onUpload,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUploaded ? const Color(0xFF93C5FD) : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isUploaded) ...[
                  SizedBox(
                    height: 56,
                    child: _buildPreviewImage(filePath),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Click to change $changeLabel',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  if (fileName != null && fileName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      fileName,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ] else ...[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    actionText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtext,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
