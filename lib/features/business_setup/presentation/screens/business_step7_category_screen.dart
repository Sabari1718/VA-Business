import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _sectorTitles = [
    '-- Select Sector Title --',
    'Goods & Merchandise',
    'Services & Solutions',
    'Manufacturing & Industrial',
    'Digital & Technology',
  ];

  static const List<String> _sectors = [
    '-- Select Sector --',
    'Retail & Consumer Goods',
    'Information & Technology',
    'Healthcare & Pharma',
    'Food & Hospitality',
    'Textile & Apparel',
    'Automotive & Transport',
  ];

  static const List<String> _subSectors = [
    '-- Select Sub Sector --',
    'Supermarkets & Grocery Stores',
    'Clothing & Fashion Stores',
    'Consumer Electronics & Gadgets',
    'Home Decor & Furnishing',
    'Pharmacy & Health Essentials',
  ];

  static const List<Map<String, dynamic>> _sampleCategories = [
    {'id': 'Grocery & Staples', 'name': 'Grocery & Staples', 'icon': Icons.local_grocery_store_outlined, 'color': Color(0xFF0284C7)},
    {'id': 'Fruits & Vegetables', 'name': 'Fruits & Vegetables', 'icon': Icons.eco_outlined, 'color': Color(0xFF16A34A)},
    {'id': 'Beverages & Juices', 'name': 'Beverages & Juices', 'icon': Icons.local_drink_outlined, 'color': Color(0xFFEA580C)},
    {'id': 'Dairy & Bakery', 'name': 'Dairy & Bakery', 'icon': Icons.breakfast_dining_outlined, 'color': Color(0xFFD97706)},
    {'id': 'Personal Care & Hygiene', 'name': 'Personal Care & Hygiene', 'icon': Icons.clean_hands_outlined, 'color': Color(0xFF9333EA)},
    {'id': 'Home & Kitchen Essentials', 'name': 'Home & Kitchen Essentials', 'icon': Icons.kitchen_outlined, 'color': Color(0xFF4F46E5)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedValue = items.contains(value) ? value : items.first;

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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
              style: TextStyle(
                fontSize: 13,
                color: selectedValue == items.first ? const Color(0xFF94A3B8) : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
    final navNotifier = ref.read(navigationProvider.notifier);
    final setupState = ref.watch(businessSetupProvider);
    final setupNotifier = ref.read(businessSetupProvider.notifier);

    final bool hasSelection = setupState.selectedSectorTitle != null &&
        setupState.selectedSectorTitle != _sectorTitles.first &&
        setupState.selectedSector != null &&
        setupState.selectedSector != _sectors.first &&
        setupState.selectedSubSector != null &&
        setupState.selectedSubSector != _subSectors.first;

    final filteredCategories = _sampleCategories.where((cat) {
      final name = cat['name'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
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
              // Stepper Header (Step 7 active)
              BusinessSetupStepperHeader(
                currentStep: 7,
                navNotifier: navNotifier,
              ),

              const SizedBox(height: 20),

              // Main Card: Step 7: Business Category Classification
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
                    // Step Badge
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

                    // 3 Dropdowns (Sector Title, Sector, Sub Sector)
                    if (isMobile) ...[
                      _buildDropdown(
                        label: 'Sector Title *',
                        value: setupState.selectedSectorTitle,
                        items: _sectorTitles,
                        onChanged: (val) => setupNotifier.updateSectorTitle(val),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown(
                        label: 'Sector *',
                        value: setupState.selectedSector,
                        items: _sectors,
                        onChanged: (val) => setupNotifier.updateSector(val),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown(
                        label: 'Sub Sector *',
                        value: setupState.selectedSubSector,
                        items: _subSectors,
                        onChanged: (val) => setupNotifier.updateSubSector(val),
                      ),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Sector Title *',
                              value: setupState.selectedSectorTitle,
                              items: _sectorTitles,
                              onChanged: (val) => setupNotifier.updateSectorTitle(val),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Sector *',
                              value: setupState.selectedSector,
                              items: _sectors,
                              onChanged: (val) => setupNotifier.updateSector(val),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Sub Sector *',
                              value: setupState.selectedSubSector,
                              items: _subSectors,
                              onChanged: (val) => setupNotifier.updateSubSector(val),
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
                          // Header: Title + Search
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCategoryHeaderTitle(),
                                    const SizedBox(height: 12),
                                    _buildSearchBar(),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCategoryHeaderTitle(),
                                    SizedBox(
                                      width: 260,
                                      child: _buildSearchBar(),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 20),

                          // Cards Area or Empty State
                          if (!hasSelection)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6), size: 28),
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
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 1 : 3,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 80,
                              ),
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final cat = filteredCategories[index];
                                final String id = cat['id'] as String;
                                final bool isSelected =
                                    setupState.selectedPrimaryCategories.contains(id);

                                return InkWell(
                                  onTap: () => setupNotifier.togglePrimaryCategory(id),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            cat['name'] as String,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: isSelected ? const Color(0xFF1E3A8A) : AppColors.textDark,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
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
                          icon: const Icon(Icons.cancel_outlined, size: 16),
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
                            if (!hasSelection) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select Sector Title, Sector, and Sub Sector.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Proceed to Step 8: Brand Selection',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isMobile ? 12 : 13.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
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

  Widget _buildCategoryHeaderTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Primary Category Visual Cards (Multi-Select)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          'Select primary category cards to load secondary sub-categories.',
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
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
}
