import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  bool _isSetupTab = true;
  String _selectedHierarchy = 'primary_brand';

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
      children: [
        _buildStepperHeader(),
        const SizedBox(height: 24),
        _buildStep1Box(),
        const SizedBox(height: 16),
        _buildStep2Box(),
        const SizedBox(height: 16),
        _buildStep3Box(),
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
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(number, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
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
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('2', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
                        Text('Select Stores', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)),
                          child: Text('Selected Stores: 0', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Select one or multiple stores belonging to the selected business', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              );

              Widget actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select All', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Text('Clear All', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
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
          _buildBoxHeader('3', 'Category & Brand Selection', 'Select categories from saved Business Setup and configure brand associations strictly per category'),
          const SizedBox(height: 24),
          
          Text('HIERARCHY ARCHITECTURE:', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 12),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final width = isSmall ? double.infinity : (constraints.maxWidth - 16) / 2;
              
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: width,
                    child: _buildHierarchyOption(
                      title: 'Primary -> Brand',
                      subtitle: 'Direct brand assignment without secondary categories.',
                      value: 'primary_brand',
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _buildHierarchyOption(
                      title: 'Primary -> Secondary -> Brand',
                      subtitle: 'Includes secondary category breakdown before brands.',
                      value: 'primary_secondary_brand',
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final width = isSmall ? double.infinity : (constraints.maxWidth - 16) / 2;
              
              Widget primaryCategory = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PRIMARY CATEGORIES', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                      Text('SAVED IN API', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('-- Select Primary Categories --', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black45)),
                        items: const [],
                        onChanged: null,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              );
              
              Widget secondaryCategory = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SECONDARY CATEGORIES', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                      Text('FILTERED BY PRIMARY', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Select Primary Category first', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38)),
                        items: const [],
                        onChanged: null,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black26),
                      ),
                    ),
                  ),
                ],
              );
              
              if (_selectedHierarchy == 'primary_brand') {
                return primaryCategory;
              }
              
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(width: width, child: primaryCategory),
                  SizedBox(width: width, child: secondaryCategory),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          
          Text('STORE SETUP NAME *', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'e.g. Electronics Store Setup',
                hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.black38),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_outlined, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Save Store Setup Configuration', 
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHierarchyOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedHierarchy == value;
    
    return InkWell(
      onTap: () => setState(() => _selectedHierarchy = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade400, width: 2),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF6366F1) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isSelected ? const Color(0xFF6366F1).withOpacity(0.8) : Colors.black54,
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
}
