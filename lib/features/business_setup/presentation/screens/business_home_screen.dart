import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_step_card.dart';
import '../widgets/dashboard_footer.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/top_nav_bar.dart';
import 'basic_business_details_screen.dart';
import 'business_location_step_screen.dart';
import 'business_step2_contact_screen.dart';
import 'business_step3_documents_screen.dart';
import 'business_step4_bank_screen.dart';
import 'business_step5_tier_screen.dart';
import 'business_step6_type_screen.dart';
import 'business_step7_category_screen.dart';
import 'business_step8_brand_screen.dart';
import 'business_category_mapping_screen.dart';
import 'business_details_screen.dart';
import 'list_business_screen.dart';
import '../../../create_shop/presentation/screens/add_platform_screen.dart';
import '../../../create_shop/presentation/screens/choose_store_type_screen.dart';
import '../../../create_shop/presentation/screens/shop_wizard_screen.dart';
import '../../../create_shop/presentation/screens/view_created_shop_screen.dart';

class BusinessHomeScreen extends ConsumerWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const TopNavBar(),
      drawer: isMobile ? const SafeArea(bottom: false, child: Drawer(child: LeftSidebar())) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Desktop & Tablet Sidebar
          if (!isMobile && navState.isSidebarOpen) const LeftSidebar(),

          // Main Content View
          Expanded(
            child: _buildCurrentContent(context, ref, navState),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentContent(BuildContext context, WidgetRef ref, NavState navState) {
    switch (navState.currentItem) {
      case NavItem.listBusiness:
        return const ListBusinessScreen();
      case NavItem.businessDetails:
        return const BusinessDetailsScreen();
      case NavItem.businessCategory:
        return const BusinessCategoryMappingScreen();
      case NavItem.createShop:
        switch (navState.shopSubView) {
          case ShopSubView.addPlatform:
            return const AddPlatformScreen();
          case ShopSubView.chooseStoreType:
            return const ChooseStoreTypeScreen();
          case ShopSubView.shopWizard:
            return const ShopWizardScreen();
          case ShopSubView.viewCreatedShop:
            return const ViewCreatedShopScreen();
        }
      case NavItem.startBusiness:
        switch (navState.setupStepView) {
          case SetupStepView.basicDetails:
            return const BasicBusinessDetailsScreen();
          case SetupStepView.locationStep:
            return const BusinessLocationStepScreen();
          case SetupStepView.step2Contact:
            return const BusinessStep2ContactScreen();
          case SetupStepView.step3Documents:
            return const BusinessStep3DocumentsScreen();
          case SetupStepView.step4Bank:
            return const BusinessStep4BankScreen();
          case SetupStepView.step5Tier:
            return const BusinessStep5TierScreen();
          case SetupStepView.step6BusinessType:
            return const BusinessStep6TypeScreen();
          case SetupStepView.step7BusinessCategory:
            return const BusinessStep7CategoryScreen();
          case SetupStepView.step8BrandSelection:
            return const BusinessStep8BrandScreen();
          case SetupStepView.intro:
            return const _LaunchBusinessDashboard();
        }
    }
  }
}

class _LaunchBusinessDashboard extends ConsumerWidget {
  const _LaunchBusinessDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(setupStepsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final navNotifier = ref.read(navigationProvider.notifier);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 14 : 28,
      ),
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1060),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 36,
                  vertical: isMobile ? 22 : 48,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Section (Badge + Title + Subtitle)
                    const DashboardHeader(),

                    SizedBox(height: isMobile ? 24 : 44),

                    // 3 Responsive Step Cards
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 740;

                        if (isNarrow) {
                          // Stack vertically on narrow screens
                          return Column(
                            children: List.generate(steps.length, (index) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: index < steps.length - 1 ? 14 : 0),
                                child: BusinessStepCard(
                                  step: steps[index],
                                  onTap: () => navNotifier.navigateToSetupBasic(),
                                ),
                              );
                            }),
                          );
                        }

                        // Horizontal Row matching exact UI
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(steps.length, (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index < steps.length - 1 ? 18 : 0,
                                ),
                                child: BusinessStepCard(
                                  step: steps[index],
                                  onTap: () => navNotifier.navigateToSetupBasic(),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    SizedBox(height: isMobile ? 28 : 44),

                    // Primary CTA Button
                    _StartBusinessCtaButton(
                      onPressed: () => navNotifier.navigateToSetupBasic(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 20 : 36),

          // Footer
          const DashboardFooter(),
        ],
      ),
    );
  }
}

class _StartBusinessCtaButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _StartBusinessCtaButton({required this.onPressed});

  @override
  State<_StartBusinessCtaButton> createState() => _StartBusinessCtaButtonState();
}

class _StartBusinessCtaButtonState extends State<_StartBusinessCtaButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: _isHovered
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        child: SizedBox(
          width: isMobile ? double.infinity : null,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isHovered ? AppColors.primary : AppColors.primaryLight,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 28,
                vertical: isMobile ? 13 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isHovered ? 8 : 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstants.ctaButton,
                    style: AppTypography.buttonText.copyWith(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
