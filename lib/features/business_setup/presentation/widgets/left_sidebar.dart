import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class LeftSidebar extends ConsumerWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final navNotifier = ref.read(navigationProvider.notifier);

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Business Accordion Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InkWell(
                onTap: () => navNotifier.toggleBusinessMenu(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: navState.currentItem == NavItem.startBusiness ||
                            navState.currentItem == NavItem.listBusiness ||
                            navState.currentItem == NavItem.businessDetails ||
                            navState.currentItem == NavItem.businessCategory
                        ? AppColors.primarySubtle.withValues(alpha: 0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.business_center_outlined,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Business',
                          style: AppTypography.navText.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      Icon(
                        navState.isBusinessMenuExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sub-items for Business
            if (navState.isBusinessMenuExpanded) ...[
              const SizedBox(height: 6),
              _SidebarSubItem(
                icon: Icons.format_list_bulleted_rounded,
                label: 'List Business',
                isSelected: navState.currentItem == NavItem.listBusiness,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.navigateToListBusiness();
                },
              ),
              const SizedBox(height: 2),
              _SidebarSubItem(
                icon: Icons.badge_outlined,
                label: 'Business Details',
                isSelected: navState.currentItem == NavItem.businessDetails,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.navigateToBusinessDetails();
                },
              ),
              const SizedBox(height: 2),
              _SidebarSubItem(
                icon: Icons.category_outlined,
                label: 'Business Category',
                isSelected: navState.currentItem == NavItem.businessCategory,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.navigateToBusinessCategory();
                },
              ),
              const SizedBox(height: 2),
              _SidebarSubItem(
                icon: Icons.add_business_outlined,
                label: '+ Add Platform',
                isSelected: navState.currentItem == NavItem.createShop &&
                    navState.shopSubView == ShopSubView.addPlatform,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.setShopSubView(ShopSubView.addPlatform);
                },
              ),
            ],

            const SizedBox(height: 12),

            // Create Shop Accordion Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InkWell(
                onTap: () => navNotifier.toggleShopMenu(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: navState.currentItem == NavItem.createShop
                        ? AppColors.primarySubtle.withValues(alpha: 0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Create Shop',
                          style: AppTypography.navText.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      Icon(
                        navState.isShopMenuExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sub-items for Create Shop
            if (navState.isShopMenuExpanded) ...[
              const SizedBox(height: 6),
              _SidebarSubItem(
                icon: Icons.add_business_outlined,
                label: 'Add Platform',
                isSelected: navState.currentItem == NavItem.createShop &&
                    (navState.shopSubView == ShopSubView.addPlatform ||
                        navState.shopSubView == ShopSubView.chooseStoreType ||
                        navState.shopSubView == ShopSubView.shopWizard),
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.setShopSubView(ShopSubView.addPlatform);
                },
              ),
              const SizedBox(height: 2),
              _SidebarSubItem(
                icon: Icons.visibility_outlined,
                label: 'View created shop',
                isSelected: navState.currentItem == NavItem.createShop &&
                    navState.shopSubView == ShopSubView.viewCreatedShop,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.setShopSubView(ShopSubView.viewCreatedShop);
                },
              ),
              const SizedBox(height: 2),
              _SidebarSubItem(
                icon: Icons.info_outline_rounded,
                label: 'Shop details',
                isSelected: false,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                  navNotifier.setShopSubView(ShopSubView.viewCreatedShop);
                },
              ),
            ],

          const Spacer(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await ref.read(userServiceProvider).logout(context);
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.logoutRed),
                        ),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.logoutRed,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Logout',
                        style: AppTypography.navText.copyWith(
                          color: AppColors.logoutRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _SidebarSubItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarSubItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navItemActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.navItemActiveText
                    : AppColors.navItemInactiveText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.navText.copyWith(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.navItemActiveText
                        : AppColors.navItemInactiveText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
