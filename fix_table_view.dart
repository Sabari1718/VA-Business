import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_list_screen.dart');
  String content = file.readAsStringSync();

  // 1. Remove the standalone table header block
  content = content.replaceFirst(RegExp(r'              // Table Header \(Only if _isTableView is true\)\n              if \(_isTableView\) \.\.\.\[[\s\S]*?              \],\n\n'), '');

  // 2. Rewrite _buildTableView to include the header and the new styles
  final newBuildTableView = '''
  Widget _buildTableView(List<StoreModel> stores) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool requiresScroll = constraints.maxWidth < 1000;
        final double tableWidth = requiresScroll ? 1000 : constraints.maxWidth;

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
                          child: Text('\${index + 1}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
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
                          Text('\${store.cityVillage}, \${store.district}, \${store.pincode}, \${store.state}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
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
                              Text('\${store.openingTime} -', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: Text('\${store.closingTime}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: store.status == 'Active' ? Colors.green : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ACTIONS
                    Expanded(
                      flex: 2, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                          const SizedBox(width: 8),
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
''';

  content = content.replaceFirst(
    RegExp(r'  Widget _buildTableView\(List<StoreModel> stores\) \{[\s\S]*?  Widget _buildFilterButton'),
    newBuildTableView + '  Widget _buildFilterButton'
  );

  file.writeAsStringSync(content);
  print('Table View updated successfully!');
}
