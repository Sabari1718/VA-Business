import 'dart:io';

void main() async {
  final fileContent = r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/features/business/data/models/supplier_model.dart';
import 'package:va_business/features/business/presentation/providers/supplier_providers.dart';
import 'package:va_business/features/business/presentation/providers/platform_providers.dart';
import 'package:va_business/features/business/data/models/platform_model.dart';
import 'create_supplier_screen.dart';
import 'dart:io';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _showCount = 10;

  @override
  Widget build(BuildContext context) {
    final suppliers = ref.watch(supplierListProvider);
    
    // Filter logic
    final filteredSuppliers = suppliers.where((s) {
      final query = _searchController.text.toLowerCase();
      return s.name.toLowerCase().contains(query) || 
             s.phone.contains(query) || 
             s.email.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suppliers',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Manage and view all your registered suppliers',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateSupplierScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: Text('Add New Supplier', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C4DDC),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600 ? 300 : double.infinity,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState((){}),
                      decoration: InputDecoration(
                        hintText: 'Search by name, company or phone...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SHOW', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _showCount,
                            items: [10, 20, 50].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString(), style: GoogleFonts.poppins(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _showCount = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Table
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: filteredSuppliers.isEmpty ? _buildEmptyState() : _buildTable(filteredSuppliers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFF4F7FB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.business, size: 32, color: Color(0xFF6384EB)),
        ),
        const SizedBox(height: 16),
        Text(
          'No Suppliers Found',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You have not added any suppliers yet or none matched your search.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTable(List<SupplierModel> suppliers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.white),
              dataRowMaxHeight: 70,
              dataRowMinHeight: 60,
              dividerThickness: 1,
              columns: [
                DataColumn(label: Text('S.NO', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                DataColumn(label: Text('SUPPLIER NAME', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                DataColumn(label: Text('BRANCH', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                DataColumn(label: Text('PHONE NUMBER', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                DataColumn(label: Text('STATUS', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
                DataColumn(label: Text('ACTION', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
              ],
              rows: List.generate(
                suppliers.length,
                (index) {
                  final supplier = suppliers[index];
                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}', style: GoogleFonts.poppins(fontSize: 13))),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C4DDC).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: supplier.companyLogoPath != null 
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(File(supplier.companyLogoPath!), fit: BoxFit.cover, errorBuilder: (c,e,s) => Center(child: Text(supplier.name[0].toUpperCase(), style: GoogleFonts.poppins(color: const Color(0xFF4C4DDC), fontWeight: FontWeight.bold)))),
                                  )
                                : Center(child: Text(supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S', style: GoogleFonts.poppins(color: const Color(0xFF4C4DDC), fontWeight: FontWeight.bold))),
                            ),
                            const SizedBox(width: 12),
                            Text(supplier.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DataCell(Text(supplier.branch, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(supplier.phone, style: GoogleFonts.poppins(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: supplier.withGst ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            supplier.withGst ? 'With GST' : 'Without GST',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: supplier.withGst ? Colors.green.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionBtn(Icons.remove_red_eye_outlined, Colors.blue, () {
                              _showSupplierDetailsDialog(context, supplier);
                            }),
                            const SizedBox(width: 8),
                            _buildActionBtn(Icons.edit_outlined, Colors.orange, () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateSupplierScreen(supplierToEdit: supplier)));
                            }),
                            const SizedBox(width: 8),
                            _buildActionBtn(Icons.delete_outline, Colors.red, () {
                              _confirmDelete(context, supplier);
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing 1 to ${suppliers.length} of ${suppliers.length} suppliers', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.chevron_left, size: 16)),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF4C4DDC), borderRadius: BorderRadius.circular(4)), child: Text('1', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.chevron_right, size: 16)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Supplier', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${supplier.name}?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () {
              ref.read(supplierListProvider.notifier).deleteSupplier(supplier.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupplierDetailsDialog(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Supplier Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Top Profile Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: supplier.companyLogoPath != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(supplier.companyLogoPath!), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.business)))
                        : const Icon(Icons.business, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(supplier.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(supplier.branch, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Two column details
              Row(
                children: [
                  Expanded(child: _buildDetailField('SUPPLIER NAME', supplier.name)),
                  Expanded(child: _buildDetailField('COMPANY NAME', supplier.name)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDetailField('BRANCH', supplier.branch)),
                  Expanded(child: _buildDetailField('PHONE', supplier.phone)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GST STATUS', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: supplier.withGst ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            supplier.withGst ? 'With GST' : 'Without GST',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: supplier.withGst ? Colors.green.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildDetailField('GST NUMBER', supplier.gstNumber.isEmpty ? 'N/A' : supplier.gstNumber)),
                ],
              ),
              const SizedBox(height: 16),
              Text('GST CERTIFICATE', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 4),
              if (supplier.gstCertificatePath != null)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.insert_drive_file_outlined, size: 14, color: Color(0xFF4C4DDC)),
                  label: Text('View / Download Certificate', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C4DDC))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4C4DDC)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                )
              else
                Text('No certificate uploaded', style: GoogleFonts.poppins(fontSize: 12)),
              
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDetailField('EMAIL', supplier.email.isEmpty ? 'N/A' : supplier.email)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BUSINESS TYPE', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Consumer(
                          builder: (context, ref, child) {
                            final shopTypesAsync = ref.watch(shopTypesProvider);
                            return shopTypesAsync.when(
                              data: (res) {
                                final all = res.data.map((e) => ShopTypeModel.fromJson(e)).toList();
                                final myTypes = all.where((element) => supplier.selectedShopTypeIds.contains(element.id)).toList();
                                if (myTypes.isEmpty) return Text('None', style: GoogleFonts.poppins(fontSize: 12));
                                return Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: myTypes.map((st) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4C4DDC).withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                                    child: Text(st.name, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF4C4DDC))),
                                  )).toList(),
                                );
                              },
                              loading: () => const SizedBox(),
                              error: (e,s) => const SizedBox(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('PLATFORM', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 4),
              Consumer(
                builder: (context, ref, child) {
                  final platformsAsync = ref.watch(platformsProvider);
                  return platformsAsync.when(
                    data: (res) {
                      final all = res.data.map((e) => PlatformModel.fromJson(e)).toList();
                      final myPlats = all.where((element) => supplier.selectedPlatformIds.contains(element.id)).toList();
                      if (myPlats.isEmpty) return Text('None', style: GoogleFonts.poppins(fontSize: 12));
                      return Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: myPlats.map((st) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(border: Border.all(color: Colors.green.withOpacity(0.3)), borderRadius: BorderRadius.circular(4)),
                          child: Text(st.name, style: GoogleFonts.poppins(fontSize: 10, color: Colors.green.shade700)),
                        )).toList(),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (e,s) => const SizedBox(),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildDetailField('ADDRESS', supplier.address.isEmpty ? 'N/A' : supplier.address),
              
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Close', style: GoogleFonts.poppins(color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }
}
''';
  final file = File('lib/features/business/presentation/screens/supplier_list_screen.dart');
  await file.writeAsString(fileContent);
  print('Successfully updated supplier_list_screen.dart');
}
