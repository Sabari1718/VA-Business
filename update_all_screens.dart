import 'dart:io';

void processFile(String path, bool isPartner) {
  final file = File(path);
  if (!file.existsSync()) return;
  
  String content = file.readAsStringSync();

  // 1. Inject State Variables if not present
  if (!content.contains('String _selectedTier = ')) {
    content = content.replaceFirst('int _currentStep = 1;', '''
  int _currentStep = 1;
  String _selectedTier = 'STANDARD';
  String? _selectedEmployeeRange;
''');
  }

  // 2. Add Employee Dropdown items array if not present
  if (!content.contains('final List<String> _employeeRanges =')) {
    content = content.replaceFirst('class _Create', '''
class _Create'''); // Just a dummy, let's insert it inside the State class
    content = content.replaceFirst('String _selectedTier', '''
  final List<String> _employeeRanges = [
    '1 - 10 employees',
    '11 - 50 employees',
    '51 - 200 employees',
    '200+ employees',
  ];
  String _selectedTier''');
  }

  // 3. Update Employee Dropdown in Business Type Step
  String oldDropdown = '''
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
                  ),''';
  
  String newDropdown = '''
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
                        value: _selectedEmployeeRange,
                        hint: Text('Select range', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                        items: _employeeRanges.map((String range) {
                          return DropdownMenuItem<String>(
                            value: range,
                            child: Text(range, style: GoogleFonts.poppins(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedEmployeeRange = val;
                          });
                        },
                      ),
                    ),
                  ),''';
  
  content = content.replaceAll(oldDropdown, newDropdown);

  // 4. Completely replace Basic Details step content to include new fields
  String stepMethodName = isPartner ? '_buildStep2BasicDetails()' : '_buildStep1BasicDetails()';
  
  // Extract everything inside the method body
  final RegExp stepRegex = RegExp(
    isPartner 
    ? r'Widget _buildStep2BasicDetails\(\) \{.*?(?=// ===================== STEP 3)' 
    : r'Widget _buildStep1BasicDetails\(\) \{.*?(?=// ===================== STEP 2)',
    dotAll: true,
  );

  String newBasicDetails = '''
  Widget $stepMethodName {
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
              const Icon(Icons.business, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Basic Business Details',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildTextField('Business Name *', 'Enter business name'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildTextField('Business Email *', 'business@example.com')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Verify', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildTextField('Business Phone *', '10-digit mobile number')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Verify', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Website', 'https://www.example.com'),
          const SizedBox(height: 16),
          _buildTextField('Udyam Registration Number *', 'Enter Udyam Registration Number'),
          const SizedBox(height: 16),
          _buildTextField('Corporate Identification Number (CIN)', 'Enter CIN'),
          const SizedBox(height: 24),

          _buildLabel('Company Logo (Optional)'),
          const SizedBox(height: 8),
          _buildDottedUploadBox('Click to upload logo', 'SVG, PNG, JPG (Max. 2MB)'),
          const SizedBox(height: 16),

          _buildLabel('Turnover / Income *'),
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
                hint: Text('Below ₹20 Lakhs', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13)),
                items: const [],
                onChanged: (val) {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildLabel('Company Tier *'),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildTierCard('STARTUP', 'Small business / new company', Icons.rocket_launch, _selectedTier == 'STARTUP', true),
              const SizedBox(height: 12),
              _buildTierCard('STANDARD', 'Growing business', Icons.business, _selectedTier == 'STANDARD', false),
              const SizedBox(height: 12),
              _buildTierCard('CORPORATE', 'Large organization', Icons.location_city, _selectedTier == 'CORPORATE', false),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              border: Border(left: BorderSide(color: Color(0xFF0284C7), width: 3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on your turnover range, we recommended this tier. You can still choose another option.',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'PAN Details',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildTextField('Business PAN Number *', 'ABCDE1234F'),
          const SizedBox(height: 4),
          Text('10-character alphanumeric PAN number', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
          const SizedBox(height: 24),
          _buildLabel('Business PAN Card Photo *'),
          const SizedBox(height: 8),
          _buildDottedUploadBox('Click to upload PAN card', 'PDF, JPG or PNG (max. 5MB)'),
          const SizedBox(height: 32),

          Row(
            children: [
              const Icon(Icons.draw, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Authorized Signature',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildLabel('Upload Signature Photo *'),
          const SizedBox(height: 8),
          _buildDottedUploadBox('Click to upload signature', 'JPG or PNG (max. 5MB)', height: 120),
          
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
                child: Text('Save & Continue to GST Details →', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: ''' + (isPartner ? '_previousStep' : '() => Navigator.pop(context)') + ''',
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(''' + (isPartner ? "'← Back to Partner Details'" : "'Cancel'") + ''', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
''';
  
  if (stepRegex.hasMatch(content)) {
    content = content.replaceFirst(stepRegex, newBasicDetails);
  } else {
    print('Failed to match basic details in \$path');
  }

  // 5. Add _buildTierCard Helper Method
  if (!content.contains('Widget _buildTierCard')) {
    String tierCardMethod = '''
  Widget _buildTierCard(String title, String subtitle, IconData icon, bool isSelected, bool isRecommended) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTier = title;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRecommended)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.red, size: 10),
                        const SizedBox(width: 4),
                        Text('Recommended', style: GoogleFonts.poppins(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                Icon(icon, color: isSelected ? AppColors.primaryBlue : Colors.blue.shade300, size: 32),
                const SizedBox(height: 12),
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11)),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
''';
    content = content.replaceFirst('Widget _buildLabel(String text)', tierCardMethod + '\n  Widget _buildLabel(String text)');
  }

  file.writeAsStringSync(content);
  print('Done processing \$path');
}

void main() {
  processFile('lib/features/business/presentation/screens/create_propagator_screen.dart', false);
  processFile('lib/features/business/presentation/screens/create_partner_screen.dart', true);
  processFile('lib/features/business/presentation/screens/create_supplier_screen.dart', false);
}
