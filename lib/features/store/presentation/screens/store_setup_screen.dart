import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  bool _isSetupTab = true;
  String? _selectedCategory;
  final List<Map<String, dynamic>> _categoryBrandMappings = [];
  final TextEditingController _storeSetupNameController = TextEditingController();

  final List<String> _availableCategories = [
    'Buses',
    'Trucks',
    'School Buses',
    'Passenger Buses',
    'Heavy Trucks',
    'Light Commercial Trucks',
  ];

  final Map<String, List<String>> _availableBrandsByCategory = {
    'Buses': ['Tata Motors', 'Ashok Leyland', 'BharatBenz', 'Volvo'],
    'Trucks': ['Tata Motors', 'Mahindra', 'Eicher', 'BharatBenz'],
    'School Buses': ['Tata Starbus', 'Ashok Leyland Sunshine', 'Eicher Starline'],
    'Passenger Buses': ['Volvo 9600', 'Scania Metrolink', 'Mercedes-Benz'],
    'Heavy Trucks': ['BharatBenz 5528TT', 'Tata Signa', 'Ashok Leyland AVTR'],
    'Light Commercial Trucks': ['Tata Ace', 'Mahindra Bolero Maxi Truck', 'Ashok Leyland Dost'],
  };

  @override
  void dispose() {
    _storeSetupNameController.dispose();
    super.dispose();
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
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'B',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business',
                  style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Business Suite',
                  style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _isSetupTab ? _buildSetupTab() : _buildListTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        
        Widget titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Setup',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E2D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure your store hierarchy and catalog across a clean 3-stage workflow.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            ),
          ],
        );
        
        Widget tabs = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabButton(
                title: '3-Stage Setup',
                icon: Icons.account_tree_outlined,
                isSelected: _isSetupTab,
                onTap: () => setState(() => _isSetupTab = true),
              ),
              _buildTabButton(
                title: 'Store Setups List',
                icon: Icons.store_mall_directory_outlined,
                isSelected: !_isSetupTab,
                onTap: () => setState(() => _isSetupTab = false),
                badgeCount: 0,
              ),
            ],
          ),
        );
        
        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleSection,
              const SizedBox(height: 16),
              tabs,
            ],
          );
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: titleSection),
            tabs,
          ],
        );
      },
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListTab() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Table Header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  _buildTableHeaderCell('S.NO', width: 60),
                  _buildTableHeaderCell('BUSINESS ENTITY', width: 150),
                  _buildTableHeaderCell('PLATFORM & SHOP MODEL', width: 200),
                  _buildTableHeaderCell('MAPPED STORE', width: 150),
                  _buildTableHeaderCell('SECTOR & CATEGORY HIERARCHY', width: 250),
                  _buildTableHeaderCell('CREATED DATE', width: 120),
                  _buildTableHeaderCell('ACTIONS', width: 100),
                ],
              ),
            ),
          ),
          // Empty state
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront_outlined, size: 48, color: Color(0xFF6366F1)),
                const SizedBox(height: 16),
                Text(
                  'No Store Setups Configured',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "Click the '3-Stage Setup' tab above to configure your first store setup.",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {required double width}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildSetupTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepperHeader(),
        const SizedBox(height: 24),
        _buildStep1Box(),
        const SizedBox(height: 16),
        _buildStep2Box(),
        const SizedBox(height: 16),
        _buildStep3Box(),
        const SizedBox(height: 24),
        _buildBottomSaveSection(),
      ],
    );
  }

  Widget _buildStepperHeader() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator('1', '1. Business Setup', true),
          _buildStepLine(),
          _buildStepIndicator('2', '2. Select Stores', false),
          _buildStepLine(),
          _buildStepIndicator('3', '3. Category & Brand', false),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6366F1) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? const Color(0xFF6366F1) : Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : Colors.black38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF6366F1) : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 60,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 24),
      color: Colors.grey.shade300,
    );
  }

  Widget _buildBoxHeader(String number, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF2563EB),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Box() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBoxHeader('1', 'Business Setup', 'Saved business entity and category hierarchy from Business Setup API'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No saved Business Setup found for this Business. Please complete Business Setup first.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Box() {
    return Container(
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
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('2', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text('Select Stores', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Text('Selected Stores: 0', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Select one or multiple stores belonging to the selected business', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              
              Widget searchBar = Container(
                width: isSmall ? double.infinity : 300,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search stores by name or location...',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              );

              Widget actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text('Select All', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text('Clear All', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
                  ),
                ],
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchBar,
                    const SizedBox(height: 12),
                    actions,
                  ],
                );
              }
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  searchBar,
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.storefront, color: Colors.black26, size: 32),
                const SizedBox(height: 8),
                Text(
                  'No stores found for this business entity.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Box() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBoxHeader(
            '3',
            'Category & Brand Selection',
            'Select categories from saved Business Setup and configure brand associations strictly per category',
          ),
          const SizedBox(height: 24),

          // Dropdowns
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 650;
              final width = isSmall ? double.infinity : (constraints.maxWidth - 16) / 2;

              Widget categoryDropdown = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CATEGORY',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          'SAVED IN API',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        hint: Text(
                          'Select Category',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        items: _availableCategories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );

              Widget brandDropdown = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BRAND',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: _selectedCategory == null
                          ? const Color(0xFFF9FAFB)
                          : Colors.white,
                      border: Border.all(
                        color: _selectedCategory == null
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF2563EB),
                        width: _selectedCategory == null ? 1 : 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: null,
                        hint: Text(
                          _selectedCategory == null
                              ? 'Select Category First'
                              : 'Select Brand',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: _selectedCategory == null
                                ? const Color(0xFF9CA3AF)
                                : Colors.black87,
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: _selectedCategory == null
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF6B7280),
                          size: 20,
                        ),
                        items: _selectedCategory == null
                            ? []
                            : (_availableBrandsByCategory[_selectedCategory] ??
                                    ['Tata', 'Ashok Leyland'])
                                .map((brand) {
                                return DropdownMenuItem<String>(
                                  value: brand,
                                  child: Text(
                                    brand,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                        onChanged: _selectedCategory == null
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() {
                                    final idx = _categoryBrandMappings.indexWhere(
                                      (m) => m['category'] == _selectedCategory,
                                    );
                                    if (idx >= 0) {
                                      final brands = List<String>.from(
                                        _categoryBrandMappings[idx]['brands'],
                                      );
                                      if (!brands.contains(val)) {
                                        brands.add(val);
                                        _categoryBrandMappings[idx]['brands'] =
                                            brands;
                                      }
                                    } else {
                                      _categoryBrandMappings.add({
                                        'category': _selectedCategory!,
                                        'brands': [val],
                                      });
                                    }
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                ],
              );

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(width: width, child: categoryDropdown),
                  SizedBox(width: width, child: brandDropdown),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // SELECTED CATEGORY & BRAND section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.layers_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SELECTED CATEGORY & BRAND',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_categoryBrandMappings.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_categoryBrandMappings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.rotate(
                          angle: 0.5,
                          child: const Icon(
                            Icons.sell_rounded,
                            color: Color(0xFFF59E0B),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No category & brand mappings added yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Select a Category, then pick Brands from the dropdowns above to automatically add mappings.',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: _categoryBrandMappings.map((mapping) {
                      final category = mapping['category'] as String;
                      final brands = mapping['brands'] as List<String>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: brands.map((b) {
                                  return Chip(
                                    label: Text(
                                      b,
                                      style: GoogleFonts.poppins(fontSize: 11),
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _categoryBrandMappings.remove(mapping);
                                });
                              },
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
  }

  Widget _buildBottomSaveSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 750;

        Widget nameField = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'STORE SETUP NAME ',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _storeSetupNameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Electronics Store Setup',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        );

        Widget saveButton = ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Save Store Setup Configuration',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );

        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameField,
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: saveButton,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 3,
              child: nameField,
            ),
            const SizedBox(width: 20),
            saveButton,
          ],
        );
      },
    );
  }
}
