import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_constants.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../../business_setup/providers/business_providers.dart';
import '../../../business_setup/presentation/widgets/dashboard_footer.dart';
import '../../providers/shop_providers.dart';

class ShopWizardScreen extends ConsumerStatefulWidget {
  const ShopWizardScreen({super.key});

  @override
  ConsumerState<ShopWizardScreen> createState() => _ShopWizardScreenState();
}

class _ShopWizardScreenState extends ConsumerState<ShopWizardScreen> {
  // Step 1 Controllers
  late TextEditingController _storeNameCtrl;
  late TextEditingController _customerCareNameCtrl;
  late TextEditingController _customerCarePhoneCtrl;
  late TextEditingController _altContactNameCtrl;
  late TextEditingController _altPhoneCtrl;

  // Step 2 Controllers
  late TextEditingController _pincodeCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _talukCtrl;
  late TextEditingController _cityVillageCtrl;
  late TextEditingController _mapSearchCtrl;

  // Step 3 Controllers
  final Map<String, TextEditingController> _closedDayControllers = {};

  // Step 4 & 5 Search Controllers
  late TextEditingController _primaryCategorySearchCtrl;
  late TextEditingController _subCategorySearchCtrl;
  late TextEditingController _brandSearchCtrl;
  String _primaryCategorySearchQuery = '';
  String _subCategorySearchQuery = '';
  String _brandSearchQuery = '';

