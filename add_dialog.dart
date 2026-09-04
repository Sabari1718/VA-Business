import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/create_propagator_screen.dart');
  String content = file.readAsStringSync();

  // 1. Make "+ Add Custom Business Type" button clickable
  content = content.replaceAll('''
          Align(
            alignment: Alignment.centerLeft, // Left aligned for mobile to prevent overflow
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'Add Custom Business Type',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                ),
              ),
            ),
          ),''', '''
          Align(
            alignment: Alignment.centerLeft, // Left aligned for mobile to prevent overflow
            child: TextButton.icon(
              onPressed: () => _showCreateBusinessTypeDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'Add Custom Business Type',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                ),
              ),
            ),
          ),''');

  // 2. Make "Add Option" card clickable
  content = content.replaceAll('''
          // Add Option Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.5), // Simulated dashed
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.black54, size: 24),
                ),
                const SizedBox(height: 12),
                Text('Add Option', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Create custom business type', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),''', '''
          // Add Option Card
          InkWell(
            onTap: () => _showCreateBusinessTypeDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5), // Simulated dashed
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.black54, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text('Add Option', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Create custom business type', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11)),
                ],
              ),
            ),
          ),''');

  // 3. Add _showCreateBusinessTypeDialog method before final closing brace
  String dialogMethod = '''
  void _showCreateBusinessTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Create New Business Type',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black54, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildLabel('1. Business Type Name *'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'e.g., Franchising, Agriculture, Logistics...',
                        hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('2. Image / Icon (Drag & Drop, Copy & Paste, or Browse)'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(height: 12),
                        Text('Click to browse or Drag & Drop image here', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black87, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('Supports all file types (PNG, JPG, SVG, WEBP, etc.)', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Ctrl + V to Paste directly', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('3. Description (Optional)'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Brief description of this business model and operations...',
                        hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {}, // Save Action
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Create Business Type', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
''';

  content = content.replaceFirst(RegExp(r'\}\s*$'), dialogMethod);
  
  file.writeAsStringSync(content);
  print('Done adding dialog');
}
