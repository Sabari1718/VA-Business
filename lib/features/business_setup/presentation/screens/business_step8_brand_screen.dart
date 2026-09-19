import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessStep8BrandScreen extends ConsumerWidget {
  const BusinessStep8BrandScreen({super.key});

  static const List<String> _popularBrands = [
    'Tata',
    'Reliance',
    'Amul',
    'Nestle',
    'Britannia',
    'ITC',
    'Hindustan Unilever',
    'Dabur',
    'Patanjali',
    'Godrej',
    'Adani Wilmar',
    'Parle',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final setupState = ref.watch(businessSetupProvider);
    final setupNotifier = ref.read(businessSetupProvider.notifier);

    final bool hasCategories = setupState.selectedPrimaryCategories.isNotEmpty;

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
              // Stepper Header (Step 8 active)
              BusinessSetupStepperHeader(
                currentStep: 8,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 8: Brand Selection
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
                    // Top Info Box (Matching screenshot 3)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF3B82F6),
                            size: 28,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            hasCategories
                                ? 'Selected Categories: ${setupState.selectedPrimaryCategories.join(", ")}'
                                : 'No sub-categories available. Please select or save category mappings in Step 7.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (hasCategories) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Assign Partner Brands (Optional):',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: _popularBrands.map((brand) {
                                final isSelected =
                                    setupState.selectedBrands.contains(brand);
                                return FilterChip(
                                  label: Text(brand),
                                  selected: isSelected,
                                  onSelected: (_) => setupNotifier.toggleBrand(brand),
                                  selectedColor: const Color(0xFFEFF6FF),
                                  checkmarkColor: const Color(0xFF2563EB),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                                  ),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Brand & Category Configuration Card (Blue banner matching screenshot 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.bookmark_outline_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildConfigCardText(setupState)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: _buildSaveConfigButton(context, setupState, setupNotifier),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(
                                  Icons.bookmark_outline_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: _buildConfigCardText(setupState)),
                                const SizedBox(width: 16),
                                _buildSaveConfigButton(context, setupState, setupNotifier),
                              ],
                            ),
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
                          onPressed: () => navNotifier.navigateToStep7(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Category Mapping'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMedium,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 20,
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
                                  final success = await setupNotifier.completeSetup();
                                  if (context.mounted && success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🎉 Business Registration Completed Successfully!'),
                                        backgroundColor: Color(0xFF10B981),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                    // Navigate to List Business to view new registered business
                                    navNotifier.setNavItem(NavItem.listBusiness);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: setupState.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 17, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Submit & Finish All Steps',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
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

  Widget _buildConfigCardText(BusinessSetupState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Save Brand & Category Configuration Card',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
            if (state.isConfigurationSaved) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SAVED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Save all mapped sub-categories & assigned brand partners into this active configuration card.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF3B82F6),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveConfigButton(
    BuildContext context,
    BusinessSetupState state,
    BusinessSetupController notifier,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        notifier.saveConfigurationCard();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration card saved successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      },
      icon: Icon(
        state.isConfigurationSaved ? Icons.check : Icons.bookmark,
        size: 15,
        color: Colors.white,
      ),
      label: Text(
        state.isConfigurationSaved ? 'Saved' : 'Save Configuration',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: state.isConfigurationSaved
            ? const Color(0xFF10B981)
            : const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
