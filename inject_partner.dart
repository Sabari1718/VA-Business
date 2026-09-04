import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/create_partner_screen.dart');
  String content = file.readAsStringSync();

  String partnerStep = '''
  // ===================== STEP 1: PARTNER DETAILS =====================
  Widget _buildStep1PartnerDetails() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.handshake_outlined, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Partner Details',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_partners.length < 10) {
                    setState(() {
                      _partners.add(_nextPartnerId++);
                    });
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add Partner', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                'Maximum of 10 partners can be added. (\${_partners.length}/10 added)',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          ..._partners.map((partnerId) {
            int index = _partners.indexOf(partnerId) + 1;
            return _buildPartnerCard(index, partnerId);
          }).toList(),
          
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
                child: Text('Save & Continue to Basic Details →', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(int index, int partnerId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Partner \$index',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
              if (index > 1)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _partners.remove(partnerId);
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Partner Name *', 'Enter partner name'),
              const SizedBox(height: 16),
              _buildTextField('PAN Number *', 'ABCDE1234F'),
              const SizedBox(height: 16),
              
              _buildLabel('Access Level'),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRadioIcon(true),
                      const SizedBox(width: 8),
                      Text('View Only', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRadioIcon(false),
                      const SizedBox(width: 8),
                      Text('Full Access', style: GoogleFonts.poppins(fontSize: 13)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildLabel('Partnership Deal *'),
              const SizedBox(height: 8),
              _buildDottedUploadBox('Upload partnership deal', 'PDF, JPG, PNG (Max 2MB)'),
              const SizedBox(height: 16),
              
              _buildLabel('Written Letter (with sign) *'),
              const SizedBox(height: 8),
              _buildDottedUploadBox('Upload written letter (signed)', 'PDF, JPG, PNG (Max 2MB)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioIcon(bool isSelected) {
    return Icon(
      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      color: isSelected ? AppColors.primaryBlue : Colors.grey,
      size: 20,
    );
  }

  // ===================== STEP 2: BASIC DETAILS =====================
''';

  content = content.replaceFirst('// ===================== STEP 1: BASIC DETAILS =====================', partnerStep);
  
  file.writeAsStringSync(content);
  print('Injected partner details');
}
