import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessSetupListScreen extends StatefulWidget {
  const BusinessSetupListScreen({super.key});

  @override
  State<BusinessSetupListScreen> createState() => _BusinessSetupListScreenState();
}

class _BusinessSetupListScreenState extends State<BusinessSetupListScreen> {
  bool _isTableView = false;

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
              _buildControls(),
              const SizedBox(height: 24),
              _isTableView ? _buildTableView() : _buildCardView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Business Setup Configurations',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1E2D),
              ),
            ),
            ElevatedButton.icon(
              onPressed: null, // Add New action placeholder
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add New Business Setup', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F4F6),
                foregroundColor: Colors.grey.shade400,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your configured business entities, platform architectures, shop types, stores, and sector hierarchies.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 700;

        Widget searchField = Container(
          width: isSmall ? double.infinity : 350,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by business, store, sector, category, brand...',
              hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black38),
              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.black38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        );

        Widget rightControls = Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Total Configured Setups: 0', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  _buildToggleButton(
                    title: 'Card View',
                    icon: Icons.grid_view_rounded,
                    isSelected: !_isTableView,
                    onTap: () => setState(() => _isTableView = false),
                  ),
                  _buildToggleButton(
                    title: 'Table View',
                    icon: Icons.list_alt_rounded,
                    isSelected: _isTableView,
                    onTap: () => setState(() => _isTableView = true),
                  ),
                ],
              ),
            ),
          ],
        );

        if (isSmall) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              const SizedBox(height: 16),
              rightControls,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            searchField,
            rightControls,
          ],
        );
      },
    );
  }

  Widget _buildToggleButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF6366F1) : Colors.black45,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF6366F1) : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏢', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No business setups found',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'You have not configured any business setup yet. Click below to get started.',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
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
                  _buildTableHeaderCell('PLATFORM & SHOP TYPE', width: 200),
                  _buildTableHeaderCell('MAPPED STORE', width: 150),
                  _buildTableHeaderCell('SECTOR & CATEGORY HIERARCHY', width: 250),
                  _buildTableHeaderCell('CREATED DATE', width: 120),
                  _buildTableHeaderCell('STATUS', width: 100),
                  _buildTableHeaderCell('ACTIONS', width: 100),
                ],
              ),
            ),
          ),
          // Empty state
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏢', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text(
                  'No business setups found',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have not configured any business setup yet. Click below to get started.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
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
}
