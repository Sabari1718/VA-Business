import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';

class TopNavBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(65);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationProvider);
    final navNotifier = ref.read(navigationProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveBuilder.isMobile(context);
    final showDropdowns = screenWidth >= 1024;
    final showUserDetails = screenWidth >= 850;
    final showExtraIcons = screenWidth >= 550;

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 65,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.surfaceBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
          // Sidebar / Drawer Toggle Button
          Builder(
            builder: (scaffoldContext) {
              return IconButton(
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (isMobile) {
                    Scaffold.of(scaffoldContext).openDrawer();
                  } else {
                    navNotifier.toggleSidebar();
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: const Icon(
                    Icons.menu,
                    size: 18,
                    color: AppColors.textMedium,
                  ),
                ),
                tooltip: 'Navigation Menu',
              );
            },
          ),

          const SizedBox(width: 8),

          // Brand Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B4B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 120 : 180),
                child: Text(
                  AppConstants.appName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),
              ),
            ],
          ),

          if (showDropdowns) ...[
            const SizedBox(width: 12),

            // Dropdown: Business
            _NavDropdownButton(
              icon: Icons.business_center_outlined,
              label: 'Business',
              isSelected: navState.currentItem == NavItem.startBusiness ||
                  navState.currentItem == NavItem.listBusiness ||
                  navState.currentItem == NavItem.businessDetails ||
                  navState.currentItem == NavItem.businessCategory,
              onTap: () {
                navNotifier.navigateToListBusiness();
              },
            ),

            const SizedBox(width: 10),

            // Dropdown: Create Shop
            _NavDropdownButton(
              icon: Icons.storefront_outlined,
              label: 'Create Shop',
              isSelected: navState.currentItem == NavItem.createShop,
              onTap: () {
                navNotifier.setShopSubView(ShopSubView.addPlatform);
              },
            ),
          ],

          const Spacer(),

          // Right action icons
          if (showExtraIcons) ...[
            // Theme Toggle
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme switched'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(
                Icons.wb_sunny_outlined,
                size: 20,
                color: AppColors.iconColor,
              ),
              tooltip: 'Toggle Theme',
            ),

            const SizedBox(width: 4),

            // Message / Mail
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Messages inbox'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: AppColors.iconColor,
              ),
              tooltip: 'Messages',
            ),

            const SizedBox(width: 4),
          ],



          // User Profile: Sabarii / Guest
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              if (showUserDetails) ...[
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'sabarii',
                      style: AppTypography.navText.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Guest',
                      style: AppTypography.footerText.copyWith(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _NavDropdownButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavDropdownButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryBorder : AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.textMedium,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.navText.copyWith(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
