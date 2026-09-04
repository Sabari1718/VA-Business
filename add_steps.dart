import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/create_propagator_screen.dart');
  String content = file.readAsStringSync();

  // Replace placeholders in build method
  content = content.replaceAll(
    "if (_currentStep == 4) _buildPlaceholderStep('Business Address'),\n              if (_currentStep == 5) _buildPlaceholderStep('Business Type'),",
    "if (_currentStep == 4) _buildStep4BusinessAddress(),\n              if (_currentStep == 5) _buildStep5BusinessType(),"
  );

  String step4 = '''
  // ===================== STEP 4: BUSINESS ADDRESS =====================
  Widget _buildStep4BusinessAddress() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Business Address',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Door Number *', 'Door Number'),
              const SizedBox(height: 16),
              _buildTextField('Street Name *', 'Street Name'),
              const SizedBox(height: 16),
              _buildTextField('Building Name', 'Building Name'),
              const SizedBox(height: 16),
              _buildTextField('Landmark', 'Landmark'),
              const SizedBox(height: 16),
              _buildTextField('Area *', 'Area'),
              const SizedBox(height: 16),
              _buildTextField('District *', 'District'),
              const SizedBox(height: 16),
              _buildTextField('Pincode *', 'Pincode'),
              const SizedBox(height: 16),
              _buildTextField('State *', 'State'),
              const SizedBox(height: 16),
              _buildTextField('Country', 'India'), // Assuming pre-filled
            ],
          ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Save & Continue to Business Type →', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('← Back to Bank Details', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
''';

  String step5 = '''
  // ===================== STEP 5: BUSINESS TYPE =====================
  Widget _buildStep5BusinessType() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Type',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      'Select one or more business types that best describe your business',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text(
            'Select one or more business types that best describe your business',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          
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
          ),
          const SizedBox(height: 24),
          
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
          ),
          const SizedBox(height: 24),
          
          // Info Alert
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can select multiple business types that apply to your business.',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF0284C7), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Year of Establishment', 'YYYY'),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Number of Employees'),
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
                        hint: Text('Select range', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                        items: const [],
                        onChanged: (val) {},
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Save & Register Business', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('← Back to Business Address', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
''';

  // Replace placeholder method entirely
  final RegExp placeholderRegex = RegExp(r'// Placeholder for Step 4 & 5.*?Widget _buildPlaceholderStep\(String title\) \{.*?\}(?=\s*// ===================== HELPER WIDGETS =====================)', dotAll: true);
  
  if (placeholderRegex.hasMatch(content)) {
    content = content.replaceFirst(placeholderRegex, step4 + step5);
  } else {
    print('Failed to find placeholder method to replace.');
    return;
  }

  file.writeAsStringSync(content);
  print('Done adding step 4 and 5');
}
