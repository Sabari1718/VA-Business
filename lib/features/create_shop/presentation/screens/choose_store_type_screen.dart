import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../business_setup/providers/business_providers.dart';
import '../../../business_setup/presentation/widgets/dashboard_footer.dart';
import '../../providers/shop_providers.dart';

class ChooseStoreTypeScreen extends ConsumerWidget {
  const ChooseStoreTypeScreen({super.key});

  static const List<Map<String, dynamic>> _storeTypes = [
    {
      'id': 'Retail Shop',
      'title': 'Retail Shop',
      'subtitle': '(Direct to Consumer)',
      'headerColor': Color(0xFF2563EB),
      'icon': Icons.storefront_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/retail_shop-DfCtgFxP.jpg',
      'illustrationIcon': Icons.shopping_cart_rounded,
      'illustrationBg': Color(0xFFEFF6FF),
      'illustrationColor': Color(0xFF2563EB),
      'description':
          'A physical or online store that sells products directly to individual end-consumer customers in smaller retail quantities.',
      'footerBadge': 'Direct sales to individual customers',
      'badgeBg': Color(0xFFEFF6FF),
      'badgeText': Color(0xFF1D4ED8),
    },
    {
      'id': 'Showroom',
      'title': 'Showroom',
      'subtitle': '(Physical Showroom)',
      'headerColor': Color(0xFF6366F1),
      'icon': Icons.apartment_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/showroom-0X48_RPf.jpg',
      'illustrationIcon': Icons.domain_rounded,
      'illustrationBg': Color(0xFFEEF2FF),
      'illustrationColor': Color(0xFF6366F1),
      'description':
          'Display products in a dedicated physical showroom where customers can visit, inspect, compare, and enquire before making a purchase.',
      'footerBadge': 'Best for product display & engagement',
      'badgeBg': Color(0xFFEEF2FF),
      'badgeText': Color(0xFF4F46E5),
    },
    {
      'id': 'Dealer / Reseller',
      'title': 'Dealer / Reseller',
      'subtitle': '(Authorized Sales)',
      'headerColor': Color(0xFF059669),
      'icon': Icons.verified_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/dealer-DA-R5G6E.jpg',
      'illustrationIcon': Icons.handshake_rounded,
      'illustrationBg': Color(0xFFECFDF5),
      'illustrationColor': Color(0xFF059669),
      'description':
          'An authorized commercial seller who buys products from brands or distributors and resells them directly to end users or local businesses.',
      'footerBadge': 'Authorized brand reseller operations',
      'badgeBg': Color(0xFFECFDF5),
      'badgeText': Color(0xFF047857),
    },
    {
      'id': 'Wholesale Shop',
      'title': 'Wholesale Shop',
      'subtitle': '(B2B Bulk Sales)',
      'headerColor': Color(0xFF7C3AED),
      'icon': Icons.inventory_2_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/wholesale-Bgtz94Mr.jpg',
      'illustrationIcon': Icons.local_shipping_rounded,
      'illustrationBg': Color(0xFFF5F3FF),
      'illustrationColor': Color(0xFF7C3AED),
      'description':
          'A business establishment focused on selling products in bulk volume quantities to other retailers, businesses, or institutional buyers.',
      'footerBadge': 'Bulk sales to retailers & businesses',
      'badgeBg': Color(0xFFF5F3FF),
      'badgeText': Color(0xFF6D28D9),
    },
    {
      'id': 'Distributor',
      'title': 'Distributor',
      'subtitle': '(Region / Supply Chain)',
      'headerColor': Color(0xFFDC2626),
      'icon': Icons.hub_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/distributor-B3qwv8Az.jpg',
      'illustrationIcon': Icons.alt_route_rounded,
      'illustrationBg': Color(0xFFFEF2F2),
      'illustrationColor': Color(0xFFDC2626),
      'description':
          'A commercial entity that manages inventory and distributes products to retailers, dealers, and shopkeepers across assigned regional markets.',
      'footerBadge': 'Regional distribution & supply networks',
      'badgeBg': Color(0xFFFEF2F2),
      'badgeText': Color(0xFFB91C1C),
    },
    {
      'id': 'Warehouse',
      'title': 'Warehouse',
      'subtitle': '(Storage & Fulfillment)',
      'headerColor': Color(0xFFD97706),
      'icon': Icons.warehouse_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/warehouse-BNAyH_lP.jpg',
      'illustrationIcon': Icons.shelves,
      'illustrationBg': Color(0xFFFFFBEB),
      'illustrationColor': Color(0xFFD97706),
      'description':
          'A commercial facility dedicated mainly to storing products, managing stock inventory levels, and fulfilling customer online orders.',
      'footerBadge': 'Store, manage and fulfill orders',
      'badgeBg': Color(0xFFFFFBEB),
      'badgeText': Color(0xFFB45309),
    },
    {
      'id': 'Manufacturer',
      'title': 'Manufacturer',
      'subtitle': '(Own Products)',
      'headerColor': Color(0xFFDB2777),
      'icon': Icons.precision_manufacturing_rounded,
      'imageUrl': 'https://business-setup.jobes24x7.com/assets/manufacturer-CZHXUwm_.jpg',
      'illustrationIcon': Icons.factory_rounded,
      'illustrationBg': Color(0xFFFDF2F8),
      'illustrationColor': Color(0xFFDB2777),
      'description':
          'A manufacturing business that produces its own branded products and sells them directly to customers through its online storefront.',
      'footerBadge': 'Manufacture and sell directly',
      'badgeBg': Color(0xFFFDF2F8),
      'badgeText': Color(0xFFBE185D),
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
                      'Choose Your Store Type',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Select the type of business that best describes your products and operations (Select one or more)',
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

              // Store Type Cards Grid
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
                      mainAxisExtent: 360,
                    ),
                    itemCount: _storeTypes.length,
                    itemBuilder: (context, index) {
                      final item = _storeTypes[index];
                      final isSelected = shopState.selectedStoreTypes.contains(item['id']);

                      return _buildStoreTypeCard(
                        item: item,
                        isSelected: isSelected,
                        onTap: () {
                          debugPrint('🔘 [USER CLICK] Store Type Toggled: ${item['title']}');
                          shopNotifier.toggleStoreType(item['id'] as String);
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Bottom Buttons (Back & Next Step)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      debugPrint('🔘 [USER CLICK] ChooseStoreType -> Back clicked');
                      navNotifier.setShopSubView(ShopSubView.addPlatform);
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (shopState.selectedStoreTypes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ Please select at least one store type to proceed.'),
                            backgroundColor: Color(0xFFF59E0B),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      debugPrint('🔘 [USER CLICK] ChooseStoreType -> Next Step clicked -> Launching Shop Wizard (Selected Types: ${shopState.selectedStoreTypes})');
                      // Move to the 5-step Create Shop Wizard
                      shopNotifier.setWizardStep(1);
                      navNotifier.setShopSubView(ShopSubView.shopWizard);
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
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreTypeCard({
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
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? headerColor.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Colored Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: Colors.white, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
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
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 13, color: headerColor)
                        : null,
                  ),
                ],
              ),
            ),

            // Body
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
                        height: 125,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: item['illustrationBg'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: item['imageUrl'] != null
                            ? Image.network(
                                item['imageUrl'] as String,
                                height: 125,
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
                    Expanded(
                      child: Text(
                        item['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 10),

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
