import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../navigation/providers/navigation_provider.dart';

class BusinessSetupStepperHeader extends StatelessWidget {
  final int currentStep; // 1 to 8
  final NavigationNotifier navNotifier;

  const BusinessSetupStepperHeader({
    super.key,
    required this.currentStep,
    required this.navNotifier,
  });

  static const List<Map<String, String>> _allSteps = [
    {'num': '1', 'title': 'Step 1: Location & GPS', 'sub': 'Address, Pincode & GPS'},
    {'num': '2', 'title': 'Step 2: Contact & Branding', 'sub': 'Email, Phone, Logo & Website'},
    {'num': '3', 'title': 'Step 3: Document Uploads', 'sub': 'Certificates & GPS Photo'},
    {'num': '4', 'title': 'Step 4: Bank Account', 'sub': 'Current Account & IFSC'},
    {'num': '5', 'title': 'Step 5: Company Tier', 'sub': 'Year, Employees & Tier'},
    {'num': '6', 'title': 'Step 6: Business Type', 'sub': 'Retail, Trade, Services, etc.'},
    {'num': '7', 'title': 'Step 7: Business Category', 'sub': 'Sector, Sub-Sector & Categories'},
    {'num': '8', 'title': 'Step 8: Brand Selection', 'sub': 'Brands for Selected...'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Title + Subtitle + Back to Setup
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPill(),
                  const SizedBox(height: 8),
                  Text(
                    'Company Profile & Location Setup',
                    style: AppTypography.headingMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete your business registration step-by-step.',
                    style: AppTypography.subtitle.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildBackToSetupButton(),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPill(),
                      const SizedBox(height: 8),
                      Text(
                        'Company Profile & Location Setup',
                        style: AppTypography.headingMedium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete your business registration step-by-step.',
                        style: AppTypography.subtitle.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                  _buildBackToSetupButton(),
                ],
              ),

        const SizedBox(height: 16),

        // Stepper Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x040F172A),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_allSteps.length, (index) {
                final stepNum = index + 1;
                final isCompleted = stepNum < currentStep;
                final isActive = stepNum == currentStep;
                final item = _allSteps[index];

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        switch (stepNum) {
                          case 1:
                            navNotifier.navigateToLocationStep();
                            break;
                          case 2:
                            navNotifier.navigateToStep2();
                            break;
                          case 3:
                            navNotifier.navigateToStep3();
                            break;
                          case 4:
                            navNotifier.navigateToStep4();
                            break;
                          case 5:
                            navNotifier.navigateToStep5();
                            break;
                          case 6:
                            navNotifier.navigateToStep6();
                            break;
                          case 7:
                            navNotifier.navigateToStep7();
                            break;
                          case 8:
                            navNotifier.navigateToStep8();
                            break;
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Step Indicator Circle
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF16A34A)
                                    : (isActive ? AppColors.primaryLight : const Color(0xFFF1F5F9)),
                                border: Border.all(
                                  color: isCompleted
                                      ? const Color(0xFF16A34A)
                                      : (isActive ? AppColors.primaryLight : AppColors.surfaceBorder),
                                ),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : Text(
                                        item['num']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isActive ? Colors.white : AppColors.textMedium,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Titles
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item['title']!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: (isActive || isCompleted) ? FontWeight.w700 : FontWeight.w500,
                                    color: isCompleted
                                        ? const Color(0xFF15803D)
                                        : (isActive ? AppColors.primaryLight : AppColors.textDark),
                                  ),
                                ),
                                Text(
                                  item['sub']!,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isCompleted
                                        ? const Color(0xFF16A34A)
                                        : (isActive ? AppColors.primaryLight : AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index < _allSteps.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.chevron_right, size: 16, color: AppColors.surfaceBorder),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Text(
        'Proprietorship / Propagator Business Setup',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D4ED8),
        ),
      ),
    );
  }

  Widget _buildBackToSetupButton() {
    return OutlinedButton.icon(
      onPressed: () => navNotifier.navigateToSetupBasic(),
      icon: const Icon(Icons.arrow_back, size: 14, color: AppColors.textMedium),
      label: const Text(
        'Back to Setup',
        style: TextStyle(
          color: AppColors.textMedium,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.surfaceBorder),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
