import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../data/models/business_structure_model.dart';
import '../../providers/business_providers.dart';
import '../widgets/dashboard_footer.dart';

class BasicBusinessDetailsScreen extends ConsumerStatefulWidget {
  const BasicBusinessDetailsScreen({super.key});

  @override
  ConsumerState<BasicBusinessDetailsScreen> createState() =>
      _BasicBusinessDetailsScreenState();
}

class _BasicBusinessDetailsScreenState
    extends ConsumerState<BasicBusinessDetailsScreen> {
  late TextEditingController _businessNameController;
  late TextEditingController _udyamController;
  late TextEditingController _gstController;
  late TextEditingController _cinController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessSetupControllerProvider);
    _businessNameController = TextEditingController(text: state.businessName);
    _udyamController = TextEditingController(text: state.udyamNumber);
    _gstController = TextEditingController(text: state.gstNumber);
    _cinController = TextEditingController(text: state.cinNumber);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _udyamController.dispose();
    _gstController.dispose();
    _cinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(businessSetupControllerProvider);
    final setupNotifier = ref.read(businessSetupControllerProvider.notifier);
    final navNotifier = ref.read(navigationProvider.notifier);
    final isMobile = ResponsiveBuilder.isMobile(context);

    final selectedStructure =
        businessStructuresList[setupState.selectedStructureIndex.clamp(0, businessStructuresList.length - 1)];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 28,
      ),
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 36,
                  vertical: isMobile ? 24 : 36,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // 1. Header: Basic Business Details + Shop Icon
                    // ==========================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Business Details',
                                style: AppTypography.headingLarge.copyWith(
                                  fontSize: isMobile ? 22 : 28,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Let's start with the essentials. Enter your business name and GST details to continue.",
                                style: AppTypography.subtitle.copyWith(
                                  fontSize: isMobile ? 13.5 : 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 16),
                          _buildShopIllustration(),
                        ],
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ==========================================
                    // 2. Form Row 1: Business Name & GST Status
                    // ==========================================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 780;

                        final businessNameField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Business Name *'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _businessNameController,
                              onChanged: (val) => setupNotifier.updateBusinessName(val),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Enter business name',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            const SizedBox(height: 6),
                            Text(
                              'Enter the official trade or brand name of your business.',
                              style: AppTypography.footerText.copyWith(fontSize: 12),
                            ),
                          ],
                        );

                        final gstStatusField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('GST Registration Status *'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGstOptionCard(
                                    title: 'With GST',
                                    subtitle: 'I have a GST registration',
                                    isSelected: setupState.isWithGst,
                                    onTap: () => setupNotifier.setWithGst(true),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGstOptionCard(
                                    title: 'Without GST',
                                    subtitle: "I don't have GST yet",
                                    isSelected: !setupState.isWithGst,
                                    onTap: () => setupNotifier.setWithGst(false),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Choose whether your business operates with GST registration or exempt.',
                              style: AppTypography.footerText.copyWith(fontSize: 12),
                            ),
                          ],
                        );

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              businessNameField,
                              const SizedBox(height: 20),
                              gstStatusField,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: businessNameField),
                            const SizedBox(width: 24),
                            Expanded(child: gstStatusField),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ==========================================
                    // 3. Dynamic Registration Inputs (Udyam, GSTIN, CIN)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBFDFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 780;

                          final udyamField = _buildInputField(
                            label: 'Udyam Registration Number *',
                            helper: 'Format: UDYAM-XX-00-0000000 (Mandatory)',
                            controller: _udyamController,
                            icon: Icons.check_circle_outline_rounded,
                            hintText: 'UDYAM-TN-01-0012345',
                            onChanged: (val) => setupNotifier.updateUdyamNumber(val),
                          );

                          final gstField = _buildInputField(
                            label: 'GST Number (GSTIN) *',
                            helper: '15-digit GSTIN number (Mandatory).',
                            controller: _gstController,
                            icon: Icons.receipt_long_outlined,
                            hintText: '33AAAAA0000A1Z5',
                            onChanged: (val) => setupNotifier.updateGstNumber(val),
                          );

                          final cinField = _buildInputField(
                            label: 'CIN Number (Corporate ID - Optional)',
                            helper: '21-character Corporate ID (Optional).',
                            controller: _cinController,
                            icon: Icons.apartment_outlined,
                            hintText: '21-digit CIN (Optional)',
                            onChanged: (val) => setupNotifier.updateCinNumber(val),
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                udyamField,
                                if (setupState.isWithGst) ...[
                                  const SizedBox(height: 16),
                                  gstField,
                                ],
                                const SizedBox(height: 16),
                                cinField,
                              ],
                            );
                          }

                          // When With GST: 3 fields
                          if (setupState.isWithGst) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: udyamField),
                                const SizedBox(width: 16),
                                Expanded(child: gstField),
                                const SizedBox(width: 16),
                                Expanded(child: cinField),
                              ],
                            );
                          }

                          // When Without GST: 2 fields (Image 2)
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: udyamField),
                              const SizedBox(width: 20),
                              Expanded(child: cinField),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ==========================================
                    // 4. Select Business Structure Section
                    // ==========================================
                    Text(
                      'Select Business Structure',
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: isMobile ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose the legal structure that best fits your business goals. Click a card to view its details.',
                      style: AppTypography.subtitle.copyWith(fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    // Grid of 6 cards + Detail Preview Panel
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;

                        final gridCards = _buildStructureCardsGrid(
                          setupState.selectedStructureIndex,
                          (idx) => setupNotifier.selectStructure(idx),
                          isCompact: !isDesktop,
                        );

                        final detailCard = _buildStructureDetailCard(selectedStructure);

                        if (!isDesktop) {
                          return Column(
                            children: [
                              gridCards,
                              const SizedBox(height: 24),
                              detailCard,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: gridCards),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: detailCard),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // ==========================================
                    // 5. Bottom Navigation Bar
                    // ==========================================
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => navNotifier.navigateBackToIntro(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Intro'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMedium,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 22,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: setupState.isSubmitting
                              ? null
                              : () async {
                                  final success = await setupNotifier.submitStep0Details();
                                  if (!mounted) return;
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✅ Business profile created on API!'),
                                        backgroundColor: Color(0xFF10B981),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                  navNotifier.navigateToLocationStep();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 18 : 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
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
                                setupState.isSubmitting ? 'Saving to API...' : 'Save & Continue',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          const DashboardFooter(),
        ],
      ),
    );
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

  Widget _buildGstOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.surfaceBorder,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryLight : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primaryLight : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String helper,
    required TextEditingController controller,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: AppColors.iconColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
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
        const SizedBox(height: 6),
        Text(
          helper,
          style: AppTypography.footerText.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }

  Widget _buildStructureCardsGrid(
    int selectedIndex,
    ValueChanged<int> onSelect, {
    required bool isCompact,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 450 ? 1 : 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: businessStructuresList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 140,
          ),
          itemBuilder: (context, index) {
            final item = businessStructuresList[index];
            final isSelected = index == selectedIndex;

            return InkWell(
              onTap: () => onSelect(index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primarySubtle : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryLight : AppColors.surfaceBorder,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.08)
                          : AppColors.cardShadow,
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.step1Bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.icon,
                            color: AppColors.primaryLight,
                            size: 18,
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? AppColors.primaryLight : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : const Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardBody.copyWith(fontSize: 11.5),
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

  Widget _buildStructureDetailCard(BusinessStructureModel structure) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.step1Bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  structure.icon,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  structure.badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            structure.title,
            style: AppTypography.cardTitle.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceBorder),
          const SizedBox(height: 12),
          Text(
            'ABOUT THIS BUSINESS TYPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            structure.aboutDescription,
            style: AppTypography.cardBody.copyWith(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopIllustration() {
    return Container(
      width: 68,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          color: AppColors.primaryLight,
          size: 38,
        ),
      ),
    );
  }
}
