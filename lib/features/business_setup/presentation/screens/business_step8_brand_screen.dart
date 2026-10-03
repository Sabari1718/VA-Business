import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class MappedSubCategoryItem {
  final int id;
  final String name;
  final int primaryId;
  final String primaryName;

  MappedSubCategoryItem({
    required this.id,
    required this.name,
    required this.primaryId,
    required this.primaryName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MappedSubCategoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class BusinessStep8BrandScreen extends ConsumerStatefulWidget {
  const BusinessStep8BrandScreen({super.key});

  @override
  ConsumerState<BusinessStep8BrandScreen> createState() =>
      _BusinessStep8BrandScreenState();
}

class _BusinessStep8BrandScreenState
    extends ConsumerState<BusinessStep8BrandScreen> {
  final TextEditingController _brandSearchController = TextEditingController();
  String _brandSearchQuery = '';

  List<MappedSubCategoryItem> _availableSubCategories = [];
  MappedSubCategoryItem? _activeSubCategory;

  List<Map<String, dynamic>> _availableBrands = [];
  bool _isLoadingBrands = false;
  bool _isLoadingCategories = false;

  // Cache fetched brands by sub-category ID
  final Map<int, List<Map<String, dynamic>>> _brandsCache = {};

  // Selected brand IDs and names mapped by sub-category ID
  final Map<int, Set<int>> _selectedBrandIdsBySubCategory = {};
  final Map<int, Map<int, String>> _selectedBrandNamesBySubCategory = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initializeSubCategoriesAndBrands());
  }

  @override
  void dispose() {
    _brandSearchController.dispose();
    super.dispose();
  }

  Future<void> _initializeSubCategoriesAndBrands() async {
    setState(() => _isLoadingCategories = true);
    final setupState = ref.read(businessSetupProvider);
    final apiService = ref.read(businessApiServiceProvider);

    final subCategories = <MappedSubCategoryItem>[];

    // 1. Try to read from savedCategoryConfigurations in state (from Step 7)
    if (setupState.savedCategoryConfigurations.isNotEmpty) {
      for (final config in setupState.savedCategoryConfigurations) {
        final pCats = config['primary_categories'];
        if (pCats is List) {
          for (final p in pCats) {
            final pId = int.tryParse(p['id']?.toString() ?? '0') ?? 0;
            final pName = p['name']?.toString() ?? 'Category';
            final subs = p['sub_categories'];
            if (subs is List) {
              for (final s in subs) {
                final sId = int.tryParse(s['id']?.toString() ?? '0') ?? 0;
                final sName = s['name']?.toString() ?? 'Sub-Category';
                if (sId > 0 && !subCategories.any((item) => item.id == sId)) {
                  subCategories.add(
                    MappedSubCategoryItem(
                      id: sId,
                      name: sName,
                      primaryId: pId,
                      primaryName: pName,
                    ),
                  );
                }
              }
            }
          }
        }
      }
    }

    // 2. Fallback to API if empty (e.g. on hot restart or direct navigation)
    if (subCategories.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedPId = prefs.getString('propagator_id');
        final activeBiz = ref.read(activeBusinessProvider);
        final pId = setupState.propagatorId ??
            int.tryParse(activeBiz.id.replaceAll('#', '').trim()) ??
            int.tryParse(savedPId ?? '') ??
            77;

        final response = await apiService.getPropagatorConfigurations(pId);
        List configs = [];
        if (response['data'] is Map && (response['data'] as Map)['configurations'] is List) {
          configs = (response['data'] as Map)['configurations'] as List;
        } else if (response['data'] is List) {
          configs = response['data'] as List;
        } else if (response['configurations'] is List) {
          configs = response['configurations'] as List;
        }

        for (final config in configs) {
          if (config is! Map) continue;
          final pCats = config['primary_categories'];
          if (pCats is List) {
            for (final p in pCats) {
              final pIdVal = int.tryParse(p['id']?.toString() ?? '0') ?? 0;
              final pName = p['name']?.toString() ?? 'Category';
              final subs = p['sub_categories'];
              if (subs is List) {
                for (final s in subs) {
                  final sIdVal = int.tryParse(s['id']?.toString() ?? '0') ?? 0;
                  final sName = s['name']?.toString() ?? 'Sub-Category';
                  if (sIdVal > 0 && !subCategories.any((item) => item.id == sIdVal)) {
                    subCategories.add(
                      MappedSubCategoryItem(
                        id: sIdVal,
                        name: sName,
                        primaryId: pIdVal,
                        primaryName: pName,
                      ),
                    );
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching saved configurations in Step 8: $e');
      }
    }

    // 3. Fallback demo items if database has none yet (matching user's session: UPS, SMPS)
    if (subCategories.isEmpty) {
      subCategories.addAll([
        MappedSubCategoryItem(
          id: 299,
          name: 'SMPS',
          primaryId: 10,
          primaryName: 'Power Supply',
        ),
        MappedSubCategoryItem(
          id: 110,
          name: 'UPS',
          primaryId: 10,
          primaryName: 'Power Supply',
        ),
      ]);
    }

    setState(() {
      _availableSubCategories = subCategories;
      _isLoadingCategories = false;
      if (subCategories.isNotEmpty) {
        // Prefer SMPS if present, else first
        final smpsMatch = subCategories.where((s) => s.name.toUpperCase() == 'SMPS');
        _activeSubCategory = smpsMatch.isNotEmpty ? smpsMatch.first : subCategories.first;
      }
    });

    if (_activeSubCategory != null) {
      await _fetchBrandsForSubCategory(_activeSubCategory!);
    }
  }

  Future<void> _fetchBrandsForSubCategory(MappedSubCategoryItem subCat) async {
    // If cached, use cache
    if (_brandsCache.containsKey(subCat.id)) {
      setState(() {
        _availableBrands = _brandsCache[subCat.id]!;
        _isLoadingBrands = false;
      });
      return;
    }

    setState(() => _isLoadingBrands = true);
    try {
      final apiService = ref.read(businessApiServiceProvider);
      debugPrint('🚀 [Step 8] Fetching brands for ${subCat.name} -> primary: ${subCat.primaryId}, secondary: ${subCat.id}');
      final list = await apiService.getBrands(
        primaryId: subCat.primaryId,
        secondaryId: subCat.id,
      );

      _brandsCache[subCat.id] = list;

      setState(() {
        _availableBrands = list;
        _isLoadingBrands = false;
      });
    } catch (e) {
      debugPrint('⚠️ Error fetching brands for ${subCat.name}: $e');
      setState(() {
        _availableBrands = [];
        _isLoadingBrands = false;
      });
    }
  }

  void _onSelectSubCategory(MappedSubCategoryItem subCat) {
    if (_activeSubCategory?.id == subCat.id) return;
    setState(() {
      _activeSubCategory = subCat;
      _brandSearchQuery = '';
      _brandSearchController.clear();
    });
    _fetchBrandsForSubCategory(subCat);
  }

  void _toggleBrandSelection(int brandId, String brandName) {
    if (_activeSubCategory == null) return;
    final activeId = _activeSubCategory!.id;

    final currentIds =
        _selectedBrandIdsBySubCategory.putIfAbsent(activeId, () => <int>{});
    final currentNames = _selectedBrandNamesBySubCategory.putIfAbsent(
        activeId, () => <int, String>{});

    setState(() {
      if (currentIds.contains(brandId)) {
        currentIds.remove(brandId);
        currentNames.remove(brandId);
      } else {
        currentIds.add(brandId);
        currentNames[brandId] = brandName;
      }
    });
  }

  void _selectAllBrands() {
    if (_activeSubCategory == null) return;
    final activeId = _activeSubCategory!.id;

    final currentIds =
        _selectedBrandIdsBySubCategory.putIfAbsent(activeId, () => <int>{});
    final currentNames = _selectedBrandNamesBySubCategory.putIfAbsent(
        activeId, () => <int, String>{});

    setState(() {
      for (final b in _availableBrands) {
        final bId = int.tryParse(b['brand_id']?.toString() ?? b['id']?.toString() ?? '0') ?? 0;
        final bName = (b['brand_name'] ?? b['name'] ?? '').toString();
        if (bId > 0 && bName.isNotEmpty) {
          currentIds.add(bId);
          currentNames[bId] = bName;
        }
      }
    });
  }

  void _clearAllBrands() {
    if (_activeSubCategory == null) return;
    final activeId = _activeSubCategory!.id;

    setState(() {
      _selectedBrandIdsBySubCategory[activeId]?.clear();
      _selectedBrandNamesBySubCategory[activeId]?.clear();
    });
  }

  void _showSubCategorySelectionModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Sub-Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableSubCategories.length,
                    itemBuilder: (context, index) {
                      final item = _availableSubCategories[index];
                      final isSelected = item.id == _activeSubCategory?.id;
                      final selectedCount =
                          _selectedBrandIdsBySubCategory[item.id]?.length ?? 0;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.bookmark_outline,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B),
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : AppColors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          'Primary: ${item.primaryName} • $selectedCount brands selected',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF2563EB), size: 20)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _onSelectSubCategory(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmitAndFinish() async {
    final setupState = ref.read(businessSetupProvider);
    final setupNotifier = ref.read(businessSetupProvider.notifier);
    final navNotifier = ref.read(navigationProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    final prefs = await SharedPreferences.getInstance();
    final savedPropagatorId = prefs.getString('propagator_id');
    final activeBiz = ref.read(activeBusinessProvider);
    final pId = setupState.propagatorId ??
        int.tryParse(activeBiz.id.replaceAll('#', '').trim()) ??
        int.tryParse(savedPropagatorId ?? '') ??
        77;

    final effectiveUserId = prefs.getString('user_main_id') ??
        prefs.getString('user_id') ??
        '4282284422';

    // Build brand_ids, brand_names, and brands map
    final allBrandIds = <int>[];
    final allBrandNames = <String>[];
    final brandsMap = <String, dynamic>{};

    for (final subCat in _availableSubCategories) {
      final ids = _selectedBrandIdsBySubCategory[subCat.id]?.toList() ?? [];
      final names =
          _selectedBrandNamesBySubCategory[subCat.id]?.values.toList() ?? [];

      if (ids.isNotEmpty) {
        allBrandIds.addAll(ids);
        allBrandNames.addAll(names);
        brandsMap[subCat.name] = ids;
      }
    }

    // If active sub-category had brands selected, ensure it is represented
    if (brandsMap.isEmpty && _activeSubCategory != null) {
      final activeIds =
          _selectedBrandIdsBySubCategory[_activeSubCategory!.id]?.toList() ?? [];
      final activeNames = _selectedBrandNamesBySubCategory[_activeSubCategory!.id]
              ?.values
              .toList() ??
          [];
      if (activeIds.isNotEmpty) {
        allBrandIds.addAll(activeIds);
        allBrandNames.addAll(activeNames);
        brandsMap[_activeSubCategory!.name] = activeIds;
      }
    }

    debugPrint('📦 [Step 8 Payload Preparation]:');
    debugPrint('   propagator_id: $pId');
    debugPrint('   user_id: $effectiveUserId');
    debugPrint('   brand_ids: $allBrandIds');
    debugPrint('   brand_names: $allBrandNames');
    debugPrint('   brands: $brandsMap');

    final success = await setupNotifier.completeSetup(
      propagatorId: pId,
      userId: effectiveUserId,
      brandIds: allBrandIds,
      brandNames: allBrandNames,
      brands: brandsMap,
    );

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('🎉 Category & Brand Configuration Saved Successfully!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 3),
        ),
      );
      ref.read(selectedBusinessIdProvider.notifier).select('#$pId');
      navNotifier.navigateToBusinessCategory();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
              setupState.apiErrorMessage ?? 'Failed to submit brand mappings.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final navNotifier = ref.read(navigationProvider.notifier);
    final setupState = ref.watch(businessSetupProvider);

    final activeSubCat = _activeSubCategory;
    final activeSubCatId = activeSubCat?.id ?? 0;
    final activeSubCatName = activeSubCat?.name ?? 'Sub-Category';

    final selectedBrandIds =
        _selectedBrandIdsBySubCategory[activeSubCatId] ?? <int>{};
    final selectedCount = selectedBrandIds.length;
    final availableCount = _availableBrands.length;

    final filteredBrands = _availableBrands.where((brand) {
      final name =
          (brand['brand_name'] ?? brand['name'] ?? '').toString().toLowerCase();
      return name.contains(_brandSearchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 16 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Header (Step 8 active)
              BusinessSetupStepperHeader(
                currentStep: 8,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 8: Brand Selection (Matching Screenshot 2 & 3)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: isMobile ? 20 : 32,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 20,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: "Select Sub-Category (N)" & "Selected Sub-Category Card"
                    if (_isLoadingCategories)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 720) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildSelectSubCategoryCard(activeSubCatName, selectedCount, availableCount)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildSelectedSubCategoryCard(activeSubCatName, selectedCount)),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSelectSubCategoryCard(activeSubCatName, selectedCount, availableCount),
                                const SizedBox(height: 14),
                                _buildSelectedSubCategoryCard(activeSubCatName, selectedCount),
                              ],
                            );
                          }
                        },
                      ),

                    const SizedBox(height: 24),

                    // Active Category Brands Box (Matching Screenshot 2 & 3)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Active Category badge, Title, and Selected Badge
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Active Category',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      activeSubCatName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: selectedCount > 0
                                      ? const Color(0xFFE6F4EA)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selectedCount > 0
                                        ? const Color(0xFFA8DAB5)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  '$selectedCount Brands Selected',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: selectedCount > 0
                                        ? const Color(0xFF137333)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select operational brand visual cards associated with $activeSubCatName.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 16),

                          // Search and Select All / Clear All Row
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildBrandSearchBar(activeSubCatName),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(child: _buildSelectAllButton()),
                                        const SizedBox(width: 8),
                                        Expanded(child: _buildClearAllButton()),
                                      ],
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _buildBrandSearchBar(activeSubCatName),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildSelectAllButton(),
                                    const SizedBox(width: 8),
                                    _buildClearAllButton(),
                                  ],
                                ),

                          const SizedBox(height: 20),

                          // Brands List or Empty State
                          if (_isLoadingBrands)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (filteredBrands.isEmpty)
                            // Empty State (matching Screenshot 2: "No brands available for UPS")
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 40, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.inbox_outlined,
                                      size: 38, color: Color(0xFF94A3B8)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No brands available for $activeSubCatName',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'There are no brands mapped to this sub-category in the database. You can proceed without selecting brands.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else
                            // Visual Brand Cards Grid (matching Screenshot 3: Assembled, Hikvision, etc.)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 72,
                                  ),
                                  itemCount: filteredBrands.length,
                                  itemBuilder: (context, index) {
                                    final brand = filteredBrands[index];
                                    final bId = int.tryParse(brand['brand_id']?.toString() ?? brand['id']?.toString() ?? '0') ?? 0;
                                    final bName = (brand['brand_name'] ?? brand['name'] ?? 'Brand').toString();
                                    final isSelected = selectedBrandIds.contains(bId);

                                    return InkWell(
                                      onTap: () => _toggleBrandSelection(bId, bName),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFEFF6FF)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFFE2E8F0),
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Blue Icon container
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: const Color(0xFFBFDBFE),
                                                    width: 0.8),
                                              ),
                                              child: const Icon(
                                                Icons.shield_outlined,
                                                color: Color(0xFF2563EB),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Brand Name & "Brand Partner"
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    bName,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w600,
                                                      color: isSelected
                                                          ? const Color(0xFF1E3A8A)
                                                          : AppColors.textDark,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  const Text(
                                                    'Brand Partner',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      color: Color(0xFF64748B),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Circular checkbox/radio
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF2563EB),
                                                size: 20,
                                              )
                                            else
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFFCBD5E1),
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Bottom Navigation Buttons (Back to Category Mapping & Submit & Finish All Steps)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => navNotifier.navigateToStep7(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Category Mapping'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textMedium,
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 14 : 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: setupState.isSubmitting
                              ? null
                              : () => _handleSubmitAndFinish(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: setupState.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        size: 17, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Submit & Finish All Steps',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
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

  // Left card: Select Sub-Category Dropdown
  Widget _buildSelectSubCategoryCard(
      String activeName, int selectedCount, int availableCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.label_outline_rounded,
                  size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select Sub-Category (${_availableSubCategories.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showSubCategorySelectionModal,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$selectedCount Selected (of $availableCount Available)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Right card: Selected Sub-Category Card (Active visual card with blue outline)
  Widget _buildSelectedSubCategoryCard(String activeName, int selectedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selected Sub-Category Card',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
            ),
            child: Row(
              children: [
                // Bookmark Icon in blue container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: selectedCount > 0
                              ? const Color(0xFFE6F4EA)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedCount > 0
                                ? const Color(0xFFA8DAB5)
                                : const Color(0xFFCBD5E1),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$selectedCount Brands Selected',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: selectedCount > 0
                                ? const Color(0xFF137333)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandSearchBar(String categoryName) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextField(
        controller: _brandSearchController,
        onChanged: (val) => setState(() => _brandSearchQuery = val),
        style: const TextStyle(fontSize: 12.5),
        decoration: InputDecoration(
          hintText: 'Search brands for $categoryName...',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon:
              const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildSelectAllButton() {
    return OutlinedButton.icon(
      onPressed: _selectAllBrands,
      icon: const Icon(Icons.done_all, size: 14, color: Color(0xFF2563EB)),
      label: const Text(
        'Select All',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF93C5FD)),
        backgroundColor: const Color(0xFFEFF6FF),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildClearAllButton() {
    return OutlinedButton.icon(
      onPressed: _clearAllBrands,
      icon: const Icon(Icons.clear_all, size: 14, color: Color(0xFF64748B)),
      label: const Text(
        'Clear All',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
