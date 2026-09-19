import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../business_setup/presentation/widgets/dashboard_footer.dart';
import '../../data/models/shop_model.dart';
import '../../providers/shop_providers.dart';

class ViewCreatedShopScreen extends ConsumerStatefulWidget {
  const ViewCreatedShopScreen({super.key});

  @override
  ConsumerState<ViewCreatedShopScreen> createState() => _ViewCreatedShopScreenState();
}

class _ViewCreatedShopScreenState extends ConsumerState<ViewCreatedShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPlatformType = 'All Platform Types';
  String _selectedStoreType = 'All Store Types';
  String _selectedStatus = 'All Statuses';
  String _searchQuery = '';

  static const List<String> _platformTypeOptions = [
    'All Platform Types',
    'Physical Shop',
    'Local Online',
    'Online - Pan India',
    'Showroom',
    'Export Hub',
  ];

  static const List<String> _storeTypeOptions = [
    'All Store Types',
    'Retail Shop',
    'Dealer / Reseller',
    'Wholesale Shop',
    'Distributor',
    'Warehouse',
    'Manufacturer',
  ];

  static const List<String> _statusOptions = [
    'All Statuses',
    'Active',
    'Under Review',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final shopState = ref.watch(shopProvider);
    final shopNotifier = ref.read(shopProvider.notifier);

    final shops = shopState.shops.where((shop) {
      final matchesSearch = shop.storeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          shop.fullAddress.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPlatform = _selectedPlatformType == 'All Platform Types' ||
          shop.platformType.toLowerCase().contains(_selectedPlatformType.toLowerCase()) ||
          _selectedPlatformType.toLowerCase().contains(shop.platformType.toLowerCase());
      final matchesStore = _selectedStoreType == 'All Store Types' ||
          shop.storeType.toLowerCase() == _selectedStoreType.toLowerCase();
      final matchesStatus = _selectedStatus == 'All Statuses' ||
          shop.status.toLowerCase() == _selectedStatus.toLowerCase();
      return matchesSearch && matchesPlatform && matchesStore && matchesStatus;
    }).toList();

    final totalStores = shopState.shops.length;
    final physicalShops = shopState.shops.where((s) =>
        s.platformType.contains('Shop') || s.platformType.contains('Physical') || s.platformType.contains('Showroom')).length;
    final onlineStores = shopState.shops.where((s) => s.platformType.contains('Online')).length;
    final exportHubs = shopState.shops.where((s) => s.platformType.contains('Export')).length;

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
              // Top Header Row
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPillHeader(),
                        const SizedBox(height: 8),
                        const Text(
                          'Created Shops & Store Platforms',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your registered physical stores, online delivery platforms, showrooms, and export hubs.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: _buildCreateShopButton(navNotifier),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPillHeader(),
                              const SizedBox(height: 8),
                              const Text(
                                'Created Shops & Store Platforms',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Manage your registered physical stores, online delivery platforms, showrooms, and export hubs.',
                                style: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildCreateShopButton(navNotifier),
                      ],
                    ),

              const SizedBox(height: 24),

              // 4 Stat Cards Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 640;
                  final isMedium = constraints.maxWidth < 1000;
                  int crossAxisCount = 4;
                  if (isSmall) {
                    crossAxisCount = 2;
                  } else if (isMedium) {
                    crossAxisCount = 2;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: isSmall ? 1.6 : 2.0,
                    children: [
                      _buildStatCard(
                        count: '$totalStores',
                        title: 'Total Registered Stores',
                        icon: Icons.store_mall_directory_outlined,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                      _buildStatCard(
                        count: '$physicalShops',
                        title: 'Physical Shops & Showrooms',
                        icon: Icons.place_outlined,
                        color: const Color(0xFF10B981),
                        bgColor: const Color(0xFFECFDF5),
                      ),
                      _buildStatCard(
                        count: '$onlineStores',
                        title: 'Online & Digital Stores',
                        icon: Icons.language_outlined,
                        color: const Color(0xFFE11D48),
                        bgColor: const Color(0xFFFFF1F2),
                      ),
                      _buildStatCard(
                        count: '$exportHubs',
                        title: 'Export & Global Hubs',
                        icon: Icons.flight_takeoff_outlined,
                        color: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFFFBEB),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Search and Filters Bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: isMobile
                    ? Column(
                        children: [
                          _buildSearchField(),
                          const SizedBox(height: 10),
                          _buildFilterDropdown(
                            value: _selectedPlatformType,
                            items: _platformTypeOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPlatformType = val);
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildFilterDropdown(
                            value: _selectedStoreType,
                            items: _storeTypeOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStoreType = val);
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildFilterDropdown(
                            value: _selectedStatus,
                            items: _statusOptions,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatus = val);
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 3, child: _buildSearchField()),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _buildFilterDropdown(
                              value: _selectedPlatformType,
                              items: _platformTypeOptions,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPlatformType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _buildFilterDropdown(
                              value: _selectedStoreType,
                              items: _storeTypeOptions,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStoreType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _buildFilterDropdown(
                              value: _selectedStatus,
                              items: _statusOptions,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStatus = val);
                              },
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Shops Content Area: Empty State or Grid of Shop Cards (Image 3)
              if (shops.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x040F172A),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 32,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Stores Found',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'No store platform matches your search filters. Try resetting filters or create a new shop.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          navNotifier.setShopSubView(ShopSubView.addPlatform);
                        },
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text(
                          'Create New Shop',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
                    ],
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    if (constraints.maxWidth >= 768 && constraints.maxWidth < 1100) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth >= 1100) {
                      crossAxisCount = 2; // Matches 2-column cards layout
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 430,
                      ),
                      itemCount: shops.length,
                      itemBuilder: (context, index) {
                        final shop = shops[index];
                        return _buildShopCard(
                          context: context,
                          shop: shop,
                          onEdit: () {
                            shopNotifier.loadShopForEdit(shop);
                            navNotifier.setShopSubView(ShopSubView.shopWizard);
                          },
                          onDelete: () => _confirmDeleteShop(context, shop),
                          onDetails: () => _showStoreDetailsModal(context, shop),
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 32),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Shop Card (Matching Image 3)
  // -------------------------------------------------------------
  Widget _buildShopCard({
    required BuildContext context,
    required ShopPlatform shop,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onDetails,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue Top Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFF2563EB),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shop.platformType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Green Active Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 6),
                      SizedBox(width: 4),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Trash / Delete Button
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3D Isometric Storefront Illustration Hero Area
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              children: [
                // Illustration Canvas
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140F172A),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_rounded,
                        size: 54,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),

                // Top Right: Operating Hours Badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xD90F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_filled_rounded, size: 11, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.openingTime} - ${shop.closingTime}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Left: Store Type Pill
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      shop.storeType,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Body Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Text(
                    shop.storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Address Line
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop.fullAddress,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Contact & Branch Model Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop.customerCarePhone.isNotEmpty
                                    ? shop.customerCarePhone
                                    : '8012107626',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (shop.altPhone.isNotEmpty)
                                Text(
                                  shop.altPhone,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            shop.branchModel,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action Buttons: [Details] and [Edit]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onDetails,
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        label: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF93C5FD)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                        label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Delete Confirmation Dialog
  // -------------------------------------------------------------
  void _confirmDeleteShop(BuildContext context, ShopPlatform shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text('Delete Store Platform', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${shop.storeName}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(shopProvider.notifier).deleteShop(shop.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Shop "${shop.storeName}" has been deleted.'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Store Details Modal Dialog (Matching Image 4)
  // -------------------------------------------------------------
  void _showStoreDetailsModal(BuildContext context, ShopPlatform shop) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Blue Header Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: const Color(0xFF2563EB),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${shop.storeName} — Store Details',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Summary Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: const Icon(
                                  Icons.store_mall_directory_rounded,
                                  size: 32,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shop.storeName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          '${shop.platformType} | ${shop.branchModel}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFA7F3D0)),
                                          ),
                                          child: const Text(
                                            'Active',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section 1: Contact & Branch Model
                        _buildModalSectionHeader(
                          icon: Icons.people_alt_rounded,
                          title: 'Contact & Branch Model',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              _buildModalInfoCol(
                                label: 'Branch Model',
                                value: shop.branchModel,
                              ),
                              _buildModalInfoCol(
                                label: 'Primary Contact',
                                value: shop.customerCarePhone.isNotEmpty ? shop.customerCarePhone : '8012107626',
                                subValue: shop.customerCareName.isNotEmpty ? shop.customerCareName : 'Customer Care',
                                isHighlight: true,
                              ),
                              _buildModalInfoCol(
                                label: 'Alternate Contact',
                                value: shop.altPhone.isNotEmpty ? shop.altPhone : '8012107628',
                                subValue: shop.altContactName.isNotEmpty ? shop.altContactName : 'Sales Executive',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Section 2: Address & GPS Coordinates
                        _buildModalSectionHeader(
                          icon: Icons.location_on_rounded,
                          title: 'Address & GPS Coordinates',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmall = constraints.maxWidth < 450;
                              if (isSmall) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildModalInfoCol(
                                      label: 'Full Address',
                                      value: shop.fullAddress,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildGPSBadge(shop.latitude, shop.longitude),
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _buildModalInfoCol(
                                      label: 'Full Address',
                                      value: shop.fullAddress,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildGPSBadge(shop.latitude, shop.longitude),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Section 3: Hours, Payments & Languages
                        _buildModalSectionHeader(
                          icon: Icons.access_time_filled_rounded,
                          title: 'Hours, Payments & Languages',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              _buildModalInfoCol(
                                label: 'Store Timings',
                                value: '${shop.openingTime} - ${shop.closingTime}',
                                valueColor: const Color(0xFF059669),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Accepted Payments',
                                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    shop.paymentMethods.isNotEmpty ? shop.paymentMethods.join(', ') : 'Cash, UPI',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Supported Languages',
                                    style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: shop.supportedLanguages.map((l) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          l,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Section 4: Mapped Categories & Brands
                        _buildModalSectionHeader(
                          icon: Icons.label_rounded,
                          title: 'Mapped Categories & Brands',
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.category_outlined, size: 14, color: Color(0xFF2563EB)),
                                  SizedBox(width: 6),
                                  Text(
                                    'General Category',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF2563EB)),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'General Sub-Category',
                                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                          ),
                                          Text(
                                            'No specific brands mapped',
                                            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '0 Brands',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Close Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF475569),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF2563EB)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildModalInfoCol({
    required String label,
    required String value,
    String? subValue,
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? (isHighlight ? const Color(0xFF2563EB) : const Color(0xFF1E293B)),
          ),
        ),
        if (subValue != null)
          Text(
            subValue,
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
      ],
    );
  }

  Widget _buildGPSBadge(double lat, double lng) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GPS Signal',
          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4ADE80),
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  // Common UI Elements
  Widget _buildPillHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
      ),
      child: const Text(
        'Store Platform Management',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D4ED8),
        ),
      ),
    );
  }

  Widget _buildCreateShopButton(NavigationNotifier navNotifier) {
    return ElevatedButton.icon(
      onPressed: () {
        navNotifier.setShopSubView(ShopSubView.addPlatform);
      },
      icon: const Icon(Icons.add, size: 16, color: Colors.white),
      label: const Text(
        'Create New Shop',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search by store name, city, brand...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: items.contains(value) ? value : items.first,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 18),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
