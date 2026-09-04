import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/platform_screen.dart');
  String content = file.readAsStringSync();
  
  // Remove import
  content = content.replaceAll("import 'package:dotted_border/dotted_border.dart';\n", "");
  
  // Replace DottedBorder around Add Platform Card
  String addCardDottedBorder = '''
          DottedBorder(
            color: Colors.grey.shade300,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              height: 100,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.grey.shade50),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Color(0xFF4F46E5), size: 24),
              ),
            ),
          ),''';
          
  String addCardReplacement = '''
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
          ),''';
          
  content = content.replaceFirst(addCardDottedBorder, addCardReplacement);
  
  // Replace DottedBorder around Dialog Upload Box
  String dialogDottedBorder = '''
                  DottedBorder(
                    color: Colors.grey.shade300,
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(color: Colors.grey.shade50),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: Colors.blue.shade300, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Drag & drop image here, paste from clipboard (Ctrl+V), or click to browse',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            'Supports PNG, JPG, SVG, WebP',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),''';
                  
  String dialogReplacement = '''
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined, color: Colors.blue.shade300, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Drag & drop image here, paste from clipboard (Ctrl+V), or click to browse',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          'Supports PNG, JPG, SVG, WebP',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),''';
                  
  content = content.replaceFirst(dialogDottedBorder, dialogReplacement);
  
  file.writeAsStringSync(content);
  print('Fixed dotted borders!');
}
