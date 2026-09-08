import 'dart:io';

void main() async {
  final fileContent = r'''
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:va_business/features/business/data/models/platform_model.dart';
import 'package:va_business/features/business/presentation/providers/platform_providers.dart';
import 'package:va_business/features/business/data/models/supplier_model.dart';
import 'package:va_business/features/business/presentation/providers/supplier_providers.dart';

class CreateSupplierScreen extends ConsumerStatefulWidget {
  final SupplierModel? supplierToEdit;
  const CreateSupplierScreen({super.key, this.supplierToEdit});

  @override
  ConsumerState<CreateSupplierScreen> createState() => _CreateSupplierScreenState();
}

class _CreateSupplierScreenState extends ConsumerState<CreateSupplierScreen> {
  int _currentStep = 1;
  bool _withGst = true;
  
  // Step 1 Controllers
  final TextEditingController _gstNumberController = TextEditingController();
  XFile? _gstCertificateFile;
  
  // Step 2 Controllers
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  XFile? _companyLogoFile;

  // Step 3 Controllers
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'India');

  // Step 4 State
  List<String> _selectedPlatformIds = [];
  List<String> _selectedShopTypeIds = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.supplierToEdit != null) {
      final s = widget.supplierToEdit!;
      _businessNameController.text = s.name;
      _businessEmailController.text = s.email;
      _phoneController.text = s.phone;
      _withGst = s.withGst;
      _gstNumberController.text = s.gstNumber;
      
      if (s.gstCertificatePath != null && s.gstCertificatePath!.isNotEmpty) {
        _gstCertificateFile = XFile(s.gstCertificatePath!);
      }
      if (s.companyLogoPath != null && s.companyLogoPath!.isNotEmpty) {
        _companyLogoFile = XFile(s.companyLogoPath!);
      }
      
      _selectedPlatformIds = List.from(s.selectedPlatformIds);
      _selectedShopTypeIds = List.from(s.selectedShopTypeIds);

      final addrParts = s.address.split(', ');
      if (addrParts.length >= 8) {
         _doorNoController.text = addrParts[0];
         _streetNameController.text = addrParts[1];
         _buildingNameController.text = addrParts[2];
         _landmarkController.text = addrParts[3];
         _areaController.text = addrParts[4];
         _districtController.text = addrParts[5];
         _pincodeController.text = addrParts[6];
         _stateController.text = addrParts[7];
      } else {
         _districtController.text = s.branch; 
      }
    }
  }

  Future<void> _pickGstFile() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _gstCertificateFile = file;
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _pickLogoFile() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _companyLogoFile = file;
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  void _removeGstFile() {
    setState(() {
      _gstCertificateFile = null;
    });
  }

  void _removeLogoFile() {
    setState(() {
      _companyLogoFile = null;
    });
  }

  String _getFileSize(XFile file) {
    try {
      final bytes = File(file.path).lengthSync();
      if (bytes < 1024) return "$bytes B";
      if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } catch (e) {
      return "Local File";
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
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
          widget.supplierToEdit != null ? 'Edit Supplier' : 'Add Supplier',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Stepper Card
              Container(
                width: double.infinity,
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
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4C4DDC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.business, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.supplierToEdit != null ? 'Edit Supplier' : 'Add Supplier',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    widget.supplierToEdit != null ? 'Update and manage supplier details' : 'Add and manage supplier details',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 16, color: Colors.black54),
                          label: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Stepper
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStepIndicator(1, 'Tax & Registration', Icons.description_outlined),
                          _buildStepLine(1),
                          _buildStepIndicator(2, 'Business Details', Icons.business_center_outlined),
                          _buildStepLine(2),
                          _buildStepIndicator(3, 'Address Details', Icons.location_on_outlined),
                          _buildStepLine(3),
                          _buildStepIndicator(4, 'Business Type', Icons.category_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Step Content
              if (_currentStep == 1) _buildStep1TaxRegistration(),
              if (_currentStep == 2) _buildStep2BusinessDetails(),
              if (_currentStep == 3) _buildStep3AddressDetails(),
              if (_currentStep == 4) _buildStep4BusinessType(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title, IconData icon) {
    bool isCompleted = _currentStep > stepNumber;
    bool isActive = _currentStep == stepNumber;
    
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? Colors.green : (isActive ? const Color(0xFF4C4DDC) : Colors.white),
            border: Border.all(
              color: isCompleted ? Colors.green : (isActive ? const Color(0xFF4C4DDC) : Colors.grey.shade300),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Icon(icon, color: isActive ? Colors.white : Colors.grey.shade400, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STEP 0$stepNumber',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.green : (isActive ? const Color(0xFF4C4DDC) : Colors.grey.shade400),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
                color: isActive || isCompleted ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepNumber) {
    bool isCompleted = _currentStep > stepNumber;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 40,
      height: 2,
      color: isCompleted ? Colors.green : Colors.grey.shade200,
    );
  }

  Widget _buildStep1TaxRegistration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_outlined, color: Color(0xFF4C4DDC), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Information & Registration',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Configure GST status, number, and compliance documents',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),
          Text('GST Status *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              children: [
                _buildGstToggleBtn(true, 'With GST'),
                _buildGstToggleBtn(false, 'Without GST'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          if (_withGst) ...[
            Text('GST Number *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _gstNumberController,
              decoration: InputDecoration(
                hintText: 'Enter GST Number',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('GST Certificate *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (_gstCertificateFile != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: const Icon(Icons.insert_drive_file, color: Color(0xFF4C4DDC)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_gstCertificateFile!.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text(_getFileSize(_gstCertificateFile!), style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.black54, size: 20),
                      onPressed: _removeGstFile,
                    ),
                  ],
                ),
              )
            else
              _buildUploadBox('Drag & drop your certificate here', _pickGstFile),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8AB4F8).withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4285F4)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GST Registration Not Required',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1967D2)),
                        ),
                        Text(
                          'GST registration details are not required for this supplier.',
                          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1967D2)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 16,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
              ),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C4DDC),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2BusinessDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_center_outlined, color: Color(0xFF4C4DDC), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Enter basic identification and organizational details',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Business Name *', _businessNameController, hint: 'Enter business name'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Business Email', _businessEmailController, hint: 'Enter business email'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
            child: _buildTextField('Phone', _phoneController, hint: 'Enter phone number'),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Company Logo', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('Optional', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 8),
          if (_companyLogoFile != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4C4DDC).withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Logo uploaded successfully', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('Supports SVG, PNG, JPG or WebP (Recommended 512x512px, Max 5MB)', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickLogoFile,
                            icon: const Icon(Icons.sync, size: 14, color: Color(0xFF4C4DDC)),
                            label: Text('Change Logo', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C4DDC))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF4C4DDC)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _removeLogoFile,
                            icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                            label: Text('Remove', style: GoogleFonts.poppins(fontSize: 12, color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            _buildUploadBox('Drag and drop your company logo here', _pickLogoFile),
          
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 16,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                    label: Text('Back', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C4DDC),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3AddressDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_outlined, color: Color(0xFF4C4DDC), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address Details',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Registered office and physical dispatch location',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(),
          ),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Door No', _doorNoController, hint: 'Enter door number'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Street Name', _streetNameController, hint: 'Enter street name'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Building Name', _buildingNameController, hint: 'Enter building name'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Landmark', _landmarkController, hint: 'Enter landmark'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Area', _areaController, hint: 'Enter area'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('District', _districtController, hint: 'Enter district'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Pincode', _pincodeController, hint: 'Enter pincode'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('State', _stateController, hint: 'Enter state'),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 152) / 2 : double.infinity,
                child: _buildTextField('Country', _countryController),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 16,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                    label: Text('Back', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C4DDC),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Next', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4BusinessType() {
    final platformsAsync = ref.watch(platformsProvider);
    final shopTypesAsync = ref.watch(shopTypesProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Header
           Row(
             children: [
               Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF4F7FB), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.category_outlined, color: Color(0xFF4C4DDC), size: 24)),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Business Type & Platform', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                     Text('Select operating platforms and business classifications', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                   ],
                 ),
               ),
             ],
           ),
           const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider()),
           
           Wrap(
             alignment: WrapAlignment.spaceBetween,
             crossAxisAlignment: WrapCrossAlignment.center,
             children: [
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text('Platforms *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                     child: Text('${_selectedPlatformIds.length} selected', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF1967D2), fontWeight: FontWeight.bold)),
                   ),
                 ],
               ),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   TextButton(onPressed: () {
                     platformsAsync.whenData((response) {
                       setState(() {
                         _selectedPlatformIds = response.data.map((e) => PlatformModel.fromJson(e).id).toList();
                       });
                     });
                   }, child: Text('Select All', style: GoogleFonts.poppins(fontSize: 12))),
                   TextButton(onPressed: () { setState(() { _selectedPlatformIds.clear(); }); }, child: Text('Clear', style: GoogleFonts.poppins(fontSize: 12))),
                 ],
               ),
             ],
           ),
           Text('Choose the channels and marketplaces where your supplier distributes products', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
           const SizedBox(height: 16),
           
           platformsAsync.when(
             loading: () => const Center(child: CircularProgressIndicator()),
             error: (e, st) => Text('Error loading platforms', style: GoogleFonts.poppins(color: Colors.red)),
             data: (response) {
               final platforms = response.data.map((e) => PlatformModel.fromJson(e)).toList();
               return Wrap(
                 spacing: 16,
                 runSpacing: 16,
                 children: platforms.map((p) => _buildPlatformCard(p)).toList(),
               );
             },
           ),
           
           const SizedBox(height: 32),
           Wrap(
             alignment: WrapAlignment.spaceBetween,
             crossAxisAlignment: WrapCrossAlignment.center,
             children: [
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text('Shop Type *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
                     child: Text('${_selectedShopTypeIds.length} selected', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF1967D2), fontWeight: FontWeight.bold)),
                   ),
                 ],
               ),
               Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   TextButton(onPressed: () {
                     shopTypesAsync.whenData((response) {
                       final allShopTypes = response.data.map((e) => ShopTypeModel.fromJson(e)).toList();
                       final filteredShopTypes = allShopTypes.where((st) => _selectedPlatformIds.contains(st.platformId)).toList();
                       setState(() {
                         _selectedShopTypeIds = filteredShopTypes.map((e) => e.id).toList();
                       });
                     });
                   }, child: Text('Select All', style: GoogleFonts.poppins(fontSize: 12))),
                   TextButton(onPressed: () { setState(() { _selectedShopTypeIds.clear(); }); }, child: Text('Clear', style: GoogleFonts.poppins(fontSize: 12))),
                 ],
               ),
             ],
           ),
           Text('Select operating shop types assigned to your chosen sales platform(s)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
           const SizedBox(height: 16),
           
           if (_selectedPlatformIds.isEmpty)
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 40),
               decoration: BoxDecoration(
                 color: const Color(0xFFF8F9FE),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.grey.shade200),
               ),
               child: Column(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                     child: const Icon(Icons.layers_outlined, color: Color(0xFF4C4DDC)),
                   ),
                   const SizedBox(height: 16),
                   Text('Select a Sales Platform above', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Text('Click on any platform above to view and choose its assigned shop types.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                 ],
               ),
             )
           else
             shopTypesAsync.when(
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (e, st) => Text('Error loading shop types', style: GoogleFonts.poppins(color: Colors.red)),
               data: (response) {
                 final allShopTypes = response.data.map((e) => ShopTypeModel.fromJson(e)).toList();
                 final filteredShopTypes = allShopTypes.where((st) => _selectedPlatformIds.contains(st.platformId)).toList();
                 
                 if (filteredShopTypes.isEmpty) {
                   return Text('No shop types available for the selected platforms.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54));
                 }
                 
                 return Wrap(
                   spacing: 16,
                   runSpacing: 16,
                   children: filteredShopTypes.map((st) => _buildShopTypeCard(st)).toList(),
                 );
               },
             ),
             
           const SizedBox(height: 40),
           Wrap(
             alignment: WrapAlignment.spaceBetween,
             spacing: 16,
             runSpacing: 16,
             children: [
               OutlinedButton(
                 onPressed: () => Navigator.pop(context),
                 style: OutlinedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   side: BorderSide(color: Colors.grey.shade300),
                 ),
                 child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
               ),
               Wrap(
                 spacing: 16,
                 runSpacing: 16,
                 children: [
                   OutlinedButton.icon(
                     onPressed: _previousStep,
                     icon: const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
                     label: Text('Back', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w500)),
                     style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       side: BorderSide(color: Colors.grey.shade300),
                     ),
                   ),
                   ElevatedButton.icon(
                     onPressed: () {
                       final address = '${_doorNoController.text}, ${_streetNameController.text}, ${_buildingNameController.text}, ${_landmarkController.text}, ${_areaController.text}, ${_districtController.text}, ${_pincodeController.text}, ${_stateController.text}';
                       
                       final newSupplier = SupplierModel(
                         id: widget.supplierToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                         name: _businessNameController.text.isEmpty ? 'Unknown Supplier' : _businessNameController.text,
                         email: _businessEmailController.text,
                         phone: _phoneController.text.isEmpty ? 'N/A' : _phoneController.text,
                         branch: _districtController.text.isEmpty ? 'Main Branch' : _districtController.text,
                         withGst: _withGst,
                         gstNumber: _gstNumberController.text,
                         companyLogoPath: _companyLogoFile?.path,
                         gstCertificatePath: _gstCertificateFile?.path,
                         selectedPlatformIds: _selectedPlatformIds,
                         selectedShopTypeIds: _selectedShopTypeIds,
                         address: address,
                       );

                       if (widget.supplierToEdit != null) {
                         ref.read(supplierListProvider.notifier).updateSupplier(newSupplier);
                       } else {
                         ref.read(supplierListProvider.notifier).addSupplier(newSupplier);
                       }
                       
                       Navigator.pop(context);
                     },
                     icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
                     label: Text(widget.supplierToEdit != null ? 'Update Supplier' : 'Save Supplier', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF4C4DDC),
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                     ),
                   ),
                 ],
               ),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(PlatformModel platform) {
    bool isSelected = _selectedPlatformIds.contains(platform.id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPlatformIds.remove(platform.id);
          } else {
            _selectedPlatformIds.add(platform.id);
          }
        });
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8F9FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4C4DDC) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: Colors.blue, size: 16),
                ),
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? const Color(0xFF4C4DDC) : Colors.grey.shade300,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(platform.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Sales Platform', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(isSelected ? 'Active' : '', style: GoogleFonts.poppins(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTypeCard(ShopTypeModel shopType) {
    bool isSelected = _selectedShopTypeIds.contains(shopType.id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedShopTypeIds.remove(shopType.id);
          } else {
            _selectedShopTypeIds.add(shopType.id);
          }
        });
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8F9FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4C4DDC) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_mall, color: Colors.orange, size: 16),
                ),
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? const Color(0xFF4C4DDC) : Colors.grey.shade300,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(shopType.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Shop Type', style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
                Text(isSelected ? 'Active' : '', style: GoogleFonts.poppins(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGstToggleBtn(bool value, String label) {
    bool isSelected = _withGst == value;
    return GestureDetector(
      onTap: () => setState(() => _withGst = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) const Icon(Icons.check_circle_outline, color: Color(0xFF4C4DDC), size: 16),
            if (isSelected) const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF4C4DDC) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF4C4DDC)),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text('or ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                Text('browse / paste (Ctrl+V)', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C4DDC), fontWeight: FontWeight.bold)),
                Text(' to upload', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Supported formats: PDF, PNG, JPG, JPEG (Max 10MB)', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}
''';
  final file = File('lib/features/business/presentation/screens/create_supplier_screen.dart');
  await file.writeAsString(fileContent);
  print('Successfully updated create_supplier_screen.dart');
}
