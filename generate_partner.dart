import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/create_propagator_screen.dart');
  String content = file.readAsStringSync();

  // 1. Rename classes
  content = content.replaceAll('CreatePropagatorScreen', 'CreatePartnerScreen');
  content = content.replaceAll('Create Propagator Business', 'Create Partner Business');
  content = content.replaceAll('register your propagator business', 'register your partner business');

  // 2. Change steps logic (from 5 to 6)
  content = content.replaceAll('_currentStep < 5', '_currentStep < 6');

  // 3. Update Stepper Header
  content = content.replaceAll('''
                          _buildStepIndicator(1, 'Basic Details'),
                          _buildStepLine(1),
                          _buildStepIndicator(2, 'GST Details'),
                          _buildStepLine(2),
                          _buildStepIndicator(3, 'Bank Details'),
                          _buildStepLine(3),
                          _buildStepIndicator(4, 'Business Address'),
                          _buildStepLine(4),
                          _buildStepIndicator(5, 'Business Type'),''', '''
                          _buildStepIndicator(1, 'Partner'),
                          _buildStepLine(1),
                          _buildStepIndicator(2, 'Basic Details'),
                          _buildStepLine(2),
                          _buildStepIndicator(3, 'GST Details'),
                          _buildStepLine(3),
                          _buildStepIndicator(4, 'Bank Details'),
                          _buildStepLine(4),
                          _buildStepIndicator(5, 'Business Address'),
                          _buildStepLine(5),
                          _buildStepIndicator(6, 'Business Type'),''');

  // 4. Update Step Routing
  content = content.replaceAll('''
              if (_currentStep == 1) _buildStep1BasicDetails(),
              if (_currentStep == 2) _buildStep2GstDetails(),
              if (_currentStep == 3) _buildStep3BankDetails(),
              if (_currentStep == 4) _buildStep4BusinessAddress(),
              if (_currentStep == 5) _buildStep5BusinessType(),''', '''
              if (_currentStep == 1) _buildStep1PartnerDetails(),
              if (_currentStep == 2) _buildStep2BasicDetails(),
              if (_currentStep == 3) _buildStep3GstDetails(),
              if (_currentStep == 4) _buildStep4BankDetails(),
              if (_currentStep == 5) _buildStep5BusinessAddress(),
              if (_currentStep == 6) _buildStep6BusinessType(),''');

  // Rename the actual methods to match the shifted numbers
  content = content.replaceAll('_buildStep1BasicDetails', '_buildStep2BasicDetails');
  content = content.replaceAll('_buildStep2GstDetails', '_buildStep3GstDetails');
  content = content.replaceAll('_buildStep3BankDetails', '_buildStep4BankDetails');
  content = content.replaceAll('_buildStep4BusinessAddress', '_buildStep5BusinessAddress');
  content = content.replaceAll('_buildStep5BusinessType', '_buildStep6BusinessType');

  // Inject Partner Details State
  content = content.replaceAll('int _currentStep = 1;', '''
  int _currentStep = 1;
  List<int> _partners = [1];
  int _nextPartnerId = 2;
''');

  // Fix Back Button logic inside the new Step 2 (Basic Details)
  // Step 2 should now go back to Partner Details
  content = content.replaceAll('''
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),''', '''
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('← Back to Partner Details', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),''');

  // Inject Step 1 Partner Details Implementation before Step 2
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
              Row(
                children: [
                  _buildRadioIcon(true),
                  const SizedBox(width: 8),
                  Text('View Only', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 24),
                  _buildRadioIcon(false),
                  const SizedBox(width: 8),
                  Text('Full Access', style: GoogleFonts.poppins(fontSize: 13)),
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

  // ===================== STEP 2: BASIC DETAILS =====================''';

  content = content.replaceFirst('// ===================== STEP 2: BASIC DETAILS =====================', partnerStep);

  // Write new file
  File('lib/features/business/presentation/screens/create_partner_screen.dart').writeAsStringSync(content);
  print('Done creating create_partner_screen.dart');
}
