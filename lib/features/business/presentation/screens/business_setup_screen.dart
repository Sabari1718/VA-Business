import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_providers.dart';
import '../providers/category_providers.dart';
import '../providers/platform_providers.dart';
import '../../data/models/category_model.dart';

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

  // Step 3 State
  final List<dynamic> _selectedPlatforms = [];

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildTopStepper(),
              const SizedBox(height: 24),
              _currentStep == 1
                  ? _buildStep1()
                  : (_currentStep == 2 ? _buildStep2() : _buildStep3()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStepper() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
    return Column(
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
                      onToggle: (item, isChecked) {
                        setState(() {
                          if (isChecked) {
                            _selectedPrimaryCategories.add(item);
                          } else {
                            _selectedPrimaryCategories.remove(item);
                            // Also remove dependent secondary categories? For now let's just clear all if it's too complex
                          }
                        });
                      },
                      onSelectAll: () {
                        if (_selectedSubSector == null) return;
                        final asyncData = ref.read(
                          primaryCategoriesProvider(_selectedSubSector!.id),
                        );
                        if (asyncData.hasValue) {
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
                          : ref.watch(
                              combinedSecondaryCategoriesProvider(
                                _selectedPrimaryCategories
                                    .map((e) => e.id)
                                    .toList(),
                              ),
                            ),
                      selectedItems: _selectedSecondaryCategories,
                      onToggle: (item, isChecked) {
                        setState(() {
                          if (isChecked) {
                            _selectedSecondaryCategories.add(item);
                          } else {
                            _selectedSecondaryCategories.remove(item);
                          }
                        });
                      },
                      onSelectAll: () {
                        if (_selectedPrimaryCategories.isEmpty) return;
                        final asyncData = ref.read(
                          combinedSecondaryCategoriesProvider(
                            _selectedPrimaryCategories
                                .map((e) => e.id)
                                .toList(),
                          ),
                        );
                        if (asyncData.hasValue) {
                          setState(() {
                            _selectedSecondaryCategories.clear();
                            _selectedSecondaryCategories.addAll(
                              asyncData.value!,
                            );
                          });
                        }
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
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
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
                      if (items.isEmpty)
                        return _buildEmptyState('No categories available.');
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = selectedItems.contains(item);
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
                              _selectedPlatforms.addAll(response.data);
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
                  final platforms = response.data;
                  final filteredPlatforms = _searchQuery.isEmpty
                      ? platforms
                      : platforms
                            .where(
                              (p) => p['platformName']
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
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 250,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFFF8F9FE),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.storefront,
                                                size: 28,
                                                color: isSelected
                                                    ? const Color(0xFF6366F1)
                                                    : Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              platform['platformName']
                                                      ?.toString() ??
                                                  'Unknown',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? const Color(0xFF6366F1)
                                                    : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Operational Platform',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
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
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      if (isSelected)
                                        Positioned(
                                          bottom: 12,
                                          left: 0,
                                          right: 0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                  color: const Color(
                                                    0xFF6366F1,
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep = 2),
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
                onPressed: () {}, // Mock next for step 4
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
}
