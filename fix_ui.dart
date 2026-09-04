import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/create_propagator_screen.dart');
  String content = file.readAsStringSync();

  // Fix Row 1
  content = content.replaceAll('''
          Row(
            children: [
              Expanded(child: _buildTextField('Business Name *', 'Enter business name')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextFieldWithVerify('Business Email *', 'business@example.com')),
            ],
          ),''', '''
          Column(
            children: [
              _buildTextField('Business Name *', 'Enter business name'),
              const SizedBox(height: 16),
              _buildTextFieldWithVerify('Business Email *', 'business@example.com'),
            ],
          ),''');

  // Fix Row 2
  content = content.replaceAll('''
          Row(
            children: [
              Expanded(child: _buildTextFieldWithVerify('Business Phone *', '10-digit mobile number')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Website', 'https://www.example.com')),
            ],
          ),''', '''
          Column(
            children: [
              _buildTextFieldWithVerify('Business Phone *', '10-digit mobile number'),
              const SizedBox(height: 16),
              _buildTextField('Website', 'https://www.example.com'),
            ],
          ),''');

  // Fix Row 3
  content = content.replaceAll('''
          Row(
            children: [
              Expanded(child: _buildTextField('Udyam Registration Number *', 'Enter Udyam (e.g., UDYAM-...)')),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Corporate Identification Number (CIN)', 'Enter CIN')),
            ],
          ),''', '''
          Column(
            children: [
              _buildTextField('Udyam Registration Number *', 'Enter Udyam (e.g., UDYAM-...)'),
              const SizedBox(height: 16),
              _buildTextField('Corporate Identification Number (CIN)', 'Enter CIN'),
            ],
          ),''');

  // Fix Row 4 (Company Logo and Turnover)
  content = content.replaceAll('''
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Company Logo (Optional)'),
                    const SizedBox(height: 8),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                              border: Border(right: BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Text('Choose File', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 16),
                          Text('No file chosen', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('JPG, PNG (Max 2MB)', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          hint: Text('Select Turnover Range', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                          items: const [],
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),''', '''
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Company Logo (Optional)'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                            border: Border(right: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: Text('Choose File', style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text('No file chosen', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('JPG, PNG (Max 2MB)', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        hint: Text('Select Turnover Range', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                        items: const [],
                        onChanged: (val) {},
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),''');

  // Fix PAN Details Row
  content = content.replaceAll('''
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Business PAN Number *', 'ABCDE1234F'),
                    const SizedBox(height: 4),
                    Text('10-character alphanumeric PAN number', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Business PAN Card Photo *'),
                    const SizedBox(height: 8),
                    _buildDottedUploadBox('Click to upload PAN card', 'PDF, JPG or PNG (max. 5MB)'),
                  ],
                ),
              ),
            ],
          ),''', '''
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Business PAN Number *', 'ABCDE1234F'),
              const SizedBox(height: 4),
              Text('10-character alphanumeric PAN number', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
              const SizedBox(height: 24),
              _buildLabel('Business PAN Card Photo *'),
              const SizedBox(height: 8),
              _buildDottedUploadBox('Click to upload PAN card', 'PDF, JPG or PNG (max. 5MB)'),
            ],
          ),''');

  file.writeAsStringSync(content);
  print('Done rewriting rows to columns');
}
