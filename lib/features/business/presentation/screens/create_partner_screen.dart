import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/business_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'package:va_business/core/utils/safe_base64_decode.dart';
import '../../data/repositories/business_repository.dart';
import 'package:va_business/core/theme/app_colors.dart';

class CreatePartnerScreen extends ConsumerStatefulWidget {
  const CreatePartnerScreen({super.key});

  @override
  ConsumerState<CreatePartnerScreen> createState() => _CreatePartnerScreenState();
}

class _CreatePartnerScreenState extends ConsumerState<CreatePartnerScreen> {
      int _currentStep = 1;
  List<String> _selectedBusinessTypes = [];
  final TextEditingController _customBusinessTypeNameCtrl = TextEditingController();
  final TextEditingController _customBusinessTypeDescCtrl = TextEditingController();
  String? _customBusinessTypeImageBase64;
  bool _isPickingImage = false;
  final ImagePicker _picker = ImagePicker();
  final Map<String, String> _uploadedDocuments = {};

  Future<void> _pickImage(Function(String) onPicked) async {
    if (_isPickingImage) return;
    setState(() {
      _isPickingImage = true;
    });
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        onPicked('data:image/jpeg;base64,$base64String');
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

    final List<String> _employeeRanges = [
    '1 - 10 employees',
    '11 - 50 employees',
    '51 - 200 employees',
    '200+ employees',
  ];
  String? _selectedTier;
  String? _selectedEmployeeRange;

  List<int> _partners = [1];
  int _nextPartnerId = 2;

  String _selectedDocumentType = 'Bank Statement';

  void _nextStep() {
    if (_currentStep < 6) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
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
          'Business Create',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Stepper Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Partner Business',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Complete the steps below to register your partner business',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.black54,
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
                    const SizedBox(height: 30),
                    
                    // Stepper
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
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
                          _buildStepIndicator(6, 'Business Type'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Step Content
              if (_currentStep == 1) _buildStep1PartnerDetails(),
              if (_currentStep == 2) _buildStep2BasicDetails(),
              if (_currentStep == 3) _buildStep3GstDetails(),
              if (_currentStep == 4) _buildStep4BankDetails(),
              if (_currentStep == 5) _buildStep5BusinessAddress(),
              if (_currentStep == 6) _buildStep6BusinessType(),
              
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title) {
    bool isActive = _currentStep == stepNumber;
    bool isCompleted = _currentStep > stepNumber;

    Color circleColor = isActive ? AppColors.primaryBlue : (isCompleted ? const Color(0xFF26D38B) : Colors.white);
    Color textColor = isActive || isCompleted ? Colors.white : Colors.black45;
    Color borderColor = isActive || isCompleted ? Colors.transparent : Colors.grey.shade300;
    Color titleColor = isActive ? AppColors.primaryBlue : (isCompleted ? const Color(0xFF26D38B) : Colors.black45);

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  '$stepNumber',
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: titleColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int previousStepNumber) {
    bool isCompleted = _currentStep > previousStepNumber;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
      color: isCompleted ? const Color(0xFF26D38B) : Colors.grey.shade300,
    );
  }

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
              Expanded(
                child: Text(
                  'Maximum of 10 partners can be added. (${_partners.length}/10 added)',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                ),
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
                'Partner $index',
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
              _buildDottedUploadBox('partnership_deal', 'Upload partnership deal', 'PDF, JPG, PNG (Max 2MB)'),
              const SizedBox(height: 16),
              
              _buildLabel('Written Letter (with sign) *'),
              const SizedBox(height: 8),
              _buildDottedUploadBox('written_letter', 'Upload written letter (signed)', 'PDF, JPG, PNG (Max 2MB)'),
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

    Widget _buildStep2BasicDetails() {
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
          _buildDottedUploadBox('logo', 'Click to upload logo', 'SVG, PNG, JPG (Max. 2MB)'),
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
              _buildTierCard('STARTUP', 'Small business / new company', Icons.rocket_launch, isSelected: _selectedTier == 'STARTUP', isRecommended: true),
              const SizedBox(height: 12),
              _buildTierCard('STANDARD', 'Growing business', Icons.business, isSelected: _selectedTier == 'STANDARD'),
              const SizedBox(height: 12),
              _buildTierCard('CORPORATE', 'Large organization', Icons.location_city, isSelected: _selectedTier == 'CORPORATE'),
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
          _buildDottedUploadBox('pan_card', 'Click to upload PAN card', 'PDF, JPG or PNG (max. 5MB)'),
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
          _buildDottedUploadBox('signature', 'Click to upload signature', 'JPG or PNG (max. 5MB)', height: 120),
          
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
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('← Back to Partner Details', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
// ===================== STEP 3: BANK DETAILS =====================
  // ===================== STEP 3: GST DETAILS =====================
Widget _buildStep3GstDetails() {
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
              const Icon(Icons.receipt_long, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'GST Details',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildTextField('GST Number *', '22AAAAA0000A1Z5'),
          const SizedBox(height: 4),
          Text('15-character alphanumeric GST number', style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
          const SizedBox(height: 24),

          _buildLabel('GST Certificate *'),
          const SizedBox(height: 8),
          _buildDottedUploadBox('gst_certificate', 'Click to upload GST certificate', 'PDF, JPG or PNG (max. 5MB)', height: 160),
          
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
                child: Text('Save & Continue to Bank Details →', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('← Back to Basic Details', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildStep4BankDetails() {
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
              const Icon(Icons.account_balance, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Current Account Details',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildTextField('Current Account Number *', 'Enter current account number'),
          const SizedBox(height: 16),
          _buildTextField('Confirm Account Number *', 'Re-enter account number'),
          const SizedBox(height: 24),

          _buildLabel('Document Type'),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRadioButton('Bank Statement'),
              const SizedBox(height: 16),
              _buildRadioButton('Canceled Cheque Leaf'),
            ],
          ),
          const SizedBox(height: 24),

          _buildLabel('Upload $_selectedDocumentType *'),
          const SizedBox(height: 8),
          _buildDottedUploadBox('document', 'Click to upload document', 'PDF, JPG or PNG (max. 5MB)', height: 160),
          
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
                child: Text('Save & Continue to Business Address →', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('← Back to GST Details', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

    // ===================== STEP 4: BUSINESS ADDRESS =====================
  Widget _buildStep5BusinessAddress() {
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
  // ===================== STEP 5: BUSINESS TYPE =====================
  Widget _buildStep6BusinessType() {
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
              const Icon(
                Icons.storefront_outlined,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Type',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Select one or more business types that best describe your business',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
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
            alignment: Alignment
                .centerLeft, // Left aligned for mobile to prevent overflow
            child: TextButton.icon(
              onPressed: () => _showBusinessTypeDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'Add Custom Business Type',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          ref
              .watch(businessTypesProvider)
              .when(
                data: (data) {
                  final types = data.data;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      ...types.map((type) {
                        final id = type['id']?.toString() ?? '';
                        final name = type['name'] ?? 'Unknown';
                        final iconBase64 = type['image'] ?? type['icon'] ?? '';
                        final desc = type['description'] ?? '';
                        final isSelected = _selectedBusinessTypes.contains(
                          name,
                        );

                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedBusinessTypes.remove(name);
                              } else {
                                _selectedBusinessTypes.add(name);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(11),
                                              ),
                                          color: Colors.grey.shade100,
                                        ),
                                        child:
                                            iconBase64.isNotEmpty &&
                                                iconBase64.startsWith(
                                                  'data:image',
                                                )
                                            ? ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(11),
                                                    ),
                                                child: Image.memory(
                                                  safeBase64Decode(
                                                    iconBase64.split(',').last,
                                                  ),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.grey,
                                                      ),
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.store,
                                                  color: Colors.grey,
                                                  size: 32,
                                                ),
                                              ),
                                      ),
                                      // Edit and Delete icons overlay
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _showBusinessTypeDialog(
                                                    context,
                                                    existingType: type,
                                                  ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  size: 12,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            InkWell(
                                              onTap: () =>
                                                  _confirmDeleteBusinessType(
                                                    id,
                                                  ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 12,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryBlue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (desc.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            desc,
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      // Add Option Card
                      InkWell(
                        onTap: () => _showBusinessTypeDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 1.5,
                            ),
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
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add Option',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create custom\nbusiness type',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  color: Colors.black38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text(
                  'Error loading business types: $e',
                  style: const TextStyle(color: Colors.red),
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


  // ===================== HELPER WIDGETS =====================
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithVerify(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text('Verify', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

    Widget _buildTierCard(String title, String subtitle, IconData icon, {bool isSelected = false, bool isRecommended = false}) {
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

  Widget _buildDottedUploadBox(String key, String title, String subtitle, {double height = 100}) {
    return InkWell(
      onTap: () async {
        try {
          final picker = ImagePicker();
          final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
          if (image != null) {
            setState(() {
              _uploadedDocuments[key] = image.path;
            });
          }
        } catch (e) {
          print("Error picking image: $e");
        }
      },
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1.5),
        ),
        child: _uploadedDocuments.containsKey(key)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(_uploadedDocuments[key]!),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _uploadedDocuments.remove(key);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF475569),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(title, style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: GoogleFonts.poppins(color: Colors.black45, fontSize: 10)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildRadioButton(String title) {
    bool isSelected = _selectedDocumentType == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDocumentType = title;
        });
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSelected ? AppColors.primaryBlue : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
  void _showBusinessTypeDialog(
    BuildContext context, {
    Map<String, dynamic>? existingType,
  }) {
    final bool isEdit = existingType != null;
    final String id = isEdit ? (existingType['id']?.toString() ?? '') : '';

    _customBusinessTypeNameCtrl.text = isEdit
        ? (existingType['name'] ?? '')
        : '';
    _customBusinessTypeDescCtrl.text = isEdit
        ? (existingType['description'] ?? '')
        : '';
    _customBusinessTypeImageBase64 = isEdit
        ? (existingType['image'] ?? existingType['icon'])
        : null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isSubmitting = false;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                              isEdit
                                  ? 'Edit Business Type (ID: $id)'
                                  : 'Create New Business Type',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black54,
                              size: 20,
                            ),
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
                          controller: _customBusinessTypeNameCtrl,
                          decoration: InputDecoration(
                            hintText:
                                'e.g., Franchising, Agriculture, Logistics...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel(
                        '2. Image / Icon (Drag & Drop, Copy & Paste, or Browse)',
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          if (_isPickingImage) return;
                          setDialogState(() => _isPickingImage = true);
                          try {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 50,
                            );
                            if (image != null) {
                              final bytes = await image.readAsBytes();
                              final base64String = base64Encode(bytes);
                              setDialogState(() {
                                _customBusinessTypeImageBase64 =
                                    'data:image/jpeg;base64,$base64String';
                              });
                            }
                          } catch (e) {
                            debugPrint("Error picking image: $e");
                          } finally {
                            setDialogState(() => _isPickingImage = false);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0F9FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _customBusinessTypeImageBase64 != null
                                      ? Icons.check_circle
                                      : Icons.cloud_upload_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_customBusinessTypeImageBase64 != null) ...[
                                Text(
                                  'Image Attached',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      _customBusinessTypeImageBase64 = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Remove Image',
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Click to browse or Drag & Drop image here',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Supports all file types (PNG, JPG, SVG, WEBP, etc.)',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black45,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
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
                          controller: _customBusinessTypeDescCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText:
                                'Brief description of this business model and operations...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (_customBusinessTypeNameCtrl
                                          .text
                                          .isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please enter a business type name',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      setDialogState(() => isSubmitting = true);
                                      try {
                                        final repo = ref.read(
                                          businessRepositoryProvider,
                                        );

                                        final payload = {
                                          "userId": "2146610213",
                                          "name":
                                              _customBusinessTypeNameCtrl.text,
                                          "description":
                                              _customBusinessTypeDescCtrl.text,
                                          "image":
                                              _customBusinessTypeImageBase64 ??
                                              "",
                                        };

                                        if (isEdit) {
                                          await repo.updateBusinessType(
                                            id,
                                            payload,
                                          );
                                        } else {
                                          await repo.createBusinessType(
                                            payload,
                                          );
                                        }

                                        ref.invalidate(businessTypesProvider);

                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isEdit
                                                    ? 'Business Type updated successfully'
                                                    : 'Business Type created successfully',
                                              ),
                                            ),
                                          );
                                          _customBusinessTypeNameCtrl.clear();
                                          _customBusinessTypeDescCtrl.clear();
                                          _customBusinessTypeImageBase64 = null;
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      } finally {
                                        setDialogState(
                                          () => isSubmitting = false,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEdit
                                          ? 'Save Changes'
                                          : 'Create Business Type',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
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
          },
        );
      },
    );
  }

  void _confirmDeleteBusinessType(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Business Type',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to delete this business type?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repo = ref.read(businessRepositoryProvider);
                await repo.deleteBusinessType(id);
                ref.invalidate(businessTypesProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
