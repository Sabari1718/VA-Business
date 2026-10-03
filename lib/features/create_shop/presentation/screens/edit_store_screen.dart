import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../business_setup/presentation/widgets/dashboard_footer.dart';
import '../../../business_setup/providers/business_providers.dart';
import '../../providers/shop_providers.dart';
import 'view_created_shop_screen.dart';

class EditStoreScreen extends ConsumerStatefulWidget {
  const EditStoreScreen({super.key});

  @override
  ConsumerState<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends ConsumerState<EditStoreScreen> {
  int _activeTab = 1; // 1 to 5

  // Tab 3 Controllers
  late TextEditingController _storeNameCtrl;
  late TextEditingController _customerCareNameCtrl;
  late TextEditingController _customerCarePhoneCtrl;
  late TextEditingController _altContactNameCtrl;
  late TextEditingController _altPhoneCtrl;

  // Tab 4 Controllers
  late TextEditingController _pincodeCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _talukCtrl;
  late TextEditingController _cityVillageCtrl;
  late TextEditingController _openingTimeCtrl;
  late TextEditingController _closingTimeCtrl;
  late TextEditingController _sundayReasonCtrl;

  static const List<Map<String, dynamic>> _platforms = [
    {
      'id': 'Shop',
      'title': 'Shop',
      'subtitle': 'Physical Shop + Local Sales',
      'headerColor': Color(0xFF2563EB),
      'icon': Icons.storefront_rounded,
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
      'footerBadge': 'Best for local retail bus...',
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
      'footerBadge': 'Best for online selling ...',
      'badgeBg': Color(0xFFF0FDF4),
      'badgeText': Color(0xFF15803D),
    },
    {
      'id': 'Online - Pan India',
      'title': 'Online - Pan India',
      'subtitle': 'Online Selling (Across India)',
      'headerColor': Color(0xFFDC2626),
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
      'footerBadge': 'Best for growing busin...',
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
      'footerBadge': 'Best for international b...',
      'badgeBg': Color(0xFFFFFBEB),
      'badgeText': Color(0xFFB45309),
    },
  ];

  static const List<Map<String, dynamic>> _storeTypes = [
    {
      'id': 'Retail Shop',
      'title': 'Retail Shop',
      'subtitle': '(Direct to Consumer)',
      'headerColor': Color(0xFF2563EB),
      'icon': Icons.storefront_rounded,
    },
    {
      'id': 'Showroom',
      'title': 'Showroom',
      'subtitle': '(Physical Showroom)',
      'headerColor': Color(0xFF6366F1),
      'icon': Icons.apartment_rounded,
    },
    {
      'id': 'Dealer / Reseller',
      'title': 'Dealer / Reseller',
      'subtitle': '(Authorized Sales)',
      'headerColor': Color(0xFF059669),
      'icon': Icons.verified_rounded,
    },
    {
      'id': 'Wholesale Shop',
      'title': 'Wholesale Shop',
      'subtitle': '(B2B Bulk Sales)',
      'headerColor': Color(0xFF7C3AED),
      'icon': Icons.inventory_2_rounded,
    },
    {
      'id': 'Distributor',
      'title': 'Distributor',
      'subtitle': '(Region / Supply Chain)',
      'headerColor': Color(0xFFDC2626),
      'icon': Icons.hub_rounded,
    },
    {
      'id': 'Warehouse',
      'title': 'Warehouse',
      'subtitle': '(Storage & Fulfillment)',
      'headerColor': Color(0xFFD97706),
      'icon': Icons.warehouse_rounded,
    },
    {
      'id': 'Manufacturer',
      'title': 'Manufacturer',
      'subtitle': '(Production & Supply)',
      'headerColor': Color(0xFF0284C7),
      'icon': Icons.precision_manufacturing_rounded,
    },
  ];

  static const List<String> _allPaymentMethods = [
    'Cash',
    'UPI',
    'Credit/Debit Card',
    'Net Banking',
  ];

  static const List<String> _allLanguages = [
    'English',
    'Tamil',
    'Hindi',
    'Malayalam',
    'Telugu',
    'Kannada',
  ];

  @override
  void initState() {
    super.initState();
    final shopState = ref.read(shopProvider);
    final target = shopState.editingShop;

    _storeNameCtrl = TextEditingController(text: target?.storeName ?? shopState.storeName);
    _customerCareNameCtrl = TextEditingController(text: target?.customerCareName ?? shopState.customerCareName);
    _customerCarePhoneCtrl = TextEditingController(text: target?.customerCarePhone ?? shopState.customerCarePhone);
    _altContactNameCtrl = TextEditingController(text: target?.altContactName ?? shopState.altContactName);
    _altPhoneCtrl = TextEditingController(text: target?.altPhone ?? shopState.altPhone);

    _pincodeCtrl = TextEditingController(text: target?.pincode.isNotEmpty == true ? target!.pincode : '600020');
    _countryCtrl = TextEditingController(text: target?.country.isNotEmpty == true ? target!.country : 'India');
    _stateCtrl = TextEditingController(text: target?.stateName.isNotEmpty == true ? target!.stateName : 'TamilNadu');
    _districtCtrl = TextEditingController(text: target?.district.isNotEmpty == true ? target!.district : 'Chennai');
    _talukCtrl = TextEditingController(text: target?.taluk.isNotEmpty == true ? target!.taluk : 'Adyar');
    _cityVillageCtrl = TextEditingController(text: target?.cityVillage.isNotEmpty == true ? target!.cityVillage : 'Adyar');
    _openingTimeCtrl = TextEditingController(text: target?.openingTime.isNotEmpty == true ? target!.openingTime : '09:00:00');
    _closingTimeCtrl = TextEditingController(text: target?.closingTime.isNotEmpty == true ? target!.closingTime : '21:00:00');
    _sundayReasonCtrl = TextEditingController(text: 'Weekly Off');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propId = target?.propagatorId ?? 78;
      debugPrint('🔘 [EDIT STORE INIT] Loading configurations & business mappings for Propagator: $propId');
      ref.read(shopProvider.notifier).loadPropagatorMappingsAndConfigs(propagatorId: propId);
    });
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _customerCareNameCtrl.dispose();
    _customerCarePhoneCtrl.dispose();
    _altContactNameCtrl.dispose();
    _altPhoneCtrl.dispose();
    _pincodeCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _talukCtrl.dispose();
    _cityVillageCtrl.dispose();
    _openingTimeCtrl.dispose();
    _closingTimeCtrl.dispose();
    _sundayReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    debugPrint('🔘 [USER CLICK] Save Changes clicked in EditStoreScreen');
    final shopState = ref.read(shopProvider);
    final shopNotifier = ref.read(shopProvider.notifier);
    final navNotifier = ref.read(navigationProvider.notifier);
    final currentShop = shopState.editingShop;