  @override
  void initState() {
    super.initState();
    final shop = ref.read(shopProvider);

    _storeNameCtrl = TextEditingController(text: shop.storeName);
    _customerCareNameCtrl = TextEditingController(text: shop.customerCareName);
    _customerCarePhoneCtrl = TextEditingController(text: shop.customerCarePhone);
    _altContactNameCtrl = TextEditingController(text: shop.altContactName);
    _altPhoneCtrl = TextEditingController(text: shop.altPhone);

    _pincodeCtrl = TextEditingController(text: shop.pincode);
    _countryCtrl = TextEditingController(text: shop.country);
    _stateCtrl = TextEditingController(text: shop.stateName);
    _districtCtrl = TextEditingController(text: shop.district);
    _talukCtrl = TextEditingController(text: shop.taluk);
    _cityVillageCtrl = TextEditingController(text: shop.cityVillage);
    _mapSearchCtrl = TextEditingController(text: shop.mapSearch);

    _primaryCategorySearchCtrl = TextEditingController();
    _subCategorySearchCtrl = TextEditingController();
    _brandSearchCtrl = TextEditingController();

    _primaryCategorySearchCtrl.addListener(() {
      setState(() => _primaryCategorySearchQuery = _primaryCategorySearchCtrl.text.trim());
    });
    _subCategorySearchCtrl.addListener(() {
      setState(() => _subCategorySearchQuery = _subCategorySearchCtrl.text.trim());
    });
    _brandSearchCtrl.addListener(() {
      setState(() => _brandSearchQuery = _brandSearchCtrl.text.trim());
    });

    final defaultReasons = {
      'Monday': shop.closedDayReasons['Monday'] ?? '',
      'Tuesday': shop.closedDayReasons['Tuesday'] ?? '',
      'Wednesday': shop.closedDayReasons['Wednesday'] ?? '',
      'Thursday': shop.closedDayReasons['Thursday'] ?? '',
      'Friday': shop.closedDayReasons['Friday'] ?? 'Weekly Off',
      'Saturday': shop.closedDayReasons['Saturday'] ?? 'Weekend Off',
      'Sunday': shop.closedDayReasons['Sunday'] ?? (shop.sundayClosingReason.isNotEmpty ? shop.sundayClosingReason : 'Weekly Holiday'),
    };
    for (final entry in defaultReasons.entries) {
      _closedDayControllers[entry.key] = TextEditingController(text: entry.value);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPropagatorCategories();
    });
  }

  Future<void> _loadPropagatorCategories() async {
    final businessState = ref.read(businessSetupProvider);
    final activeBusiness = ref.read(activeBusinessProvider);
    final selectedId = ref.read(selectedBusinessIdProvider);
    final prefs = await SharedPreferences.getInstance();

    int effectivePropagatorId = 0;
    if (businessState.propagatorId != null && businessState.propagatorId! > 0 && businessState.propagatorId != 14) {
      effectivePropagatorId = businessState.propagatorId!;
    } else {
      final selectedParsed = int.tryParse(selectedId.replaceAll('#', ''));
      if (selectedParsed != null && selectedParsed > 0 && selectedParsed != 14) {
        effectivePropagatorId = selectedParsed;
      } else {
        final activeIdParsed = int.tryParse(activeBusiness.id.replaceAll('#', ''));
        if (activeIdParsed != null && activeIdParsed > 0 && activeIdParsed != 14) {
          effectivePropagatorId = activeIdParsed;
        }
      }
    }

    if (effectivePropagatorId <= 0 || effectivePropagatorId == 14) {
      final saved = prefs.getString('propagator_id');
      if (saved != null) {
        final parsed = int.tryParse(saved);
        if (parsed != null && parsed > 0 && parsed != 14) effectivePropagatorId = parsed;
      }
    }

    final effectiveUserId = prefs.getString('user_main_id') ?? prefs.getString('user_id') ?? ApiConstants.defaultUserId;

    if (effectivePropagatorId <= 0 || effectivePropagatorId == 14) {
      try {
        final propagators = await ref.read(shopApiServiceProvider).getPropagatorDetails(userId: effectiveUserId);
        if (propagators.isNotEmpty) {
          final sorted = List<Map<String, dynamic>>.from(propagators);
          sorted.sort((a, b) => (int.tryParse(b['id']?.toString() ?? '0') ?? 0).compareTo(int.tryParse(a['id']?.toString() ?? '0') ?? 0));
          effectivePropagatorId = int.tryParse(sorted.first['id']?.toString() ?? '') ?? 78;
        } else {
          effectivePropagatorId = 78;
        }
      } catch (_) {
        effectivePropagatorId = 78;
      }
    }

    print('📡 [SHOP WIZARD] Auto-loading categories for Propagator: $effectivePropagatorId, User: $effectiveUserId');
    await ref.read(shopProvider.notifier).loadPropagatorMappingsAndConfigs(
      propagatorId: effectivePropagatorId,
      userId: effectiveUserId,
    );
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
    _mapSearchCtrl.dispose();
    _primaryCategorySearchCtrl.dispose();
    _subCategorySearchCtrl.dispose();
    _brandSearchCtrl.dispose();
    for (final ctrl in _closedDayControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _saveCurrentStepData() {
    final shopNotifier = ref.read(shopProvider.notifier);
    final currentStep = ref.read(shopProvider).wizardStep;

    if (currentStep == 1) {
      shopNotifier.updateStep1(
        storeName: _storeNameCtrl.text,
        customerCareName: _customerCareNameCtrl.text,
        customerCarePhone: _customerCarePhoneCtrl.text,
        altContactName: _altContactNameCtrl.text,
        altPhone: _altPhoneCtrl.text,
      );
    } else if (currentStep == 2) {
      shopNotifier.updateAddress(
        pincode: _pincodeCtrl.text,
        country: _countryCtrl.text,
        stateName: _stateCtrl.text,
        district: _districtCtrl.text,
        taluk: _talukCtrl.text,
        cityVillage: _cityVillageCtrl.text,
        mapSearch: _mapSearchCtrl.text,
      );
    } else if (currentStep == 3) {
      for (final entry in _closedDayControllers.entries) {
        shopNotifier.updateClosedDayReason(entry.key, entry.value.text.trim());
      }
    }
  }

  void _goToNextStep() {
    _saveCurrentStepData();
    final currentStep = ref.read(shopProvider).wizardStep;
    final shopNotifier = ref.read(shopProvider.notifier);

    if (currentStep < 5) {
      print('🔘 [USER CLICK] Shop Wizard: Moving from Step $currentStep -> Step ${currentStep + 1}');
      shopNotifier.setWizardStep(currentStep + 1);
    } else {
      print('🔘 [USER CLICK] Submit Shop Setup Clicked! Starting API submission...');
      _submitShop();
    }
  }

  Future<void> _submitShop() async {
    final shopNotifier = ref.read(shopProvider.notifier);
    final navNotifier = ref.read(navigationProvider.notifier);
    final businessState = ref.read(businessSetupProvider);
    final activeBusiness = ref.read(activeBusinessProvider);
    final selectedId = ref.read(selectedBusinessIdProvider);
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = prefs.getString('user_main_id') ?? prefs.getString('user_id') ?? ApiConstants.defaultUserId;

    // Resolve propagatorId
    int effectivePropagatorId = 0;
    if (businessState.propagatorId != null && businessState.propagatorId! > 0 && businessState.propagatorId != 14) {
      effectivePropagatorId = businessState.propagatorId!;
    } else {
      final selectedParsed = int.tryParse(selectedId.replaceAll('#', ''));
      if (selectedParsed != null && selectedParsed > 0 && selectedParsed != 14) {
        effectivePropagatorId = selectedParsed;
      } else {
        final activeIdParsed = int.tryParse(activeBusiness.id.replaceAll('#', ''));
        if (activeIdParsed != null && activeIdParsed > 0 && activeIdParsed != 14) {
          effectivePropagatorId = activeIdParsed;
        }
      }
    }

    if (effectivePropagatorId <= 0 || effectivePropagatorId == 14) {
      final saved = prefs.getString('propagator_id');
      if (saved != null) {
        final parsed = int.tryParse(saved);
        if (parsed != null && parsed > 0 && parsed != 14) effectivePropagatorId = parsed;
      }
    }

    if (effectivePropagatorId <= 0 || effectivePropagatorId == 14) {
      try {
        final propagators = await ref.read(shopApiServiceProvider).getPropagatorDetails(userId: effectiveUserId);
        if (propagators.isNotEmpty) {
          final sorted = List<Map<String, dynamic>>.from(propagators);
          sorted.sort((a, b) => (int.tryParse(b['id']?.toString() ?? '0') ?? 0).compareTo(int.tryParse(a['id']?.toString() ?? '0') ?? 0));
          effectivePropagatorId = int.tryParse(sorted.first['id']?.toString() ?? '') ?? 78;
        } else {
          effectivePropagatorId = 78;
        }
      } catch (_) {
        effectivePropagatorId = 78;
      }
    }

    final bName = businessState.businessName.isNotEmpty
        ? businessState.businessName
        : (activeBusiness.brandName.isNotEmpty
            ? activeBusiness.brandName
            : 'circuit');

    print('📡 [START API FLOW] Submitting Shop Details: Store="$bName", PropagatorId=$effectivePropagatorId, UserId=$effectiveUserId');
    final success = await shopNotifier.submitShopSetup(
      propagatorId: effectivePropagatorId,
      businessName: bName,
      userId: effectiveUserId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Shop "${_storeNameCtrl.text}" created successfully!'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      navNotifier.setShopSubView(ShopSubView.viewCreatedShop);
    } else {
      final errorMsg = ref.read(shopProvider).errorMessage ??
          'Failed to create shop. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _goToPreviousStep() {
    _saveCurrentStepData();
    final currentStep = ref.read(shopProvider).wizardStep;
    final shopNotifier = ref.read(shopProvider.notifier);
    final navNotifier = ref.read(navigationProvider.notifier);

    if (currentStep > 1) {
      shopNotifier.setWizardStep(currentStep - 1);
    } else {
      navNotifier.setShopSubView(ShopSubView.chooseStoreType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final shopState = ref.watch(shopProvider);
    final businessState = ref.watch(businessSetupProvider);
    final navNotifier = ref.read(navigationProvider.notifier);

    final businessName = businessState.businessName.isNotEmpty
        ? businessState.businessName
        : (businessState.brandName.isNotEmpty ? businessState.brandName : 'circuit point');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Main Modal-like Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x060F172A),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Blue Header Banner
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20,
                        vertical: isMobile ? 14 : 16,
                      ),
                      color: const Color(0xFF1D4ED8),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Create New Shop for $businessName',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 15 : 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Step ${shopState.wizardStep} of 5 — Setup shop details, categories & brand mapping',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: isMobile ? 11 : 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              navNotifier.setShopSubView(ShopSubView.addPlatform);
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),

                    // Horizontal 5-Step Progress Bar
                    _buildStepperBar(shopState.wizardStep, isMobile),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),

                    // Main Content (Left Tips/Graphics + Right Form)
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 14 : 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 750) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLeftSidebarCard(isCompact: true),
                                const SizedBox(height: 20),
                                _buildCurrentStepContent(shopState),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 240,
                                child: _buildLeftSidebarCard(isCompact: false),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildCurrentStepContent(shopState),
                              ),
                            ],
                          );
                        },
                      ),
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

  // Horizontal Stepper Bar
  Widget _buildStepperBar(int currentStep, bool isMobile) {
    const steps = [
      {'num': 1, 'title': 'Shop Details', 'sub': 'Basic Information'},
      {'num': 2, 'title': 'Address Details', 'sub': 'Location & map'},
      {'num': 3, 'title': 'Store Configuration', 'sub': 'Hours & payment'},
      {'num': 4, 'title': 'Business Category', 'sub': 'Sector & categories'},
      {'num': 5, 'title': 'Brand Selection', 'sub': 'Brand mapping'},
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: 12,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(steps.length, (index) {
            final step = steps[index];
            final stepNum = step['num'] as int;
            final isCurrent = stepNum == currentStep;
            final isCompleted = stepNum < currentStep;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _saveCurrentStepData();
                    ref.read(shopProvider.notifier).setWizardStep(stepNum);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent || isCompleted
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFE2E8F0),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : Text(
                                    '$stepNum',
                                    style: TextStyle(
                                      color: isCurrent ? Colors.white : const Color(0xFF64748B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              step['sub'] as String,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 20,
                      height: 1.5,
                      color: isCompleted ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Left Column Card (3D illustration + Quick Tips)
  Widget _buildLeftSidebarCard({required bool isCompact}) {
    return Column(
      children: [
        // 3D Shop Illustration
        Container(
          height: isCompact ? 130 : 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF93C5FD).withValues(alpha: 0.5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative background circles
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 18),
                ),
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.park, color: Color(0xFF059669), size: 16),
                ),
              ),
              // Center Isometric Shop Graphic
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isCompact ? 64 : 80,
                    height: isCompact ? 64 : 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.store_mall_directory_rounded,
                      size: 42,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Storefront Ready',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Quick Tips Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: Color(0xFF2563EB), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Quick Tips',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...[
                'Use your official business name',
                'Enter correct contact details',
                'Make sure your phone number is active',
                'You can add more details in the next steps',
              ].map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // Switch between Step Contents
  Widget _buildCurrentStepContent(ShopState shopState) {
    switch (shopState.wizardStep) {
      case 1:
        return _buildStep1ShopDetails(shopState);
      case 2:
        return _buildStep2AddressDetails(shopState);
      case 3:
        return _buildStep3StoreConfiguration(shopState);
      case 4:
        return _buildStep4BusinessCategory(shopState);
      case 5:
        return _buildStep5BrandSelection(shopState);
      default:
        return _buildStep1ShopDetails(shopState);
    }
  }

  // -------------------------------------------------------------
  // STEP 1: Shop Details (Image 2)
  // -------------------------------------------------------------
  Widget _buildStep1ShopDetails(ShopState shopState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section: Store / Outlet Details
        _buildSectionHeader(
          icon: Icons.store_rounded,
          title: 'Store / Outlet Details *',
          subtitle: 'Enter your store name and select branch model.',
        ),
        const SizedBox(height: 14),

        if (isCompact) ...[
          _buildTextField(
            label: 'Store / Outlet Name *',
            hint: 'e.g. Chennai Adyar Outlet',
            helper: 'Enter official store or shop outlet name',
            controller: _storeNameCtrl,
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 14),
          _buildBranchModelDropdown(shopState),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Store / Outlet Name *',
                  hint: 'e.g. Chennai Adyar Outlet',
                  helper: 'Enter official store or shop outlet name',
                  controller: _storeNameCtrl,
                  icon: Icons.store_outlined,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildBranchModelDropdown(shopState),
              ),
            ],
          ),
        ],

        const SizedBox(height: 22),

        // Section: Store Contact Information
        _buildSectionHeader(
          icon: Icons.person_rounded,
          title: 'Store Contact Information',
          subtitle: 'Provide contact details for your store',
        ),
        const SizedBox(height: 14),

        if (isCompact) ...[
          _buildTextField(
            label: 'Customer Care Contact Name',
            hint: 'e.g. Customer Care Executive',
            helper: 'Enter customer care or support contact name',
            controller: _customerCareNameCtrl,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Customer Care Phone Number *',
            hint: 'e.g. 9876543210',
            helper: 'Enter 10-digit customer care phone number',
            controller: _customerCarePhoneCtrl,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Alternate Contact Name',
            hint: 'e.g. Sales Executive',
            helper: 'Enter alternate or secondary contact name',
            controller: _altContactNameCtrl,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            label: 'Alternate Phone Number',
            hint: 'e.g. 9876543211',
            helper: 'Enter 10-digit alternate phone number',
            controller: _altPhoneCtrl,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Customer Care Contact Name',
                  hint: 'e.g. Customer Care Executive',
                  helper: 'Enter customer care or support contact name',
                  controller: _customerCareNameCtrl,
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  label: 'Customer Care Phone Number *',
                  hint: 'e.g. 9876543210',
                  helper: 'Enter 10-digit customer care phone number',
                  controller: _customerCarePhoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Alternate Contact Name',
                  hint: 'e.g. Sales Executive',
                  helper: 'Enter alternate or secondary contact name',
                  controller: _altContactNameCtrl,
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTextField(
                  label: 'Alternate Phone Number',
                  hint: 'e.g. 9876543211',
                  helper: 'Enter 10-digit alternate phone number',
                  controller: _altPhoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 28),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildBranchModelDropdown(ShopState shopState) {
    const models = [
      'Multi-Branch Franchise',
      'Single Store Outlet',
      'Company Owned (COCO)',
      'Franchise Owned (FOCO)',
      'Dealer / Reseller Store',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Branch Management Model *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: models.contains(shopState.branchModel) ? shopState.branchModel : models.first,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: models.map((m) {
                return DropdownMenuItem<String>(
                  value: m,
                  child: Row(
                    children: [
                      const Icon(Icons.apartment_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          m,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(shopProvider.notifier).updateStep1(branchModel: val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select your branch setup type',
          style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: Address Details (Images 3 & 4)
  // -------------------------------------------------------------
  Widget _buildStep2AddressDetails(ShopState shopState) {
    final isAuto = shopState.addressMode == 'auto';
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pill Segmented Toggle: [Auto Pincode] vs [Map Picker]
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSegmentButton(
                  title: 'Auto Pincode',
                  isSelected: isAuto,
                  onTap: () => ref.read(shopProvider.notifier).setAddressMode('auto'),
                ),
                const SizedBox(width: 4),
                _buildSegmentButton(
                  title: 'Map Picker',
                  isSelected: !isAuto,
                  onTap: () => ref.read(shopProvider.notifier).setAddressMode('map'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        if (isAuto) ...[
          // Auto Pincode Mode (Image 3)
          // Shortcut Pincode + Fetch Details
          const Text(
            'Shortcut Pincode *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _pincodeCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. 600020',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: const Icon(Icons.tag_rounded, size: 16, color: Color(0xFF64748B)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final pin = _pincodeCtrl.text.trim();
                  if (pin.isNotEmpty) {
                    final details = await ref.read(shopApiServiceProvider).getPincodeDetails(pin);
                    if (details != null && mounted) {
                      setState(() {
                        _countryCtrl.text = details['country'] ?? 'India';
                        _stateCtrl.text = details['state'] ?? 'TamilNadu';
                        _districtCtrl.text = details['district'] ?? 'Chennai';
                        _talukCtrl.text = details['taluk'] ?? 'Adyar';
                        _cityVillageCtrl.text = details['cityVillage'] ?? 'Adyar';
                      });
                      ref.read(shopProvider.notifier).updateAddress(
                        pincode: pin,
                        country: _countryCtrl.text,
                        stateName: _stateCtrl.text,
                        district: _districtCtrl.text,
                        taluk: _talukCtrl.text,
                        cityVillage: _cityVillageCtrl.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Details fetched: ${_cityVillageCtrl.text}, ${_districtCtrl.text} ($pin)'),
                          backgroundColor: const Color(0xFF2563EB),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pincode $pin not found, please enter manually'),
                          backgroundColor: const Color(0xFFF59E0B),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.sync_rounded, size: 15, color: Colors.white),
                label: const Text('Fetch Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2x2 Grid of Address Fields
          if (isCompact) ...[
            _buildTextField(label: 'Country *', hint: 'India', controller: _countryCtrl),
            const SizedBox(height: 12),
            _buildTextField(label: 'State *', hint: 'e.g. Tamil Nadu', controller: _stateCtrl),
            const SizedBox(height: 12),
            _buildTextField(label: 'District *', hint: 'e.g. Chennai', controller: _districtCtrl),
            const SizedBox(height: 12),
            _buildTextField(label: 'Taluk *', hint: 'e.g. Guindy', controller: _talukCtrl),
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Country *', hint: 'India', controller: _countryCtrl)),
                const SizedBox(width: 14),
                Expanded(child: _buildTextField(label: 'State *', hint: 'e.g. Tamil Nadu', controller: _stateCtrl)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'District *', hint: 'e.g. Chennai', controller: _districtCtrl)),
                const SizedBox(width: 14),
                Expanded(child: _buildTextField(label: 'Taluk *', hint: 'e.g. Guindy', controller: _talukCtrl)),
              ],
            ),
          ],

          const SizedBox(height: 12),
          _buildTextField(label: 'City / Village *', hint: 'e.g. Adyar', controller: _cityVillageCtrl),
        ] else ...[
          // Map Picker Mode (Image 4)
          const Text(
            'Click on the map area below to pinpoint the store coordinates. The address details will resolve automatically.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // Search Location Bar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _mapSearchCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  final q = _mapSearchCtrl.text.trim();
                  if (q.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pinpoint resolved for: $q'),
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.search_rounded, size: 15, color: Colors.white),
                label: const Text('Search', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Leaflet-style Interactive Map Canvas Container
          _buildMapPickerCanvas(shopState),
        ],

        const SizedBox(height: 28),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0F0F172A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPickerCanvas(ShopState shopState) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map Background Grid & Roads Design
          CustomPaint(
            size: const Size(double.infinity, 260),
            painter: _MapCanvasPainter(),
          ),

          // Top Right: Default (Carto) Dropdown Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Default (Carto)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),

          // Center Pin Marker & Label
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFEF4444),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D0F172A),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${shopState.cityVillage} ${shopState.pincode} Pin Location',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Text(
                        'Interactive Leaflet Map View',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Right Coordinates Pill
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080F172A),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LATITUDE: ${shopState.latitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 1,
                    height: 10,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Text(
                    'LONGITUDE: ${shopState.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
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
  // STEP 3: Store Configuration & Operations (Image 5)
  // -------------------------------------------------------------
  Widget _buildStep3StoreConfiguration(ShopState shopState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(
          icon: Icons.tune_rounded,
          title: 'Store Configuration & Operations',
          subtitle: 'Configure operating hours, weekly schedules, accepted payments, and multilingual support.',
        ),
        const SizedBox(height: 18),

        // Operating Hours (Opening Time & Closing Time)
        if (isCompact) ...[
          _buildTimeCard(
            title: 'Opening Time *',
            time: shopState.openingTime,
            icon: Icons.wb_sunny_outlined,
            onEdit: () => _pickTime(isOpening: true),
          ),
          const SizedBox(height: 12),
          _buildTimeCard(
            title: 'Closing Time *',
            time: shopState.closingTime,
            icon: Icons.nightlight_round_outlined,
            onEdit: () => _pickTime(isOpening: false),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  title: 'Opening Time *',
                  time: shopState.openingTime,
                  icon: Icons.wb_sunny_outlined,
                  onEdit: () => _pickTime(isOpening: true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildTimeCard(
                  title: 'Closing Time *',
                  time: shopState.closingTime,
                  icon: Icons.nightlight_round_outlined,
                  onEdit: () => _pickTime(isOpening: false),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),

        // Working Days Schedule
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF2563EB)),
                      SizedBox(width: 6),
                      Text(
                        'Working Days Schedule',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${shopState.workingDays.length} / 7 Days Selected',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Days Toggle Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ].map((day) {
                  final isSelected = shopState.workingDays.contains(day);
                  return InkWell(
                    onTap: () => ref.read(shopProvider.notifier).toggleWorkingDay(day),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            size: 13,
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Dynamic Closed Days Details (Editable)
              _buildClosedDaysSection(shopState),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Accepted Payment Options & Supported Languages
        if (isCompact) ...[
          _buildPaymentOptionsCard(shopState),
          const SizedBox(height: 14),
          _buildSupportedLanguagesCard(shopState),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPaymentOptionsCard(shopState)),
              const SizedBox(width: 14),
              Expanded(child: _buildSupportedLanguagesCard(shopState)),
            ],
          ),
        ],

        const SizedBox(height: 28),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildClosedDaysSection(ShopState shopState) {
    const allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final closedDays = allDays.where((d) => !shopState.workingDays.contains(d)).toList();

    // If all 7 days are selected, hide Closed Days Details section completely (Matching Screenshot 2)
    if (closedDays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 14),

        // Closed Days Details (Editable) Header
        const Text(
          'Closed Days Details (Editable)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Responsive grid (2 columns on wide screen like web, 1 column on mobile)
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            if (isWide && closedDays.length > 1) {
              final leftDays = <String>[];
              final rightDays = <String>[];
              for (int i = 0; i < closedDays.length; i++) {
                if (i % 2 == 0) {
                  leftDays.add(closedDays[i]);
                } else {
                  rightDays.add(closedDays[i]);
                }
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: leftDays.map((day) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildClosedDayCard(day, shopState),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: rightDays.map((day) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildClosedDayCard(day, shopState),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: closedDays.map((day) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildClosedDayCard(day, shopState),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClosedDayCard(String day, ShopState shopState) {
    final controller = _closedDayControllers[day] ??= TextEditingController(
      text: shopState.closedDayReasons[day] ?? _getDefaultDayReason(day),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: '$day Closing Reason ',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'e.g. $day Weekly Holiday',
                    hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () {
                  final text = controller.text.trim();
                  ref.read(shopProvider.notifier).updateClosedDayReason(day, text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('$day closing reason saved!'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF16A34A),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 14, color: Colors.white),
                label: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDefaultDayReason(String day) {
    if (day == 'Sunday') return 'Weekly Holiday';
    if (day == 'Saturday') return 'Weekend Off';
    if (day == 'Friday') return 'Weekly Off';
    return '';
  }

  Widget _buildTimeCard({
    required String title,
    required String time,
    required IconData icon,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Standard',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 12, color: Colors.white),
                label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickTime({required bool isOpening}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpening
          ? const TimeOfDay(hour: 9, minute: 0)
          : const TimeOfDay(hour: 21, minute: 0),
    );

    if (picked != null) {
      if (!mounted) return;
      final formatted = picked.format(context);
      final shopNotifier = ref.read(shopProvider.notifier);
      if (isOpening) {
        shopNotifier.updateStoreTimes(openingTime: formatted);
      } else {
        shopNotifier.updateStoreTimes(closingTime: formatted);
      }
    }
  }

  Widget _buildPaymentOptionsCard(ShopState shopState) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(Icons.credit_card_rounded, size: 15, color: Color(0xFF059669)),
              SizedBox(width: 6),
              Text(
                'Accepted Payment Options',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: shopState.paymentMethods.map((m) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => ref.read(shopProvider.notifier).removePaymentMethod(m),
                      child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddDialog(
              title: 'Add Payment Method',
              hint: 'e.g. Sodexo, Cryptopay',
              onAdd: (val) => ref.read(shopProvider.notifier).addPaymentMethod(val),
            ),
            icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF2563EB)),
            label: const Text(
              '+ Add Custom Payment Method',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedLanguagesCard(ShopState shopState) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(Icons.translate_rounded, size: 15, color: Color(0xFF7C3AED)),
              SizedBox(width: 6),
              Text(
                'Supported Languages',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: shopState.supportedLanguages.map((l) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B21B6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => ref.read(shopProvider.notifier).removeSupportedLanguage(l),
                      child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFF5B21B6)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddDialog(
              title: 'Add Custom Language',
              hint: 'e.g. French, German',
              onAdd: (val) => ref.read(shopProvider.notifier).addSupportedLanguage(val),
            ),
            icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF2563EB)),
            label: const Text(
              '+ Add Custom Language',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog({
    required String title,
    required String hint,
    required Function(String) onAdd,
  }) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onAdd(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 4: Business Category (Matching Image 2)
  // -------------------------------------------------------------
  Widget _buildStep4BusinessCategory(ShopState shopState) {
    final shopNotifier = ref.read(shopProvider.notifier);

    // Filtered Primary Categories
    final filteredPrimary = shopState.primaryCategories.where((p) {
      if (_primaryCategorySearchQuery.isEmpty) return true;
      final name = p['name']?.toString().toLowerCase() ?? '';
      return name.contains(_primaryCategorySearchQuery.toLowerCase());
    }).toList();

    // Filtered Secondary Categories
    final filteredSecondary = shopState.secondaryCategories.where((s) {
      if (_subCategorySearchQuery.isEmpty) return true;
      final name = s['name']?.toString().toLowerCase() ?? '';
      return name.contains(_subCategorySearchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        _buildSectionHeader(
          icon: Icons.category_rounded,
          title: 'Business Category Classification',
          subtitle: 'Select your Sector, Sub-Sector, and mapped Category visual cards.',
        ),
        const SizedBox(height: 18),

        // 1. Saved Category Mappings Section (Image 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_open_rounded, size: 18, color: Color(0xFF16A34A)),
                const SizedBox(width: 8),
                Text(
                  'Saved Category Mappings (${shopState.savedCategoryMappings.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                _showAddCategoryMappingDialog();
              },
              icon: const Icon(Icons.add_rounded, size: 15, color: Color(0xFF2563EB)),
              label: const Text(
                '+ Add Another Sector / Sub-Sector',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Saved Category Mappings Cards
        if (shopState.savedCategoryMappings.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF64748B)),
                SizedBox(width: 8),
                Text('No saved category mappings yet.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          )
        else
          ...shopState.savedCategoryMappings.map((mapping) {
            final sectorTitle = mapping['sector_title']?.toString() ?? 'Product';
            final sectorName = mapping['sector_name']?.toString() ?? 'Electronics';
            final subSectorName = mapping['sub_sector_name']?.toString() ?? 'Basic Electronics Components';
            final pName = mapping['primary_category_name']?.toString() ?? 'Lights';
            final subCount = mapping['sub_categories_count'] ?? 2;

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x082563EB),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Sector Title Badge + Action Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sectorTitle,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF3B82F6)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'View details',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFF59E0B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Edit mapping',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Delete mapping',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sectorName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.account_tree_outlined, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Text(
                        subSectorName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      pName,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.check, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        '$subCount Sub-Categories',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 20),

        // 2. Primary Category Visual Cards (Multi-Select)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF2563EB)),
                              SizedBox(width: 6),
                              Text(
                                'Primary Category Visual Cards (Multi-Select)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Select primary category cards to load secondary sub-categories.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      height: 36,
                      child: TextField(
                        controller: _primaryCategorySearchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search Primary Categories...',
                          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search, size: 15, color: Color(0xFF94A3B8)),
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
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: filteredPrimary.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No matching primary categories', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ),
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: filteredPrimary.map((p) {
                          final pId = p['id'] as int;
                          final pName = p['name']?.toString() ?? 'Lights';
                          final subLabel = p['sub_options_label']?.toString() ?? '${p['sub_count'] ?? 2} sub-options';
                          final isSelected = shopState.selectedPrimaryCategoryIds.contains(pId);

                          return InkWell(
                            onTap: () => shopNotifier.togglePrimaryCategory(pId),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 190,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          subLabel,
                                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, size: 18, color: Color(0xFF2563EB)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. Secondary Categories Cards (Multi-Select)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.local_offer_rounded, size: 16, color: Color(0xFF059669)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Secondary Categories Cards (Multi-Select)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              '${shopState.selectedSecondaryCategoryIds.length} Selected',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      height: 36,
                      child: TextField(
                        controller: _subCategorySearchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search Sub-Categories...',
                          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search, size: 15, color: Color(0xFF94A3B8)),
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
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: filteredSecondary.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('No matching sub-categories found', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ),
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: filteredSecondary.map((s) {
                          final sId = s['id'] as int;
                          final sName = s['name']?.toString() ?? 'Sub-Category';
                          final isSelected = shopState.selectedSecondaryCategoryIds.contains(sId);

                          return InkWell(
                            onTap: () => shopNotifier.toggleSecondaryCategory(sId),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 190,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.sell_rounded, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sName,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Sub-Category',
                                          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, size: 18, color: Color(0xFF10B981)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        _buildBottomButtons(),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 5: Brand Selection (Matching Image 2)
  // -------------------------------------------------------------
  Widget _buildStep5BrandSelection(ShopState shopState) {
    final shopNotifier = ref.read(shopProvider.notifier);

    // Selected secondary categories
    final activeSubCategories = shopState.secondaryCategories.where((s) {
      final sId = s['id'] as int;
      return shopState.selectedSecondaryCategoryIds.contains(sId);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.branding_watermark_rounded,
          title: 'Brand Mapping & Selection',
          subtitle: 'Select operational brands for each configured sub-category below.',
        ),
        const SizedBox(height: 14),

        if (activeSubCategories.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _brandSearchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search brands (e.g. Assembled, Imported, Make In India, Samsung)...',
                      hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B)),
                  ),
                ),
                if (_brandSearchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => _brandSearchCtrl.clear(),
                    child: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        if (activeSubCategories.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 24,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'No sub-categories selected. Please select at least one sub-category in Step 4.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...activeSubCategories.map((sub) {
            final sName = sub['name']?.toString() ?? 'Sub-Category';
            final brandsList = shopState.brandsBySubCategory[sName] ?? [];
            final selectedBrandIds = shopState.selectedBrandIdsBySubCategory[sName] ?? [];
            final displayBrands = _brandSearchQuery.isEmpty
                ? brandsList
                : brandsList.where((b) {
                    final name = (b['name'] ?? b['brand_name'] ?? '').toString().toLowerCase();
                    return name.contains(_brandSearchQuery.toLowerCase());
                  }).toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x040F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.sell_rounded, size: 16, color: Color(0xFF059669)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Sub-Category', style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${selectedBrandIds.length} Brands Assigned',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Operational Brands:',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),

                  if (displayBrands.isEmpty)
                    Text(
                      _brandSearchQuery.isEmpty ? 'No brands mapped for this sub-category yet.' : 'No brands match "$_brandSearchQuery"',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: displayBrands.map((b) {
                        final bId = int.tryParse(b['id']?.toString() ?? b['brand_id']?.toString() ?? '0') ?? 0;
                        final bName = b['name']?.toString() ?? b['brand_name']?.toString() ?? 'Brand';
                        final isSelected = selectedBrandIds.contains(bId);

                        return InkWell(
                          onTap: () => shopNotifier.toggleBrandForSubCategory(sName, bId),
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  size: 15,
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  bName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }),

        const SizedBox(height: 28),
        _buildBottomButtons(),
      ],
    );
  }

  void _showAddCategoryMappingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Sector / Sub-Sector Mapping', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: const Text(
          'You can add additional sectors, sub-sectors, and category mappings for your business profile.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Common UI Helper Widgets
  // -------------------------------------------------------------
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? helper,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: icon != null ? Icon(icon, size: 16, color: const Color(0xFF64748B)) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomButtons() {
    final shopState = ref.watch(shopProvider);
    final currentStep = shopState.wizardStep;
    final isSubmitting = shopState.isSubmitting;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: isSubmitting ? null : _goToPreviousStep,
          icon: const Icon(Icons.arrow_back_rounded, size: 14),
          label: const Text('Back'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF475569),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: isSubmitting ? null : _goToNextStep,
          iconAlignment: IconAlignment.end,
          icon: isSubmitting
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
          label: Text(
            isSubmitting
                ? 'Creating Shop...'
                : (currentStep == 5 ? 'Submit Shop Setup' : 'Next Step'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw a clean Leaflet-like Carto map grid
class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Water body shape
    final waterPaint = Paint()..color = const Color(0xFFBFDBFE);
    final waterPath = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.6,
        size.height * 0.85,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Major road horizontal
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      roadPaint,
    );

    // Major road vertical
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );

    // Secondary roads
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.2, size.height * 0.65),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.8, size.height * 0.65),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.25),
      secondaryRoadPaint,
    );

    // Green parks
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, 20, size.width * 0.12, 60),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.83, 20, size.width * 0.12, 50),
        const Radius.circular(8),
      ),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
