import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/platform_model.dart';
import '../providers/platform_providers.dart';
import 'package:va_business/core/utils/safe_base64_decode.dart';


class PlatformScreen extends ConsumerStatefulWidget {
  const PlatformScreen({super.key});

  @override
  ConsumerState<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends ConsumerState<PlatformScreen> {
  int _currentStep = 1;
  
  
  
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Function(String) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onPicked(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _confirmDeletePlatform(PlatformModel platform) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Platform', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${platform.name}?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(platformRepositoryProvider).deletePlatform(platform.id);
        ref.invalidate(platformsProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Platform deleted successfully', style: GoogleFonts.poppins()), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting platform: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _confirmDeleteShopType(ShopTypeModel shopType) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Shop Type', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${shopType.name}?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ref.read(platformRepositoryProvider).deleteShopType(shopType.id);
        ref.invalidate(shopTypesProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shop Type deleted successfully', style: GoogleFonts.poppins()), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting shop type: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red));
      }
    }
  }

  void _showPlatformDialog({PlatformModel? platform}) {
    final isEditing = platform != null;
    final nameController = TextEditingController(text: platform?.name ?? '');
    final descController = TextEditingController(text: platform?.description ?? '');
    String? localImagePath = platform?.image;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
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
                                Icon(isEditing ? Icons.edit_outlined : Icons.add_circle_outline, color: const Color(0xFF5A4FCF)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isEditing ? 'Edit Platform' : 'Add Custom Platform',
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.black54),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),
                      
                      Text('Platform Name *', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Custom Wholesale Portal',
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Platform Logo / Icon', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      
                      if (localImagePath != null && localImagePath!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: localImagePath!.startsWith('data:image') || !localImagePath!.startsWith('http') && !File(localImagePath!).existsSync()
                                    ? Image.memory(safeBase64Decode(localImagePath!), height: 48, width: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 48))
                                    : (localImagePath!.startsWith('http')
                                        ? Image.network(localImagePath!, height: 48, width: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 48))
                                        : Image.file(File(localImagePath!), height: 48, width: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 48))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Selected Image Preview', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Text('Uploaded Image (Base64 Data)', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setDialogState(() => localImagePath = null);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                                  ),
                                  backgroundColor: const Color(0xFFFEF2F2),
                                ),
                                child: Text('Remove', style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
                              )
                            ],
                          ),
                        ),
                      
                      // Dashed upload area
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5, style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_upload_outlined, color: Color(0xFF5A4FCF), size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'Drag & drop new logo image, or click to browse',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supports PNG, JPG, SVG, WebP',
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Description', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, color: Color(0xFF5A4FCF), size: 20),
                          const SizedBox(width: 8),
                          Text('Configured Shop Types (0)', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'No shop types assigned to this platform.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () async {
                                if (nameController.text.trim().isEmpty) return;
                                
                                setDialogState(() => isLoading = true);
                                final repo = ref.read(platformRepositoryProvider);
                                final data = {
                                  'platformName': nameController.text.trim(),
                                  'integrationDescription': descController.text.trim(),
                                  'platformLogo': localImagePath != null && !localImagePath!.startsWith('http') && !localImagePath!.startsWith('data') 
                                      ? 'data:image/jpeg;base64,${base64Encode(File(localImagePath!).readAsBytesSync())}' 
                                      : localImagePath,
                                };
                                
                                try {
                                  if (isEditing) {
                                    await repo.updatePlatform(platform.id, data);
                                  } else {
                                    await repo.createPlatform(data);
                                  }
                                  ref.invalidate(platformsProvider);
                                  if (mounted) Navigator.pop(context);
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  setDialogState(() => isLoading = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1), // Indigo
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: isLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Save Changes', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
    String? localImagePath = shopType?.image;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
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
                                Icon(isEditing ? Icons.edit_outlined : Icons.storefront_outlined, color: const Color(0xFF5A4FCF)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isEditing ? 'Edit Shop Type' : 'Create New Shop Type',
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.black54),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          const Icon(Icons.image_outlined, color: Color(0xFF5A4FCF), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Shop Type Icon / Logo (Upload, Drag & Drop or Copy-Paste)', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (localImagePath != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: (localImagePath!.startsWith('http') || localImagePath!.startsWith('data:image'))
                                    ? (localImagePath!.startsWith('data:image') 
                                        ? Image.memory(safeBase64Decode(localImagePath!), height: 48, width: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 48))
                                        : Image.network(localImagePath!, height: 48, width: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 48)))
                                    : Image.file(File(localImagePath!), height: 48, width: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 48)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Selected Image Preview', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Text('Uploaded Image (Base64 Data)', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setDialogState(() => localImagePath = null);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                                  ),
                                  backgroundColor: const Color(0xFFFEF2F2),
                                ),
                                child: Text('Remove', style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
                              )
                            ],
                          ),
                        )
                      else
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5, style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, color: Color(0xFF5A4FCF), size: 28),
                                const SizedBox(height: 8),
                                Text(
                                  'Drag & drop image here, paste from clipboard (Ctrl+V), or click to browse',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Supports PNG, JPG, SVG, WebP',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      Text('Or Icon Emoji:', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '🏪',
                            hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text('Shop Type Name *', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
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
                      
                      Text('Assign to Platform (Optional)', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
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
                              DropdownMenuItem(value: '', child: Text('-- Assign Later in Step 3 --', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13))),
                              ...ref.watch(platformsProvider).maybeWhen(
                                data: (data) {
                                  final platforms = data.data.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>)).toList();
                                  return platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14))));
                                },
                                orElse: () => [],
                              ),
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
                      
                      Text('Description', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
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
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () async {
                                if (nameController.text.trim().isEmpty) return;
                                setDialogState(() => isLoading = true);
                                try {
                                  final repo = ref.read(platformRepositoryProvider);
                                  final data = {
                                    'shopTypeName': nameController.text.trim(),
                                    'description': descController.text.trim(),
                                    'platformId': selectedPlatformId,
                                    'categoryLabel': 'Custom Business Model',
                                    'shopTypeLogo': localImagePath != null && !localImagePath!.startsWith('http') && !localImagePath!.startsWith('data') 
                                        ? 'data:image/jpeg;base64,${base64Encode(File(localImagePath!).readAsBytesSync())}' 
                                        : localImagePath,
                                  };
                                  if (isEditing) {
                                    await repo.updateShopType(shopType.id, data);
                                  } else {
                                    await repo.createShopType(data);
                                  }
                                  ref.invalidate(shopTypesProvider);
                                  if (mounted) Navigator.pop(context);
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                  setDialogState(() => isLoading = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: isLoading 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(isEditing ? Icons.check : Icons.add, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Text(isEditing ? 'Save Changes' : 'Create Shop Type', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
        ref.watch(platformsProvider).when(
          data: (data) {
            final platforms = data.data.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>)).toList();
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...platforms.map((platform) => _buildPlatformCard(
                  platform, 
                  onEdit: () => _showPlatformDialog(platform: platform), 
                  onDelete: () => _confirmDeletePlatform(platform),

                )),
                _buildAddCard(
                  title: 'Add Custom Platform',
                  subtitle: 'Connect proprietary database, custom REST webhook, or legacy ERP system.',
                  btnLabel: '+ Add Custom Platform',
                  onTap: () => _showPlatformDialog(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
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
        ref.watch(shopTypesProvider).when(
          data: (data) {
            final shopTypes = data.data.map((e) => ShopTypeModel.fromJson(e as Map<String, dynamic>)).toList();
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...shopTypes.map((st) => _buildPlatformCard(
                  PlatformModel(id: st.id, name: st.name, description: st.description, image: st.image),
                  onEdit: () => _showShopTypeDialog(shopType: st),
                  onDelete: () => _confirmDeleteShopType(st),
                )),
                _buildAddCard(
                  title: 'Add Custom Shop Type',
                  subtitle: 'Create custom business model, dynamic option sets, or store configuration.',
                  btnLabel: '+ Add Custom Shop Type',
                  onTap: () => _showShopTypeDialog(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  void _showAssignAndMergeDialog({String? initialPlatformId, List<String>? initialShopTypeIds}) {
    String selectedPlatformId = initialPlatformId ?? '';
    List<String> selectedShopTypeIds = initialShopTypeIds?.toList() ?? [];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final platformsAsync = ref.watch(platformsProvider);
            final shopTypesAsync = ref.watch(shopTypesProvider);

            List<PlatformModel> platforms = [];
            if (platformsAsync.hasValue && platformsAsync.value != null) {
              platforms = platformsAsync.value!.data.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>)).toList();
            }

            List<ShopTypeModel> shopTypes = [];
            if (shopTypesAsync.hasValue && shopTypesAsync.value != null) {
              shopTypes = shopTypesAsync.value!.data.map((e) => ShopTypeModel.fromJson(e as Map<String, dynamic>)).toList();
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Colors.white,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
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
                              const Icon(Icons.storefront_outlined, color: Color(0xFF5A4FCF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Assign & Merge Shop Types to Platform',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.black54),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Text('Select Platform *', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
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
                          hint: Text('-- Select Platform --', style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13)),
                          value: selectedPlatformId.isEmpty ? null : selectedPlatformId,
                          items: [
                            DropdownMenuItem(value: '', child: Text('-- Select Platform --', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13))),
                            ...platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name, style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14)))),
                          ],
                          onChanged: (val) {
                            setDialogState(() {
                              selectedPlatformId = val ?? '';
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Select Shop Types (${selectedShopTypeIds.length} / ${shopTypes.length})', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedShopTypeIds = shopTypes.map((e) => e.id).toList();
                                });
                              },
                              child: Text('Select All', style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Text('|', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38)),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedShopTypeIds.clear();
                                });
                              },
                              child: Text('Unselect All', style: GoogleFonts.poppins(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: shopTypes.isEmpty 
                        ? Center(child: Text('No shop types available.', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 12)))
                        : ListView.builder(
                            itemCount: shopTypes.length,
                            itemBuilder: (context, index) {
                              final st = shopTypes[index];
                              final isSelected = selectedShopTypeIds.contains(st.id);
                              return CheckboxListTile(
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: Row(
                                  children: [
                                    if (st.image != null && st.image!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: st.image!.startsWith('data:image') || !st.image!.startsWith('http') && !File(st.image!).existsSync()
                                            ? Image.memory(safeBase64Decode(st.image!), width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 24))
                                            : (st.image!.startsWith('http')
                                                ? Image.network(st.image!, width: 24, height: 24, fit: BoxFit.cover)
                                                : Image.file(File(st.image!), width: 24, height: 24, fit: BoxFit.cover)),
                                        ),
                                      ),
                                    Expanded(child: Text(st.name, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87))),
                                  ],
                                ),
                                value: isSelected,
                                onChanged: (val) {
                                  setDialogState(() {
                                    if (val == true) {
                                      selectedShopTypeIds.add(st.id);
                                    } else {
                                      selectedShopTypeIds.remove(st.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isLoading || selectedPlatformId.isEmpty || selectedShopTypeIds.isEmpty) ? null : () async {
                              setDialogState(() => isLoading = true);
                              try {
                                final repo = ref.read(platformRepositoryProvider);
                                
                                final selectedPlatform = platforms.firstWhere((p) => p.id == selectedPlatformId);
                                
                                final shopTypeList = selectedShopTypeIds.map((id) {
                                  final st = shopTypes.firstWhere((s) => s.id == id);
                                  return {
                                    'shop_type_id': st.id,
                                    'shop_type_name': st.name,
                                  };
                                }).toList();

                                await repo.assignPlatform({
                                  'platformId': selectedPlatformId,
                                  'platform_name': selectedPlatform.name,
                                  'shop_type': shopTypeList,
                                });
                                
                                ref.invalidate(platformAssignmentsProvider);
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shop types assigned successfully', style: GoogleFonts.poppins()), backgroundColor: Colors.green));
                                }
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                setDialogState(() => isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text('Save & Merge Types', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
        );
      },
    );
  }

  Widget _buildListStep() {
    final platformsAsync = ref.watch(platformsProvider);
    final platforms = platformsAsync.value?.data.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];

    final shopTypesAsync = ref.watch(shopTypesProvider);
    final shopTypes = shopTypesAsync.value?.data.map((e) => ShopTypeModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];

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
              hintText: 'Search platforms and shop types...',
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
        
        // Wrap with Add Card
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildAddCard(
              title: 'Add Custom Shop Type',
              subtitle: 'Create custom business model, dynamic option sets, or store configuration.',
              btnLabel: '+ Add Custom Shop Type',
              onTap: () => _showAssignAndMergeDialog(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        ref.watch(platformAssignmentsProvider).when(
          data: (data) {
            final assignments = data.data.map((e) => PlatformAssignModel.fromJson(e as Map<String, dynamic>)).toList();
            if (assignments.isEmpty) {
              return const SizedBox();
            }
            
            final Map<String, List<PlatformAssignModel>> groupedAssignments = {};
            for (var assignment in assignments) {
              groupedAssignments.putIfAbsent(assignment.platformId, () => []).add(assignment);
            }

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: groupedAssignments.entries.map((entry) {
                final platformId = entry.key;
                final platformAssignments = entry.value;
                final platformName = platformAssignments.first.platformName ?? 'Platform $platformId';

                return Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final platform = platforms.where((p) => p.id == platformId).firstOrNull;
                              if (platform?.image != null && platform!.image!.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: platform.image!.startsWith('data:image') || !platform.image!.startsWith('http') && !File(platform.image!).existsSync()
                                    ? Image.memory(safeBase64Decode(platform.image!), width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 40, height: 40, color: const Color(0xFF1E293B), child: const Icon(Icons.broken_image, color: Colors.white, size: 20)))
                                    : (platform.image!.startsWith('http')
                                        ? Image.network(platform.image!, width: 40, height: 40, fit: BoxFit.cover)
                                        : Image.file(File(platform.image!), width: 40, height: 40, fit: BoxFit.cover)),
                                );
                              }
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.apps, color: Colors.white, size: 20),
                              );
                            }
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              platformName,
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.black45, size: 20),
                            onPressed: () {
                              _showAssignAndMergeDialog(
                                initialPlatformId: platformId,
                                initialShopTypeIds: platformAssignments.map((a) => a.shopTypeId).toList(),
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.black45, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  title: Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text('Delete Platform', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  content: Text('Are you sure you want to delete all shop types for this platform?', style: GoogleFonts.poppins(fontSize: 14)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.w500)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true) {
                                final repo = ref.read(platformRepositoryProvider);
                                for (var assignment in platformAssignments) {
                                  await repo.deletePlatformAssignment(assignment.id);
                                }
                                ref.invalidate(platformAssignmentsProvider);
                              }
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'CONFIGURED SHOP TYPES (${platformAssignments.length})',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: platformAssignments.map((assignment) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Builder(
                                  builder: (context) {
                                    final shopType = shopTypes.where((s) => s.id == assignment.shopTypeId).firstOrNull;
                                    if (shopType?.image != null && shopType!.image!.isNotEmpty) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: shopType.image!.startsWith('data:image') || !shopType.image!.startsWith('http') && !File(shopType.image!).existsSync()
                                          ? Image.memory(safeBase64Decode(shopType.image!), width: 14, height: 14, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 14))
                                          : (shopType.image!.startsWith('http')
                                              ? Image.network(shopType.image!, width: 14, height: 14, fit: BoxFit.cover)
                                              : Image.file(File(shopType.image!), width: 14, height: 14, fit: BoxFit.cover)),
                                      );
                                    }
                                    return const Icon(Icons.storefront, size: 14, color: Colors.black54);
                                  }
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  assignment.shopTypeName ?? 'Shop Type',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        title: Row(
                                          children: [
                                            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                            const SizedBox(width: 8),
                                            Text('Delete Shop Type', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        content: Text('Are you sure you want to remove this shop type from the platform?', style: GoogleFonts.poppins(fontSize: 14)),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54, fontWeight: FontWeight.w500)),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    );
                                    
                                    if (confirm == true) {
                                      await ref.read(platformRepositoryProvider).deletePlatformAssignment(assignment.id);
                                      ref.invalidate(platformAssignmentsProvider);
                                    }
                                  },
                                  child: const Icon(Icons.close, size: 14, color: Colors.black45),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ],
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
              child: platform.image != null && platform.image!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: platform.image!.startsWith('data:image') || !platform.image!.startsWith('http') && !File(platform.image!).existsSync()
                        ? Image.memory(
                            safeBase64Decode(platform.image!),
                            width: double.infinity, height: 120, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image, color: Colors.blue.shade200, size: 48),
                          )
                        : (platform.image!.startsWith('http')
                            ? Image.network(platform.image!, width: double.infinity, height: 120, fit: BoxFit.cover)
                            : Image.file(File(platform.image!), width: double.infinity, height: 120, fit: BoxFit.cover)),
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