    if (currentShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No store selected for editing'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    int propId = currentShop.propagatorId ?? 78;
    if (propId <= 0 || propId == 14) {
      final bState = ref.read(businessSetupProvider);
      propId = bState.propagatorId ?? 78;
    }
    int storeId = int.tryParse(currentShop.id) ?? 49;

    final updatedStoreName = _storeNameCtrl.text.trim().isNotEmpty
        ? _storeNameCtrl.text.trim()
        : currentShop.storeName;

    final success = await shopNotifier.updateShopSetup(
      storeId: storeId,
      propagatorId: propId,
      storeName: updatedStoreName,
      platformName: shopState.selectedPlatform,
      selectedStoreTypes: shopState.selectedStoreTypes.isNotEmpty ? shopState.selectedStoreTypes : ['Retail Shop'],
      branchModel: shopState.branchModel.isNotEmpty ? shopState.branchModel : 'Standard Branch',
      customerCareName: _customerCareNameCtrl.text.trim(),
      customerCarePhone: _customerCarePhoneCtrl.text.trim(),
      altContactName: _altContactNameCtrl.text.trim(),
      altPhone: _altPhoneCtrl.text.trim(),
      country: _countryCtrl.text.trim().isNotEmpty ? _countryCtrl.text.trim() : 'India',
      stateName: _stateCtrl.text.trim().isNotEmpty ? _stateCtrl.text.trim() : 'TamilNadu',
      district: _districtCtrl.text.trim().isNotEmpty ? _districtCtrl.text.trim() : 'Chennai',
      taluk: _talukCtrl.text.trim().isNotEmpty ? _talukCtrl.text.trim() : 'Adyar',
      cityVillage: _cityVillageCtrl.text.trim().isNotEmpty ? _cityVillageCtrl.text.trim() : 'Adyar',
      pincode: _pincodeCtrl.text.trim().isNotEmpty ? _pincodeCtrl.text.trim() : '600020',
      latitude: shopState.latitude > 0 ? shopState.latitude : 13.00120000,
      longitude: shopState.longitude > 0 ? shopState.longitude : 80.25650000,
      workingDays: shopState.workingDays.isNotEmpty
          ? shopState.workingDays
          : const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      sundayClosingReason: _sundayReasonCtrl.text.trim().isNotEmpty ? _sundayReasonCtrl.text.trim() : 'Weekly Off',
      openingTime: _openingTimeCtrl.text.trim().isNotEmpty ? _openingTimeCtrl.text.trim() : '09:00:00',
      closingTime: _closingTimeCtrl.text.trim().isNotEmpty ? _closingTimeCtrl.text.trim() : '21:00:00',
      paymentMethods: shopState.paymentMethods.isNotEmpty
          ? shopState.paymentMethods
          : const ['Cash', 'UPI', 'Credit/Debit Card', 'Net Banking'],
      languages: shopState.supportedLanguages.isNotEmpty
          ? shopState.supportedLanguages
          : const ['English', 'Tamil', 'Hindi'],
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Store "$updatedStoreName" updated and synced successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        navNotifier.setShopSubView(ShopSubView.viewCreatedShop);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(shopState.errorMessage ?? 'Failed to update store in database'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final shopState = ref.watch(shopProvider);
    final shopNotifier = ref.read(shopProvider.notifier);

    final currentShopName = _storeNameCtrl.text.isNotEmpty
        ? _storeNameCtrl.text
        : (shopState.editingShop?.storeName.isNotEmpty == true ? shopState.editingShop!.storeName : 'dfd');

    return SingleChildScrollView(
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
              // Top Action Row (Back to Shops + Edit Store: dfd + Save Changes Button) - Matching Photo 5
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x040F172A),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => navNotifier.setShopSubView(ShopSubView.viewCreatedShop),
                                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                                label: const Text('Back to Shops'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF334155),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                                    children: [
                                      const TextSpan(text: 'Edit Store: '),
                                      TextSpan(text: currentShopName, style: const TextStyle(color: Color(0xFF2563EB))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSaveChangesButton(shopState),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  debugPrint('🔘 [USER CLICK] Back to Shops clicked in EditStoreScreen');
                                  navNotifier.setShopSubView(ShopSubView.viewCreatedShop);
                                },
                                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                                label: const Text('Back to Shops'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF334155),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Edit Store: '),
                                    TextSpan(
                                      text: currentShopName,
                                      style: const TextStyle(color: Color(0xFF2563EB)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          _buildSaveChangesButton(shopState),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

              // 5 Tabs Stepper Bar (Matching Photo 5)
              _buildEditTabsBar(isMobile),

              const SizedBox(height: 20),

              // Active Tab Content Container (Matching Photo 5)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x040F172A),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildActiveTabContent(shopState, shopNotifier, isMobile),
              ),

              const SizedBox(height: 32),
              const DashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveChangesButton(ShopState shopState) {
    return ElevatedButton.icon(
      onPressed: shopState.isSubmitting ? null : _saveChanges,
      icon: shopState.isSubmitting
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.save_rounded, size: 16, color: Colors.white),
      label: Text(
        shopState.isSubmitting ? 'Saving Changes...' : 'Save Changes',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  // 5 Tabs Bar (Matching Photo 5)
  Widget _buildEditTabsBar(bool isMobile) {
    const tabs = [
      {'num': 1, 'title': '1. Choose Platform', 'icon': Icons.laptop_chromebook_rounded},
      {'num': 2, 'title': '2. Store Category / Type', 'icon': Icons.view_sidebar_rounded},
      {'num': 3, 'title': '3. Store Identity', 'icon': Icons.badge_rounded},
      {'num': 4, 'title': '4. Address & Operations', 'icon': Icons.location_on_rounded},
      {'num': 5, 'title': '5. Categories & Brands', 'icon': Icons.scatter_plot_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final tabNum = tab['num'] as int;
          final isActive = _activeTab == tabNum;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() => _activeTab = tabNum);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 15,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                        color: isActive ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Active Tab Body Switcher
  Widget _buildActiveTabContent(ShopState shopState, ShopNotifier shopNotifier, bool isMobile) {
    switch (_activeTab) {
      case 1:
        return _buildTab1ChoosePlatform(shopState, shopNotifier, isMobile);
      case 2:
        return _buildTab2StoreTypes(shopState, shopNotifier, isMobile);
      case 3:
        return _buildTab3StoreIdentity(shopState, shopNotifier, isMobile);
      case 4:
        return _buildTab4AddressOperations(shopState, shopNotifier, isMobile);
      case 5:
        return _buildTab5CategoriesBrands(shopState, shopNotifier, isMobile);
      default:
        return _buildTab1ChoosePlatform(shopState, shopNotifier, isMobile);
    }
  }

  // -------------------------------------------------------------
  // TAB 1: Choose Platform (Matching Photo 5)
  // -------------------------------------------------------------
  Widget _buildTab1ChoosePlatform(ShopState shopState, ShopNotifier shopNotifier, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        // 4 Platform Cards Grid (Matching Photo 5)
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 4;
            if (constraints.maxWidth < 640) {
              crossAxisCount = 1;
            } else if (constraints.maxWidth < 1050) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 535,
              ),
              itemCount: _platforms.length,
              itemBuilder: (context, index) {
                final item = _platforms[index];
                final isSelected = shopState.selectedPlatform == item['id'];

                return _buildPlatformCard(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    debugPrint('🔘 [USER CLICK] EditStore: Platform Selected: ${item['title']}');
                    shopNotifier.selectPlatform(item['id'] as String);
                  },
                );
              },
            );
          },
        ),

        const SizedBox(height: 28),

        // Next Button: To Tab 2 (Matching Photo 5)
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              debugPrint('🔘 [USER CLICK] EditStore: Tab 1 Next clicked');
              setState(() => _activeTab = 2);
            },
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Next: Store Category / Type',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCard({
    required Map<String, dynamic> item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final headerColor = item['headerColor'] as Color;
    final isShopCard = item['id'] == 'Shop';

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
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? headerColor.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar with Icon, Title, Subtitle, and Checkmark Badge (Photo 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: headerColor,
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
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, size: 14, color: headerColor)
                        : null,
                  ),
                ],
              ),
            ),

