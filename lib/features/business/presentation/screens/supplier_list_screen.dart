import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/features/business/data/repositories/supplier_repository.dart';
import 'package:va_business/features/business/presentation/providers/supplier_providers.dart';
import 'create_supplier_screen.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isTableView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supplierAsync = ref.watch(supplierNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suppliers',
              style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 17),
            ),
            Text(
              'Manage registered suppliers',
              style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateSupplierScreen()),
              ).then((_) => ref.read(supplierNotifierProvider.notifier).loadSuppliers()),
              icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
              label: Text(
                'Add Supplier',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C4DDC),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(supplierNotifierProvider.notifier).loadSuppliers(),
          color: const Color(0xFF4C4DDC),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search & View Controls Card
                supplierAsync.maybeWhen(
                  data: (suppliers) {
                    final filteredCount = _filterSuppliers(suppliers).length;
                    return _buildSearchAndControls(filteredCount);
                  },
                  orElse: () => _buildSearchAndControls(0),
                ),
                const SizedBox(height: 14),

                // Content
                Expanded(
                  child: supplierAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4C4DDC))),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 12),
                          Text('Failed to load suppliers', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text('$e', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.read(supplierNotifierProvider.notifier).loadSuppliers(),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C4DDC)),
                            child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    data: (suppliers) {
                      final filtered = _filterSuppliers(suppliers);
                      if (filtered.isEmpty) return _emptyState();
                      return _isTableView ? _buildTableView(filtered) : _buildCardView(filtered);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SupplierApiModel> _filterSuppliers(List<SupplierApiModel> suppliers) {
    if (_searchQuery.isEmpty) return suppliers;
    return suppliers.where((s) {
      return (s.businessName ?? '').toLowerCase().contains(_searchQuery) ||
          (s.businessEmail ?? '').toLowerCase().contains(_searchQuery) ||
          (s.phone ?? '').contains(_searchQuery) ||
          (s.district ?? '').toLowerCase().contains(_searchQuery) ||
          (s.type ?? '').toLowerCase().contains(_searchQuery) ||
          (s.platform ?? '').toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildSearchAndControls(int count) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by name, email, phone, branch...',
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 12),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $count ${count == 1 ? "supplier" : "suppliers"}',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              ),
              // View Toggle
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toggleBtn(
                      icon: Icons.grid_view_rounded,
                      label: 'Cards',
                      isSelected: !_isTableView,
                      onTap: () => setState(() => _isTableView = false),
                    ),
                    _toggleBtn(
                      icon: Icons.table_rows_rounded,
                      label: 'Table',
                      isSelected: _isTableView,
                      onTap: () => setState(() => _isTableView = true),
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

  Widget _toggleBtn({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? const Color(0xFF4C4DDC) : const Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF4C4DDC) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFFF4F7FB), shape: BoxShape.circle),
                child: const Icon(Icons.business_center_outlined, size: 40, color: Color(0xFF4C4DDC)),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty ? 'No Matching Suppliers' : 'No Suppliers Found',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try searching with another name, email or phone.'
                    : 'Add a new supplier to get started.',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateSupplierScreen()),
                  ).then((_) => ref.read(supplierNotifierProvider.notifier).loadSuppliers()),
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: Text('Add New Supplier', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C4DDC),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardView(List<SupplierApiModel> suppliers) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: suppliers.length,
      itemBuilder: (context, i) => _supplierCard(suppliers[i], i),
    );
  }

  Widget _supplierCard(SupplierApiModel s, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Logo, Name, Branch, and Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (s.fullCompanyLogoUrl != null && s.fullCompanyLogoUrl!.isNotEmpty)
                        ? Image.network(
                            s.fullCompanyLogoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _avatarFallback(s.businessName),
                          )
                        : _avatarFallback(s.businessName),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.businessName ?? 'Unknown',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              s.district?.isNotEmpty == true ? s.district! : 'No branch',
                              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: s.withGst ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    s.withGst ? 'With GST' : 'Without GST',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: s.withGst ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Info chips (Phone, Type, Platform)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (s.phone != null && s.phone!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_outlined, size: 11, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          s.phone!,
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF334155), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                if (s.type != null && s.type!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Text(
                      s.type!,
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                    ),
                  ),
                if (s.platform != null && s.platform!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Text(
                      s.platform!,
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF16A34A), fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
            ),

            // Row 3: Action Buttons (View, Edit, Delete)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showDetailsDialog(s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility_outlined, size: 14, color: Color(0xFF4C4DDC)),
                          const SizedBox(width: 6),
                          Text('View', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF4C4DDC))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateSupplierScreen(supplierToEdit: s)),
                    ).then((_) => ref.read(supplierNotifierProvider.notifier).loadSuppliers()),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_outlined, size: 14, color: Color(0xFFEA580C)),
                          const SizedBox(width: 6),
                          Text('Edit', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFEA580C))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _confirmDelete(s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                          const SizedBox(width: 6),
                          Text('Delete', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView(List<SupplierApiModel> suppliers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
            child: DataTable(
              headingRowColor: const WidgetStatePropertyAll(Color(0xFFF8FAFC)),
              dataRowMaxHeight: 64,
              dataRowMinHeight: 56,
              dividerThickness: 0.8,
              columns: ['S.NO', 'SUPPLIER NAME', 'BRANCH', 'PHONE NUMBER', 'STATUS', 'ACTION']
                  .map((col) => DataColumn(label: Text(col, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B)))))
                  .toList(),
              rows: List.generate(suppliers.length, (i) {
                final s = suppliers[i];
                return DataRow(cells: [
                  DataCell(Text('${i + 1}', style: GoogleFonts.poppins(fontSize: 13))),
                  DataCell(Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: const Color(0xFF4C4DDC).withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Center(child: Text(
                        (s.businessName ?? 'S').isNotEmpty ? (s.businessName ?? 'S')[0].toUpperCase() : 'S',
                        style: GoogleFonts.poppins(color: const Color(0xFF4C4DDC), fontWeight: FontWeight.bold, fontSize: 12),
                      )),
                    ),
                    const SizedBox(width: 10),
                    Flexible(child: Text(s.businessName ?? 'Unknown', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                  ])),
                  DataCell(Text(s.district ?? 'N/A', style: GoogleFonts.poppins(fontSize: 13))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.phone_outlined, size: 12, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(s.phone ?? 'N/A', style: GoogleFonts.poppins(fontSize: 11)),
                      ]),
                    ),
                  ),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: s.withGst ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s.withGst ? 'With GST' : 'Without GST', style: GoogleFonts.poppins(fontSize: 10, color: s.withGst ? Colors.green.shade700 : Colors.orange.shade700, fontWeight: FontWeight.w600)),
                  )),
                  DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                    _actionBtn(Icons.remove_red_eye_outlined, Colors.blue, () => _showDetailsDialog(s)),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.edit_outlined, Colors.orange, () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateSupplierScreen(supplierToEdit: s)))
                            .then((_) => ref.read(supplierNotifierProvider.notifier).loadSuppliers())),
                    const SizedBox(width: 6),
                    _actionBtn(Icons.delete_outline, Colors.red, () => _confirmDelete(s)),
                  ])),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _confirmDelete(SupplierApiModel supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Delete Supplier', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to delete "${supplier.businessName}"?', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(supplierNotifierProvider.notifier).deleteSupplier(supplier.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Supplier deleted successfully', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(SupplierApiModel s) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 480,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Supplier Details',
                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Content Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: (s.fullCompanyLogoUrl != null && s.fullCompanyLogoUrl!.isNotEmpty)
                                    ? Image.network(
                                        s.fullCompanyLogoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _avatarFallback(s.businessName),
                                      )
                                    : _avatarFallback(s.businessName),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.businessName ?? 'Unknown',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    [s.type, s.district].where((p) => p != null && p.isNotEmpty && p != 'null').join(' • '),
                                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Row 1: SUPPLIER NAME & COMPANY NAME
                      _twoColRow(
                        _fieldCol('SUPPLIER NAME', Text(s.businessName ?? 'N/A', style: _valueStyle)),
                        _fieldCol('COMPANY NAME', Text(s.businessName ?? 'N/A', style: _valueStyle)),
                      ),
                      const SizedBox(height: 18),

                      // Row 2: BRANCH & PHONE
                      _twoColRow(
                        _fieldCol('BRANCH', Text(s.district ?? 'N/A', style: _valueStyle)),
                        _fieldCol('PHONE', Text(s.phone ?? 'N/A', style: _valueStyle)),
                      ),
                      const SizedBox(height: 18),

                      // Row 3: GST STATUS & EMAIL
                      _twoColRow(
                        _fieldCol(
                          'GST STATUS',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: s.withGst ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  s.withGst ? 'With GST' : 'Without GST',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: s.withGst ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                              if (s.withGst && s.gstNumber != null && s.gstNumber!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(s.gstNumber!, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                              ],
                            ],
                          ),
                        ),
                        _fieldCol('EMAIL', Text(s.businessEmail ?? 'N/A', style: _valueStyle)),
                      ),
                      const SizedBox(height: 18),

                      // Row 4: BUSINESS TYPE & PLATFORM
                      _twoColRow(
                        _fieldCol(
                          'BUSINESS TYPE',
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (s.type ?? 'N/A').split(', ').where((t) => t.isNotEmpty).map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFC7D2FE)),
                              ),
                              child: Text(
                                t,
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                              ),
                            )).toList(),
                          ),
                        ),
                        _fieldCol(
                          'PLATFORM',
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (s.platform ?? 'N/A').split(', ').where((p) => p.isNotEmpty).map((p) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Text(
                                p,
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A)),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Row 5: ADDRESS (Full Width)
                      _fieldCol(
                        'ADDRESS',
                        Text(
                          s.fullAddress.isNotEmpty ? s.fullAddress : 'N/A',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF334155)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback(String? name) {
    final initial = (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'S';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.poppins(color: const Color(0xFF4C4DDC), fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  TextStyle get _valueStyle => GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B));

  Widget _twoColRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  Widget _fieldCol(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}
