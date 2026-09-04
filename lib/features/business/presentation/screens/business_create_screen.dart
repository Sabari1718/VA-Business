import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'create_propagator_screen.dart';
import 'create_partner_screen.dart';
import 'create_supplier_screen.dart';
import 'business_details_screen.dart';
import '../providers/business_providers.dart';

class BusinessCreateScreen extends ConsumerWidget {
  final String? filterCategory;

  const BusinessCreateScreen({super.key, this.filterCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propagatorAsync = ref.watch(propagatorBusinessProvider);
    final partnerAsync = ref.watch(partnerBusinessProvider);
    final supplierAsync = ref.watch(supplierBusinessProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Same soft background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Business Create',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search business by name, category, or type...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    icon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // "Your Business at a Glance" Header
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Business at a Glance',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1D2B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All your businesses, one place.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Scrollable Stats
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _GlanceItem(
                      icon: Icons.storefront,
                      iconColor: const Color(0xFF4C8DFB),
                      count: propagatorAsync.maybeWhen(
                        data: (data) => data.count.toString(),
                        orElse: () => '0',
                      ),
                      title: 'My Businesses',
                      subtitle: 'Businesses you own',
                    ),
                    _buildDivider(),
                    _GlanceItem(
                      icon: Icons.domain,
                      iconColor: const Color(0xFF26D38B),
                      count: '0',
                      title: 'Private Limited',
                      subtitle: 'Private Limited Companies',
                    ),
                    _buildDivider(),
                    _GlanceItem(
                      icon: Icons.business,
                      iconColor: const Color(0xFF00BCD4),
                      count: '0',
                      title: 'Public Limited',
                      subtitle: 'Public Limited Companies',
                    ),
                    _buildDivider(),
                    _GlanceItem(
                      icon: Icons.handshake_outlined,
                      iconColor: const Color(0xFFFCAE39),
                      count: partnerAsync.maybeWhen(
                        data: (data) => data.count.toString(),
                        orElse: () => '0',
                      ),
                      title: 'Partner Businesses',
                      subtitle: 'Businesses you partner with',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Creation Cards
              if (filterCategory == null || filterCategory == 'Propagator') ...[
                _CreationCard(
                  businessCategory: 'propagator',
                stepNo: '01',
                stepColor: const Color(0xFF4C8DFB),
                title: propagatorAsync.when(
                  data: (data) => 'Propagator (${data.count})',
                  loading: () => 'Propagator (...)',
                  error: (e, s) => 'Propagator (Error)',
                ),
                subtitle: 'Businesses you own and operate',
                boxTitle: 'Register New Business',
                boxDesc: 'Create a new proprietorship or registered business.',
                btnText: 'Create Business',
                btnColor: const Color(0xFF4C8DFB),
                businesses: propagatorAsync.maybeWhen(
                  data: (data) => data.data,
                  orElse: () => [],
                ),
                onDelete: (id) async {
                  try {
                    await ref.read(businessRepositoryProvider).deletePropagatorBusiness(id);
                    ref.invalidate(propagatorBusinessProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Business deleted successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete business: $e')),
                    );
                  }
                },
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePropagatorScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ],
              
              if (filterCategory == null || filterCategory == 'Partner') ...[
                _CreationCard(
                  businessCategory: 'partner',
                stepNo: '02',
                stepColor: const Color(0xFF9C27B0), // Purple theme
                title: partnerAsync.when(
                  data: (data) => 'Partner Businesses (${data.count})',
                  loading: () => 'Partner Businesses (...)',
                  error: (e, s) => 'Partner (Error)',
                ),
                subtitle: 'Businesses you collaborate or partner with',
                boxTitle: 'Grow Your Network',
                boxDesc: 'Add more partners and expand your business reach.',
                btnText: 'Create Partner Business',
                btnColor: const Color(0xFF9C27B0),
                businesses: partnerAsync.maybeWhen(
                  data: (data) => data.data,
                  orElse: () => [],
                ),
                onDelete: (id) async {
                  try {
                    await ref.read(businessRepositoryProvider).deletePartnerBusiness(id);
                    ref.invalidate(partnerBusinessProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partner Business deleted successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete partner business: $e')),
                    );
                  }
                },
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePartnerScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ],

              if (filterCategory == null || filterCategory == 'Supplier') ...[
                _CreationCard(
                  businessCategory: 'supplier',
                stepNo: '03',
                stepColor: const Color(0xFF0284C7), // Blue theme
                title: supplierAsync.when(
                  data: (data) => 'Supplier Businesses (${data.count})',
                  loading: () => 'Supplier Businesses (...)',
                  error: (e, s) => 'Supplier (Error)',
                ),
                subtitle: 'Businesses supplying goods or services to you',
                boxTitle: 'Manage Your Supply Chain',
                boxDesc: 'Register your suppliers for streamlined operations.',
                btnText: 'Create Supplier Business',
                btnColor: const Color(0xFF0284C7),
                businesses: supplierAsync.maybeWhen(
                  data: (data) => data.data,
                  orElse: () => [],
                ),
                onDelete: (id) async {
                  try {
                    await ref.read(businessRepositoryProvider).deleteSupplierBusiness(id);
                    ref.invalidate(supplierBusinessProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Supplier Business deleted successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete supplier business: $e')),
                    );
                  }
                },
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateSupplierScreen()),
                  );
                },
              ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: VerticalDivider(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
    );
  }
}

class _GlanceItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String count;
  final String title;
  final String subtitle;

  const _GlanceItem({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Fixed width for horizontal scrolling items
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      count,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreationCard extends StatelessWidget {
  final String businessCategory;
  final String stepNo;
  final Color stepColor;
  final String title;
  final String subtitle;
  final String boxTitle;
  final String boxDesc;
  final String btnText;
  final Color btnColor;
  final VoidCallback? onPressed;
  final List<dynamic> businesses;
  final Function(String id)? onDelete;

  const _CreationCard({
    required this.businessCategory,
    required this.stepNo,
    required this.stepColor,
    required this.title,
    required this.subtitle,
    required this.boxTitle,
    required this.boxDesc,
    required this.btnText,
    required this.btnColor,
    this.onPressed,
    this.businesses = const [],
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stepColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stepNo,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 42, top: 2),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (businesses.isNotEmpty)
                  ...businesses.map((business) => _buildBusinessCard(context, business, businessCategory)).toList(),
                  
                // Dotted Box Area
                Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: stepColor.withOpacity(0.3), width: 1.5, style: BorderStyle.solid), // In Flutter dashed border requires a package, we'll use solid
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add, color: stepColor, size: 28),
                      const SizedBox(height: 12),
                      Text(
                        boxTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        boxDesc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: onPressed ?? () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: btnColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            btnText,
                            style: GoogleFonts.poppins(
                              color: btnColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, dynamic business, String category) {
    final name = business['businessName'] ?? business['name'] ?? 'Unknown Business';
    String typesStr = 'General';
    if (business['businessType'] != null) {
      final types = business['businessType'];
      if (types is List) {
        typesStr = types.join(', ');
      } else {
        typesStr = types.toString();
      }
    }
    final id = business['id']?.toString() ?? '';

    Color categoryColor;
    IconData categoryIcon;
    String categoryText;

    if (category == 'partner') {
      categoryColor = const Color(0xFFF97316); // Orange/Red
      categoryIcon = Icons.handshake_outlined;
      categoryText = 'Partner Business';
    } else if (category == 'supplier') {
      categoryColor = const Color(0xFF10B981); // Green
      categoryIcon = Icons.local_shipping_outlined;
      categoryText = 'Supplier Business';
    } else {
      categoryColor = const Color(0xFF3B82F6); // Blue
      categoryIcon = Icons.storefront;
      categoryText = 'My Business';
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24), // Spacer for centering
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              InkWell(
                onTap: () {
                  if (onDelete != null) onDelete!(id);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            typesStr,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              categoryText,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailsScreen(businessData: business, businessCategory: category),
                  ),
                );
              },
              icon: const Icon(Icons.login, size: 14, color: Colors.white),
              label: Text(
                'Login',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
