import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/business_entity_model.dart';
import '../../providers/business_providers.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../widgets/dashboard_footer.dart';

class BusinessCategoryMappingScreen extends ConsumerStatefulWidget {
  const BusinessCategoryMappingScreen({super.key});

  @override
  ConsumerState<BusinessCategoryMappingScreen> createState() =>
      _BusinessCategoryMappingScreenState();
}

class _BusinessCategoryMappingScreenState
    extends ConsumerState<BusinessCategoryMappingScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  int? _activePropagatorId;
  List<Map<String, dynamic>> _configurations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData([int? customPropagatorId]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Refresh business list from API: GET /api/propagator-details?user_id=...
      await ref.read(businessListProvider.notifier).refreshBusinesses();

      final apiService = ref.read(businessApiServiceProvider);

      // 2. Call sector titles API: GET /api/sector-title (as seen in web request)
      try {
        await apiService.getSectorTitles();
      } catch (_) {}

      // 3. Resolve target propagator ID
      int? pId = customPropagatorId;
      if (pId == null || pId <= 0) {
        final activeBiz = ref.read(activeBusinessProvider);
        pId = int.tryParse(activeBiz.id.replaceAll('#', '').trim());
      }
      if (pId == null || pId <= 0) {
        final saved = prefs.getString('propagator_id');
        pId = int.tryParse(saved ?? '');
      }
      if (pId == null || pId <= 0) {
        pId = 78; // Fallback to current propagator ID
      }

      _activePropagatorId = pId;
      await prefs.setString('propagator_id', pId.toString());

      // 4. Fetch configurations from API: GET /api/propagator/{id}/configurations
      final res = await apiService.getPropagatorConfigurations(pId);
      debugPrint('📦 [Propagator Configurations]: $res');

      List<Map<String, dynamic>> configs = [];
      if (res['data'] is Map) {
        final inner = res['data'] as Map;
        if (inner['configurations'] is List) {
          configs = (inner['configurations'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } else if (res['data'] is List) {
        configs = (res['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } else if (res['configurations'] is List) {
        configs = (res['configurations'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      // Fallback: If configurations is empty, query business mappings
      if (configs.isEmpty) {
        final mappingsRes = await apiService.getPropagatorBusinessMappings(pId);
        if (mappingsRes['data'] is Map && (mappingsRes['data'] as Map)['configurations'] is List) {
          configs = ((mappingsRes['data'] as Map)['configurations'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else if (mappingsRes['data'] is List) {
          configs = (mappingsRes['data'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      }

      if (mounted) {
        setState(() {
          _configurations = configs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error loading configurations for business: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCategoryWizard(int pId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('propagator_id', pId.toString());
    ref.read(businessSetupProvider.notifier).setPropagatorId(pId);
    ref.read(navigationProvider.notifier).navigateToStep7();
  }

  void _showDeleteConfirmDialog(BuildContext context, BusinessProfile activeBiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text(
              'Delete Category Mapping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove the category and brand mappings for "${activeBiz.businessName}"?',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _configurations.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category mapping removed.'),
                  backgroundColor: Color(0xFFEF4444),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final activeBiz = ref.watch(activeBusinessProvider);
    final businesses = ref.watch(businessListProvider);

    // Listen to business switches from elsewhere in the app
    ref.listen<String>(selectedBusinessIdProvider, (prev, next) {
      if (prev != next) {
        final pId = int.tryParse(next.replaceAll('#', '').trim());
        _loadData(pId);
      }
    });

    final currentId = _activePropagatorId ??
        int.tryParse(activeBiz.id.replaceAll('#', '').trim()) ??
        78;

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: () => _loadData(currentId),
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
                // 1. Top Header Row (Matches Web Image 2)
                if (isMobile) ...[
                  _buildTitleWithBadge(activeBiz),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage configured sectors, sub-sectors, primary categories, sub-categories, and brand mappings for this specific business.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildSwitchDropdown(businesses, activeBiz, currentId),
                      _buildAddConfigButton(currentId),
                    ],
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleWithBadge(activeBiz),
                            const SizedBox(height: 6),
                            const Text(
                              'Manage configured sectors, sub-sectors, primary categories, sub-categories, and brand mappings for this specific business.',
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          _buildSwitchDropdown(businesses, activeBiz, currentId),
                          const SizedBox(width: 10),
                          _buildAddConfigButton(currentId),
                        ],
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // 2. Main Content: Loading State, Error State, Empty State, or Live Category Mappings Card
                if (_isLoading)
                  _buildLoadingCard()
                else if (_errorMessage != null)
                  _buildErrorCard(_errorMessage!, currentId)
                else if (_configurations.isEmpty)
                  _buildEmptyStateCard(isMobile, activeBiz, currentId)
                else
                  _buildCategoryBrandMappingCard(
                    isMobile: isMobile,
                    activeBiz: activeBiz,
                    currentPropagatorId: currentId,
                    configurations: _configurations,
                  ),

                const SizedBox(height: 36),
                const DashboardFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Title with Store Name Pill Badge (Photo 2)
  Widget _buildTitleWithBadge(BusinessProfile activeBiz) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        const Icon(Icons.hub_outlined, color: Color(0xFF2563EB), size: 22),
        const Text(
          'Propagator Categories & Brand Mapping',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (activeBiz.businessName.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_outlined, size: 13, color: Color(0xFF2563EB)),
                const SizedBox(width: 4),
                Text(
                  activeBiz.businessName,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Switch Dropdown: Switch: dfd (ID: #78) ▾
  Widget _buildSwitchDropdown(
    List<BusinessProfile> businesses,
    BusinessProfile activeBiz,
    int currentPropagatorId,
  ) {
    final list = businesses.isNotEmpty
        ? businesses
        : [
            BusinessProfile(
              id: '#$currentPropagatorId',
              brandName: activeBiz.businessName.isNotEmpty ? activeBiz.businessName : 'dfd',
              tradeName: activeBiz.businessName.isNotEmpty ? activeBiz.businessName : 'dfd',
              businessName: activeBiz.businessName.isNotEmpty ? activeBiz.businessName : 'dfd',
              entityType: EntityType.proprietorship,
              gstPreference: GstPreference.required,
              createdAt: DateTime.now(),
            ),
          ];

    final currentKey = list.any((b) => b.id.replaceAll('#', '').trim() == currentPropagatorId.toString())
        ? list.firstWhere((b) => b.id.replaceAll('#', '').trim() == currentPropagatorId.toString()).id
        : list.first.id;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentKey,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          items: list.map((b) {
            final rawId = b.id.replaceAll('#', '').trim();
            return DropdownMenuItem<String>(
              value: b.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 15, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Switch: ${b.businessName} (ID: #$rawId)',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(selectedBusinessIdProvider.notifier).select(val);
              final newId = int.tryParse(val.replaceAll('#', '').trim());
              if (newId != null && newId > 0) {
                _loadData(newId);
              }
            }
          },
        ),
      ),
    );
  }

  // Top Blue "+ Add Configuration" Button
  Widget _buildAddConfigButton(int currentPropagatorId) {
    return ElevatedButton.icon(
      onPressed: () => _navigateToCategoryWizard(currentPropagatorId),
      icon: const Icon(Icons.add, size: 16, color: Colors.white),
      label: const Text(
        'Add Configuration',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  // Loading Card
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 2.5),
          SizedBox(height: 16),
          Text(
            'Fetching Category & Brand Mappings...',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  // Empty State Card
  Widget _buildEmptyStateCard(
    bool isMobile,
    BusinessProfile activeBiz,
    int currentPropagatorId,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 48 : 64,
      ),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 32,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Categories or Brand Mappings Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'There are currently no active category or brand configurations assigned to ${activeBiz.businessName} (ID: #$currentPropagatorId).',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCategoryWizard(currentPropagatorId),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text(
              'Add First Configuration',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // PHOTO 2: The Exact Category & Brand Mappings Card
  // =========================================================================
  Widget _buildCategoryBrandMappingCard({
    required bool isMobile,
    required BusinessProfile activeBiz,
    required int currentPropagatorId,
    required List<Map<String, dynamic>> configurations,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Header (Grid icon + Title + Subtitle + Action Buttons) ──
          Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.grid_view_rounded, size: 20, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Category & Brand Mappings',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Mapped categories, sub-categories, and brands',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditMappingButton(currentPropagatorId),
                          ),
                          const SizedBox(width: 10),
                          _buildDeleteButton(context, activeBiz),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF2563EB)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Category & Brand Mappings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Mapped categories, sub-categories, and brands',
                                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildEditMappingButton(currentPropagatorId),
                          const SizedBox(width: 10),
                          _buildDeleteButton(context, activeBiz),
                        ],
                      ),
                    ],
                  ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // ── Card Body (Render each Configuration) ──
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final config in configurations)
                  _buildSingleConfigurationBlock(
                    config: config,
                    isMobile: isMobile,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Edit Category Mapping button (Image 2)
  Widget _buildEditMappingButton(int currentPropagatorId) {
    return OutlinedButton.icon(
      onPressed: () => _navigateToCategoryWizard(currentPropagatorId),
      icon: const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF2563EB)),
      label: const Text(
        'Edit Category Mapping',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Delete button (Image 2)
  Widget _buildDeleteButton(BuildContext context, BusinessProfile activeBiz) {
    return OutlinedButton.icon(
      onPressed: () => _showDeleteConfirmDialog(context, activeBiz),
      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
      label: const Text(
        'Delete',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Builds a single configuration group with Sector / Primary Categories / Subcategories / Brands
  Widget _buildSingleConfigurationBlock({
    required Map<String, dynamic> config,
    required bool isMobile,
  }) {
    // 1. Extract Primary Categories
    List<Map<String, dynamic>> primaryCategories = [];

    if (config['primary_categories'] is List && (config['primary_categories'] as List).isNotEmpty) {
      primaryCategories = (config['primary_categories'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else if (config['primary_category_ids'] is List || config['primary_category_id'] != null) {
      // Fallback: construct primary category using name from sub_categories
      final primaryName = config['primary_category_name']?.toString() ?? 'Primary Category';
      final subs = (config['sub_categories'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      primaryCategories.add({
        'name': primaryName,
        'sub_categories': subs,
      });
    }

    // If still empty, check sub_categories directly
    if (primaryCategories.isEmpty && config['sub_categories'] is List) {
      primaryCategories.add({
        'name': 'Primary Category',
        'sub_categories': (config['sub_categories'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final pCat in primaryCategories)
          _buildPrimaryCategoryContainer(
            pCat: pCat,
            config: config,
            isMobile: isMobile,
          ),
      ],
    );
  }

  // Primary Category Container with Blue Top Badge (Image 2)
  Widget _buildPrimaryCategoryContainer({
    required Map<String, dynamic> pCat,
    required Map<String, dynamic> config,
    required bool isMobile,
  }) {
    final catName = pCat['name']?.toString() ?? 'Category';
    List subCategories = [];
    if (pCat['sub_categories'] is List) {
      subCategories = pCat['sub_categories'] as List;
    } else if (config['sub_categories'] is List) {
      subCategories = config['sub_categories'] as List;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue Header Badge: [ :: Primary Category: Lights ] (Exact Match to Photo 2)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_view_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Primary Category: $catName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Sub-Categories list under Primary Category
          if (subCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No sub-categories mapped yet.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              ),
            )
          else
            for (final sub in subCategories)
              _buildSubCategoryRow(
                sub: Map<String, dynamic>.from(sub as Map),
                config: config,
                isMobile: isMobile,
              ),
        ],
      ),
    );
  }

  // Sub-Category Row: [ 🏷️ LED Spotlight ] -> Mapped Brands (3): [ 🎖️ Assembled ] [ 🎖️ Imported ] [ 🎖️ Make In India ]
  Widget _buildSubCategoryRow({
    required Map<String, dynamic> sub,
    required Map<String, dynamic> config,
    required bool isMobile,
  }) {
    final subName = sub['name']?.toString() ?? sub['sub_category_name']?.toString() ?? 'Sub Category';
    final List<String> brandNames = _extractBrandsForSubCategory(sub, config);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mint Sub-Category Tag
                _buildSubCategoryTag(subName),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 15, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Text(
                      'Mapped Brands (${brandNames.length}):',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBrandBadgesList(brandNames),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mint Sub-Category Tag
                _buildSubCategoryTag(subName),
                const SizedBox(width: 14),

                // Arrow
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 14),

                // Label: Mapped Brands (X):
                Text(
                  'Mapped Brands (${brandNames.length}):',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 12),

                // Amber Brand Badges
                Expanded(
                  child: _buildBrandBadgesList(brandNames),
                ),
              ],
            ),
    );
  }

  // Mint Green Tag for Sub-Category: [ 🏷️ LED Spotlight ]
  Widget _buildSubCategoryTag(String subName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell_outlined, size: 14, color: Color(0xFF059669)),
          const SizedBox(width: 6),
          Text(
            subName,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF065F46),
            ),
          ),
        ],
      ),
    );
  }

  // Amber Badges for Brands: [ 🎖️ Assembled ] [ 🎖️ Imported ] [ 🎖️ Make In India ]
  Widget _buildBrandBadgesList(List<String> brandNames) {
    if (brandNames.isEmpty) {
      return const Text(
        'No brands mapped',
        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final brand in brandNames)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 5),
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Error Card with Retry Button
  Widget _buildErrorCard(String error, int currentId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 36),
          const SizedBox(height: 12),
          const Text(
            'Failed to Load Category Configurations',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadData(currentId),
            icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
            label: const Text('Try Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to extract brands for a specific sub-category
  List<String> _extractBrandsForSubCategory(
    Map<String, dynamic> sub,
    Map<String, dynamic> config,
  ) {
    final List<String> result = [];

    // 1. Check if sub-category object directly contains 'brand_names'
    if (sub['brand_names'] is List) {
      for (final b in sub['brand_names'] as List) {
        if (b != null && b.toString().trim().isNotEmpty) {
          result.add(b.toString().trim());
        }
      }
    }

    // 2. Check if sub-category object contains 'brands' list of objects or strings
    if (result.isEmpty && sub['brands'] is List) {
      for (final b in sub['brands'] as List) {
        if (b is Map && b['name'] != null) {
          result.add(b['name'].toString().trim());
        } else if (b != null && b.toString().trim().isNotEmpty) {
          result.add(b.toString().trim());
        }
      }
    }

    final subId = sub['id']?.toString() ?? sub['secondary_id']?.toString() ?? '';
    final subName = sub['name']?.toString() ?? sub['sub_category_name']?.toString() ?? '';

    // 3. Fallback: check config['brands'] map by ID or name
    if (result.isEmpty && config['brands'] is Map) {
      final brandsMap = config['brands'] as Map;

      final listById = brandsMap[subId];
      final listByName = brandsMap[subName];

      if (listById is List && listById.isNotEmpty) {
        for (final b in listById) {
          if (b != null && b.toString().trim().isNotEmpty) {
            result.add(b.toString().trim());
          }
        }
      } else if (listByName is List && listByName.isNotEmpty) {
        for (final b in listByName) {
          if (b != null && b.toString().trim().isNotEmpty) {
            result.add(b.toString().trim());
          }
        }
      }
    }

    // 4. Fallback: check config['mappings'] for this sub_category_id
    if (result.isEmpty && config['mappings'] is List) {
      for (final m in config['mappings'] as List) {
        if (m is Map) {
          final mSubId = m['sub_category_id']?.toString();
          if (mSubId == subId && m['brand_names'] is List) {
            for (final b in m['brand_names'] as List) {
              if (b != null && b.toString().trim().isNotEmpty) {
                result.add(b.toString().trim());
              }
            }
          }
        }
      }
    }

    // 5. Fallback: check config['brand_names']
    if (result.isEmpty && config['brand_names'] is List) {
      for (final b in config['brand_names'] as List) {
        if (b != null && b.toString().trim().isNotEmpty) {
          result.add(b.toString().trim());
        }
      }
    }

    return result.toSet().toList(); // Deduplicate
  }
}
