import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'store_create_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_providers.dart';
import '../../data/models/store_model.dart';
import 'dart:convert';

class StoreListScreen extends ConsumerStatefulWidget {
  const StoreListScreen({super.key});

  @override
  ConsumerState<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends ConsumerState<StoreListScreen> {
  bool _isTableView = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StoreCreateScreen()),
    );
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
                  style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
            body: ref.watch(storesProvider).when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (error, stack) => Center(child: Text('Error: $error', style: GoogleFonts.poppins(color: Colors.red))),
        data: (stores) {
          final filteredStores = stores.where((s) {
            final matchesSearch = s.storeName.toLowerCase().contains(_searchQuery) ||
                s.cityVillage.toLowerCase().contains(_searchQuery) ||
                s.customerCarePhone.toLowerCase().contains(_searchQuery);
            return matchesSearch;
          }).toList();
          
          return SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section (Title + Action Buttons)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // Title & Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Setup List',
                            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your connected storefronts, branch models, customer care details, and operating schedules.',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                      // Action Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _navigateToCreate(context),
                            icon: const Icon(Icons.add, size: 16, color: Colors.white),
                            label: Text('Add New Store', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1), // Purple tone
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Search Bar Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Search Input
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search by store name, branch model, contact or city...',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.black45, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    
                    // Filters / View Toggles
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF), // Light blue bg
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filteredStores.length} Stores Total',
                            style: GoogleFonts.poppins(color: const Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                        // View Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isTableView = false),
                                child: _buildViewToggle(Icons.grid_view_outlined, 'Cards', !_isTableView),
                              ),
                              Container(width: 1, height: 20, color: Colors.grey.shade300),
                              GestureDetector(
                                onTap: () => setState(() => _isTableView = true),
                                child: _buildViewToggle(Icons.table_rows_outlined, 'Table', _isTableView),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Empty State
              if (filteredStores.isEmpty)
                // Empty State
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _isTableView 
                        ? const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
                        : BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront, size: 32, color: Colors.black45),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Stores Found',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No store setups match your search criteria. Click "+ Add New Store" to create one.',
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToCreate(context),
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: Text('Add New Store', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                )
              else 
                _isTableView ? _buildTableView(filteredStores) : _buildCardView(filteredStores),
            ],
          ),
        ),
      );
        },
      ),
    );
  }
  
    void _deleteStore(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this store?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(dialogContext); // Close dialog
              try {
                final message = await ref.read(storeRepositoryProvider).deleteStore(id);
                if (mounted) {
                  ref.invalidate(storesProvider);
                  scaffoldMessenger.showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  String errorMsg = e.toString();
                  if (errorMsg.contains('Exception:')) {
                    errorMsg = errorMsg.replaceAll('Exception:', '').trim();
                  }
                  scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView(List<StoreModel> stores) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: stores.length + 1,
                    itemBuilder: (context, index) {
            if (index == stores.length) {
              return GestureDetector(
                onTap: () => _navigateToCreate(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // Not natively dashed without package, using solid light
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3), style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Color(0xFF6366F1), size: 24),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add New Store', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text(
                                'Configure storefront location, business schedule, contact care, and payment setup.',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                                maxLines: 3,
                              ),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _navigateToCreate(context),
                                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                                  label: Text('Add New Store', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final store = stores[index];

            ImageProvider? logoImage;
            if (store.storeLogo.isNotEmpty) {
              try {
                final base64Str = store.storeLogo.contains(',') ? store.storeLogo.split(',')[1] : store.storeLogo;
                logoImage = MemoryImage(base64Decode(base64Str));
              } catch (e) {
                // Ignore parsing errors
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                        image: logoImage != null ? DecorationImage(image: logoImage, fit: BoxFit.cover) : null,
                      ),
                      child: Stack(
                        children: [
                          if (logoImage == null)
                            const Center(child: Icon(Icons.storefront, size: 40, color: Colors.black26)),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                              Container(
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.black54),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => StoreCreateScreen(store: store)),
                                    );
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  onPressed: () => _deleteStore(store.id!),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Details
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  store.storeName,
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: store.status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  store.status,
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: store.status == 'Active' ? Colors.green : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.branchManagementModel,
                            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6366F1), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${store.cityVillage}, ${store.district}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text(
                                store.customerCarePhone,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text(
                                '${store.openingTime} - ${store.closingTime}',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildTableView(List<StoreModel> stores) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool requiresScroll = constraints.maxWidth < 1100;
        final double tableWidth = requiresScroll ? 1100 : constraints.maxWidth;

        Widget headerRow = Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text('S.NO', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(flex: 3, child: Text('STORE NAME & MODEL', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(flex: 3, child: Text('CUSTOMER CARE CONTACT', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(flex: 3, child: Text('ADDRESS LOCATION', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(flex: 2, child: Text('OPERATING HOURS', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(flex: 1, child: Text('STATUS', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(flex: 2, child: Text('ACTIONS', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.right)),
            ],
          ),
        );

        Widget listContent = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stores.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
            itemBuilder: (context, index) {
              final store = stores[index];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // S.NO
                    Expanded(
                      flex: 1, 
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                          child: Text('${index + 1}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
                        ),
                      ),
                    ),
                    // STORE NAME & MODEL
                    Expanded(
                      flex: 3, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.storeName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(store.branchManagementModel, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                    // CUSTOMER CARE
                    Expanded(
                      flex: 3, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.customerCareName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text(store.customerCarePhone, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ADDRESS
                    Expanded(
                      flex: 3, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${store.cityVillage}, ${store.district}, ${store.pincode}, ${store.state}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text(store.country, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // OPERATING HOURS
                    Expanded(
                      flex: 2, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_outlined, size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text('${store.openingTime} -', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: Text('${store.closingTime}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(height: 4),
                          Text(store.workingDays, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    // STATUS
                    Expanded(
                      flex: 1, 
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: store.status == 'Active' ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: store.status == 'Active' ? Colors.green.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline, size: 12, color: store.status == 'Active' ? Colors.green : Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  store.status,
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: store.status == 'Active' ? Colors.green : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ACTIONS
                    Expanded(
                      flex: 2, 
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StoreCreateScreen(store: store)),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.black54),
                            label: Text('Edit', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _deleteStore(store.id!),
                            icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                            label: Text('Delete', style: GoogleFonts.poppins(fontSize: 12, color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                              backgroundColor: Colors.red.withValues(alpha: 0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        Widget tableContent = SizedBox(
          width: tableWidth,
          child: Column(
            children: [
              headerRow,
              listContent,
            ],
          ),
        );

        return requiresScroll
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: tableContent)
            : tableContent;
      },
    );
  }


  Widget _buildViewToggle(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? const Color(0xFF6366F1) : Colors.black45),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? const Color(0xFF6366F1) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
