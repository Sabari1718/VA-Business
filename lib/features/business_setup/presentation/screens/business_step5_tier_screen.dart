import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessStep5TierScreen extends ConsumerStatefulWidget {
  const BusinessStep5TierScreen({super.key});

  @override
  ConsumerState<BusinessStep5TierScreen> createState() => _BusinessStep5TierScreenState();
}

class _BusinessStep5TierScreenState extends ConsumerState<BusinessStep5TierScreen> {
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessSetupProvider);
    _yearController = TextEditingController(text: state.establishmentYear);
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
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
              // Stepper Header (Step 5 active)
              BusinessSetupStepperHeader(
                currentStep: 5,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 5: Company Scale & Tier Selection
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
                          child: const Icon(Icons.trending_up_rounded, size: 17, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Step 5: Company Scale & Tier Selection',
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
                        'Provide company establishment year, workforce headcount, and select your business operational tier.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Top Row: Establishment Year, Number of Employees, Turnover / Income
                    if (isMobile) ...[
                      _buildEstablishmentYearField(setupNotifier),
                      const SizedBox(height: 16),
                      _buildEmployeeCountDropdown(setupState, setupNotifier),
                      const SizedBox(height: 16),
                      _buildTurnoverDropdown(setupState, setupNotifier),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildEstablishmentYearField(setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildEmployeeCountDropdown(setupState, setupNotifier)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTurnoverDropdown(setupState, setupNotifier)),
                        ],
                      ),

                    const SizedBox(height: 28),

                    // Section Title: Company Tier *
                    _buildFieldLabel('Company Tier *'),
                    const SizedBox(height: 14),

                    // 3 Tier Cards (STARTUP, STANDARD, CORPORATE)
                    if (isMobile) ...[
                      _buildTierCard(
                        title: 'STARTUP',
                        subtitle: 'Small business / new company',
                        icon: Icons.rocket_launch_rounded,
                        iconColor: const Color(0xFFEF4444),
                        iconBgColor: const Color(0xFFFEE2E2),
                        isRecommended: true,
                        isSelected: setupState.selectedTier == 'STARTUP',
                        onTap: () => setupNotifier.updateSelectedTier('STARTUP'),
                      ),
                      const SizedBox(height: 16),
                      _buildTierCard(
                        title: 'STANDARD',
                        subtitle: 'Growing business',
                        icon: Icons.business_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBgColor: const Color(0xFFE0F2FE),
                        isRecommended: false,
                        isSelected: setupState.selectedTier == 'STANDARD',
                        onTap: () => setupNotifier.updateSelectedTier('STANDARD'),
                      ),
                      const SizedBox(height: 16),
                      _buildTierCard(
                        title: 'CORPORATE',
                        subtitle: 'Large organization',
                        icon: Icons.apartment_rounded,
                        iconColor: const Color(0xFF7C3AED),
                        iconBgColor: const Color(0xFFF3E8FF),
                        isRecommended: false,
                        isSelected: setupState.selectedTier == 'CORPORATE',
                        onTap: () => setupNotifier.updateSelectedTier('CORPORATE'),
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTierCard(
                              title: 'STARTUP',
                              subtitle: 'Small business / new company',
                              icon: Icons.rocket_launch_rounded,
                              iconColor: const Color(0xFFEF4444),
                              iconBgColor: const Color(0xFFFEE2E2),
                              isRecommended: true,
                              isSelected: setupState.selectedTier == 'STARTUP',
                              onTap: () => setupNotifier.updateSelectedTier('STARTUP'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTierCard(
                              title: 'STANDARD',
                              subtitle: 'Growing business',
                              icon: Icons.business_rounded,
                              iconColor: const Color(0xFF0284C7),
                              iconBgColor: const Color(0xFFE0F2FE),
                              isRecommended: false,
                              isSelected: setupState.selectedTier == 'STANDARD',
                              onTap: () => setupNotifier.updateSelectedTier('STANDARD'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTierCard(
                              title: 'CORPORATE',
                              subtitle: 'Large organization',
                              icon: Icons.apartment_rounded,
                              iconColor: const Color(0xFF7C3AED),
                              iconBgColor: const Color(0xFFF3E8FF),
                              isRecommended: false,
                              isSelected: setupState.selectedTier == 'CORPORATE',
                              onTap: () => setupNotifier.updateSelectedTier('CORPORATE'),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Caption note below cards
                    Text(
                      'Based on your turnover range (${setupState.turnoverRange}), we recommended the ${setupState.selectedTier} tier. You can still choose another option.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                          onPressed: () => navNotifier.navigateToStep4(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Step 4'),
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
                                  final success = await setupNotifier.submitStep5CompanyScale();
                                  if (!mounted) return;
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('✅ Company scale & tier saved to API!'),
                                        backgroundColor: Color(0xFF10B981),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                  navNotifier.navigateToStep6();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24,
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
                                setupState.isSubmitting ? 'Saving to API...' : 'Next: Business Type',
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

  Widget _buildEstablishmentYearField(BusinessSetupController setupNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Establishment Year *'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _yearController,
          keyboardType: TextInputType.number,
          onChanged: (val) => setupNotifier.updateEstablishmentYear(val),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: '2024',
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
        const SizedBox(height: 4),
        const Text(
          'Year the company was founded.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildEmployeeCountDropdown(BusinessSetupState state, BusinessSetupController setupNotifier) {
    const options = [
      '1 - 10 Employees (Micro)',
      '11 - 50 Employees (Small)',
      '51 - 200 Employees (Medium)',
      '200+ Employees (Large)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Number of Employees *'),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(state.employeeCount) ? state.employeeCount : options.first,
              isExpanded: true,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) setupNotifier.updateEmployeeCount(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTurnoverDropdown(BusinessSetupState state, BusinessSetupController setupNotifier) {
    const options = [
      'Select Turnover Range',
      'Up to 20 Lakhs',
      '20 Lakhs to 50 Lakhs',
      '50 Lakhs to 2 Crores',
      'Above 2 Crores',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Turnover / Income *'),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2563EB), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(state.turnoverRange) ? state.turnoverRange : options.first,
              isExpanded: true,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) setupNotifier.updateTurnoverRange(val);
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Annual business revenue range.',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required bool isRecommended,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : AppColors.surfaceBorder,
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x102563EB),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Recommended Pill Badge on top border
          if (isRecommended)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '★ Recommended',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Blue checkmark circle on top right when selected
          if (isSelected)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