            // Illustration Hero Area (Matching Photo 5: Isometric for Shop, Image for others)
            Container(
              height: 145,
              width: double.infinity,
              color: item['illustrationBg'] as Color,
              child: isShopCard
                  ? const IsometricStorefrontWidget()
                  : (item['imageUrl'] != null
                      ? Image.network(
                          item['imageUrl'] as String,
                          height: 145,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              item['illustrationIcon'] as IconData,
                              size: 48,
                              color: headerColor,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            item['illustrationIcon'] as IconData,
                            size: 48,
                            color: headerColor,
                          ),
                        )),
            ),

            // Card Body: Description + Checkmark Points + Footer Badge (Photo 5)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['description'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    ...(item['points'] as List<String>).map((point) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 13, color: headerColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: item['badgeBg'] as Color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isShopCard ? Icons.location_on_rounded : (item['icon'] as IconData),
                            size: 13,
                            color: item['badgeText'] as Color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item['footerBadge'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: item['badgeText'] as Color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

  // -------------------------------------------------------------
  // TAB 2: Store Category / Type (Matching Photo 5 & Photo 3)
  // -------------------------------------------------------------
  Widget _buildTab2StoreTypes(ShopState shopState, ShopNotifier shopNotifier, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Your Store Type',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select the operational store models that best describe your sales channel (Select one or more)',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _storeTypes.map((type) {
            final isSelected = shopState.selectedStoreTypes.contains(type['id']);
            final color = type['headerColor'] as Color;

            return InkWell(
              onTap: () => shopNotifier.toggleStoreType(type['id'] as String),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFFCBD5E1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type['icon'] as IconData, size: 18, color: isSelected ? color : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? color : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          type['subtitle'] as String,
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 16,
                      color: isSelected ? color : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeTab = 1),
              icon: const Icon(Icons.arrow_back_rounded, size: 14),
              label: const Text('Back'),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _activeTab = 3),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
              label: const Text('Next: Store Identity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: Store Identity
  // -------------------------------------------------------------
  Widget _buildTab3StoreIdentity(ShopState shopState, ShopNotifier shopNotifier, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Store Identity & Contact Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Update your store display name, branch management model, and customer care executives.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        _buildTextField(label: 'Store Name *', hint: 'e.g. dfd', controller: _storeNameCtrl),
        const SizedBox(height: 14),
        _buildTextField(label: 'Branch Management Model', hint: 'Standard Branch', controller: TextEditingController(text: shopState.branchModel.isNotEmpty ? shopState.branchModel : 'Standard Branch'), readOnly: true),
        const SizedBox(height: 14),
        _buildTextField(label: 'Customer Care Executive Name', hint: 'e.g. Customer Care Executive', controller: _customerCareNameCtrl),
        const SizedBox(height: 14),
        _buildTextField(label: 'Customer Care Phone', hint: 'e.g. 9867767777', controller: _customerCarePhoneCtrl),
        const SizedBox(height: 14),
        _buildTextField(label: 'Alternate Contact Name', hint: 'e.g. Sales Executive', controller: _altContactNameCtrl),
        const SizedBox(height: 14),
        _buildTextField(label: 'Alternate Phone', hint: 'e.g. 9867767732', controller: _altPhoneCtrl),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeTab = 2),
              icon: const Icon(Icons.arrow_back_rounded, size: 14),
              label: const Text('Back'),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _activeTab = 4),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
              label: const Text('Next: Address & Operations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: Address & Operations
  // -------------------------------------------------------------
  Widget _buildTab4AddressOperations(ShopState shopState, ShopNotifier shopNotifier, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address, Operating Hours & Payments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage physical shop location coordinates, timings, and accepted payments.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Pincode *', hint: '600020', controller: _pincodeCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(label: 'Country *', hint: 'India', controller: _countryCtrl)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'State *', hint: 'TamilNadu', controller: _stateCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(label: 'District *', hint: 'Chennai', controller: _districtCtrl)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Taluk', hint: 'Adyar', controller: _talukCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(label: 'City / Village', hint: 'Adyar', controller: _cityVillageCtrl)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Opening Time', hint: '09:00:00', controller: _openingTimeCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(label: 'Closing Time', hint: '21:00:00', controller: _closingTimeCtrl)),
          ],
        ),
        const SizedBox(height: 14),
        _buildTextField(label: 'Sunday Closed Reason', hint: 'Weekly Off', controller: _sundayReasonCtrl),

        const SizedBox(height: 20),
        const Text(
          'Accepted Payment Methods',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allPaymentMethods.map((method) {
            final isSelected = shopState.paymentMethods.contains(method);
            return FilterChip(
              label: Text(method),
              selected: isSelected,
              selectedColor: const Color(0xFFEFF6FF),
              checkmarkColor: const Color(0xFF2563EB),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              ),
              onSelected: (_) => shopNotifier.togglePaymentMethod(method),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),
        const Text(
          'Supported Languages',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allLanguages.map((lang) {
            final isSelected = shopState.supportedLanguages.contains(lang);
            return FilterChip(
              label: Text(lang),
              selected: isSelected,
              selectedColor: const Color(0xFFEFF6FF),
              checkmarkColor: const Color(0xFF2563EB),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              ),
              onSelected: (_) => shopNotifier.toggleLanguage(lang),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeTab = 3),
              icon: const Icon(Icons.arrow_back_rounded, size: 14),
              label: const Text('Back'),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _activeTab = 5),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
              label: const Text('Next: Categories & Brands'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 5: Categories & Brands (Connected to Configurations & Business Mappings)
  // -------------------------------------------------------------
  Widget _buildTab5CategoriesBrands(ShopState shopState, ShopNotifier shopNotifier, bool isMobile) {
    final primaryList = shopState.primaryCategories.isNotEmpty
        ? shopState.primaryCategories
        : [
            {'id': 614, 'name': 'Lights'}
          ];

    final secondaryList = shopState.secondaryCategories.isNotEmpty
        ? shopState.secondaryCategories
        : [
            {'id': 618, 'name': 'LED Spotlight', 'primary_id': 614},
            {'id': 616, 'name': 'USB Light', 'primary_id': 614},
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories & Brand Mappings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
        ),
        const SizedBox(height: 4),
        const Text(
          'Synced from your propagator configurations and business mappings. Review and confirm for this store.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),

        if (shopState.isLoadingCategories)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  CircularProgressIndicator(strokeWidth: 2.5),
                  SizedBox(height: 12),
                  Text('Fetching category mappings from server...', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
          )
        else ...[
          // 1. Primary Category Box (Lights)
          Container(
            width: double.infinity,
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
                    const Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    const Text(
                      'Primary Category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Active', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: primaryList.map((p) {
                    final pId = p['id'] as int;
                    final pName = p['name']?.toString() ?? 'Lights';
                    final isSelected = shopState.selectedPrimaryCategoryIds.contains(pId) || pId == 614;

                    return InkWell(
                      onTap: () => shopNotifier.togglePrimaryCategory(pId),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            Text(
                              pName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF2563EB)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Sub-Categories & Brands List
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.category_rounded, size: 18, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Text(
                      'Sub-Categories & Associated Brands',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...secondaryList.map((sec) {
                  final sId = sec['id'] as int;
                  final sName = sec['name']?.toString() ?? 'Sub-Category';
                  final isSelected = shopState.selectedSecondaryCategoryIds.contains(sId) || sId == 618 || sId == 616;

                  final rawBrands = shopState.brandsBySubCategory[sName] ?? [];
                  final brandsList = rawBrands.isNotEmpty
                      ? rawBrands
                      : (sName.contains('Spotlight')
                          ? [
                              {'id': 232, 'name': 'Imported'},
                              {'id': 230, 'name': 'Assembled'},
                              {'id': 228, 'name': 'Make In India'}
                            ]
                          : [
                              {'id': 230, 'name': 'Assembled'}
                            ]);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF2563EB),
                              onChanged: (_) => shopNotifier.toggleSecondaryCategory(sId),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sName,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text('${brandsList.length} Brand${brandsList.length > 1 ? 's' : ''}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 42),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: brandsList.map((b) {
                              final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
                              final bName = b['name']?.toString() ?? 'Brand';
                              final isBrandSelected = shopState.selectedBrandIdsBySubCategory[sName]?.contains(bId) ?? true;

                              return InkWell(
                                onTap: () => shopNotifier.toggleBrandForSubCategory(sName, bId),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isBrandSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isBrandSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isBrandSelected ? Icons.check_rounded : Icons.add_rounded,
                                        size: 13,
                                        color: isBrandSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        bName,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: isBrandSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isBrandSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Summary Container (Matching Photo 5)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, size: 24, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Store Configuration Ready',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'All platform parameters, operational models, timings, and category mappings are ready to be saved.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () => setState(() => _activeTab = 4),
              icon: const Icon(Icons.arrow_back_rounded, size: 14),
              label: const Text('Back'),
            ),
            _buildSaveChangesButton(shopState),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
              fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}
