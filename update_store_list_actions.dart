import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_list_screen.dart');
  String content = file.readAsStringSync();

  // 1. Add _deleteStore method
  final deleteMethod = '''
  void _deleteStore(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this store?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                await ref.read(storeRepositoryProvider).deleteStore(id);
                if (mounted) {
                  ref.invalidate(storesProvider);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store deleted successfully!'), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: \$e'), backgroundColor: Colors.red));
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
''';
  
  if (!content.contains('_deleteStore(')) {
    content = content.replaceFirst(
      'Widget _buildCardView(List<StoreModel> stores) {',
      deleteMethod + '\n  Widget _buildCardView(List<StoreModel> stores) {'
    );
  }

  // 2. Modify _buildCardView to include the Add New Store card
  // It returns GridView.builder. We change itemCount to stores.length + 1
  content = content.replaceFirst(
    'itemCount: stores.length,',
    'itemCount: stores.length + 1,'
  );

  final cardItemBuilderStart = '''
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
''';

  content = content.replaceFirst(
    RegExp(r'itemBuilder: \(context, index\) \{\s*final store = stores\[index\];'),
    cardItemBuilderStart
  );

  // 3. Connect Edit and Delete buttons in Card View
  final editIconBlock = '''
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
''';

  // The card view image header block replacement for icons
  content = content.replaceFirst(
    'image: logoImage != null ? DecorationImage(image: logoImage, fit: BoxFit.cover) : null,\n                      ),\n                      child: logoImage == null \n                          ? const Center(child: Icon(Icons.storefront, size: 40, color: Colors.black26)) \n                          : null,',
    '''image: logoImage != null ? DecorationImage(image: logoImage, fit: BoxFit.cover) : null,
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
$editIconBlock
                              ],
                            ),
                          ),
                        ],
                      ),'''
  );

  // 4. Fix overflow and add edit/delete actions in Table View
  content = content.replaceFirst(
    "Expanded(flex: 3, child: Text('\${store.cityVillage}, \${store.district}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),",
    "Expanded(flex: 3, child: Text('\${store.cityVillage}, \${store.district}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),"
  );
  
  // The error was "A RenderFlex overflowed by 75 pixels on the right. The relevant error-causing widget was: Row Row:file:///.../store_list_screen.dart:555:26"
  // Let's replace the actions row at the end of the table view
  content = content.replaceFirst(
    '''
                Expanded(
                  flex: 1, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                    ],
                  )
                ),''',
    '''
                Expanded(
                  flex: 1, 
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.black54), 
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StoreCreateScreen(store: store)),
                          );
                        }
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), 
                        onPressed: () => _deleteStore(store.id!)
                      ),
                    ],
                  )
                ),'''
  );
  
  file.writeAsStringSync(content);
  print('Updated StoreListScreen successfully!');
}
