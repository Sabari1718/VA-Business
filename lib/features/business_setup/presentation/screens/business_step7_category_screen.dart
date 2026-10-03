import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../navigation/providers/navigation_provider.dart';
import '../../providers/business_providers.dart';
import '../widgets/business_setup_stepper_header.dart';
import '../widgets/dashboard_footer.dart';

class BusinessStep7CategoryScreen extends ConsumerStatefulWidget {
  const BusinessStep7CategoryScreen({super.key});

  @override
  ConsumerState<BusinessStep7CategoryScreen> createState() =>
      _BusinessStep7CategoryScreenState();
}

class _BusinessStep7CategoryScreenState
    extends ConsumerState<BusinessStep7CategoryScreen> {
  final TextEditingController _primarySearchController = TextEditingController();
  final TextEditingController _secondarySearchController = TextEditingController();

  String _primarySearchQuery = '';
  String _secondarySearchQuery = '';

  List<Map<String, dynamic>> _sectorTitlesList = [];
  Map<String, dynamic>? _selectedSectorTitleMap;

  List<Map<String, dynamic>> _sectorsList = [];
  Map<String, dynamic>? _selectedSectorMap;

  List<Map<String, dynamic>> _subSectorsList = [];
  Map<String, dynamic>? _selectedSubSectorMap;

  List<Map<String, dynamic>> _primaryCategoriesList = [];
  final List<int> _selectedPrimaryCategoryIds = [];
  final Map<int, int> _subCountCache = {};

  List<Map<String, dynamic>> _secondaryCategoriesList = [];
  final List<int> _selectedSecondaryCategoryIds = [];

  // Saved database configurations
  List<Map<String, dynamic>> _savedConfigurations = [];
  final Set<int> _alreadySavedPrimaryCategoryIds = {};
  final Set<String> _alreadySavedPrimaryCategoryNames = {};

  bool _isLoadingSectorTitles = false;
  bool _isLoadingSectors = false;
  bool _isLoadingSubSectors = false;
  bool _isLoadingPrimary = false;
  bool _isLoadingSecondary = false;
  bool _isCategoryMappingSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _primarySearchController.dispose();
    _secondarySearchController.dispose();
    super.dispose();
  }

  Future<int> _getResolvedPropagatorId() async {
    final setupState = ref.read(businessSetupProvider);
    if (setupState.propagatorId != null && setupState.propagatorId! > 0) {
      return setupState.propagatorId!;
    }

    try {
      final activeBiz = ref.read(activeBusinessProvider);
      final activeId = int.tryParse(activeBiz.id.replaceAll('#', '').trim());
      if (activeId != null && activeId > 0) {
        return activeId;
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('propagator_id');
      if (saved != null) {
        final parsed = int.tryParse(saved);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    } catch (_) {}

    return 77; // Fallback active business ID
  }

  Future<void> _fetchInitialData() async {
    final pId = await _getResolvedPropagatorId();
    final apiService = ref.read(businessApiServiceProvider);

    // Call GET /api/propagator-business-mappings?propagator_id={pId}&user_main_id={userId}
    try {
      final res = await apiService.getPropagatorBusinessMappings(pId);
      debugPrint('📦 Existing mappings response: $res');
    } catch (_) {}

    await _fetchSectorTitles();
  }

  Future<void> _fetchSectorTitles() async {
    setState(() => _isLoadingSectorTitles = true);
    try {
      final apiService = ref.read(businessApiServiceProvider);
      final list = await apiService.getSectorTitles();
      setState(() {
        _sectorTitlesList = list;
        _isLoadingSectorTitles = false;
      });
    } catch (e) {
      debugPrint('Error fetching sector titles: $e');
      setState(() => _isLoadingSectorTitles = false);
    }
  }

  Future<void> _onSectorTitleSelected(Map<String, dynamic>? item) async {
    setState(() {
      _selectedSectorTitleMap = item;
      _sectorsList = [];
      _selectedSectorMap = null;
      _subSectorsList = [];
      _selectedSubSectorMap = null;
      _primaryCategoriesList = [];
      _selectedPrimaryCategoryIds.clear();
      _secondaryCategoriesList = [];
      _selectedSecondaryCategoryIds.clear();
    });

    if (item != null && item['id'] != null) {
      final sectorTitleId = item['id'];
      setState(() => _isLoadingSectors = true);
      try {
        final apiService = ref.read(businessApiServiceProvider);
        final list = await apiService.getSectors(sectorTitleId);
        setState(() {
          _sectorsList = list;
          _isLoadingSectors = false;
        });
      } catch (e) {
        debugPrint('Error fetching sectors: $e');
        setState(() => _isLoadingSectors = false);
      }
    }
  }

  Future<void> _onSectorSelected(Map<String, dynamic>? item) async {
    setState(() {
      _selectedSectorMap = item;
      _subSectorsList = [];
      _selectedSubSectorMap = null;
      _primaryCategoriesList = [];
      _selectedPrimaryCategoryIds.clear();
      _secondaryCategoriesList = [];
      _selectedSecondaryCategoryIds.clear();
    });

    if (item != null && item['id'] != null) {
      final sectorId = item['id'];
      setState(() => _isLoadingSubSectors = true);
      try {
        final apiService = ref.read(businessApiServiceProvider);
        final list = await apiService.getSubSectors(sectorId: sectorId);
        setState(() {
          _subSectorsList = list;
          _isLoadingSubSectors = false;
        });
      } catch (e) {
        debugPrint('Error fetching sub-sectors: $e');
        setState(() => _isLoadingSubSectors = false);
      }
    }
  }

  Future<void> _onSubSectorSelected(Map<String, dynamic>? item) async {
    setState(() {
      _selectedSubSectorMap = item;
      _primaryCategoriesList = [];
      _selectedPrimaryCategoryIds.clear();
      _secondaryCategoriesList = [];
      _selectedSecondaryCategoryIds.clear();
    });

    if (item != null && item['id'] != null) {
      final subSectorId = item['id'];
      setState(() => _isLoadingPrimary = true);
      try {
        final apiService = ref.read(businessApiServiceProvider);
        final list = await apiService.getPrimaryCategories(subSectorId: subSectorId);
        setState(() {
          _primaryCategoriesList = list;
          _isLoadingPrimary = false;
        });
      } catch (e) {
        debugPrint('Error fetching primary categories: $e');
        setState(() => _isLoadingPrimary = false);
      }
    }
  }

  Future<void> _togglePrimaryCategory(Map<String, dynamic> cat) async {
    final int id = int.tryParse(cat['id']?.toString() ?? '0') ?? 0;
    if (id <= 0) return;

    final String name = (cat['name'] ?? cat['category_name'] ?? '').toString();
    final bool isAlreadySaved = _alreadySavedPrimaryCategoryIds.contains(id) ||
        _alreadySavedPrimaryCategoryNames.contains(name.toLowerCase());

    if (isAlreadySaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ "$name" is already saved in your database configuration.'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
      return;
    }

    final bool isSelected = _selectedPrimaryCategoryIds.contains(id);

    if (isSelected) {
      // Deselect
      setState(() {
        _selectedPrimaryCategoryIds.remove(id);
        _secondaryCategoriesList.removeWhere((item) {
          final pId = int.tryParse(item['parent_category_id']?.toString() ?? item['primary_id']?.toString() ?? '');
          return pId == id;
        });
        _selectedSecondaryCategoryIds.removeWhere((sId) {
          return !_secondaryCategoriesList.any((s) => (int.tryParse(s['id']?.toString() ?? '') ?? 0) == sId);
        });
      });
    } else {
      // Select
      setState(() {
        _selectedPrimaryCategoryIds.add(id);
        _isLoadingSecondary = true;
      });

      try {
        final apiService = ref.read(businessApiServiceProvider);
        final secList = await apiService.getSecondaryCategoriesByPrimaryId(id);

        setState(() {
          _subCountCache[id] = secList.length;
          for (final item in secList) {
            final sId = int.tryParse(item['id']?.toString() ?? '0') ?? 0;
            if (!_secondaryCategoriesList.any((existing) => (int.tryParse(existing['id']?.toString() ?? '0') ?? 0) == sId)) {
              final enriched = Map<String, dynamic>.from(item);
              enriched['parent_category_id'] = id;
              enriched['primary_name'] = name;
              _secondaryCategoriesList.add(enriched);
            }
          }
          _isLoadingSecondary = false;
        });
      } catch (e) {
        debugPrint('Error fetching secondary categories for $id: $e');
        setState(() => _isLoadingSecondary = false);
      }
    }
  }

  void _showSavedCategoryMappingDetailsDialog(Map<String, dynamic> config) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final sectorTitle = config['sector_title_name']?.toString() ??
            config['sector_title_id']?.toString() ??
            '1';
        final sector = config['sector_name']?.toString() ?? 'Electronics';
        final subSector = config['sub_sector_name']?.toString() ??
            'Basic Electronics Components';
        final rawPrimary = (config['primary_categories'] is List)
            ? config['primary_categories'] as List
            : [];

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 680,
              maxHeight: MediaQuery.of(ctx).size.height * 0.88,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: const Color(0xFF2563EB),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Saved Category Mapping Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Dialog Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top info box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sector Title',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Text(
                                        sectorTitle,
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2563EB)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sector',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Text(
                                      sector,
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sub-Sector',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.account_tree_outlined,
                                            size: 14, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            subSector,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A)),
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

                        const SizedBox(height: 20),

                        // Section Title
                        Row(
                          children: [
                            const Icon(Icons.category_outlined,
                                size: 18, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Mapped Categories & Sub-Categories (${rawPrimary.length} Primary Categories Mapped)',
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Primary Category Cards List
                        if (rawPrimary.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('No categories mapped for this configuration.',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ...rawPrimary.map((pCat) {
                            final pName = pCat['name']?.toString() ?? 'Category';
                            final rawSubs = (pCat['sub_categories'] is List)
                                ? pCat['sub_categories'] as List
                                : [];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x05000000),
                                      blurRadius: 6,
                                      offset: Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.grid_view_rounded,
                                              size: 16, color: Color(0xFF2563EB)),
                                          const SizedBox(width: 8),
                                          Text(
                                            pName,
                                            style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF0F172A)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Primary Category',
                                          style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2563EB)),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.only(left: 14),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                            color: Color(0xFF2563EB), width: 2.5),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Secondary Sub-Categories (${rawSubs.length}):',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF475569)),
                                        ),
                                        const SizedBox(height: 8),
                                        if (rawSubs.isEmpty)
                                          const Text(
                                            'No secondary sub-categories selected for this category.',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Color(0xFF94A3B8)),
                                          )
                                        else
                                          Column(
                                            children: rawSubs.map((sub) {
                                              final subName = sub['name']?.toString() ??
                                                  'Sub-Category';
                                              final brands = (sub['brand_names'] is List)
                                                  ? sub['brand_names'] as List
                                                  : [];
                                              final brandCount = brands.length;

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 8),
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF8FAFC),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: const Color(0xFFE2E8F0)),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFECFDF5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(6),
                                                            border: Border.all(
                                                                color: const Color(
                                                                    0xFFA7F3D0)),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .local_offer_outlined,
                                                                  size: 12,
                                                                  color: Color(
                                                                      0xFF059669)),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                subName,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        11.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Color(
                                                                        0xFF065F46)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Text(
                                                          '$brandCount Brands',
                                                          style: const TextStyle(
                                                              fontSize: 11.5,
                                                              fontWeight:
                                                                  FontWeight.w700,
                                                              color: Color(
                                                                  0xFF334155)),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      brandCount > 0
                                                          ? '$brandCount brands assigned'
                                                          : 'No brands assigned yet.',
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          color:
                                                              Color(0xFF94A3B8)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                // Dialog Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64748B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Close',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    final isRequired = text.endsWith('*');
    final label = isRequired ? text.substring(0, text.length - 1).trim() : text;

    return Text.rich(
      TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDynamicDropdown({
    required String label,
    required String hint,
    required Map<String, dynamic>? selectedValue,
    required List<Map<String, dynamic>> items,
    required ValueChanged<Map<String, dynamic>?> onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Map<String, dynamic>>(
                    value: selectedValue,
                    isExpanded: true,
                    hint: Text(hint,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: Color(0xFF64748B)),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    items: items.map((e) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: e,
                        child: Text(
                          e['name']?.toString() ?? 'Unnamed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final navNotifier = ref.read(navigationProvider.notifier);
    final setupState = ref.watch(businessSetupProvider);
    final setupNotifier = ref.read(businessSetupProvider.notifier);

    final bool hasSelection = _selectedSubSectorMap != null;

    final filteredPrimary = _primaryCategoriesList.where((cat) {
      final name = (cat['name'] ?? cat['category_name'] ?? '').toString().toLowerCase();
      return name.contains(_primarySearchQuery.toLowerCase());
    }).toList();

    final filteredSecondary = _secondaryCategoriesList.where((cat) {
      final name = (cat['name'] ?? cat['category_name'] ?? '').toString().toLowerCase();
      return name.contains(_secondarySearchQuery.toLowerCase());
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
              BusinessSetupStepperHeader(
                currentStep: 7,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Setup Card
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA8DAB5), width: 0.8),
                      ),
                      child: const Text(
                        'Step 7 of 8',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF137333),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Business Category Classification',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select your Sector, Sub-Sector, and mapped Category visual cards.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Saved Category Mappings Preview Card
                    if (_isCategoryMappingSaved && _savedConfigurations.isNotEmpty) ...[
                      ..._savedConfigurations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final config = entry.value;
                        final label = config['config_label']?.toString() ??
                            'Unified Configuration #${index + 1}';
                        final sectorName = config['sector_name']?.toString() ?? 'Electronics';
                        final subSectorName =
                            config['sub_sector_name']?.toString() ??
                                'Basic Electronics Components';

                        final pCats = (config['primary_categories'] is List)
                            ? config['primary_categories'] as List
                            : [];

                        int totalSavedSubCategories = 0;
                        for (final p in pCats) {
                          if (p['sub_categories'] is List) {
                            totalSavedSubCategories += (p['sub_categories'] as List).length;
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x050F172A), blurRadius: 10)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.folder_open_rounded,
                                            size: 18, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Saved Category Mappings (${_savedConfigurations.length})',
                                            style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Wrap(
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.layers,
                                                      color: Color(0xFF2563EB), size: 18),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      sectorName,
                                                      style: const TextStyle(
                                                          fontSize: 13.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppColors.textDark),
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
                                                  color: const Color(0xFFEFF6FF),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: const Color(0xFFBFDBFE)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.account_tree_outlined,
                                                        size: 12, color: Color(0xFF2563EB)),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        subSectorName,
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(0xFF2563EB),
                                                            fontWeight: FontWeight.w600),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Action Icons: Eye (View Details Modal) & Edit
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility_outlined,
                                                  size: 18, color: Color(0xFF2563EB)),
                                              tooltip: 'View Mapping Details',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () =>
                                                  _showSavedCategoryMappingDetailsDialog(config),
                                            ),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined,
                                                  size: 18, color: Color(0xFF64748B)),
                                              tooltip: 'Edit Configuration',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Select new categories below to update configuration.'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Primary Category Badges
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: pCats.map((p) {
                                        final catName = p['name']?.toString() ?? 'Category';
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                                color: const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.grid_view_rounded,
                                                    size: 11, color: Color(0xFF2563EB)),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    catName,
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF334155)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        );
                                      }).toList(),
                                    ),

                                    const SizedBox(height: 12),

                                    Wrap(
                                      alignment:
                                          WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        Text(
                                          '✓ $totalSavedSubCategories Sub-Categories Saved',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const Text(
                                          '✓ Active Database Mapping',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF10B981),
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],

                    // 3 Dropdowns (Sector Title, Sector, Sub Sector)
                    if (isMobile) ...[
                      _buildDynamicDropdown(
                        label: 'Sector Title *',
                        hint: '-- Select Sector Title --',
                        selectedValue: _selectedSectorTitleMap,
                        items: _sectorTitlesList,
                        onChanged: _onSectorTitleSelected,
                        isLoading: _isLoadingSectorTitles,
                      ),
                      const SizedBox(height: 14),
                      _buildDynamicDropdown(
                        label: 'Sector *',
                        hint: _selectedSectorTitleMap == null
                            ? '-- Select Sector Title First --'
                            : '-- Select Sector --',
                        selectedValue: _selectedSectorMap,
                        items: _sectorsList,
                        onChanged: _onSectorSelected,
                        isLoading: _isLoadingSectors,
                      ),
                      const SizedBox(height: 14),
                      _buildDynamicDropdown(
                        label: 'Sub Sector *',
                        hint: _selectedSectorMap == null
                            ? '-- Select Sector First --'
                            : '-- Select Sub Sector --',
                        selectedValue: _selectedSubSectorMap,
                        items: _subSectorsList,
                        onChanged: _onSubSectorSelected,
                        isLoading: _isLoadingSubSectors,
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDynamicDropdown(
                              label: 'Sector Title *',
                              hint: '-- Select Sector Title --',
                              selectedValue: _selectedSectorTitleMap,
                              items: _sectorTitlesList,
                              onChanged: _onSectorTitleSelected,
                              isLoading: _isLoadingSectorTitles,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildDynamicDropdown(
                              label: 'Sector *',
                              hint: _selectedSectorTitleMap == null
                                  ? '-- Select Sector Title First --'
                                  : '-- Select Sector --',
                              selectedValue: _selectedSectorMap,
                              items: _sectorsList,
                              onChanged: _onSectorSelected,
                              isLoading: _isLoadingSectors,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildDynamicDropdown(
                              label: 'Sub Sector *',
                              hint: _selectedSectorMap == null
                                  ? '-- Select Sector First --'
                                  : '-- Select Sub Sector --',
                              selectedValue: _selectedSubSectorMap,
                              items: _subSectorsList,
                              onChanged: _onSubSectorSelected,
                              isLoading: _isLoadingSubSectors,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 28),

                    // Primary Category Visual Cards Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPrimaryHeaderTitle(),
                                    const SizedBox(height: 12),
                                    _buildPrimarySearchBar(),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPrimaryHeaderTitle(),
                                    SizedBox(
                                      width: 260,
                                      child: _buildPrimarySearchBar(),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 20),

                          if (!hasSelection)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 40, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: Color(0xFF3B82F6), size: 28),
                                  SizedBox(height: 10),
                                  Text(
                                    'Please select Sector & Sub Sector above to view visual category cards.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          else if (_isLoadingPrimary)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (filteredPrimary.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text('No Primary Categories found.',
                                  style: TextStyle(color: Colors.grey)),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 82,
                              ),
                              itemCount: filteredPrimary.length,
                              itemBuilder: (context, index) {
                                final cat = filteredPrimary[index];
                                final int id =
                                    int.tryParse(cat['id']?.toString() ?? '0') ?? 0;
                                final String name = (cat['name'] ??
                                        cat['category_name'] ??
                                        'Category')
                                    .toString();
                                final String? imageUrl =
                                    cat['image'] ?? cat['image_url'];

                                final bool isAlreadySaved =
                                    _alreadySavedPrimaryCategoryIds.contains(id) ||
                                        _alreadySavedPrimaryCategoryNames
                                            .contains(name.toLowerCase());
                                final bool isSelected =
                                    _selectedPrimaryCategoryIds.contains(id);

                                final int cachedCount = _subCountCache[id] ?? 0;
                                final String subOptionText = isAlreadySaved
                                    ? 'Already Selected'
                                    : (cachedCount > 0
                                        ? '$cachedCount sub-options'
                                        : '0 sub-options');

                                Color cardBg = Colors.white;
                                Border cardBorder =
                                    Border.all(color: const Color(0xFFE2E8F0));

                                if (isAlreadySaved) {
                                  cardBg = const Color(0xFFFEF2F2);
                                  cardBorder = Border.all(
                                      color: const Color(0xFFFECACA), width: 1.2);
                                } else if (isSelected) {
                                  cardBg = const Color(0xFFEFF6FF);
                                  cardBorder = Border.all(
                                      color: const Color(0xFF2563EB), width: 1.5);
                                }

                                return InkWell(
                                  onTap: () => _togglePrimaryCategory(cat),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border: cardBorder,
                                    ),
                                    child: Row(
                                      children: [
                                        if (imageUrl != null && imageUrl.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => const Icon(
                                                  Icons.category,
                                                  color: Color(0xFF2563EB),
                                                  size: 28),
                                            ),
                                          )
                                        else
                                          const Icon(Icons.category,
                                              color: Color(0xFF2563EB), size: 28),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: (isSelected || isAlreadySaved)
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? const Color(0xFF1E3A8A)
                                                      : AppColors.textDark,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                subOptionText,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isAlreadySaved
                                                      ? const Color(0xFFEF4444)
                                                      : (isSelected
                                                          ? const Color(0xFF2563EB)
                                                          : const Color(0xFF64748B)),
                                                  fontWeight: (isAlreadySaved || isSelected)
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle_rounded,
                                              color: Color(0xFF2563EB), size: 18)
                                        else if (!isAlreadySaved)
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: const Color(0xFFCBD5E1),
                                                  width: 1.5),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Secondary Categories Cards Section
                    if (_selectedPrimaryCategoryIds.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSecondaryHeaderTitle(),
                                      const SizedBox(height: 12),
                                      _buildSecondarySearchBar(),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildSecondaryHeaderTitle(),
                                      SizedBox(
                                        width: 260,
                                        child: _buildSecondarySearchBar(),
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 20),

                            if (_isLoadingSecondary)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(30.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (filteredSecondary.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                    'No Secondary Sub-Categories found for selected primary category.',
                                    style: TextStyle(color: Colors.grey)),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: 82,
                                ),
                                itemCount: filteredSecondary.length,
                                itemBuilder: (context, index) {
                                  final cat = filteredSecondary[index];
                                  final int id = int.tryParse(
                                          cat['id']?.toString() ?? '0') ??
                                      0;
                                  final String name = (cat['name'] ??
                                          cat['category_name'] ??
                                          'Sub-Category')
                                      .toString();
                                  final String? imageUrl =
                                      cat['image'] ?? cat['image_url'];
                                  final bool isSelected =
                                      _selectedSecondaryCategoryIds.contains(id);

                                  return InkWell(
                                    onTap: () => setState(() {
                                      if (isSelected) {
                                        _selectedSecondaryCategoryIds.remove(id);
                                      } else {
                                        _selectedSecondaryCategoryIds.add(id);
                                      }
                                    }),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
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
                                          if (imageUrl != null && imageUrl.isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                imageUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) =>
                                                    const Icon(
                                                        Icons
                                                            .subdirectory_arrow_right,
                                                        color: Color(0xFF2563EB),
                                                        size: 28),
                                              ),
                                            )
                                          else
                                            const Icon(
                                                Icons.subdirectory_arrow_right,
                                                color: Color(0xFF2563EB),
                                                size: 28),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? const Color(0xFF1E3A8A)
                                                        : AppColors.textDark,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 3),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    border: Border.all(
                                                        color:
                                                            const Color(0xFFE2E8F0)),
                                                  ),
                                                  child: const Text(
                                                    'Sub-Category',
                                                    style: TextStyle(
                                                        fontSize: 9.5,
                                                        color: Color(0xFF475569),
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF2563EB)
                                                    : const Color(0xFFCBD5E1),
                                                width: 1.5,
                                              ),
                                              color: isSelected
                                                  ? const Color(0xFF2563EB)
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check,
                                                    size: 12, color: Colors.white)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Save Category Mapping Card Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_selectedPrimaryCategoryIds.isEmpty ||
                                setupState.isSubmitting)
                            ? null
                            : () async {
                                final primaryPayload =
                                    _selectedPrimaryCategoryIds.map((pId) {
                                  final subIds = _selectedSecondaryCategoryIds
                                      .where((sId) {
                                    final sec =
                                        _secondaryCategoriesList.firstWhere(
                                      (item) =>
                                          (int.tryParse(item['id']
                                                      ?.toString() ??
                                                  '0') ??
                                              0) ==
                                          sId,
                                      orElse: () => {},
                                    );
                                    final parentId = int.tryParse(sec[
                                                'parent_category_id']
                                            ?.toString() ??
                                        sec['primary_id']?.toString() ??
                                        '') ??
                                        0;
                                    return parentId == pId;
                                  }).toList();

                                  return {
                                    'primary_category_id': pId,
                                    'sub_category_ids': subIds,
                                  };
                                }).toList();

                                final messenger = ScaffoldMessenger.of(context);
                                final propagatorId = await _getResolvedPropagatorId();

                                final selectedSectorTitleName =
                                    _selectedSectorTitleMap?['name']?.toString() ?? 'Product';
                                final selectedSectorTitleId =
                                    _selectedSectorTitleMap?['id'] ?? 1;
                                final selectedSectorName =
                                    _selectedSectorMap?['name']?.toString() ?? 'Electronics';
                                final selectedSectorId =
                                    _selectedSectorMap?['id'] ?? 19;
                                final selectedSubSectorName =
                                    _selectedSubSectorMap?['name']?.toString() ??
                                        'Basic Electronics Components';
                                final selectedSubSectorId =
                                    _selectedSubSectorMap?['id'] ?? 20;

                                final savedPrimaryCategories =
                                    _selectedPrimaryCategoryIds.map((pId) {
                                  final pCat = _primaryCategoriesList.firstWhere(
                                    (c) =>
                                        (int.tryParse(c['id']?.toString() ?? '') ?? 0) ==
                                        pId,
                                    orElse: () => {'id': pId, 'name': 'Category'},
                                  );
                                  final pName =
                                      pCat['name'] ?? pCat['category_name'] ?? 'Category';

                                  final subs = _selectedSecondaryCategoryIds.where((sId) {
                                    final sec = _secondaryCategoriesList.firstWhere(
                                      (item) =>
                                          (int.tryParse(item['id']?.toString() ?? '0') ??
                                              0) ==
                                          sId,
                                      orElse: () => {},
                                    );
                                    final parentId = int.tryParse(
                                            sec['parent_category_id']?.toString() ??
                                                sec['primary_id']?.toString() ??
                                                '') ??
                                        0;
                                    return parentId == pId;
                                  }).map((sId) {
                                    final sec = _secondaryCategoriesList.firstWhere(
                                      (item) =>
                                          (int.tryParse(item['id']?.toString() ?? '0') ??
                                              0) ==
                                          sId,
                                      orElse: () => {'id': sId, 'name': 'Sub-Category'},
                                    );
                                    return {
                                      'id': sId,
                                      'name':
                                          sec['name'] ?? sec['category_name'] ?? 'Sub-Category',
                                      'brand_names': [],
                                    };
                                  }).toList();

                                  return {
                                    'id': pId,
                                    'name': pName,
                                    'sub_categories': subs,
                                  };
                                }).toList();

                                final newConfig = {
                                  'config_label': 'Unified Configuration #1',
                                  'sector_title_name': selectedSectorTitleName,
                                  'sector_title_id': selectedSectorTitleId,
                                  'sector_name': selectedSectorName,
                                  'sector_id': selectedSectorId,
                                  'sub_sector_name': selectedSubSectorName,
                                  'sub_sector_id': selectedSubSectorId,
                                  'primary_categories': savedPrimaryCategories,
                                };

                                final success = await setupNotifier
                                    .submitStep7CategoryMapping(
                                  propagatorId: propagatorId,
                                  sectorTitleId: selectedSectorTitleId,
                                  sectorId: selectedSectorId,
                                  subSectorId: selectedSubSectorId,
                                  primaryCategories: primaryPayload,
                                );

                                if (!mounted) return;
                                if (success) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          '✅ Propagator business mapping created successfully!'),
                                      backgroundColor: Color(0xFF10B981),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );

                                  setState(() {
                                    _savedConfigurations = [newConfig];
                                    _isCategoryMappingSaved = true;
                                    _alreadySavedPrimaryCategoryIds
                                        .addAll(_selectedPrimaryCategoryIds);
                                    for (final p in savedPrimaryCategories) {
                                      _alreadySavedPrimaryCategoryNames.add(
                                          (p['name'] ?? '').toString().toLowerCase());
                                    }

                                    // Reset dropdowns & current selections back to initial state (as in Photo 2)
                                    _selectedSectorTitleMap = null;
                                    _selectedSectorMap = null;
                                    _selectedSubSectorMap = null;
                                    _sectorsList = [];
                                    _subSectorsList = [];
                                    _primaryCategoriesList = [];
                                    _selectedPrimaryCategoryIds.clear();
                                    _secondaryCategoriesList = [];
                                    _selectedSecondaryCategoryIds.clear();
                                  });
                                  setupNotifier.setSavedCategoryConfigurations([newConfig]);
                                }
                              },
                        icon: setupState.isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.bookmark_added_outlined,
                                size: 18, color: Colors.white),
                        label: Text(
                          setupState.isSubmitting
                              ? 'Saving Mapping...'
                              : 'Save This Category Mapping Card',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Bottom Navigation Buttons
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => navNotifier.navigateToStep6(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Cancel & Back'),
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
                          onPressed: () {
                            if (_savedConfigurations.isNotEmpty) {
                              ref
                                  .read(businessSetupProvider.notifier)
                                  .setSavedCategoryConfigurations(_savedConfigurations);
                            }
                            navNotifier.navigateToStep8();
                          },
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Proceed to Step 8: Brand Selection',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward,
                                  size: 15, color: Colors.white),
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

  Widget _buildPrimaryHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Primary Category Visual Cards (Multi-Select)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Select primary category cards to load secondary sub-categories.',
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryHeaderTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
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
                      'Secondary Categories Cards (Multi-Select)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Select sub-category cards related to selected primary categories.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EA),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${_selectedSecondaryCategoryIds.length} Selected',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF137333)),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimarySearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextField(
        controller: _primarySearchController,
        onChanged: (val) => setState(() => _primarySearchQuery = val),
        style: const TextStyle(fontSize: 12.5),
        decoration: const InputDecoration(
          hintText: 'Search Primary Categories...',
          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildSecondarySearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextField(
        controller: _secondarySearchController,
        onChanged: (val) => setState(() => _secondarySearchQuery = val),
        style: const TextStyle(fontSize: 12.5),
        decoration: const InputDecoration(
          hintText: 'Search Sub-Categories...',
          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
