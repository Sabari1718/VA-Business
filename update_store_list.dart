import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_list_screen.dart');
  String content = file.readAsStringSync();

  // 1. Update imports
  if (!content.contains('flutter_riverpod')) {
    content = content.replaceFirst(
      "import 'store_create_screen.dart';",
      "import 'store_create_screen.dart';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../providers/store_providers.dart';\nimport '../../data/models/store_model.dart';\nimport 'dart:convert';"
    );
  }

  // 2. Convert to ConsumerStatefulWidget
  content = content.replaceFirst(
    'class StoreListScreen extends StatefulWidget {',
    'class StoreListScreen extends ConsumerStatefulWidget {'
  );
  content = content.replaceFirst(
    'State<StoreListScreen> createState() => _StoreListScreenState();',
    'ConsumerState<StoreListScreen> createState() => _StoreListScreenState();'
  );
  content = content.replaceFirst(
    'class _StoreListScreenState extends State<StoreListScreen> {',
    'class _StoreListScreenState extends ConsumerState<StoreListScreen> {'
  );

  // 3. Add search state
  content = content.replaceFirst(
    "bool _isTableView = false;",
    "bool _isTableView = false;\n  final TextEditingController _searchController = TextEditingController();\n  String _searchQuery = '';\n\n  @override\n  void dispose() {\n    _searchController.dispose();\n    super.dispose();\n  }\n"
  );

  // 4. Update TextField to use controller and trigger setState on change
  content = content.replaceFirst(
    "child: TextField(",
    "child: TextField(\n                        controller: _searchController,\n                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),"
  );
  
  // 5. Build Main body integration
  final bodyIntegration = '''
      body: ref.watch(storesProvider).when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (error, stack) => Center(child: Text('Error: \$error', style: GoogleFonts.poppins(color: Colors.red))),
        data: (stores) {
          final singleBranchStores = stores.where((s) => s.branchManagementModel == 'Single Branch (Automatic Single Setup)' || s.branchManagementModel == 'Single Branch').toList();
          final multipleBranchStores = stores.where((s) => s.branchManagementModel == 'Multiple Branch').toList();
          
          final filteredStores = stores.where((s) {
            final matchesFilter = _selectedBranchFilter == 'Single Branch' 
                ? (s.branchManagementModel == 'Single Branch (Automatic Single Setup)' || s.branchManagementModel == 'Single Branch')
                : (s.branchManagementModel == 'Multiple Branch');
            final matchesSearch = s.storeName.toLowerCase().contains(_searchQuery) ||
                s.cityVillage.toLowerCase().contains(_searchQuery) ||
                s.customerCarePhone.toLowerCase().contains(_searchQuery);
            return matchesFilter && matchesSearch;
          }).toList();
          
          return SingleChildScrollView(
''';

  content = content.replaceFirst(
    "body: SingleChildScrollView(",
    bodyIntegration
  );
  
  // Update the closing braces for the body
  content = content.replaceFirst(
    "      ),\n    );\n  }\n\n  Widget _buildFilterButton",
    "      ),\n        },\n      ),\n    );\n  }\n\n  Widget _buildFilterButton"
  );
  
  // 6. Update Filter Buttons to use dynamic counts
  content = content.replaceFirst(
    "_buildFilterButton('Single Branch', '0', Icons.store),",
    "_buildFilterButton('Single Branch', '\${singleBranchStores.length}', Icons.store),"
  );
  content = content.replaceFirst(
    "_buildFilterButton('Multiple Branch', '0', Icons.account_tree_outlined),",
    "_buildFilterButton('Multiple Branch', '\${multipleBranchStores.length}', Icons.account_tree_outlined),"
  );
  
  content = content.replaceFirst(
    "'0 Stores Total',",
    "'\${filteredStores.length} Stores Total',"
  );

  // 7. Inject Empty vs Populated State
  final populatedState = '''
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
                          backgroundColor: const Color(0xFF6366F1), // Purple tone
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                )
              else 
                _isTableView ? _buildTableView(filteredStores) : _buildCardView(filteredStores),
''';

  content = content.replaceFirst(RegExp(r'// Empty State[\s\S]*?\]\),\n                \),'), populatedState);
  
  // 8. Define _buildCardView and _buildTableView
  final helperMethods = '''

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
          itemCount: stores.length,
          itemBuilder: (context, index) {
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
                      child: logoImage == null 
                          ? const Center(child: Icon(Icons.storefront, size: 40, color: Colors.black26)) 
                          : null,
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
                                  '\${store.cityVillage}, \${store.district}',
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
                                '\${store.openingTime} - \${store.closingTime}',
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
    return Container(
      width: double.infinity,
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
          ImageProvider? logoImage;
          if (store.storeLogo.isNotEmpty) {
            try {
              final base64Str = store.storeLogo.contains(',') ? store.storeLogo.split(',')[1] : store.storeLogo;
              logoImage = MemoryImage(base64Decode(base64Str));
            } catch (e) {}
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('\${index + 1}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54))),
                Expanded(
                  flex: 3, 
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          image: logoImage != null ? DecorationImage(image: logoImage, fit: BoxFit.cover) : null,
                        ),
                        child: logoImage == null ? const Icon(Icons.storefront, size: 20, color: Colors.black26) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store.storeName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(store.branchManagementModel, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6366F1))),
                          ],
                        ),
                      )
                    ],
                  )
                ),
                Expanded(
                  flex: 3, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.customerCareName, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(store.customerCarePhone, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                    ],
                  )
                ),
                Expanded(flex: 3, child: Text('\${store.cityVillage}, \${store.district}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),
                Expanded(
                  flex: 2, 
                  child: Text('\${store.openingTime}\\n\${store.closingTime}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87))
                ),
                Expanded(
                  flex: 1, 
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: store.status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      store.status,
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: store.status == 'Active' ? Colors.green : Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                ),
                Expanded(
                  flex: 1, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                    ],
                  )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
''';

  content = content.replaceFirst(
    "Widget _buildFilterButton",
    helperMethods + "Widget _buildFilterButton"
  );
  
  file.writeAsStringSync(content);
  print('Store List Screen updated successfully!');
}
