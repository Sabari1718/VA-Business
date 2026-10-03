import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../business_setup/providers/business_providers.dart';
import '../../../business_setup/presentation/widgets/dashboard_footer.dart';
import '../../providers/shop_providers.dart';

class AddPlatformScreen extends ConsumerWidget {
  const AddPlatformScreen({super.key});

  static const List<Map<String, dynamic>> _platforms = [
    {
      'id': 'Shop',
      'title': 'Shop',
      'subtitle': 'Physical Shop + Local Sales',
      'headerColor': Color(0xFF2563EB),
      'icon': Icons.storefront_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/shop-D7FXfKjS.jpg',
      'illustrationIcon': Icons.store_mall_directory_rounded,
      'illustrationBg': Color(0xFFEFF6FF),
      'description':
          'Sell products through your physical local shop to customers in your area. Both walk-in customers and local delivery services are supported.',
      'points': [
        'Physical shop location required',
        'Walk-in customers',
        'Local delivery possible',
        'Build local customer base',
      ],
      'footerBadge': 'Best for local retail business presence',
      'badgeBg': Color(0xFFEFF6FF),
      'badgeText': Color(0xFF1D4ED8),
    },
    {
      'id': 'Local Online',
      'title': 'Local Online',
      'subtitle': 'Online Selling (Local Delivery)',
      'headerColor': Color(0xFF16A34A),
      'icon': Icons.phone_android_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/local_online-BfAiiPzM.jpg',
      'illustrationIcon': Icons.delivery_dining_rounded,
      'illustrationBg': Color(0xFFF0FDF4),
      'description':
          'Sell products online to customers in your local area. No physical storefront is required. Orders are delivered through local delivery partners.',
      'points': [
        'No physical shop required',
        'Online orders only',
        'Delivery only within local area',
        'Ideal for local online business',
      ],
      'footerBadge': 'Best for online selling with local delivery',
      'badgeBg': Color(0xFFF0FDF4),
      'badgeText': Color(0xFF15803D),
    },
    {
      'id': 'Online - Pan India',
      'title': 'Online - Pan India',
      'subtitle': 'Online Selling (Across India)',
      'headerColor': Color(0xFFE11D48),
      'icon': Icons.public_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/local_online-BfAiiPzM.jpg',
      'illustrationIcon': Icons.laptop_chromebook_rounded,
      'illustrationBg': Color(0xFFFFF1F2),
      'description':
          'Sell products online to customers across all states in India. No physical shop is required. Orders are fulfilled via nationwide courier partners.',
      'points': [
        'No physical shop required',
        'Online orders only',
        'Delivery across India',
        'Reach a wider customer base',
      ],
      'footerBadge': 'Best for growing business across India',
      'badgeBg': Color(0xFFFFF1F2),
      'badgeText': Color(0xFFBE123C),
    },
    {
      'id': 'Export',
      'title': 'Export',
      'subtitle': 'International Selling',
      'headerColor': Color(0xFFD97706),
      'icon': Icons.flight_takeoff_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/export-Gblb5qXt.jpg',
      'illustrationIcon': Icons.sailing_rounded,
      'illustrationBg': Color(0xFFFFFBEB),
      'description':
          'Sell products internationally to global buyers, businesses, or distributors. Manage export documentation, customs requirements, and international trade.',
      'points': [
        'Sell to international buyers',
        'Export license required',
        'International shipping',
        'Expand reach globally',
      ],
      'footerBadge': 'Best for international business expansion',
      'badgeBg': Color(0xFFFFFBEB),
      'badgeText': Color(0xFFB45309),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final businessState = ref.watch(businessSetupProvider);
    final shopState = ref.watch(shopProvider);
    final shopNotifier = ref.read(shopProvider.notifier);

    final activeBiz = ref.watch(activeBusinessProvider);

    final businessName = businessState.businessName.isNotEmpty
        ? businessState.businessName
        : (activeBiz.businessName.isNotEmpty
            ? activeBiz.businessName
            : (businessState.brandName.isNotEmpty ? businessState.brandName : 'My Business'));

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner: Current Selected Business
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x040F172A),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT SELECTED BUSINESS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            businessName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        navNotifier.setNavItem(NavItem.listBusiness);
                      },
                      icon: const Icon(Icons.sync_alt_rounded, size: 14),
                      label: const Text('Change'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main Heading
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Choose Your Platform',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select how you sell your products and reach your customers',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 4 Platform Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 4;
                  if (constraints.maxWidth < 640) {
                    crossAxisCount = 1;
                  } else if (constraints.maxWidth < 1024) {
                    crossAxisCount = 2;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 530,
                    ),
                    itemCount: _platforms.length,
                    itemBuilder: (context, index) {
                      final item = _platforms[index];
                      final isSelected = shopState.selectedPlatform == item['id'];

                      return _buildPlatformCard(
                        item: item,
                        isSelected: isSelected,
                        onTap: () {
                          debugPrint('🔘 [USER CLICK] Platform Selected: ${item['title']}');
                          shopNotifier.selectPlatform(item['id'] as String);
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 28),

              // Next Step Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('🔘 [USER CLICK] AddPlatform -> Next Step clicked (Selected Platform: "${shopState.selectedPlatform}")');
                    // Navigate to ChooseStoreType so all platforms are created into the live database via API
                    navNotifier.setShopSubView(ShopSubView.chooseStoreType);
                  },
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Next Step',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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

  Widget _buildPlatformCard({
    required Map<String, dynamic> item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final headerColor = item['headerColor'] as Color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? headerColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? headerColor.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar with Title & Checkmark
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 13, color: headerColor)
                        : null,
                  ),
                ],
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Illustration Image Area
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 135,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: item['illustrationBg'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: item['imageUrl'] != null
                            ? Image.network(
                                item['imageUrl'] as String,
                                height: 135,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(headerColor),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      item['illustrationIcon'] as IconData,
                                      size: 52,
                                      color: headerColor,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(
                                  item['illustrationIcon'] as IconData,
                                  size: 52,
                                  color: headerColor,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    Text(
                      item['description'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMedium,
                        height: 1.35,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Bullet Points
                    ...((item['points'] as List<String>).map((point) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Color(0xFF10B981),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    })),

                    const Spacer(),

                    // Footer Pill Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: item['badgeBg'] as Color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['footerBadge'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item['badgeText'] as Color,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
