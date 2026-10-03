import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../business_setup/presentation/widgets/dashboard_footer.dart';
import '../../../business_setup/providers/business_providers.dart';
import '../../data/models/shop_model.dart';
import '../../providers/shop_providers.dart';

class ViewCreatedShopScreen extends ConsumerStatefulWidget {
  const ViewCreatedShopScreen({super.key});

  @override
  ConsumerState<ViewCreatedShopScreen> createState() => _ViewCreatedShopScreenState();
}

class _ViewCreatedShopScreenState extends ConsumerState<ViewCreatedShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStoreType = 'All Shop Types';
  String _searchQuery = '';

  static const List<String> _storeTypeOptions = [
    'All Shop Types',
    'Retail Shop',
    'Dealer / Reseller',
    'Wholesale Shop',
    'Distributor',
    'Warehouse',
    'Manufacturer',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShopsFromApi();
    });
  }

  Future<void> _loadShopsFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = prefs.getString('user_main_id') ?? prefs.getString('user_id') ?? ApiConstants.defaultUserId;

    // Refresh business list from API to get the user's latest active business
    await ref.read(businessListProvider.notifier).refreshBusinesses();

    final businessState = ref.read(businessSetupProvider);
    final activeBusiness = ref.read(activeBusinessProvider);
    final selectedId = ref.read(selectedBusinessIdProvider);

    int? effectiveId = businessState.propagatorId;
    if (effectiveId == null || effectiveId <= 0 || effectiveId == 14) {
      final selectedParsed = int.tryParse(selectedId.replaceAll('#', ''));
      if (selectedParsed != null && selectedParsed > 0 && selectedParsed != 14) {
        effectiveId = selectedParsed;
      } else {
        final activeParsed = int.tryParse(activeBusiness.id.replaceAll('#', ''));
        if (activeParsed != null && activeParsed > 0 && activeParsed != 14) {
          effectiveId = activeParsed;
        }
      }
    }

    if (effectiveId == null || effectiveId <= 0 || effectiveId == 14) {
      final saved = prefs.getString('propagator_id');
      if (saved != null) {
        final parsed = int.tryParse(saved);
        if (parsed != null && parsed > 0 && parsed != 14) effectiveId = parsed;
      }
    }

    if (effectiveId == null || effectiveId <= 0 || effectiveId == 14) {
      final bizList = ref.read(businessListProvider);
      if (bizList.isNotEmpty) {
        final sorted = List.from(bizList);
        sorted.sort((a, b) => (int.tryParse(b.id.replaceAll('#', '')) ?? 0)
            .compareTo(int.tryParse(a.id.replaceAll('#', '')) ?? 0));
        final topId = int.tryParse(sorted.first.id.replaceAll('#', ''));
        if (topId != null && topId > 0 && topId != 14) {
          effectiveId = topId;
        }
      }
    }

    if (effectiveId == null || effectiveId <= 0 || effectiveId == 14) {
      effectiveId = 78;
    }

    debugPrint('🔘 [LOAD SHOPS] Fetching stores from server (propagatorId: $effectiveId, User: $effectiveUserId)...');
    await ref.read(shopProvider.notifier).fetchShopsFromApi(
      propagatorId: effectiveId,
      fallbackBusinessName: activeBusiness.brandName,
      userId: effectiveUserId,
    );
  }

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
      final matchesStore = _selectedStoreType == 'All Shop Types' ||
          _selectedStoreType == 'All Store Types' ||
          shop.storeType.toLowerCase().contains(_selectedStoreType.toLowerCase()) ||
          _selectedStoreType.toLowerCase().contains(shop.storeType.toLowerCase()) ||
          shop.storeTypesList.any((t) => t.toLowerCase().contains(_selectedStoreType.toLowerCase()));
      return matchesSearch && matchesStore;
    }).toList();

    final totalStores = shopState.shops.length;
    final physicalShops = shopState.shops.where((s) =>
        s.platformType.contains('Shop') || s.platformType.contains('Physical') || s.platformType.contains('Showroom')).length;
    final onlineStores = shopState.shops.where((s) => s.platformType.contains('Online')).length;
    final exportHubs = shopState.shops.where((s) => s.platformType.contains('Export')).length;

    return RefreshIndicator(
      onRefresh: _loadShopsFromApi,
      color: const Color(0xFF2563EB),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
              // Top Header Row (Matching Screenshot 3)
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STORE MANAGEMENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: Color(0xFF2563EB),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Shops',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Discover and manage your registered stores',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _loadShopsFromApi,
                              icon: shopState.isLoadingShops
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
                              tooltip: 'Refresh Stores from Server',
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _buildCreateShopButton(navNotifier)),
                          ],
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
                              const Text(
                                'STORE MANAGEMENT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.storefront_rounded,
                                      color: Color(0xFF2563EB),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Shops',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Discover and manage your registered stores',
                                style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _loadShopsFromApi,
                              icon: shopState.isLoadingShops
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Refresh'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFFBFDBFE)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildCreateShopButton(navNotifier),
                          ],
                        ),
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

              // Search and Filters Bar (Matching Screenshot 3)
              Container(
                padding: const EdgeInsets.all(12),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterDropdown(
                                  value: _selectedStoreType,
                                  items: _storeTypeOptions,
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedStoreType = val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = _searchController.text.trim();
                                  });
                                },
                                icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white),
                                label: const Text('Search', style: TextStyle(fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 5, child: _buildSearchField()),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildFilterDropdown(
                              value: _selectedStoreType,
                              items: _storeTypeOptions,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedStoreType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = _searchController.text.trim();
                              });
                            },
                            icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white),
                            label: const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Shops Content Area: Loading / Empty State or Grid of Shop Cards
              if (shopState.isLoadingShops && shops.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 64),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(strokeWidth: 2.5),
                        SizedBox(height: 16),
                        Text(
                          'Loading stores from server...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (shops.isEmpty)
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
                          ref.read(shopProvider.notifier).resetWizardForm();
                          navNotifier.setShopSubView(ShopSubView.addPlatform);
                        },
                        icon: const Icon(Icons.add, size: 18, color: Colors.white),
                        label: const Text(
                          '+  Add New Shop',
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
                        mainAxisExtent: 490,
                      ),
                      itemCount: shops.length,
                      itemBuilder: (context, index) {
                        final shop = shops[index];
                        return _buildShopCard(
                          context: context,
                          shop: shop,
                          onEdit: () {
                            shopNotifier.loadShopForEdit(shop);
                            navNotifier.setShopSubView(ShopSubView.editStore);
                          },
                          onDelete: () => _confirmDeleteShop(context, shop),
                          onDetails: () => _showStoreDetailsModal(context, shop),
                        );
                      },
                    );
                  },
                ),

              // Pagination Footer (Matching Screenshot 3)
              if (shops.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing 1-${shops.length} of ${shops.length} shops',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(Icons.chevron_left_rounded, size: 18, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // -------------------------------------------------------------
  // -------------------------------------------------------------
  // Shop Card (Matching Screenshot 3)
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
            color: Color(0x080F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Isometric Storefront Hero Area with Overlaid Badges & 3-Dot Menu & Shop Name/Address
          SizedBox(
            height: 195,
            width: double.infinity,
            child: Stack(
              children: [
                // Illustration / Visual of Open Shop
                const Positioned.fill(
                  child: IsometricStorefrontWidget(),
                ),

                // Top-Left Dual Badges: "Verified" (Blue) & "Open Now" (Green) - Screenshot 3
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Blue "Verified" pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Green "Open Now" pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.storefront_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Open Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top-Right: White Circle 3-Dots Menu Button (Screenshot 3)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF475569)),
                      padding: EdgeInsets.zero,
                      tooltip: 'Store options',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 8,
                      offset: const Offset(0, 36),
                      onSelected: (value) {
                        if (value == 'view_details') {
                          onDetails();
                        } else if (value == 'edit_store') {
                          onEdit();
                        } else if (value == 'delete_store') {
                          onDelete();
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem<String>(
                          value: 'view_details',
                          height: 38,
                          child: Row(
                            children: [
                              Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF2563EB)),
                              SizedBox(width: 10),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(
                          value: 'edit_store',
                          height: 38,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
                              SizedBox(width: 10),
                              Text(
                                'Edit Store',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        const PopupMenuItem<String>(
                          value: 'delete_store',
                          height: 38,
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                              SizedBox(width: 10),
                              Text(
                                'Delete Store',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Gradient Overlay on Image for readable store name & location
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 75,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom-Left Overlay: Store Name & Location (Screenshot 3)
                Positioned(
                  bottom: 10,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shop.storeName.isNotEmpty ? shop.storeName : 'dfd',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (shop.cityVillage.isNotEmpty && shop.stateName.isNotEmpty)
                                  ? '${shop.cityVillage}, ${shop.stateName}'
                                  : (shop.fullAddress.isNotEmpty ? shop.fullAddress : 'Adyar, TamilNadu'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

          // 2. Card Content (Matching Screenshot 3)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating & Distance Row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        '${shop.rating > 0 ? shop.rating : 4.4} ',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        '(87)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      const Text(
                        '5.2 km',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Store Types Tags (Retail Shop, Showroom, Dealer)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (shop.storeTypesList.isNotEmpty
                            ? shop.storeTypesList
                            : ['Retail Shop', 'Showroom', 'Dealer'])
                        .map((type) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Home Delivery Badge (Screenshot 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 6),
                        Text(
                          'Home Delivery',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Buttons: [View Shop] (Dark Navy Button) + [Direction] (Outlined Button) - Screenshot 3
                  Row(
                    children: [
                      // View Shop Button (Dark Navy)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDetails,
                          icon: const Icon(Icons.storefront_rounded, size: 15, color: Colors.white),
                          label: const Text(
                            'View Shop',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Direction Button (Outlined)
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Directions to ${shop.storeName}: ${shop.fullAddress}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.explore_outlined, size: 14, color: Color(0xFF0F172A)),
                        label: const Text(
                          'Direction',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F172A),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 24),
            SizedBox(width: 10),
            Text('Delete Store Platform', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${shop.storeName.isNotEmpty ? shop.storeName : 'Store #${shop.id}'}"? This action cannot be undone and will delete the store from database.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final propId = shop.propagatorId ?? 78;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text('Deleting store "${shop.storeName}"...'),
                    ],
                  ),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              final success = await ref.read(shopProvider.notifier).deleteStoreFromApi(
                storeId: shop.id,
                propagatorId: propId,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Propagator store deleted successfully',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete store from server. Please try again.'),
                      backgroundColor: Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Delete Store', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Store Details Modal Dialog (Live GET /api/propagator-store/{storeId})
  // -------------------------------------------------------------
  void _showStoreDetailsModal(BuildContext context, ShopPlatform shop) {
    showDialog(
      context: context,
      builder: (ctx) => _StoreDetailsDialog(shop: shop),
    );
  }



  Widget _buildCreateShopButton(NavigationNotifier navNotifier) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(shopProvider.notifier).resetWizardForm();
        navNotifier.setShopSubView(ShopSubView.addPlatform);
      },
      icon: const Icon(Icons.add, size: 16, color: Colors.white),
      label: const Text(
        '+  Add New Shop',
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
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
          ),
          Row(
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
                        fontSize: 22,
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

// -------------------------------------------------------------
// Store Details Modal Dialog (Live GET /api/propagator-store/{storeId})
// -------------------------------------------------------------
class _StoreDetailsDialog extends ConsumerStatefulWidget {
  final ShopPlatform shop;

  const _StoreDetailsDialog({required this.shop});

  @override
  ConsumerState<_StoreDetailsDialog> createState() => _StoreDetailsDialogState();
}

class _StoreDetailsDialogState extends ConsumerState<_StoreDetailsDialog> {
  bool _isLoading = true;
  Map<String, dynamic>? _storeData;

  @override
  void initState() {
    super.initState();
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storeIdInt = int.tryParse(widget.shop.id) ?? 50;
      final apiService = ref.read(shopApiServiceProvider);
      final res = await apiService.getPropagatorStore(storeIdInt);

      if (res['success'] == true || res['data'] != null) {
        final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;
        if (mounted) {
          setState(() {
            _storeData = data;
            _isLoading = false;
          });
        }
      } else {
        // Fallback to lastCreatedStoreDetails from Riverpod or local shop
        final lastCreated = ref.read(shopProvider).lastCreatedStoreDetails;
        if (mounted) {
          setState(() {
            _storeData = lastCreated;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      final lastCreated = ref.read(shopProvider).lastCreatedStoreDetails;
      if (mounted) {
        setState(() {
          _storeData = lastCreated;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _storeData;

    // Resolved store fields from API data or widget.shop fallback
    final storeName = data?['name']?.toString() ?? data?['store_name']?.toString() ?? widget.shop.storeName;

    final platformMap = (data != null && data['platform'] is Map) ? data['platform'] as Map : null;
    final platformName = platformMap?['name']?.toString() ?? widget.shop.platformType;

    // Contact & Branch Model
    final branchModel = data?['branch_management_model']?.toString() ?? data?['branch_model']?.toString() ?? widget.shop.branchModel;
    final primaryContact = data?['customer_care_contact_name']?.toString() ?? data?['customer_care_name']?.toString() ?? widget.shop.customerCareName;
    final altContact = data?['alternate_contact_name']?.toString() ?? data?['alt_contact_name']?.toString() ?? widget.shop.altContactName;

    // Address
    final addr = (data != null && data['address'] is Map) ? data['address'] as Map<String, dynamic> : null;
    final city = addr?['city_village']?.toString() ?? widget.shop.cityVillage;
    final taluk = addr?['taluk']?.toString() ?? widget.shop.taluk;
    final district = addr?['district']?.toString() ?? widget.shop.district;
    final state = addr?['state']?.toString() ?? widget.shop.stateName;
    final pincode = addr?['pincode']?.toString() ?? widget.shop.pincode;
    final lat = addr?['latitude']?.toString() ?? (widget.shop.latitude > 0 ? widget.shop.latitude.toStringAsFixed(8) : '13.00120000');
    final lng = addr?['longitude']?.toString() ?? (widget.shop.longitude > 0 ? widget.shop.longitude.toStringAsFixed(8) : '80.25650000');

    final fullAddressParts = [city, taluk, district, state].where((p) => p.isNotEmpty).toList();
    final fullAddress = fullAddressParts.isNotEmpty
        ? (pincode.isNotEmpty ? '${fullAddressParts.join(', ')} - $pincode' : fullAddressParts.join(', '))
        : (widget.shop.fullAddress.isNotEmpty ? widget.shop.fullAddress : 'df, df, as, sd - 600020');

    // Hours
    final hours = (data != null && data['hours'] is Map) ? data['hours'] as Map<String, dynamic> : null;
    final openingTime = hours?['opening_time']?.toString() ?? '09:00:00';
    final closingTime = hours?['closing_time']?.toString() ?? '21:00:00';

    // Payments
    final rawPayments = (data != null && data['payments'] is List) ? (data['payments'] as List) : null;
    final List<String> paymentsList = [];
    if (rawPayments != null && rawPayments.isNotEmpty) {
      for (final p in rawPayments) {
        final name = p is Map ? p['payment_method_name']?.toString() : p.toString();
        if (name != null && name.isNotEmpty) paymentsList.add(name);
      }
    }

    // Languages
    final rawLanguages = (data != null && data['languages'] is List) ? (data['languages'] as List) : null;
    final List<String> languagesList = [];
    if (rawLanguages != null && rawLanguages.isNotEmpty) {
      for (final l in rawLanguages) {
        final name = l is Map ? l['language_name']?.toString() : l.toString();
        if (name != null && name.isNotEmpty) languagesList.add(name);
      }
    }
    if (languagesList.isEmpty) {
      languagesList.addAll(['English', 'Tamil', 'Hindi']);
    }

    // Store Setup (Categories & Brands)
    final storeSetup = (data != null && data['store_setup'] is List) ? (data['store_setup'] as List) : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 850),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar (Blue Bar matching Photo 4)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${storeName.isNotEmpty ? storeName : 'dfd'} — Store Details',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Modal Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(strokeWidth: 2.5),
                          SizedBox(height: 16),
                          Text(
                            'Fetching live store details from server...',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Store Header Card (Matching Photo 4)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: const IsometricStorefrontWidget(),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        storeName.isNotEmpty ? storeName : 'dfd',
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${platformName.isNotEmpty ? platformName : 'Shop'} (Store Platform)',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Active',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF94A3B8),
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

                          // 2. Section: Contact & Branch Model (Matching Photo 4)
                          _buildSectionTitle(Icons.people_alt_outlined, 'Contact & Branch Model', iconColor: const Color(0xFF2563EB)),
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  label: 'Branch Model',
                                  value: branchModel.isNotEmpty ? branchModel : 'Standard Branch',
                                  isBold: true,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  label: 'Primary Contact',
                                  value: primaryContact.isNotEmpty ? primaryContact : '',
                                ),
                              ),
                              Expanded(
                                child: _buildInfoItem(
                                  label: 'Alternate Contact',
                                  value: altContact.isNotEmpty ? altContact : '',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 3. Section: Address & GPS Coordinates (Matching Photo 4)
                          _buildSectionTitle(Icons.location_on, 'Address & GPS Coordinates', iconColor: const Color(0xFFEF4444)),
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildInfoItem(
                                  label: 'Full Address',
                                  value: fullAddress,
                                  isBold: true,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'GPS Signal',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Lat: $lat, Lng: $lng',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // 4. Section: Hours, Payments & Languages (Matching Photo 4)
                          _buildSectionTitle(Icons.access_time_filled, 'Hours, Payments & Languages', iconColor: const Color(0xFF10B981)),
                          const Divider(height: 16, color: Color(0xFFE2E8F0)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Store Timings', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$openingTime - $closingTime',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Accepted Payments', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                    const SizedBox(height: 4),
                                    Text(
                                      paymentsList.isNotEmpty ? paymentsList.join(', ') : '',
                                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Supported Languages', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: languagesList.map((lang) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFBFDBFE)),
                                          ),
                                          child: Text(
                                            lang,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 5. Section: Mapped Categories & Brands (Matching Photo 4)
                          _buildSectionTitle(Icons.military_tech_rounded, 'Mapped Categories & Brands', iconColor: const Color(0xFF1E293B)),
                          const SizedBox(height: 12),
                          _buildMappedCategoriesBox(storeSetup),
                        ],
                      ),
                    ),
            ),

            // Modal Footer Actions (Matching Photo 4 with page < [1] > & Close button)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.chevron_left_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64748B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, {Color iconColor = const Color(0xFF2563EB)}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({required String label, required String value, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
        const SizedBox(height: 3),
        Text(
          value.isNotEmpty ? value : '-',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildMappedCategoriesBox(List? storeSetup) {
    String primaryName = 'Lights';
    List secondaryList = [];

    if (storeSetup != null && storeSetup.isNotEmpty) {
      final first = storeSetup.first;
      if (first is Map) {
        primaryName = first['primary']?['name']?.toString() ?? 'Lights';
        if (first['secondary'] is List) {
          secondaryList = first['secondary'] as List;
        }
      }
    }

    // Default fallback matching Photo 4 if empty
    if (secondaryList.isEmpty) {
      secondaryList = [
        {
          'name': 'LED Spotlight',
          'brands': [{'name': 'Imported'}]
        },
        {
          'name': 'USB Light',
          'brands': [{'name': 'Assembled'}]
        }
      ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                primaryName,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...secondaryList.map((sec) {
            final secName = sec is Map ? (sec['name']?.toString() ?? 'LED Spotlight') : sec.toString();
            final brands = sec is Map && sec['brands'] is List ? sec['brands'] as List : [];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded, size: 11, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            secName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          '${brands.isNotEmpty ? brands.length : 1} Brand',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: brands.isNotEmpty
                        ? brands.map((b) {
                            final bName = b is Map ? (b['name']?.toString() ?? 'Imported') : b.toString();
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 4),
                                  Text(
                                    bName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        : [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF2563EB)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Imported',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

}

// -------------------------------------------------------------
// Isometric Storefront Illustration Widget (Matching Image 1 & 3)
// -------------------------------------------------------------
class IsometricStorefrontWidget extends StatelessWidget {
  const IsometricStorefrontWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE6EDF5), Color(0xFFCDD7E2)],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 260,
          height: 185,
          child: CustomPaint(
            painter: _StorefrontPainter(),
          ),
        ),
      ),
    );
  }
}

class _StorefrontPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Isometric Base Ground Platform
    final groundPaint = Paint()..color = const Color(0xFFBAC7D5);
    final groundPath = Path()
      ..moveTo(w * 0.5, h * 0.96)
      ..lineTo(w * 0.94, h * 0.74)
      ..lineTo(w * 0.5, h * 0.52)
      ..lineTo(w * 0.06, h * 0.74)
      ..close();
    canvas.drawPath(groundPath, groundPaint);

    final groundSidePaint = Paint()..color = const Color(0xFF9AAAB9);
    final groundSidePath = Path()
      ..moveTo(w * 0.06, h * 0.74)
      ..lineTo(w * 0.5, h * 0.96)
      ..lineTo(w * 0.5, h * 0.99)
      ..lineTo(w * 0.06, h * 0.77)
      ..close();
    canvas.drawPath(groundSidePath, groundSidePaint);

    final groundSideRight = Path()
      ..moveTo(w * 0.5, h * 0.96)
      ..lineTo(w * 0.94, h * 0.74)
      ..lineTo(w * 0.94, h * 0.77)
      ..lineTo(w * 0.5, h * 0.99)
      ..close();
    canvas.drawPath(groundSideRight, Paint()..color = const Color(0xFF8294A5));

    // 2. Isometric Shop Building Walls
    // Left Wall (Shaded in grey/slate)
    final leftWallPaint = Paint()..color = const Color(0xFFE2E8F0);
    final leftWall = Path()
      ..moveTo(w * 0.18, h * 0.67)
      ..lineTo(w * 0.48, h * 0.81)
      ..lineTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.18, h * 0.24)
      ..close();
    canvas.drawPath(leftWall, leftWallPaint);

    // Front Wall (Facing camera/right)
    final frontWallPaint = Paint()..color = const Color(0xFFF8FAFC);
    final frontWall = Path()
      ..moveTo(w * 0.48, h * 0.81)
      ..lineTo(w * 0.82, h * 0.65)
      ..lineTo(w * 0.82, h * 0.23)
      ..lineTo(w * 0.48, h * 0.38)
      ..close();
    canvas.drawPath(frontWall, frontWallPaint);

    // Roof (Flat isometric top)
    final roofPaint = Paint()..color = const Color(0xFF94A3B8);
    final roof = Path()
      ..moveTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.82, h * 0.23)
      ..lineTo(w * 0.52, h * 0.10)
      ..lineTo(w * 0.18, h * 0.24)
      ..close();
    canvas.drawPath(roof, roofPaint);

    // Roof trim
    final roofTrim = Path()
      ..moveTo(w * 0.18, h * 0.24)
      ..lineTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.82, h * 0.23)
      ..lineTo(w * 0.82, h * 0.26)
      ..lineTo(w * 0.48, h * 0.41)
      ..lineTo(w * 0.18, h * 0.27)
      ..close();
    canvas.drawPath(roofTrim, Paint()..color = const Color(0xFF64748B));

    // 3. "OPEN SHOP" Signboard on Roof/Top
    final signBg = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.28), width: 96, height: 26),
      const Radius.circular(5),
    );
    canvas.drawRRect(signBg, Paint()..color = Colors.white);
    canvas.drawRRect(
      signBg,
      Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'OPEN SHOP',
        style: TextStyle(
          color: Color(0xFFDC2626),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(w * 0.50 - textPainter.width / 2, h * 0.28 - textPainter.height / 2),
    );

    // 4. Red-and-White Striped Awning
    final awningTopY = h * 0.39;
    final awningBottomY = h * 0.48;
    final awningStartX = w * 0.35;
    final awningEndX = w * 0.84;
    const awningSteps = 8;
    final stepW = (awningEndX - awningStartX) / awningSteps;

    for (int i = 0; i < awningSteps; i++) {
      final isRed = i % 2 == 0;
      final x1 = awningStartX + i * stepW;
      final x2 = awningStartX + (i + 1) * stepW;
      final yOffset1 = (i / awningSteps) * -16;
      final yOffset2 = ((i + 1) / awningSteps) * -16;

      final stripe = Path()
        ..moveTo(x1, awningTopY + yOffset1)
        ..lineTo(x2, awningTopY + yOffset2)
        ..lineTo(x2 - 5, awningBottomY + yOffset2)
        ..lineTo(x1 - 5, awningBottomY + yOffset1)
        ..close();

      canvas.drawPath(
        stripe,
        Paint()..color = isRed ? const Color(0xFFDC2626) : Colors.white,
      );
    }

    // 5. Glass Front & Display Shelves
    final glassRect = Path()
      ..moveTo(w * 0.50, h * 0.77)
      ..lineTo(w * 0.80, h * 0.63)
      ..lineTo(w * 0.80, h * 0.48)
      ..lineTo(w * 0.50, h * 0.62)
      ..close();
    canvas.drawPath(glassRect, Paint()..color = const Color(0x3538BDF8));
    canvas.drawPath(
      glassRect,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Glass Double Doors in the middle
    final doorPath = Path()
      ..moveTo(w * 0.58, h * 0.73)
      ..lineTo(w * 0.70, h * 0.68)
      ..lineTo(w * 0.70, h * 0.53)
      ..lineTo(w * 0.58, h * 0.58)
      ..close();
    canvas.drawPath(doorPath, Paint()..color = const Color(0x250284C7));
    canvas.drawPath(
      doorPath,
      Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Door center line
    canvas.drawLine(
      Offset(w * 0.64, h * 0.705),
      Offset(w * 0.64, h * 0.555),
      Paint()
        ..color = const Color(0xFF64748B)
        ..strokeWidth = 1,
    );

    // Handles
    canvas.drawLine(
      Offset(w * 0.63, h * 0.64),
      Offset(w * 0.63, h * 0.61),
      Paint()
        ..color = const Color(0xFF0284C7)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(w * 0.65, h * 0.63),
      Offset(w * 0.65, h * 0.60),
      Paint()
        ..color = const Color(0xFF0284C7)
        ..strokeWidth = 2,
    );

    // 6. Potted Plants on Sides
    _drawPlant(canvas, Offset(w * 0.44, h * 0.82));
    _drawPlant(canvas, Offset(w * 0.82, h * 0.68));
    _drawPlant(canvas, Offset(w * 0.38, h * 0.78));
  }

  void _drawPlant(Canvas canvas, Offset pos) {
    // Terracotta pot
    final potPath = Path()
      ..moveTo(pos.dx - 6, pos.dy)
      ..lineTo(pos.dx + 6, pos.dy)
      ..lineTo(pos.dx + 4, pos.dy + 12)
      ..lineTo(pos.dx - 4, pos.dy + 12)
      ..close();
    canvas.drawPath(potPath, Paint()..color = const Color(0xFFEA580C));

    // Green Bush
    canvas.drawCircle(Offset(pos.dx, pos.dy - 5), 9, Paint()..color = const Color(0xFF15803D));
    canvas.drawCircle(Offset(pos.dx - 4, pos.dy - 3), 6, Paint()..color = const Color(0xFF22C55E));
    canvas.drawCircle(Offset(pos.dx + 3, pos.dy - 7), 6, Paint()..color = const Color(0xFF16A34A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
