import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/models/nav_state.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../data/models/business_entity_model.dart';
import '../../providers/business_providers.dart';
import '../widgets/dashboard_footer.dart';
import '../../../../core/network/api_constants.dart';
import '../../../create_shop/providers/shop_providers.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({super.key});

  @override
  ConsumerState<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  int _selectedTabIndex = 0;

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _pincodeController;
  late TextEditingController _cityController;
  late TextEditingController _districtController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;

  // Tab 1 (Contact) controllers
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;

  // Tab 3 (Bank) controllers
  late TextEditingController _bankNameController;
  late TextEditingController _branchController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;

  String? _loadedBizId;
  String? _lastUpdatedHash;
  String? _lastFetchedBizId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      var selectedId = ref.read(selectedBusinessIdProvider);
      if (selectedId.isEmpty) {
        selectedId = prefs.getString('propagator_id') ?? '';
      }
      final pId = int.tryParse(selectedId.replaceAll('#', ''));
      if (pId != null && pId > 0) {
        await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
        if (mounted) {
          _populateControllers(ref.read(activeBusinessProvider), force: true);
        }
      }
    });
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _pincodeController = TextEditingController();
    _cityController = TextEditingController();
    _districtController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _addressController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();

    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();

    _bankNameController = TextEditingController();
    _branchController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscController = TextEditingController();
  }

  void _populateControllers(BusinessProfile biz, {bool force = false}) {
    final currentHash = '${biz.id}_${biz.businessName}_${biz.pincode}_${biz.city}_${biz.district}_${biz.stateName}_${biz.country}_${biz.fullAddress}_${biz.latitude}_${biz.longitude}_${biz.phone}_${biz.email}_${biz.website}_${biz.bankName}_${biz.branchName}_${biz.accountNumber}_${biz.ifscCode}';
    if (!force && _loadedBizId == biz.id && _lastUpdatedHash == currentHash) return;
    _loadedBizId = biz.id;
    _lastUpdatedHash = currentHash;

    _nameController.text = biz.businessName;
    _pincodeController.text = biz.pincode;
    _cityController.text = biz.city;
    _districtController.text = biz.district;
    _stateController.text = biz.stateName;
    _countryController.text = biz.country;
    _addressController.text = biz.fullAddress;
    _latController.text = biz.latitude;
    _lngController.text = biz.longitude;

    _phoneController.text = biz.phone;
    _emailController.text = biz.email;
    _websiteController.text = biz.website;

    _bankNameController.text = biz.bankName;
    _branchController.text = biz.branchName;
    _accountNumberController.text = biz.accountNumber;
    _ifscController.text = biz.ifscCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pincodeController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();

    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();

    _bankNameController.dispose();
    _branchController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _fetchPincodeDetails() {
    final pin = _pincodeController.text.trim();
    if (pin.isEmpty) return;

    // Simulated pincode autofill
    if (pin.startsWith('600')) {
      _cityController.text = 'Chennai';
      _districtController.text = 'Chennai';
      _stateController.text = 'Tamil Nadu';
      _countryController.text = 'India';
      _latController.text = '13.0827';
      _lngController.text = '80.2707';
    } else if (pin.startsWith('560')) {
      _cityController.text = 'Bengaluru';
      _districtController.text = 'Bengaluru Urban';
      _stateController.text = 'Karnataka';
      _countryController.text = 'India';
      _latController.text = '12.9716';
      _lngController.text = '77.5946';
    } else {
      _cityController.text = 'Local City';
      _districtController.text = 'Local District';
      _stateController.text = 'Tamil Nadu';
      _countryController.text = 'India';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pincode details fetched for $pin'),
        backgroundColor: const Color(0xFF2563EB),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  Future<void> _saveChanges(BusinessProfile activeBiz) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      int pId = int.tryParse(activeBiz.id.replaceAll('#', '')) ?? 0;
      if (pId == 0) {
        final prefs = await SharedPreferences.getInstance();
        pId = int.tryParse(prefs.getString('propagator_id') ?? '') ?? 0;
      }

      if (pId > 0) {
        final apiService = ref.read(businessApiServiceProvider);
        final lat = double.tryParse(_latController.text.trim()) ?? 13.0827;
        final lng = double.tryParse(_lngController.text.trim()) ?? 80.2707;

        // 1. Save Address API (Calls PUT /propagator-address/update/:id to match Web)
        final res = await apiService.saveOrUpdatePropagatorAddress(
          addressId: activeBiz.addressId,
          propagatorId: pId,
          pincode: _pincodeController.text.trim().isNotEmpty
              ? _pincodeController.text.trim()
              : '600001',
          fullAddress: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : 'Official Business Address',
          cityTaluk: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : 'Chennai',
          district: _districtController.text.trim().isNotEmpty
              ? _districtController.text.trim()
              : 'Chennai',
          state: _stateController.text.trim().isNotEmpty
              ? _stateController.text.trim()
              : 'Tamil Nadu',
          country: _countryController.text.trim().isNotEmpty
              ? _countryController.text.trim()
              : 'India',
          latitude: lat,
          longitude: lng,
        );
        debugPrint('✅ [Propagator Address Saved/Updated]: $res');

        // 2. Save Contact API if contact info present
        if (_phoneController.text.trim().isNotEmpty || _emailController.text.trim().isNotEmpty) {
          try {
            final contactRes = await apiService.saveOrUpdatePropagatorContact(
              contactId: activeBiz.contactId,
              propagatorId: pId,
              primaryEmail: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : activeBiz.email,
              phoneNumber: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : activeBiz.phone,
              companyWebsiteUrl: _websiteController.text.trim(),
            );
            debugPrint('✅ [Propagator Contact Saved/Updated]: $contactRes');
          } catch (e) {
            debugPrint('⚠️ Error updating contact: $e');
          }
        }

        // 3. Save Bank API if bank info present
        if (_accountNumberController.text.trim().isNotEmpty || _bankNameController.text.trim().isNotEmpty) {
          try {
            final bankRes = await apiService.createPropagatorBankDetails(
              propagatorId: pId,
              accountHolderName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : activeBiz.businessName,
              bankName: _bankNameController.text.trim().isNotEmpty
                  ? _bankNameController.text.trim()
                  : 'Bank',
              branchName: _branchController.text.trim().isNotEmpty
                  ? _branchController.text.trim()
                  : 'Branch',
              accountNumber: _accountNumberController.text.trim(),
              accountType: activeBiz.accountType.isNotEmpty ? activeBiz.accountType : 'Current',
              ifscCode: _ifscController.text.trim().isNotEmpty
                  ? _ifscController.text.trim()
                  : 'IFSC0001',
            );
            debugPrint('✅ [Propagator Bank Created/Updated]: $bankRes');
          } catch (e) {
            debugPrint('⚠️ Error updating bank: $e');
          }
        }
      }

      final updatedBiz = activeBiz.copyWith(
        businessName: _nameController.text.trim(),
        brandName: _nameController.text.trim(),
        pincode: _pincodeController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        stateName: _stateController.text.trim(),
        country: _countryController.text.trim(),
        fullAddress: _addressController.text.trim(),
        latitude: _latController.text.trim(),
        longitude: _lngController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        website: _websiteController.text.trim(),
        bankName: _bankNameController.text.trim(),
        branchName: _branchController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim(),
      );

      ref.read(businessListProvider.notifier).updateBusiness(updatedBiz);

      if (pId > 0) {
        await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
        if (mounted) {
          _populateControllers(ref.read(activeBusinessProvider), force: true);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propagator address updated successfully!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );

        ref.read(navigationProvider.notifier).navigateToBusinessDetails(
              mode: BusinessDetailsMode.viewProfile,
            );
      }
    } catch (e) {
      debugPrint('⚠️ Error updating address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update address: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final navNotifier = ref.read(navigationProvider.notifier);
    final activeBiz = ref.watch(activeBusinessProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final isEditMode = navState.businessDetailsMode == BusinessDetailsMode.editProfile;
    if (!isEditMode) {
      _populateControllers(activeBiz);
    }

    if (_lastFetchedBizId != activeBiz.id) {
      _lastFetchedBizId = activeBiz.id;
      final pId = int.tryParse(activeBiz.id.replaceAll('#', ''));
      if (pId != null && pId > 0) {
        Future.microtask(() async {
          await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
          if (mounted) {
            _populateControllers(ref.read(activeBusinessProvider), force: true);
            setState(() {});
          }
        });
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        final pId = int.tryParse(activeBiz.id.replaceAll('#', ''));
        if (pId != null && pId > 0) {
          await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
          if (mounted) {
            _populateControllers(ref.read(activeBusinessProvider), force: true);
            setState(() {});
          }
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 28,
          vertical: isMobile ? 16 : 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (navState.businessDetailsMode == BusinessDetailsMode.overview)
                  _buildOverviewView(context, isMobile, navNotifier, activeBiz)
                else
                  _buildProfileView(context, isMobile, navNotifier, activeBiz,
                      isEditMode: navState.businessDetailsMode == BusinessDetailsMode.editProfile),
                const SizedBox(height: 36),
                const DashboardFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PHOTO 2: Overview Card View
  // ==========================================
  Widget _buildOverviewView(
    BuildContext context,
    bool isMobile,
    NavigationNotifier navNotifier,
    BusinessProfile biz,
  ) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Main Business Card
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C0F172A),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: isMobile
                  ? Column(
                      children: [
                        _buildCardLeftSection(biz, isMobile: true),
                        _buildCardRightSection(biz, isMobile: true),
                      ],
                    )
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 250,
                            child: _buildCardLeftSection(biz, isMobile: false),
                          ),
                          Expanded(
                            child: _buildCardRightSection(biz, isMobile: false),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 4 Action Buttons in a Row below Card (Photo 2)
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                // 1. View Profile Button
                ElevatedButton.icon(
                  onPressed: () async {
                    final pId = int.tryParse(biz.id.replaceAll('#', ''));
                    if (pId != null && pId > 0) {
                      await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
                      if (mounted) {
                        _populateControllers(ref.read(activeBusinessProvider), force: true);
                      }
                    }
                    navNotifier.navigateToBusinessDetails(mode: BusinessDetailsMode.viewProfile);
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.white),
                  label: const Text(
                    'View Profile',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),

                // 2. View Category Button (Web Match - Image 1)
                ElevatedButton.icon(
                  onPressed: () async {
                    final pId = int.tryParse(biz.id.replaceAll('#', '').trim());
                    if (pId != null && pId > 0) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('propagator_id', pId.toString());
                      ref.read(businessSetupProvider.notifier).setPropagatorId(pId);
                      ref.read(selectedBusinessIdProvider.notifier).select(biz.id);
                    }
                    navNotifier.navigateToBusinessCategory();
                  },
                  icon: const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF1E293B)),
                  label: const Text(
                    'View Category',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),

                // 3. View Store Button (Matching Photo 2)
                ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    var selectedId = ref.read(selectedBusinessIdProvider);
                    if (selectedId.isEmpty || selectedId == '14') {
                      selectedId = biz.id.isNotEmpty ? biz.id : (prefs.getString('propagator_id') ?? '78');
                    }
                    final pId = int.tryParse(selectedId.replaceAll('#', '')) ?? 78;
                    await prefs.setString('propagator_id', pId.toString());
                    ref.read(businessSetupProvider.notifier).setPropagatorId(pId);
                    final effectiveUserId = prefs.getString('user_main_id') ?? prefs.getString('user_id') ?? ApiConstants.defaultUserId;
                    ref.read(shopProvider.notifier).fetchShopsFromApi(
                      propagatorId: pId,
                      userId: effectiveUserId,
                    );
                    navNotifier.setShopSubView(ShopSubView.viewCreatedShop);
                  },
                  icon: const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF1E293B)),
                  label: const Text(
                    'View Store',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),

                // 4. Add Platform Button (Blue Button - Image 1)
                ElevatedButton.icon(
                  onPressed: () {
                    navNotifier.setShopSubView(ShopSubView.addPlatform);
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Add Platform',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Left Navy Section of Photo 2 Card
  Widget _buildCardLeftSection(BusinessProfile biz, {required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0F1E36),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Avatar 'S'
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  biz.businessName.isNotEmpty ? biz.businessName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                biz.businessName.isNotEmpty ? biz.businessName : 'Sabari',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                biz.businessType,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Storefront icon outline
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Icon(
                  Icons.store_mall_directory_outlined,
                  size: 38,
                  color: Color(0xFF60A5FA),
                ),
              ),
              const SizedBox(height: 20),

              // Established and Team Size row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTABLISHED',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          biz.establishmentYear,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TEAM SIZE',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          biz.employeeCount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // VERIFIED badge at bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF60A5FA), size: 14),
                SizedBox(width: 6),
                Text(
                  'VERIFIED',
                  style: TextStyle(
                    color: Color(0xFF93C5FD),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Right White Section of Photo 2 Card
  Widget _buildCardRightSection(BusinessProfile biz, {required bool isMobile}) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Title
          Text(
            biz.businessName.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Proprietorship / Propagator',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // Badges: Proprietorship & Startup
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPillTag(
                icon: Icons.folder_outlined,
                label: 'Proprietorship / Propagator',
                bgColor: const Color(0xFFEFF6FF),
                textColor: const Color(0xFF2563EB),
                borderColor: const Color(0xFFBFDBFE),
              ),
              _buildPillTag(
                icon: Icons.rocket_launch_outlined,
                label: biz.tier,
                bgColor: const Color(0xFFEFF6FF),
                textColor: const Color(0xFF2563EB),
                borderColor: const Color(0xFFBFDBFE),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 18),

          // Contact details grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.phone_outlined,
                  label: 'PHONE',
                  value: biz.phone,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.email_outlined,
                  label: 'EMAIL',
                  value: biz.email,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoItem(
            icon: Icons.location_on_outlined,
            label: 'ADDRESS',
            value: '${biz.city}, ${biz.stateName}',
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 18),

          // Verification Row: GST & UDYAM
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  const Text(
                    'GST VERIFIED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    biz.gstNumber,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.military_tech_outlined, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  const Text(
                    'UDYAM MSME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    biz.udyamNumber,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PHOTO 3 & 4: Profile View / Edit View
  // ==========================================
  Widget _buildProfileView(
    BuildContext context,
    bool isMobile,
    NavigationNotifier navNotifier,
    BusinessProfile biz, {
    required bool isEditMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top "<- Back to List" link
        InkWell(
          onTap: () {
            navNotifier.navigateToBusinessDetails(mode: BusinessDetailsMode.overview);
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.arrow_back, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 6),
                Text(
                  'Back to List',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Header with Title & Action Buttons
        if (isMobile) ...[
          Text(
            'Business Details - ${biz.businessName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'View and update your registered business profile details.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildTopActionButtons(navNotifier, biz, isEditMode),
          ),
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Details - ${biz.businessName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'View and update your registered business profile details.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Row(
                children: _buildTopActionButtons(navNotifier, biz, isEditMode),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Card Container with 6 Tabs
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_outlined, color: Color(0xFF2563EB), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Business Address & Location Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'View and manage registered business address, pincode, city, and GPS location coordinates.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Horizontal Scrollable Tabs
              _buildHorizontalTabs(isMobile),

              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Tab Content Area
              Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: _buildActiveTabContent(isMobile, biz, isEditMode),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTopActionButtons(
    NavigationNotifier navNotifier,
    BusinessProfile biz,
    bool isEditMode,
  ) {
    if (isEditMode) {
      // Photo 4 Buttons: [ Cancel ] [ Save Changes ] [ Add More Business ]
      return [
        OutlinedButton.icon(
          onPressed: () {
            // Revert changes
            _populateControllers(biz);
            navNotifier.navigateToBusinessDetails(mode: BusinessDetailsMode.viewProfile);
          },
          icon: const Icon(Icons.close, size: 15, color: Color(0xFF64748B)),
          label: const Text(
            'Cancel',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : () => _saveChanges(biz),
          icon: _isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, size: 15, color: Colors.white),
          label: Text(
            _isSaving ? 'Saving...' : 'Save Changes',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            navNotifier.setNavItem(NavItem.startBusiness);
            navNotifier.navigateToSetupBasic();
          },
          icon: const Icon(Icons.rocket_launch_outlined, size: 15, color: Color(0xFF2563EB)),
          label: const Text(
            'Add More Business',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            backgroundColor: const Color(0xFFEFF6FF),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ];
    } else {
      // Photo 3 Buttons: [ Edit Profile ] [ Add More Business ]
      return [
        OutlinedButton.icon(
          onPressed: () async {
            final pId = int.tryParse(biz.id.replaceAll('#', ''));
            if (pId != null && pId > 0) {
              await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
              if (mounted) {
                _populateControllers(ref.read(activeBusinessProvider), force: true);
              }
            } else {
              _populateControllers(biz, force: true);
            }
            navNotifier.navigateToBusinessDetails(mode: BusinessDetailsMode.editProfile);
          },
          icon: const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF2563EB)),
          label: const Text(
            'Edit Profile',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final pId = int.tryParse(biz.id.replaceAll('#', ''));
            if (pId != null && pId > 0) {
              await ref.read(businessListProvider.notifier).loadBusinessOnLogin(pId);
              if (mounted) {
                _populateControllers(ref.read(activeBusinessProvider), force: true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Synced with live server data!'),
                    backgroundColor: Color(0xFF2563EB),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.sync, size: 15, color: Color(0xFF475569)),
          label: const Text(
            'Sync',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            navNotifier.setNavItem(NavItem.startBusiness);
            navNotifier.navigateToSetupBasic();
          },
          icon: const Icon(Icons.rocket_launch_outlined, size: 15, color: Color(0xFF2563EB)),
          label: const Text(
            'Add More Business',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            backgroundColor: const Color(0xFFEFF6FF),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ];
    }
  }

  Widget _buildHorizontalTabs(bool isMobile) {
    final tabs = [
      {'icon': Icons.location_on_outlined, 'title': 'Address & Location'},
      {'icon': Icons.people_outline, 'title': 'Contact & Branding'},
      {'icon': Icons.description_outlined, 'title': 'Document Uploads'},
      {'icon': Icons.account_balance_outlined, 'title': 'Bank Account'},
      {'icon': Icons.corporate_fare_outlined, 'title': 'Company Tier'},
      {'icon': Icons.work_outline, 'title': 'Business Type'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _selectedTabIndex == idx;
          final tab = tabs[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = idx),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFBFDBFE) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 15,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabContent(bool isMobile, BusinessProfile biz, bool isEditMode) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAddressLocationTab(isMobile, isEditMode);
      case 1:
        return _buildContactBrandingTab(isMobile, biz, isEditMode);
      case 2:
        return _buildDocumentUploadsTab(isMobile, biz);
      case 3:
        return _buildBankAccountTab(isMobile, biz, isEditMode);
      case 4:
        return _buildCompanyTierTab(isMobile, biz);
      case 5:
        return _buildBusinessTypeTab(isMobile, biz);
      default:
        return _buildAddressLocationTab(isMobile, isEditMode);
    }
  }

  // Tab 0: Address & Location (Photos 3 and 4)
  Widget _buildAddressLocationTab(bool isMobile, bool isEditMode) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Business Address & Location Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter the official business address and location details.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 1: Business Name, Pincode (with Fetch in edit mode), City / Taluk
          if (isMobile) ...[
            _buildField(
              label: 'Business Name *',
              helper: 'Registered enterprise legal title.',
              icon: Icons.storefront_outlined,
              controller: _nameController,
              isEditMode: isEditMode,
            ),
            const SizedBox(height: 14),
            _buildPincodeField(isEditMode),
            const SizedBox(height: 14),
            _buildField(
              label: 'City / Taluk *',
              helper: 'Local municipality / city zone.',
              icon: Icons.bar_chart_outlined,
              controller: _cityController,
              isEditMode: isEditMode,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Business Name *',
                    helper: 'Registered enterprise legal title.',
                    icon: Icons.storefront_outlined,
                    controller: _nameController,
                    isEditMode: isEditMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPincodeField(isEditMode),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: 'City / Taluk *',
                    helper: 'Local municipality / city zone.',
                    icon: Icons.bar_chart_outlined,
                    controller: _cityController,
                    isEditMode: isEditMode,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Row 2: District, State, Country
          if (isMobile) ...[
            _buildField(
              label: 'District *',
              helper: 'Administrative revenue district.',
              icon: Icons.apartment_outlined,
              controller: _districtController,
              isEditMode: isEditMode,
            ),
            const SizedBox(height: 14),
            _buildField(
              label: 'State *',
              helper: 'State jurisdiction territory.',
              icon: Icons.account_balance_outlined,
              controller: _stateController,
              isEditMode: isEditMode,
            ),
            const SizedBox(height: 14),
            _buildField(
              label: 'Country *',
              helper: 'Country of operation.',
              icon: Icons.public_outlined,
              controller: _countryController,
              isEditMode: isEditMode,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(
                    label: 'District *',
                    helper: 'Administrative revenue district.',
                    icon: Icons.apartment_outlined,
                    controller: _districtController,
                    isEditMode: isEditMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: 'State *',
                    helper: 'State jurisdiction territory.',
                    icon: Icons.account_balance_outlined,
                    controller: _stateController,
                    isEditMode: isEditMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: 'Country *',
                    helper: 'Country of operation.',
                    icon: Icons.public_outlined,
                    controller: _countryController,
                    isEditMode: isEditMode,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Row 3: Full Building / Street Address (multi-line)
          _buildField(
            label: 'Full Building / Street Address *',
            helper: 'Complete door number, street, landmark, and floor.',
            icon: Icons.location_on_outlined,
            controller: _addressController,
            isEditMode: isEditMode,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Row 4: Latitude & Longitude
          if (isMobile) ...[
            _buildField(
              label: 'Latitude (° N) *',
              helper: 'GPS Latitude coordinate (e.g. 13.0827).',
              icon: Icons.my_location_outlined,
              controller: _latController,
              isEditMode: isEditMode,
            ),
            const SizedBox(height: 14),
            _buildField(
              label: 'Longitude (° E) *',
              helper: 'GPS Longitude coordinate (e.g. 80.2707).',
              icon: Icons.my_location_outlined,
              controller: _lngController,
              isEditMode: isEditMode,
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildField(
                    label: 'Latitude (° N) *',
                    helper: 'GPS Latitude coordinate (e.g. 13.0827).',
                    icon: Icons.my_location_outlined,
                    controller: _latController,
                    isEditMode: isEditMode,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    label: 'Longitude (° E) *',
                    helper: 'GPS Longitude coordinate (e.g. 80.2707).',
                    icon: Icons.my_location_outlined,
                    controller: _lngController,
                    isEditMode: isEditMode,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String helper,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditMode,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isEditMode ? Colors.white : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEditMode ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
            ),
          ),
          child: TextFormField(
            controller: controller,
            enabled: isEditMode,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              prefixIcon: Icon(icon, size: 16, color: const Color(0xFF64748B)),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildPincodeField(bool isEditMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pincode *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isEditMode ? Colors.white : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEditMode ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: TextFormField(
                  controller: _pincodeController,
                  enabled: isEditMode,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    prefixIcon: Icon(Icons.pin_drop_outlined, size: 16, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (isEditMode) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _fetchPincodeDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text(
                  'Fetch',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '6-digit postal code (Mandatory).',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  // Tab 1: Contact & Branding
  Widget _buildContactBrandingTab(bool isMobile, BusinessProfile biz, bool isEditMode) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'Phone Number *',
            helper: 'Registered official contact phone.',
            icon: Icons.phone_outlined,
            controller: _phoneController,
            isEditMode: isEditMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'Primary Email *',
            helper: 'Official email address for communication.',
            icon: Icons.email_outlined,
            controller: _emailController,
            isEditMode: isEditMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'Website URL',
            helper: 'Official company website / landing page.',
            icon: Icons.language_outlined,
            controller: _websiteController,
            isEditMode: isEditMode,
          ),
        ],
      ),
    );
  }

  // Tab 2: Document Uploads
  Widget _buildDocumentUploadsTab(bool isMobile, BusinessProfile biz) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocItem('GST Registration Certificate', biz.gstNumber, true),
          const SizedBox(height: 12),
          _buildDocItem('Udyam MSME Certificate', biz.udyamNumber, true),
          const SizedBox(height: 12),
          _buildDocItem('CIN Document', biz.cinNumber.isNotEmpty ? biz.cinNumber : 'Not Provided', biz.cinNumber.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildDocItem(String title, String number, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_outline : Icons.pending_outlined,
            color: isVerified ? const Color(0xFF10B981) : const Color(0xFF64748B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  number,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isVerified ? 'VERIFIED' : 'PENDING',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isVerified ? const Color(0xFF059669) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Bank Account Details
  Widget _buildBankAccountTab(bool isMobile, BusinessProfile biz, bool isEditMode) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'Bank Name *',
            helper: 'Official banking partner.',
            icon: Icons.account_balance_outlined,
            controller: _bankNameController,
            isEditMode: isEditMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'Branch Name *',
            helper: 'Local home branch location.',
            icon: Icons.location_city_outlined,
            controller: _branchController,
            isEditMode: isEditMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'Account Number *',
            helper: 'Operational current/savings account number.',
            icon: Icons.numbers_outlined,
            controller: _accountNumberController,
            isEditMode: isEditMode,
          ),
          const SizedBox(height: 14),
          _buildField(
            label: 'IFSC Code *',
            helper: '11-character bank branch identifier.',
            icon: Icons.tag_outlined,
            controller: _ifscController,
            isEditMode: isEditMode,
          ),
        ],
      ),
    );
  }

  // Tab 4: Company Tier
  Widget _buildCompanyTierTab(bool isMobile, BusinessProfile biz) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStaticInfoRow('Selected Tier', biz.tier),
          const SizedBox(height: 10),
          _buildStaticInfoRow('Establishment Year', biz.establishmentYear),
          const SizedBox(height: 10),
          _buildStaticInfoRow('Employee Count', biz.employeeCount),
          const SizedBox(height: 10),
          _buildStaticInfoRow('Turnover Range', biz.turnoverRange),
        ],
      ),
    );
  }

  // Tab 5: Business Type
  Widget _buildBusinessTypeTab(bool isMobile, BusinessProfile biz) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStaticInfoRow('Entity Type', biz.entityType.label),
          const SizedBox(height: 10),
          _buildStaticInfoRow('Business Activity', biz.businessType),
          const SizedBox(height: 10),
          _buildStaticInfoRow('Registration Status', biz.registrationStatus),
        ],
      ),
    );
  }

  Widget _buildStaticInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
      ],
    );
  }
}
