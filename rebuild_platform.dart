import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/platform_screen.dart');
  
  String content = '''
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class PlatformModel {
  final String id;
  String name;
  String description;
  String? imagePath;

  PlatformModel({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
  });
}

class ShopTypeModel {
  final String id;
  String name;
  String description;
  String platformId;
  String? imagePath;

  ShopTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.platformId,
    this.imagePath,
  });
}

class PlatformScreen extends StatefulWidget {
  const PlatformScreen({super.key});

  @override
  State<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends State<PlatformScreen> {
  int _currentStep = 1;
  final List<PlatformModel> _platforms = [];
  final List<ShopTypeModel> _shopTypes = [];
  
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(String) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onPicked(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: \$e');
    }
  }

  void _showPlatformDialog({PlatformModel? platform}) {
    final isEditing = platform != null;
    final nameController = TextEditingController(text: platform?.name ?? '');
    final descController = TextEditingController(text: platform?.description ?? '');
    String? localImagePath = platform?.imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(isEditing ? Icons.edit : Icons.tune, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isEditing ? 'Edit Platform' : 'Add Custom Integration / Endpoint',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      Text('Platform Icon / Logo (Upload, Drag & Drop or Copy-Paste)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      
                      GestureDetector(
                        onTap: () {
                          _pickImage((path) {
                            setDialogState(() {
                              localImagePath = path;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: localImagePath != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(localImagePath!), height: 80, width: 80, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() => localImagePath = null);
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                    label: Text('Remove', style: GoogleFonts.poppins(color: Colors.red, fontSize: 12)),
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Icon(Icons.cloud_upload_outlined, color: Colors.blue.shade300, size: 32),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Drag & drop image here, paste from clipboard (Ctrl+V), or click to browse',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  Text(
                                    'Supports PNG, JPG, SVG, WebP',
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Platform / Service Name *', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Custom Wholesale Portal, Magento ERP',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Integration Description', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe what this endpoint syncs...',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.storefront, color: AppColors.primaryBlue, size: 16),
                            const SizedBox(width: 8),
                            Text('Configured Shop Types (0)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'No shop types assigned to this platform.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) return;
                              
                              setState(() {
                                if (isEditing) {
                                  platform.name = nameController.text.trim();
                                  platform.description = descController.text.trim();
                                  platform.imagePath = localImagePath;
                                } else {
                                  _platforms.add(PlatformModel(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: nameController.text.trim(),
                                    description: descController.text.trim(),
                                    imagePath: localImagePath,
                                  ));
                                }
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5A4FCF),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(isEditing ? '✓ Save Changes' : '+ Add Platform', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  void _showShopTypeDialog({ShopTypeModel? shopType}) {
    final isEditing = shopType != null;
    final nameController = TextEditingController(text: shopType?.name ?? '');
    final descController = TextEditingController(text: shopType?.description ?? '');
    String selectedPlatformId = shopType?.platformId ?? '';
    String? localImagePath = shopType?.imagePath;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(isEditing ? Icons.edit : Icons.store, color: AppColors.primaryBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isEditing ? 'Edit Shop Type' : 'Create New Shop Type',
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.black54),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      Text('Shop Type Icon / Logo (Upload, Drag & Drop or Copy-Paste)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      
                      GestureDetector(
                        onTap: () {
                          _pickImage((path) {
                            setDialogState(() {
                              localImagePath = path;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: localImagePath != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(File(localImagePath!), height: 80, width: 80, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      setDialogState(() => localImagePath = null);
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                    label: Text('Remove', style: GoogleFonts.poppins(color: Colors.red, fontSize: 12)),
                                  )
                                ],
                              )
                            : Column(
                                children: [
                                  Icon(Icons.cloud_upload_outlined, color: Colors.blue.shade300, size: 32),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Drag & drop image here, paste from clipboard (Ctrl+V), or click to browse',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                                  Text(
                                    'Supports PNG, JPG, SVG, WebP',
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Shop Type Name *', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Pop-up Boutique, Franchise Outlet, Marketplace',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Assign to Platform (Optional)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text('-- Assign Later in Step 3 --', style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13)),
                            value: selectedPlatformId.isEmpty ? null : selectedPlatformId,
                            items: [
                              const DropdownMenuItem(value: '', child: Text('-- Assign Later in Step 3 --')),
                              ..._platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                            ],
                            onChanged: (val) {
                              setDialogState(() {
                                selectedPlatformId = val ?? '';
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Description', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe this shop type model...',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) return;
                              
                              setState(() {
                                if (isEditing) {
                                  shopType.name = nameController.text.trim();
                                  shopType.description = descController.text.trim();
                                  shopType.platformId = selectedPlatformId;
                                  shopType.imagePath = localImagePath;
                                } else {
                                  _shopTypes.add(ShopTypeModel(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: nameController.text.trim(),
                                    description: descController.text.trim(),
                                    platformId: selectedPlatformId,
                                    imagePath: localImagePath,
                                  ));
                                }
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5A4FCF),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(isEditing ? '✓ Save Changes' : '+ Create Shop Type', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
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
        title: Text(
          'Platform',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Color(0xFFE0E7FF), shape: BoxShape.circle),
                        child: const Icon(Icons.campaign, color: Color(0xFF4338CA), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Platform & Shop Setup', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text('Complete the steps below to configure your sales platform and create custom shop types', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Visual Stepper
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildStepIndicator(1, 'Platform Create Page', _currentStep == 1)),
                          if (!isMobile) Expanded(child: _buildStepLine()),
                          Expanded(child: _buildStepIndicator(2, 'Selected the Platform Based to Create the Type', _currentStep == 2)),
                          if (!isMobile) Expanded(child: _buildStepLine()),
                          Expanded(child: _buildStepIndicator(3, 'Platform & Type List', _currentStep == 3)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dynamic Content Area
            if (_currentStep == 1) _buildPlatformStep(),
            if (_currentStep == 2) _buildShopTypeStep(),
            if (_currentStep == 3) _buildListStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search platforms (e.g. Shopify, Amazon, POS)...',
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Platform Grid
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ..._platforms.map((platform) => _buildPlatformCard(platform, onEdit: () => _showPlatformDialog(platform: platform), onDelete: () => setState(() => _platforms.remove(platform)))),
            _buildAddCard(
              title: 'Add Custom Platform',
              subtitle: 'Connect proprietary database, custom REST webhook, or legacy ERP system.',
              btnLabel: '+ Add Custom Platform',
              onTap: () => _showPlatformDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShopTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search shop types (e.g. Retail, Wholesale, POS)...',
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.black45),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Shop Type Grid
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ..._shopTypes.map((st) => _buildPlatformCard(
              PlatformModel(id: st.id, name: st.name, description: st.description, imagePath: st.imagePath),
              onEdit: () => _showShopTypeDialog(shopType: st),
              onDelete: () => setState(() => _shopTypes.remove(st)),
            )),
            _buildAddCard(
              title: 'Add Custom Shop Type',
              subtitle: 'Create custom business model, dynamic option sets, or store configuration.',
              btnLabel: '+ Add Custom Shop Type',
              onTap: () => _showShopTypeDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag, color: Colors.blue.shade300, size: 48),
          const SizedBox(height: 16),
          Text('No platforms or shop types created yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Get started by creating your first platform or custom shop type.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            icon: const Icon(Icons.add, size: 16),
            label: Text('Go to Platform Create Page', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A4FCF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentStep = stepNumber;
        });
      },
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4338CA) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? const Color(0xFF4338CA) : Colors.grey.shade300, width: 2),
            ),
            child: Text(
              stepNumber.toString(),
              style: GoogleFonts.poppins(color: isActive ? Colors.white : Colors.grey.shade400, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isActive ? const Color(0xFF4338CA) : Colors.grey.shade500, 
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, 
              fontSize: 12
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Adjusted vertical margin to align correctly
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashWidth = 5.0;
          final dashCount = (constraints.constrainWidth() / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey.shade300)),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildPlatformCard(PlatformModel platform, {required VoidCallback onEdit, required VoidCallback onDelete}) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5A4FCF), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image Area
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            child: Center(
              child: platform.imagePath != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: Image.file(File(platform.imagePath!), width: double.infinity, height: 120, fit: BoxFit.cover),
                  )
                : Icon(Icons.dashboard_customize, color: Colors.blue.shade200, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(platform.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Color(0xFF5A4FCF), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(platform.description, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_outlined, color: Colors.black54, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), shape: BoxShape.circle),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCard({required String title, required String subtitle, required String btnLabel, required VoidCallback onTap}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Color(0xFF4F46E5), size: 24),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add, size: 16),
              label: Text(btnLabel, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
''';
  
  file.writeAsStringSync(content);
  print('Regenerated platform screen with complete functionality and overflow fixes!');
}
