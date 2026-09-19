import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessStep6TypeScreen extends ConsumerWidget {
  const BusinessStep6TypeScreen({super.key});

  static const List<Map<String, dynamic>> _types = [
    {
      'id': 'Trade',
      'title': 'Trade',
      'description': 'Buying and selling of goods and commodities',
      'icon': Icons.swap_horiz_rounded,
      'color': Color(0xFF0284C7),
      'bgColor': Color(0xFFE0F2FE),
    },
    {
      'id': 'Import',
      'title': 'Import',
      'description': 'Importing goods from international markets',
      'icon': Icons.file_download_outlined,
      'color': Color(0xFF10B981),
      'bgColor': Color(0xFFD1FAE5),
    },
    {
      'id': 'Export',
      'title': 'Export',
      'description': 'Exporting goods to international markets',
      'icon': Icons.file_upload_outlined,
      'color': Color(0xFF06B6D4),
      'bgColor': Color(0xFFCFFAFE),
    },
    {
      'id': 'Manufacturing',
      'title': 'Manufacturing',
      'description': 'Manufacturing and production activities',
      'icon': Icons.precision_manufacturing_outlined,
      'color': Color(0xFFA855F7),
      'bgColor': Color(0xFFF3E8FF),
    },
    {
      'id': 'Services',
      'title': 'Services',
      'description': 'Service based business and consulting',
      'icon': Icons.business_center_outlined,
      'color': Color(0xFF64748B),
      'bgColor': Color(0xFFF1F5F9),
    },
    {
      'id': 'Retail',
      'title': 'Retail',
      'description': 'Retail business and store operations',
      'icon': Icons.storefront_outlined,
      'color': Color(0xFFF97316),
      'bgColor': Color(0xFFFFEDD5),
    },
    {
      'id': 'Wholesale',
      'title': 'Wholesale',
      'description': 'Wholesale trading and bulk distribution',
      'icon': Icons.local_shipping_outlined,
      'color': Color(0xFF6366F1),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'id': 'Distribution',
      'title': 'Distribution',
      'description': 'Distribution and supply chain management',
      'icon': Icons.hub_outlined,
      'color': Color(0xFF14B8A6),
      'bgColor': Color(0xFFCCFBF1),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // Stepper Header (Step 6 active)
              BusinessSetupStepperHeader(
                currentStep: 6,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 6: Business Type
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
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.business_center_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Business Type',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Select one or more business types that best describe your business operations.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Grid of 8 Selection Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 640;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isSmall ? 1 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: isSmall ? 110 : 120,
                          ),
                          itemCount: _types.length,
                          itemBuilder: (context, index) {
                            final item = _types[index];
                            final String id = item['id'] as String;
                            final bool isSelected =
                                setupState.selectedBusinessTypes.contains(id);

                            return _buildTypeCard(
                              title: item['title'] as String,
                              description: item['description'] as String,
                              icon: item['icon'] as IconData,
                              iconColor: item['color'] as Color,
                              iconBgColor: item['bgColor'] as Color,
                              isSelected: isSelected,
                              onTap: () => setupNotifier.toggleBusinessType(id),
                            );
                          },
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
                          onPressed: () => navNotifier.navigateToStep5(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Step 5'),
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
                          onPressed: () {
                            if (setupState.selectedBusinessTypes.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select at least one Business Type.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            navNotifier.navigateToStep7();
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Proceed to Step 7 (Category)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isMobile ? 12 : 13.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
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

  Widget _buildTypeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Title and Description
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Checkbox on top/right
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
