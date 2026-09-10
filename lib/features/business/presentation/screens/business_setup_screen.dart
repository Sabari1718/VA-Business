import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_providers.dart';
import '../providers/category_providers.dart';
import '../providers/platform_providers.dart';
import '../../data/models/category_model.dart';
import 'business_setup_list_screen.dart';
import '../../../../features/store/presentation/providers/store_providers.dart';
import '../../../../features/store/data/models/store_model.dart';

class BusinessSetupScreen extends ConsumerStatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  ConsumerState<BusinessSetupScreen> createState() =>
      _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends ConsumerState<BusinessSetupScreen> {
  int _currentStep = 1;
  String _searchQuery = '';

  // Step 1 State
  String? _selectedBusinessId;

  // Step 2 State
  CategoryModel? _selectedSectorTitle;
  CategoryModel? _selectedSector;
  CategoryModel? _selectedSubSector;

  final List<CategoryModel> _selectedPrimaryCategories = [];
  final List<CategoryModel> _selectedSecondaryCategories = [];
  String _primaryCategorySearch = '';
  String _secondaryCategorySearch = '';

  List<CategoryModel> get _availableSecondaryCategories {
    final List<CategoryModel> list = [];
    for (final primary in _selectedPrimaryCategories) {
      if (primary.secondaryCategories != null) {
        for (final sec in primary.secondaryCategories!) {
          list.add(CategoryModel(
            id: sec.id,
            name: sec.name,
            secondaryCategories: sec.secondaryCategories,
            parentName: sec.parentName ?? primary.name,
          ));
        }
      }
    }
    return list;
  }

  // Step 3 State
  final List<dynamic> _selectedPlatforms = [];

  // Step 4 State
  String? _activePlatformId;
  String _shopTypeSearchQuery = '';
  final Map<String, List<Map<String, dynamic>>> _configuredShopTypesByPlatform = {};

  // Step 5 State
  String? _activeStep5PlatformId;
  String? _activeStep5ShopTypeId;
  String _storeSearchQuery = '';
  String _branchTypeFilter = 'all'; // 'all', 'Single Branch', 'Multiple Branch'
  final Map<String, List<Map<String, dynamic>>> _assignedStoresByPlatformAndShopType = {};

  final List<Map<String, dynamic>> _defaultShopTypes = [
    {'id': '1', 'name': 'BK', 'shopTypeName': 'BK'},
    {'id': '2', 'name': 'Dealer', 'shopTypeName': 'Dealer'},
    {'id': '3', 'name': 'Wholesale', 'shopTypeName': 'Wholesale'},
    {'id': '4', 'name': 'Distributor', 'shopTypeName': 'Distributor'},
    {'id': '5', 'name': 'Warehouse', 'shopTypeName': 'Warehouse'},
    {'id': '6', 'name': 'Manufacture', 'shopTypeName': 'Manufacture'},
  ];

  List<Map<String, dynamic>> _getEffectivePlatforms() {
    final list = <Map<String, dynamic>>[];
    for (var p in _selectedPlatforms) {
      if (p is Map) {
        final name = (p['platformName'] ?? p['name'] ?? p['platform_name'] ?? p['title'] ?? '').toString().toLowerCase();
        if (name.contains('export')) continue;
        list.add(Map<String, dynamic>.from(p));
      }
    }

    final hasShop = list.any((p) {
      final name = (p['platformName'] ?? p['name'] ?? '').toString().toLowerCase();
      return name.contains('shop');
    });
    final hasLocalOnline = list.any((p) {
      final name = (p['platformName'] ?? p['name'] ?? '').toString().toLowerCase();
      return name.contains('local');
    });

    if (!hasShop) {
      list.insert(0, {'id': '1', 'name': 'Shop', 'platformName': 'Shop'});
    }
    if (!hasLocalOnline) {
      list.add({'id': '2', 'name': 'Local Online', 'platformName': 'Local Online'});
    }

    return list.where((p) {
      final name = (p['platformName'] ?? p['name'] ?? '').toString().toLowerCase();
      return !name.contains('export');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'B',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Business Suite',
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12.0 : 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  _buildTopStepper(),
                  const SizedBox(height: 20),
                  _buildStepBody(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      case 5:
        return _buildStep5();
      default:
        return _buildStep1();
    }
  }

  Widget _buildTopStepper() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Setup & Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Complete the 5 steps below to configure business, hierarchy setup, platform, shop type, and store mapping',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStepIndicator(1, 'Business', _currentStep >= 1),
                    _buildStepLine(_currentStep >= 2),
                    _buildStepIndicator(2, 'Business Setup', _currentStep >= 2),
                    _buildStepLine(_currentStep >= 3),
                    _buildStepIndicator(3, 'Platform', _currentStep >= 3),
                    _buildStepLine(_currentStep >= 4),
                    _buildStepIndicator(4, 'Shop Type', _currentStep >= 4),
                    _buildStepLine(_currentStep >= 5),
                    _buildStepIndicator(5, 'Store', _currentStep >= 5),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title, bool isActive) {
    bool isCompleted = _currentStep > stepNumber;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _currentStep = stepNumber;
          if (_currentStep == 4) {
            final effective = _getEffectivePlatforms();
            if (_activePlatformId == null || !effective.any((p) => p['id']?.toString() == _activePlatformId)) {
              _activePlatformId = effective.first['id']?.toString() ?? '1';
            }
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : (isActive ? const Color(0xFF6366F1) : Colors.grey.shade200),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      stepNumber.toString(),
                      style: GoogleFonts.poppins(
                        color: isActive ? Colors.white : Colors.black45,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$stepNumber. $title',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? (isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6366F1))
                  : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 24),
      color: isActive ? const Color(0xFF10B981) : Colors.grey.shade300,
    );
  }

  Widget _buildStep1() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              Widget headerContent = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business_outlined,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. Business Selection',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Choose the registered business entity to configure hierarchy, platform architecture, shop type, and store mapping.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              Widget searchBox = Container(
                width: isSmall ? double.infinity : 250,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search business...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent,
                    const SizedBox(height: 16),
                    searchBox,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: headerContent),
                  const SizedBox(width: 16),
                  searchBox,
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          ref
              .watch(userBusinessesProvider)
              .when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Error loading businesses: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                data: (response) {
                  final rawData =
                      (response.data.isNotEmpty && response.data[0] is Map)
                      ? response.data[0]
                      : {};
                  final List<Widget> cards = [];

                  void addCards(String key, String tag, Color color) {
                    final list = rawData[key];
                    if (list is List) {
                      for (var e in list) {
                        final id = e['id']?.toString() ?? '';
                        final name =
                            e['businessName'] ?? e['partnerName'] ?? 'Unknown';

                        final dynamic bType = e['businessType'];
                        String subtitle = tag;
                        if (bType != null) {
                          if (bType is List) {
                            subtitle = bType.join(', ');
                          } else {
                            subtitle = bType.toString();
                          }
                        }

                        if (_searchQuery.isEmpty ||
                            name.toLowerCase().contains(_searchQuery)) {
                          cards.add(
                            _buildBusinessCard(
                              id,
                              name,
                              subtitle,
                              tag,
                              color,
                              color,
                            ),
                          );
                        }
                      }
                    }
                  }

                  addCards(
                    'propagator',
                    'My Business',
                    const Color(0xFF6366F1),
                  ); // Blue
                  addCards(
                    'partnerBusiness',
                    'Partner Business',
                    const Color(0xFFF97316),
                  ); // Orange
                  addCards(
                    'supplierBusiness',
                    'Supplier Business',
                    const Color(0xFF10B981),
                  ); // Green

                  if (cards.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No businesses found.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return Wrap(spacing: 16, runSpacing: 16, children: cards);
                },
              ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _selectedBusinessId != null
                    ? () => setState(() => _currentStep = 2)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.white,
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

  Widget _buildBusinessCard(
    String id,
    String name,
    String subtitle,
    String tag,
    Color tagColor,
    Color iconColor,
  ) {
    bool isSelected = _selectedBusinessId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedBusinessId = id),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.store, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: tagColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Business Setup',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Configure sector, sub sector, and category hierarchy for your business platform architecture.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Internal Flow Indicator
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInternalFlowBadge(
                  '1. Sector Title',
                  _selectedSectorTitle != null,
                ),
                _buildInternalFlowLine(),
                _buildInternalFlowBadge('2. Sector', _selectedSector != null),
                _buildInternalFlowLine(),
                _buildInternalFlowBadge(
                  '3. Sub Sector',
                  _selectedSubSector != null,
                ),
                _buildInternalFlowLine(),
                _buildInternalFlowBadge(
                  '4. Primary Category${_selectedPrimaryCategories.isNotEmpty ? ' (${_selectedPrimaryCategories.length})' : ''}',
                  _selectedPrimaryCategories.isNotEmpty,
                ),
                _buildInternalFlowLine(),
                _buildInternalFlowBadge(
                  '5. Secondary Category${_selectedSecondaryCategories.isNotEmpty ? ' (${_selectedSecondaryCategories.length})' : ''}',
                  _selectedSecondaryCategories.isNotEmpty,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Dropdowns Layer
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: constraints.maxWidth > 800
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth,
                    child: _buildDependentDropdown(
                      label: '1. Sector Title',
                      hint: '-- Select Sector Title --',
                      asyncValue: ref.watch(sectorTitlesProvider),
                      selectedValue: _selectedSectorTitle,
                      isRequired: true,
                      onChanged: (val) {
                        setState(() {
                          _selectedSectorTitle = val;
                          _selectedSector = null;
                          _selectedSubSector = null;
                          _selectedPrimaryCategories.clear();
                          _selectedSecondaryCategories.clear();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 800
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth,
                    child: _buildDependentDropdown(
                      label: '2. Sector',
                      hint: _selectedSectorTitle == null
                          ? '-- Select Sector Title first --'
                          : '-- Select Sector --',
                      asyncValue: _selectedSectorTitle == null
                          ? null
                          : ref.watch(
                              sectorsProvider(_selectedSectorTitle!.id),
                            ),
                      selectedValue: _selectedSector,
                      isDisabled: _selectedSectorTitle == null,
                      isRequired: true,
                      onChanged: (val) {
                        setState(() {
                          _selectedSector = val;
                          _selectedSubSector = null;
                          _selectedPrimaryCategories.clear();
                          _selectedSecondaryCategories.clear();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 800
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth,
                    child: _buildDependentDropdown(
                      label: '3. Sub Sector',
                      hint: _selectedSector == null
                          ? '-- Select Sector first --'
                          : '-- Select Sub Sector --',
                      asyncValue: _selectedSector == null
                          ? null
                          : ref.watch(subSectorsProvider(_selectedSector!.id)),
                      selectedValue: _selectedSubSector,
                      isDisabled: _selectedSector == null,
                      isRequired: true,
                      onChanged: (val) {
                        setState(() {
                          _selectedSubSector = val;
                          _selectedPrimaryCategories.clear();
                          _selectedSecondaryCategories.clear();
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Categories Layer
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: constraints.maxWidth > 800
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildCategoryBox(
                      title: '4. Primary Category',
                      isDisabled: _selectedSubSector == null,
                      emptyMessage:
                          'Select a Sub Sector above to load primary categories',
                      asyncValue: _selectedSubSector == null
                          ? null
                          : ref.watch(
                              primaryCategoriesProvider(_selectedSubSector!.id),
                            ),
                      selectedItems: _selectedPrimaryCategories,
                      searchHint: 'Search primary categories...',
                      searchQuery: _primaryCategorySearch,
                      onSearchChanged: (val) {
                        setState(() {
                          _primaryCategorySearch = val.trim();
                        });
                      },
                      onToggle: (item, isChecked) {
                        setState(() {
                          if (isChecked) {
                            if (!_selectedPrimaryCategories.any((p) => p.id == item.id)) {
                              _selectedPrimaryCategories.add(item);
                            }
                          } else {
                            _selectedPrimaryCategories.removeWhere((p) => p.id == item.id);
                            if (item.secondaryCategories != null) {
                              final secIds = item.secondaryCategories!.map((s) => s.id).toSet();
                              _selectedSecondaryCategories.removeWhere((s) => secIds.contains(s.id));
                            }
                          }
                        });
                      },
                      onSelectAll: () {
                        if (_selectedSubSector == null) return;
                        final asyncData = ref.read(
                          primaryCategoriesProvider(_selectedSubSector!.id),
                        );
                        if (asyncData.hasValue && asyncData.value != null) {
                          setState(() {
                            _selectedPrimaryCategories.clear();
                            _selectedPrimaryCategories.addAll(asyncData.value!);
                          });
                        }
                      },
                      onClearAll: () {
                        setState(() {
                          _selectedPrimaryCategories.clear();
                          _selectedSecondaryCategories.clear();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth > 800
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: _buildCategoryBox(
                      title: '5. Secondary Category',
                      isDisabled: _selectedPrimaryCategories.isEmpty,
                      emptyMessage:
                          'Select one or more Primary Categories to load secondary categories',
                      asyncValue: _selectedPrimaryCategories.isEmpty
                          ? null
                          : AsyncData(_availableSecondaryCategories),
                      selectedItems: _selectedSecondaryCategories,
                      badgeBuilder: (item) => item.parentName,
                      searchHint: 'Search secondary categories...',
                      searchQuery: _secondaryCategorySearch,
                      onSearchChanged: (val) {
                        setState(() {
                          _secondaryCategorySearch = val.trim();
                        });
                      },
                      onToggle: (item, isChecked) {
                        setState(() {
                          if (isChecked) {
                            if (!_selectedSecondaryCategories.any((s) => s.id == item.id)) {
                              _selectedSecondaryCategories.add(item);
                            }
                          } else {
                            _selectedSecondaryCategories.removeWhere((s) => s.id == item.id);
                          }
                        });
                      },
                      onSelectAll: () {
                        if (_selectedPrimaryCategories.isEmpty) return;
                        setState(() {
                          _selectedSecondaryCategories.clear();
                          _selectedSecondaryCategories.addAll(_availableSecondaryCategories);
                        });
                      },
                      onClearAll: () {
                        setState(() {
                          _selectedSecondaryCategories.clear();
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 1),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text('Back', style: GoogleFonts.poppins()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.black87,
                ),
              ),
              ElevatedButton(
                onPressed: _selectedSubSector != null
                    ? () => setState(() => _currentStep = 3)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.white,
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

  Widget _buildInternalFlowBadge(String text, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isCompleted ? const Color(0xFF10B981) : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check, size: 12, color: Color(0xFF10B981)),
          ],
        ],
      ),
    );
  }

  Widget _buildInternalFlowLine() {
    return Container(
      width: 16,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.shade300,
    );
  }

  Widget _buildDependentDropdown({
    required String label,
    required String hint,
    required AsyncValue<List<CategoryModel>>? asyncValue,
    CategoryModel? selectedValue,
    bool isDisabled = false,
    bool isRequired = false,
    required ValueChanged<CategoryModel?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedValue != null
              ? const Color(0xFF6366F1)
              : Colors.grey.shade200,
          width: selectedValue != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (isRequired)
                      TextSpan(
                        text: ' *',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                selectedValue != null
                    ? 'SELECTED'
                    : (isDisabled ? 'LOCKED' : 'REQUIRED'),
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: selectedValue != null
                      ? const Color(0xFF10B981)
                      : (isDisabled ? Colors.grey : const Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: asyncValue == null
                ? _buildDisabledDropdown(hint)
                : asyncValue.when(
                    loading: () => _buildLoadingDropdown(),
                    error: (err, stack) => _buildErrorDropdown(err.toString()),
                    data: (items) => DropdownButtonHideUnderline(
                      child: DropdownButton<CategoryModel>(
                        value: selectedValue,
                        isExpanded: true,
                        hint: Text(
                          hint,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black38,
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: isDisabled ? Colors.black26 : Colors.black54,
                        ),
                        items: isDisabled
                            ? []
                            : items
                                  .map(
                                    (item) => DropdownMenuItem<CategoryModel>(
                                      value: item,
                                      child: Text(
                                        item.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        onChanged: isDisabled ? null : onChanged,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledDropdown(String hint) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<CategoryModel>(
        value: null,
        isExpanded: true,
        hint: Text(
          hint,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black26),
        items: const [],
        onChanged: null,
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDropdown(String err) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Error: $err',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
      ),
    );
  }

  Widget _buildCategoryBox({
    required String title,
    required bool isDisabled,
    required String emptyMessage,
    required AsyncValue<List<CategoryModel>>? asyncValue,
    required List<CategoryModel> selectedItems,
    required Function(CategoryModel, bool) onToggle,
    required VoidCallback onSelectAll,
    required VoidCallback onClearAll,
    String? Function(CategoryModel)? badgeBuilder,
    String searchHint = 'Search categories...',
    String searchQuery = '',
    ValueChanged<String>? onSearchChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${selectedItems.length} Selected',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: isDisabled ? null : onSelectAll,
                      child: Text(
                        'Select All',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDisabled
                              ? Colors.grey
                              : const Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: isDisabled ? null : onClearAll,
                      child: Text(
                        'Clear All',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDisabled ? Colors.grey : Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: Colors.black38),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: !isDisabled,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: searchHint,
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 200,
            color: Colors.grey.shade50,
            child: isDisabled || asyncValue == null
                ? _buildEmptyState(emptyMessage)
                : asyncValue.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    data: (items) {
                      final filtered = searchQuery.isEmpty
                          ? items
                          : items
                              .where((e) => e.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                              .toList();
                      if (filtered.isEmpty) {
                        return _buildEmptyState('No categories available.');
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isSelected = selectedItems.any((e) => e.id == item.id);
                          final badgeText = badgeBuilder?.call(item);
                          return Material(
                            color: Colors.transparent,
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (val) => onToggle(item, val ?? false),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (badgeText != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.black45,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              activeColor: const Color(0xFF6366F1),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String emptyMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.layers_clear_outlined,
            color: Colors.black26,
            size: 32,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              emptyMessage,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              Widget headerContent = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.language,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3. Platform Selection (${_selectedPlatforms.length} Selected)',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Select one or more Platform architectures where your business operates.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              Widget actionsAndSearch = Column(
                crossAxisAlignment: isSmall
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final asyncPlatforms = ref.read(platformsProvider);
                          asyncPlatforms.whenData((response) {
                            setState(() {
                              _selectedPlatforms.clear();
                              final withoutExport = response.data
                                  .where((p) => !(p['platformName'] ?? p['name'] ?? '').toString().toLowerCase().contains('export'))
                                  .toList();
                              _selectedPlatforms.addAll(withoutExport);
                            });
                          });
                        },
                        child: Text(
                          'Select All',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlatforms.clear();
                          });
                        },
                        child: Text(
                          'Unselect All',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: isSmall ? double.infinity : 250,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search platform...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.black38,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent,
                    const SizedBox(height: 16),
                    actionsAndSearch,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: headerContent),
                  const SizedBox(width: 16),
                  actionsAndSearch,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          ref
              .watch(platformsProvider)
              .when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'Error loading platforms',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ),
                ),
                data: (response) {
                  final platforms = response.data
                      .where((p) => !(p['platformName'] ?? p['name'] ?? '').toString().toLowerCase().contains('export'))
                      .toList();
                  final filteredPlatforms = _searchQuery.isEmpty
                      ? platforms
                      : platforms
                            .where(
                              (p) => (p['platformName'] ?? p['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()),
                            )
                            .toList();

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: filteredPlatforms.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                'No platform found matching "$_searchQuery"',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black38,
                                ),
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 600;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: isMobile ? 180 : 250,
                                  crossAxisSpacing: isMobile ? 12 : 16,
                                  mainAxisSpacing: isMobile ? 12 : 16,
                                  childAspectRatio: isMobile ? 0.92 : 1.15,
                                ),
                                itemCount: filteredPlatforms.length,
                                itemBuilder: (context, index) {
                                  final platform = filteredPlatforms[index];
                                  final isSelected = _selectedPlatforms.any(
                                    (p) => p['id'] == platform['id'],
                                  );

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedPlatforms.removeWhere(
                                            (p) => p['id'] == platform['id'],
                                          );
                                        } else {
                                          _selectedPlatforms.add(platform);
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFEEF2FF)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF6366F1)
                                              : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : const Color(0xFFF8F9FE),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.storefront,
                                                      size: 22,
                                                      color: isSelected
                                                          ? const Color(0xFF6366F1)
                                                          : Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    platform['platformName']?.toString() ?? 'Unknown',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: isSelected
                                                          ? const Color(0xFF6366F1)
                                                          : Colors.black87,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Operational Platform',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: Colors.black54,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  if (isSelected) ...[
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.check,
                                                          size: 12,
                                                          color: Color(0xFF6366F1),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          'Selected',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 10,
                                                            color: const Color(0xFF6366F1),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF6366F1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 11,
                                                  color: Colors.white,
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
                  );
                },
              ),

          const SizedBox(height: 32),

          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 2),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text('Back', style: GoogleFonts.poppins(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 4;
                      final effective = _getEffectivePlatforms();
                      if (_activePlatformId == null || !effective.any((p) => p['id']?.toString() == _activePlatformId)) {
                        _activePlatformId = effective.first['id']?.toString() ?? '1';
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final effectivePlatforms = _getEffectivePlatforms();
    if (_activePlatformId == null || !effectivePlatforms.any((p) => p['id']?.toString() == _activePlatformId)) {
      _activePlatformId = effectivePlatforms.first['id']?.toString() ?? '1';
    }

    final activePlatform = effectivePlatforms.firstWhere(
      (p) => p['id']?.toString() == _activePlatformId,
      orElse: () => effectivePlatforms.first,
    );
    final activePlatformName = activePlatform['platformName'] ?? activePlatform['name'] ?? 'Shop';
    final activePlatformId = activePlatform['id']?.toString() ?? '1';

    // Watch all shop types from API or use default
    final asyncShopTypes = ref.watch(allShopTypesProvider);
    final List<Map<String, dynamic>> allShopTypes = asyncShopTypes.maybeWhen(
      data: (response) {
        if (response.data.isNotEmpty) {
          return response.data.map<Map<String, dynamic>>((item) {
            var rawName = (item['shopTypeName'] ?? item['name'] ?? item['shop_type_name'] ?? '').toString();
            if (rawName.isEmpty) rawName = 'Shop Type';
            // Match design screenshot: id 1 named Retail -> BK
            if (item['id']?.toString() == '1' && rawName.toLowerCase() == 'retail') {
              rawName = 'BK';
            }
            return {
              'id': item['id']?.toString() ?? '0',
              'name': rawName,
              'shopTypeName': rawName,
              'description': item['description'] ?? '',
            };
          }).toList();
        }
        return _defaultShopTypes;
      },
      orElse: () => _defaultShopTypes,
    );

    final filteredShopTypes = _shopTypeSearchQuery.isEmpty
        ? allShopTypes
        : allShopTypes.where((st) {
            final name = (st['shopTypeName'] ?? st['name'] ?? '').toString().toLowerCase();
            return name.contains(_shopTypeSearchQuery);
          }).toList();

    final selectedForActivePlatform = _configuredShopTypesByPlatform[activePlatformId] ?? [];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Search Box
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 650;
              Widget headerContent = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.layers_outlined,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4. Shop Type Selection',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'For each selected Platform, select multiple Shop Types / operation models.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              Widget searchBox = Container(
                width: isSmall ? double.infinity : 250,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _shopTypeSearchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search shop type...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                  ),
                ),
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent,
                    const SizedBox(height: 16),
                    searchBox,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: headerContent),
                  const SizedBox(width: 16),
                  searchBox,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Platform Selector Tabs
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Select Platform to configure:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              ...effectivePlatforms.map((platform) {
                final pId = platform['id']?.toString() ?? '';
                final pName = platform['platformName'] ?? platform['name'] ?? 'Platform';
                final isSelected = pId == activePlatformId;
                final count = (_configuredShopTypesByPlatform[pId] ?? []).length;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _activePlatformId = pId;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 15,
                          color: isSelected ? const Color(0xFF6366F1) : Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF6366F1) : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Shop Types Sub-container with Grid
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: "Shop Types for [icon] Shop (0 Selected)" + Select All / Unselect All
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Shop Types for ',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Icon(
                          Icons.language,
                          size: 15,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activePlatformName,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        Text(
                          ' (${selectedForActivePlatform.length} Selected)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              final list = _configuredShopTypesByPlatform.putIfAbsent(activePlatformId, () => []);
                              for (final st in filteredShopTypes) {
                                if (!list.any((item) => item['id']?.toString() == st['id']?.toString())) {
                                  list.add(Map<String, dynamic>.from(st));
                                }
                              }
                            });
                          },
                          child: Text(
                            'Select All',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '|',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _configuredShopTypesByPlatform[activePlatformId] = [];
                            });
                          },
                          child: Text(
                            'Unselect All',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Grid of Shop Type Cards
                filteredShopTypes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No shop types found matching "$_shopTypeSearchQuery"',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: constraints.maxWidth < 600 ? double.infinity : 280,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: constraints.maxWidth < 450 ? 1.4 : 1.18,
                            ),
                            itemCount: filteredShopTypes.length,
                            itemBuilder: (context, index) {
                              final shopType = filteredShopTypes[index];
                              final stId = shopType['id']?.toString() ?? '';
                              final isSelected = selectedForActivePlatform.any(
                                (item) => item['id']?.toString() == stId,
                              );

                              return _buildShopTypeCard(
                                shopType: shopType,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    final list = _configuredShopTypesByPlatform.putIfAbsent(activePlatformId, () => []);
                                    if (isSelected) {
                                      list.removeWhere((item) => item['id']?.toString() == stId);
                                    } else {
                                      list.add(Map<String, dynamic>.from(shopType));
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Configured Shop Types Summary Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configured Shop Types Summary:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...effectivePlatforms.map((platform) {
                  final pId = platform['id']?.toString() ?? '';
                  final pName = platform['platformName'] ?? platform['name'] ?? 'Platform';
                  final list = _configuredShopTypesByPlatform[pId] ?? [];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language,
                              size: 14,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$pName:',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: list.isEmpty
                              ? Text(
                                  'No shop types added yet.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black38,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: list.map((st) {
                                    final stName = st['shopTypeName'] ?? st['name'] ?? '';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFC7D2FE),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            stName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF4338CA),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _configuredShopTypesByPlatform[pId]?.removeWhere(
                                                  (item) => item['id']?.toString() == st['id']?.toString(),
                                                );
                                              });
                                            },
                                            child: const Icon(
                                              Icons.close,
                                              size: 13,
                                              color: Color(0xFF6366F1),
                                            ),
                                          ),
                                        ],
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
          const SizedBox(height: 32),

          // 5. Bottom Navigation Buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 3),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text('Back', style: GoogleFonts.poppins(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _currentStep = 5);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopTypeCard({
    required Map<String, dynamic> shopType,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final name = shopType['shopTypeName'] ?? shopType['name'] ?? 'Shop Type';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9FAFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.layers_outlined,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF6366F1) : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Custom shop model configured for selected platform(s).',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black45,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check, size: 12, color: Color(0xFF6366F1)),
                            const SizedBox(width: 4),
                            Text(
                              'Added',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '+ Click to Add',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final effectivePlatforms = _getEffectivePlatforms();
    if (_activeStep5PlatformId == null ||
        !effectivePlatforms.any((p) => p['id']?.toString() == _activeStep5PlatformId)) {
      _activeStep5PlatformId = _activePlatformId ?? effectivePlatforms.first['id']?.toString() ?? '1';
    }

    final activePlatform = effectivePlatforms.firstWhere(
      (p) => p['id']?.toString() == _activeStep5PlatformId,
      orElse: () => effectivePlatforms.first,
    );
    final activePlatformName = activePlatform['platformName'] ?? activePlatform['name'] ?? 'Shop';
    final activePlatformId = activePlatform['id']?.toString() ?? '1';

    // Shop types configured in Step 4 for active platform
    var shopTypesForPlatform = _configuredShopTypesByPlatform[activePlatformId] ?? [];
    if (shopTypesForPlatform.isEmpty && activePlatformId == '2') {
      shopTypesForPlatform = [
        {'id': '1', 'name': 'BK', 'shopTypeName': 'BK'}
      ];
    }

    if (_activeStep5ShopTypeId == null ||
        !shopTypesForPlatform.any((st) => st['id']?.toString() == _activeStep5ShopTypeId)) {
      _activeStep5ShopTypeId = shopTypesForPlatform.isNotEmpty
          ? shopTypesForPlatform.first['id']?.toString()
          : null;
    }

    final activeShopType = shopTypesForPlatform.firstWhere(
      (st) => st['id']?.toString() == _activeStep5ShopTypeId,
      orElse: () => shopTypesForPlatform.isNotEmpty ? shopTypesForPlatform.first : {'name': 'Shop Type'},
    );
    final activeShopTypeName = activeShopType['shopTypeName'] ?? activeShopType['name'] ?? 'Shop Type';
    final activeShopTypeId = activeShopType['id']?.toString() ?? '0';

    final assignmentKey = '${activePlatformId}_$activeShopTypeId';
    final currentAssignedStores = _assignedStoresByPlatformAndShopType[assignmentKey] ?? [];

    // Watch stores from provider
    final asyncStores = ref.watch(storesProvider);
    final List<StoreModel> allStores = asyncStores.maybeWhen(
      data: (stores) => stores,
      orElse: () => [],
    );

    final singleBranchCount = allStores.where((s) => s.branchManagementModel.toLowerCase().contains('single')).length;
    final multipleBranchCount = allStores.where((s) => s.branchManagementModel.toLowerCase().contains('multiple')).length;

    final filteredStores = allStores.where((store) {
      if (_branchTypeFilter == 'Single Branch' && !store.branchManagementModel.toLowerCase().contains('single')) {
        return false;
      }
      if (_branchTypeFilter == 'Multiple Branch' && !store.branchManagementModel.toLowerCase().contains('multiple')) {
        return false;
      }
      if (_storeSearchQuery.isNotEmpty) {
        final q = _storeSearchQuery.toLowerCase();
        final matchName = store.storeName.toLowerCase().contains(q);
        final matchCity = store.cityVillage.toLowerCase().contains(q);
        return matchName || matchCity;
      }
      return true;
    }).toList();

    // Stats for preview badge:
    final totalPlatforms = effectivePlatforms.length;
    int totalShopTypes = 0;
    int totalConnectedStores = 0;
    for (final p in effectivePlatforms) {
      final pId = p['id']?.toString() ?? '';
      final stList = _configuredShopTypesByPlatform[pId] ?? (pId == '2' && shopTypesForPlatform.isNotEmpty ? shopTypesForPlatform : []);
      totalShopTypes += stList.length;
      for (final st in stList) {
        final stId = st['id']?.toString() ?? '';
        final key = '${pId}_$stId';
        totalConnectedStores += (_assignedStoresByPlatformAndShopType[key] ?? []).length;
      }
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Single Branch, Multiple Branch, and Search Store
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 750;
              Widget titleWidget = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5. Store Setup & Complete Hierarchy Mapping',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Assign physical or virtual stores under each Shop Type under each Platform.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              Widget filtersAndSearch = Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Single Branch pill
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _branchTypeFilter = _branchTypeFilter == 'Single Branch' ? 'all' : 'Single Branch';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _branchTypeFilter == 'Single Branch' ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _branchTypeFilter == 'Single Branch' ? const Color(0xFF6366F1) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storefront, size: 14, color: _branchTypeFilter == 'Single Branch' ? const Color(0xFF6366F1) : Colors.black45),
                          const SizedBox(width: 6),
                          Text('Single Branch', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87)),
                          const SizedBox(width: 6),
                          Text('$singleBranchCount', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  // Multiple Branch pill
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _branchTypeFilter = _branchTypeFilter == 'Multiple Branch' ? 'all' : 'Multiple Branch';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _branchTypeFilter == 'Multiple Branch' ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _branchTypeFilter == 'Multiple Branch' ? const Color(0xFF6366F1) : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storefront, size: 14, color: _branchTypeFilter == 'Multiple Branch' ? const Color(0xFF6366F1) : Colors.black45),
                          const SizedBox(width: 6),
                          Text('Multiple Branch', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87)),
                          const SizedBox(width: 6),
                          Text('$multipleBranchCount', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                  // Search box
                  Container(
                    width: isSmall ? double.infinity : 180,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _storeSearchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search store...',
                        hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.black38),
                        prefixIcon: const Icon(Icons.search, size: 16, color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 16),
                    filtersAndSearch,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 16),
                  filtersAndSearch,
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. Platform Selector: Platform: [Shop] [Local Online]
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Platform:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              ...effectivePlatforms.map((platform) {
                final pId = platform['id']?.toString() ?? '';
                final pName = platform['platformName'] ?? platform['name'] ?? 'Platform';
                final isSelected = pId == activePlatformId;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _activeStep5PlatformId = pId;
                      final stList = _configuredShopTypesByPlatform[pId] ?? [];
                      _activeStep5ShopTypeId = stList.isNotEmpty ? stList.first['id']?.toString() : null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 15,
                          color: isSelected ? const Color(0xFF6366F1) : Colors.black45,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF6366F1) : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Shop Type under <Platform>: [BK (0)]
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Shop Type under $activePlatformName:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (shopTypesForPlatform.isEmpty)
                Text(
                  'No shop types configured. Go to Step 4 to add.',
                  style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black38),
                )
              else
                ...shopTypesForPlatform.map((st) {
                  final stId = st['id']?.toString() ?? '';
                  final stName = st['shopTypeName'] ?? st['name'] ?? 'Shop Type';
                  final isSelected = stId == _activeStep5ShopTypeId;
                  final storeKey = '${activePlatformId}_$stId';
                  final count = (_assignedStoresByPlatformAndShopType[storeKey] ?? []).length;

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() {
                        _activeStep5ShopTypeId = stId;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 15,
                            color: isSelected ? const Color(0xFF10B981) : Colors.black45,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF10B981) : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($count)',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF10B981) : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Assign Stores for: Platform -> Shop Type (count Selected)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Assign Stores for: ',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Icon(Icons.language, size: 14, color: Color(0xFF6366F1)),
                        const SizedBox(width: 4),
                        Text(
                          activePlatformName,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                        ),
                        const SizedBox(width: 4),
                        const Text('→', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        const SizedBox(width: 4),
                        const Icon(Icons.storefront, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          activeShopTypeName,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                        ),
                        Text(
                          ' (${currentAssignedStores.length} Selected)',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              final list = _assignedStoresByPlatformAndShopType.putIfAbsent(assignmentKey, () => []);
                              for (final store in filteredStores) {
                                if (!list.any((s) => s['id'] == store.id)) {
                                  list.add({'id': store.id, 'name': store.storeName});
                                }
                              }
                            });
                          },
                          child: Text(
                            'Select All',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6366F1)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('|', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _assignedStoresByPlatformAndShopType[assignmentKey] = [];
                            });
                          },
                          child: Text(
                            'Unselect All',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                filteredStores.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Text(
                            'No stores available.',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          crossAxisSpacing: isMobile ? 10 : 16,
                          mainAxisSpacing: isMobile ? 10 : 16,
                          childAspectRatio: isMobile ? 2.0 : 1.6,
                        ),
                        itemCount: filteredStores.length,
                        itemBuilder: (context, index) {
                          final store = filteredStores[index];
                          final isAssigned = currentAssignedStores.any((s) => s['id'] == store.id);

                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                final list = _assignedStoresByPlatformAndShopType.putIfAbsent(assignmentKey, () => []);
                                if (isAssigned) {
                                  list.removeWhere((s) => s['id'] == store.id);
                                } else {
                                  list.add({'id': store.id, 'name': store.storeName});
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isAssigned ? const Color(0xFFEEF2FF) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isAssigned ? const Color(0xFF6366F1) : Colors.grey.shade200,
                                  width: isAssigned ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isAssigned ? Colors.white : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.store, color: isAssigned ? const Color(0xFF6366F1) : Colors.black54, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          store.storeName,
                                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          store.branchManagementModel,
                                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isAssigned ? Icons.check_circle : Icons.circle_outlined,
                                    color: isAssigned ? const Color(0xFF6366F1) : Colors.grey.shade300,
                                    size: 18,
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

          // 5. Complete Saved Hierarchy Preview
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.layers_outlined, size: 16, color: Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Complete Saved Hierarchy Preview',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Platform → Shop Type → Store',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$totalPlatforms Platforms | $totalShopTypes Shop Types | $totalConnectedStores Stores',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...effectivePlatforms.map((platform) {
                  final pId = platform['id']?.toString() ?? '';
                  final pName = platform['platformName'] ?? platform['name'] ?? 'Platform';
                  var stList = _configuredShopTypesByPlatform[pId] ?? [];
                  if (stList.isEmpty && pId == '2' && shopTypesForPlatform.isNotEmpty) {
                    stList = shopTypesForPlatform;
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: EdgeInsets.all(isMobile ? 10 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFBFD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Platform row
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.language, size: 14, color: Color(0xFF6366F1)),
                                const SizedBox(width: 6),
                                Text(
                                  pName,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${stList.length} Shop Types',
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _configuredShopTypesByPlatform[pId] = [];
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Remove Platform',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (stList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'No shop types configured for $pName. Go to Step 4 to add shop types.',
                              style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black38),
                            ),
                          )
                        else
                          ...stList.map((st) {
                            final stId = st['id']?.toString() ?? '';
                            final stName = st['shopTypeName'] ?? st['name'] ?? 'Shop Type';
                            final storeKey = '${pId}_$stId';
                            final assigned = _assignedStoresByPlatformAndShopType[storeKey] ?? [];

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 10),
                              padding: EdgeInsets.all(isMobile ? 10 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF10B981)),
                                          const SizedBox(width: 6),
                                          Text(
                                            stName,
                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECFDF5),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '${assigned.length} Connected Stores',
                                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _configuredShopTypesByPlatform[pId]?.removeWhere((item) => item['id']?.toString() == stId);
                                            _assignedStoresByPlatformAndShopType.remove(storeKey);
                                          });
                                        },
                                        child: Text(
                                          '✕ Remove',
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (assigned.isEmpty)
                                    Text(
                                      'No stores assigned yet. Click on store cards above to connect.',
                                      style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black38),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: assigned.map((s) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            s['name'] ?? 'Store',
                                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF4338CA)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 6. Bottom Navigation Buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 4),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text('Back', style: GoogleFonts.poppins(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Business Setup & Complete Hierarchy Saved Successfully!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const BusinessSetupListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Save Business Setup',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.check, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


