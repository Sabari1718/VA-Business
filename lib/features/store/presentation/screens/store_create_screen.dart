import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/store_providers.dart';
import '../../data/models/store_model.dart';
import '../../../business/presentation/providers/business_providers.dart';
import '../../../business/presentation/providers/platform_providers.dart';
import '../../../business/data/models/business_response_model.dart';

class StoreCreateScreen extends ConsumerStatefulWidget {
  final StoreModel? store;
  const StoreCreateScreen({super.key, this.store});

  @override
  ConsumerState<StoreCreateScreen> createState() => _StoreCreateScreenState();
}

class _StoreCreateScreenState extends ConsumerState<StoreCreateScreen> {
  int _currentStep = 1;
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _customerCareNameController = TextEditingController();
  final TextEditingController _customerCarePhoneController = TextEditingController();
  final TextEditingController _altContactNameController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'India');
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _talukController = TextEditingController();
  final TextEditingController _cityVillageController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController(text: '09:00 AM');
  final TextEditingController _closingTimeController = TextEditingController(text: '09:00 PM');
  
  String? _storeLogoBase64;
  bool _isLoading = false;
  bool _showStep1Errors = false;
  bool _showStep2Errors = false;
  bool _showStep3Errors = false;
  bool _showStep4Errors = false;
  bool _showStep5Errors = false;
  
  // Step 1: Business Selection State
  String? _selectedBusinessType;
  String? _selectedBusinessId;
  
  // Step 2: Platform Configuration State
  String? _selectedPlatformId;
  String? _selectedPlatformModuleId;
  String? _selectedShopTypeId;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        _storeLogoBase64 = 'data:image/jpeg;base64,$base64Image';
      });
    }
  }
  
    Future<void> _submitForm() async {
    setState(() {
      _showStep1Errors = true;
      _showStep2Errors = true;
      _showStep3Errors = true;
    });
    
    if (_storeNameController.text.trim().isEmpty ||
        _selectedBranchModel == null ||
        _customerCareNameController.text.trim().isEmpty ||
        _customerCarePhoneController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _districtController.text.trim().isEmpty ||
        _talukController.text.trim().isEmpty ||
        _cityVillageController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty ||
        _openingTimeController.text.trim().isEmpty ||
        _closingTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    
    setState(() => _isLoading = true);
    try {
      final payload = StoreModel(
        id: widget.store?.id,
        userId: widget.store?.userId,
        storeName: _storeNameController.text.trim(),
        branchManagementModel: _selectedBranchModel ?? '',
        customerCareName: _customerCareNameController.text.trim(),
        customerCarePhone: _customerCarePhoneController.text.trim(),
        altContactName: _altContactNameController.text.trim(),
        altPhone: _altPhoneController.text.trim(),
        country: _countryController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        taluk: _talukController.text.trim(),
        cityVillage: _cityVillageController.text.trim(),
        pincode: _pincodeController.text.trim(),
        openingTime: _openingTimeController.text.trim(),
        closingTime: _closingTimeController.text.trim(),
        workingDays: _selectedWorkingDays.join(', '),
        holidayNotes: _weeklyOffNotesControllers.entries.map((e) => "${e.key}: ${e.value.text}").join('; '),
        paymentMethods: _paymentMethods.join(', '),
        supportedLanguages: _languages.join(', '),
        businessId: _selectedBusinessId ?? '1',
        platformId: _selectedPlatformId ?? '1',
        shopType: _selectedShopTypeId,
        platformModule: _selectedPlatformModuleId,
        status: widget.store?.status ?? 'Active',
        storeLogo: _storeLogoBase64 ?? '',
      );
      
      final repository = ref.read(storeRepositoryProvider);
      if (widget.store != null) {
        await repository.updateStore(widget.store!.id!, payload);
      } else {
        await repository.createStore(payload);
      }
      
      if (mounted) {
        ref.invalidate(storesProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.store != null ? 'Store Setup Updated Successfully!' : 'Store Setup Created Successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  String? _selectedBranchModel;

  // Step 3 State
  final List<String> _workingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final Set<String> _selectedWorkingDays = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
  final Map<String, TextEditingController> _weeklyOffNotesControllers = {};

  final List<String> _paymentMethods = ['Cash on Delivery'];
  final List<String> _languages = ['English', 'Tamil', 'Hindi'];

  @override
  void initState() {
    super.initState();
    for (var day in _workingDays) {
      _weeklyOffNotesControllers[day] = TextEditingController(text: '$day weekly off');
    }
    
    if (widget.store != null) {
      final s = widget.store!;
      _selectedBusinessId = s.businessId.isNotEmpty ? s.businessId : null;
      _selectedPlatformId = s.platformId.isNotEmpty ? s.platformId : null;
      _selectedShopTypeId = s.shopType;
      _selectedPlatformModuleId = s.platformModule;
      
      _storeNameController.text = s.storeName;
      _selectedBranchModel = s.branchManagementModel;
      _customerCareNameController.text = s.customerCareName;
      _customerCarePhoneController.text = s.customerCarePhone;
      _altContactNameController.text = s.altContactName;
      _altPhoneController.text = s.altPhone;
      _countryController.text = s.country;
      _stateController.text = s.state;
      _districtController.text = s.district;
      _talukController.text = s.taluk;
      _cityVillageController.text = s.cityVillage;
      _openingTimeController.text = s.openingTime;
      _closingTimeController.text = s.closingTime;
      
      if (s.storeLogo.isNotEmpty) {
        _storeLogoBase64 = s.storeLogo;
      }
      
      if (s.workingDays.isNotEmpty) {
        _selectedWorkingDays.clear();
        _selectedWorkingDays.addAll(s.workingDays.split(', '));
      }
      
      if (s.paymentMethods.isNotEmpty) {
        _paymentMethods.clear();
        _paymentMethods.addAll(s.paymentMethods.split(', '));
      }
      
      if (s.supportedLanguages.isNotEmpty) {
        _languages.clear();
        _languages.addAll(s.supportedLanguages.split(', '));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _weeklyOffNotesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      if (_currentStep == 1) {
        _showStep1Errors = true;
        if (_selectedBusinessType != null && _selectedBusinessId != null) {
          _currentStep++;
        }
      } else if (_currentStep == 2) {
        _showStep2Errors = true;
        if (_selectedPlatformId != null && _selectedPlatformModuleId != null && _selectedShopTypeId != null) {
          _currentStep++;
        }
      } else if (_currentStep == 3) {
        _showStep3Errors = true;
        if (_storeNameController.text.trim().isNotEmpty &&
            _selectedBranchModel != null &&
            _customerCareNameController.text.trim().isNotEmpty &&
            _customerCarePhoneController.text.trim().isNotEmpty) {
          _currentStep++;
        }
      } else if (_currentStep == 4) {
        _showStep4Errors = true;
        if (_countryController.text.trim().isNotEmpty &&
            _stateController.text.trim().isNotEmpty &&
            _districtController.text.trim().isNotEmpty &&
            _talukController.text.trim().isNotEmpty &&
            _cityVillageController.text.trim().isNotEmpty &&
            _pincodeController.text.trim().isNotEmpty) {
          _currentStep++;
        }
      }
    });
  }


  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'B',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business',
                  style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Business Suite',
                  style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Store Creation & Configuration',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B)),
              ),
              const SizedBox(height: 8),
              Text(
                'Configure store identity, location details, operating hours, payment gateways, and languages.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 32),

              // Custom Stepper
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStepTab(1, 'Business', Icons.business),
                      _buildStepTab(2, 'Platform', Icons.devices),
                      _buildStepTab(3, 'Store Info', Icons.store_outlined),
                      _buildStepTab(4, 'Address', Icons.location_on_outlined),
                      _buildStepTab(5, 'Config', Icons.tune_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step Content
              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),
              if (_currentStep == 4) _buildStep4(),
              if (_currentStep == 5) _buildStep5(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTab(int step, String title, IconData icon) {
    final isActive = _currentStep == step;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentStep = step);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6366F1) : Colors.transparent, // Purple-blue from screenshot
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.black54, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isActive ? Colors.white : Colors.black87,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== STEP 1: Business Selection =====================
  Widget _buildStep1() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF4C8DFB), shape: BoxShape.circle),
                child: const Icon(Icons.business, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Business Selection', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Select the type of business and register your store under it.', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildResponsiveRow(
            _buildDropdownWithSub(
              'Select Business Type *',
              'Select Business Type',
              'Choose your business category',
              ['Partner Business', 'Supplier Business', 'Propagator'],
              _selectedBusinessType,
              (val) {
                setState(() {
                  _selectedBusinessType = val;
                  _selectedBusinessId = null; // Reset business ID on type change
                });
              },
              errorText: _showStep1Errors && _selectedBusinessType == null ? 'Business Type is required.' : null,
            ),
            _buildBusinessDropdown(),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Next Step', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDropdown() {
    if (_selectedBusinessType == null) {
      return _buildDropdownWithSub(
        'Select Registered Business *',
        'Select Business',
        'Please select a business type first',
        [],
        null,
        (val) {},
      );
    }

    AsyncValue businessData;
    if (_selectedBusinessType == 'Partner Business') {
      businessData = ref.watch(partnerBusinessProvider);
    } else if (_selectedBusinessType == 'Supplier Business') {
      businessData = ref.watch(supplierBusinessProvider);
    } else {
      businessData = ref.watch(propagatorBusinessProvider);
    }

    return businessData.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      error: (err, stack) => Text('Error loading businesses: $err', style: const TextStyle(color: Colors.red)),
      data: (response) {
        final List<dynamic> list = response.data;
        if (list.isEmpty) {
          return _buildDropdownWithSub(
            'Select Registered Business *',
            'No Businesses Found',
            'No businesses found for this type',
            [],
            null,
            (val) {},
          );
        }

        // Mapping id to Name
        final items = list.map((e) {
          final id = e['id'].toString();
          final name = e['partnerName'] ?? e['businessName'] ?? 'Unknown Business';
          return DropdownMenuItem<String>(
            value: id,
            child: Text(name, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Select Registered Business *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBusinessId,
              hint: Text('Select Business', style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13)),
              items: items,
              onChanged: (val) => setState(() => _selectedBusinessId = val),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                errorText: _showStep1Errors && _selectedBusinessId == null ? 'Business is required.' : null,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text('Select the specific business to link this store', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
          ],
        );
      },
    );
  }

  // ===================== STEP 2: Platform Configuration =====================
  Widget _buildStep2() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF4C8DFB), shape: BoxShape.circle),
                child: const Icon(Icons.devices, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. Platform Configuration', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Configure your e-commerce platform and shop type.', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildResponsiveRow(
            _buildApiDropdown('Select E-Commerce Platform *', 'Select Platform', 'Choose your platform', platformsProvider, _selectedPlatformId, (val) => setState(() => _selectedPlatformId = val), 'platformName', _showStep2Errors && _selectedPlatformId == null ? 'Platform is required' : null),
            _buildApiDropdown('Select Platform Module *', 'Select Module', 'Choose your platform module', platformAssignmentsProvider, _selectedPlatformModuleId, (val) => setState(() => _selectedPlatformModuleId = val), 'moduleName', _showStep2Errors && _selectedPlatformModuleId == null ? 'Platform Module is required' : null),
            _buildApiDropdown('Select Shop Type *', 'Select Shop Type', 'Choose your shop type', shopTypesProvider, _selectedShopTypeId, (val) => setState(() => _selectedShopTypeId = val), 'shopTypeName', _showStep2Errors && _selectedShopTypeId == null ? 'Shop Type is required' : null),
          ),
          
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Previous', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Next Step', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApiDropdown(String label, String hint, String sub, FutureProvider<BusinessResponseModel> provider, String? selectedValue, Function(String?) onChanged, String nameKey, String? errorText) {
    final dataAsync = ref.watch(provider);
    
    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
      data: (response) {
        final List<dynamic> list = response.data;
        if (list.isEmpty) {
          return _buildDropdownWithSub(label, 'No Items Found', sub, [], null, (val) {});
        }

        final items = list.map((e) {
          final id = e['id'].toString();
          // Fallback fields in case nameKey isn't right
          final name = e[nameKey] ?? e['name'] ?? e['title'] ?? 'Unknown';
          return DropdownMenuItem<String>(
            value: id,
            child: Text(name, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(label),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedValue,
              hint: Text(hint, style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13)),
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                errorText: errorText,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
          ],
        );
      }
    );
  }

  // ===================== STEP 3: Store Information =====================
  Widget _buildStep3() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF4C8DFB), shape: BoxShape.circle),
                child: const Icon(Icons.store, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Manage your store identity, branch model, and customer care contact details', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLabel('Store Logo / Showcase Image'),
              Text('Supports Drag & Drop, Copy-Paste (Ctrl+V), or Click to Browse', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(onTap: _pickImage, child: _storeLogoBase64 != null ? Container(height: 120, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: MemoryImage(base64Decode(_storeLogoBase64!.split(',')[1])), fit: BoxFit.cover))) : _buildDottedUploadBox('Click to upload, or drag & drop store image here', 'Tip: You can also copy & paste (Ctrl + V) any image directly')),
          const SizedBox(height: 24),
          
          _buildResponsiveRow(
            _buildTextFieldWithSub('Store Name / Store Title *', 'Enter store name', 'Enter official storefront or business trading title', controller: _storeNameController, errorText: _showStep3Errors && _storeNameController.text.trim().isEmpty ? 'Store Name is required.' : null),
            _buildDropdownWithSub('Branch Management Model *', 'Single Branch (Automatic Single Setup)', 'Select branch operation and management model', ['Single Branch (Automatic Single Setup)', 'Multiple Branch'], _selectedBranchModel, (val) => setState(() => _selectedBranchModel = val), errorText: _showStep3Errors && _selectedBranchModel == null ? 'Branch Management Model is required.' : null),
          ),
          const SizedBox(height: 24),
          
          _buildResponsiveRow(
            _buildTextFieldWithSub('Customer Care Contact Name *', 'Enter customer care contact name', 'Enter customer care or support contact name', controller: _customerCareNameController, errorText: _showStep3Errors && _customerCareNameController.text.trim().isEmpty ? 'Customer Care Contact Name is required.' : null),
            _buildTextFieldWithSub('Customer Care Phone Number *', 'Enter customer care phone number', 'Enter customer care or support phone number', controller: _customerCarePhoneController, errorText: _showStep3Errors && _customerCarePhoneController.text.trim().isEmpty ? 'Customer Care Phone Number is required.' : null),
          ),
          const SizedBox(height: 24),

          _buildResponsiveRow(
            _buildTextFieldWithSub('Alternate Contact Name', 'Enter alternate contact name', 'Enter alternate or secondary contact name', controller: _altContactNameController),
            _buildTextFieldWithSub('Alternate Phone Number', 'Enter alternate phone number', 'Enter alternate or secondary phone number', controller: _altPhoneController),
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Previous', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Next Step', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== STEP 4: Address Details =====================
  Widget _buildStep4() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveRow(
            _buildTextField('Country *', 'India', controller: _countryController, errorText: _showStep4Errors && _countryController.text.trim().isEmpty ? 'Country is required.' : null),
            _buildTextField('State *', 'e.g. Tamil Nadu', controller: _stateController, errorText: _showStep4Errors && _stateController.text.trim().isEmpty ? 'State is required.' : null),
            _buildTextField('District *', 'e.g. Chennai', controller: _districtController, errorText: _showStep4Errors && _districtController.text.trim().isEmpty ? 'District is required.' : null),
          ),
          const SizedBox(height: 24),
          _buildResponsiveRow(
            _buildTextField('Taluk *', 'e.g. Guindy', controller: _talukController, errorText: _showStep4Errors && _talukController.text.trim().isEmpty ? 'Taluk is required.' : null),
            _buildTextField('City / Village *', 'e.g. Chennai City', controller: _cityVillageController, errorText: _showStep4Errors && _cityVillageController.text.trim().isEmpty ? 'City / Village is required.' : null),
            _buildTextField('Pincode *', 'e.g. 600020', controller: _pincodeController, errorText: _showStep4Errors && _pincodeController.text.trim().isEmpty ? 'Pincode is required.' : null),
          ),
          
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Previous', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Next Step', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== STEP 5: Store Configuration =====================
  Widget _buildStep5() {
    return Column(
      children: [
        // Operating Hours
        _buildSectionCard(
          icon: Icons.access_time,
          title: 'Store Operating Hours',
          subtitle: 'Set daily opening and closing schedule for customer visits & orders',
          child: _buildResponsiveRow(
            _buildTextField('Opening Time *', '09:00 AM', controller: _openingTimeController, errorText: _showStep5Errors && _openingTimeController.text.trim().isEmpty ? 'Opening Time is required.' : null),
            _buildTextField('Closing Time *', '09:00 PM', controller: _closingTimeController, errorText: _showStep5Errors && _closingTimeController.text.trim().isEmpty ? 'Closing Time is required.' : null),
          ),
        ),
        const SizedBox(height: 24),
        
        // Working Days & Holidays
        _buildSectionCard(
          icon: Icons.calendar_today_outlined,
          title: 'Working Days & Weekly Off / Holidays',
          subtitle: 'Select active business working days and specify weekly leaves or holiday schedules',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Working Days', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _workingDays.map((day) {
                  final isSelected = _selectedWorkingDays.contains(day);
                  return ChoiceChip(
                    label: Text(day, style: GoogleFonts.poppins(color: isSelected ? Colors.blue.shade700 : Colors.black87, fontSize: 13)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedWorkingDays.add(day);
                        } else {
                          _selectedWorkingDays.remove(day);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? Colors.blue.shade200 : Colors.grey.shade300),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Weekly Off / Holiday Notes', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              ..._workingDays.where((day) => !_selectedWorkingDays.contains(day)).map((day) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                      const SizedBox(height: 4),
                      _buildTextField('', 'Enter note', controller: _weeklyOffNotesControllers[day]),
                    ],
                  ),
                );
              }),
              Text('Specify individual weekly leave or official holiday details for unselected days', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Payment Methods
        _buildSectionCard(
          icon: Icons.credit_card,
          title: 'Supported Payment Methods',
          subtitle: 'Dynamically manage accepted checkout payment options (Edit & Delete supported)',
          actionButton: _buildAddButton('+ Add Payment Method', () => _showAddMethodDialog('Add Payment Method', 'Payment Method Name *', 'e.g. Apple Pay, Crypto / Bitcoin, Bank Transfer', (val) {
            setState(() => _paymentMethods.add(val));
          })),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _paymentMethods.map((method) => _buildItemChip(method, Icons.money, () {
              // Edit
              _showAddMethodDialog('Edit Payment Method', 'Payment Method Name *', 'e.g. Apple Pay', (val) {
                setState(() {
                  int idx = _paymentMethods.indexOf(method);
                  if (idx != -1) _paymentMethods[idx] = val;
                });
              }, initialValue: method);
            }, () {
              // Delete
              setState(() => _paymentMethods.remove(method));
            })).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Supported Languages
        _buildSectionCard(
          icon: Icons.language,
          title: 'Supported Languages',
          subtitle: 'Dynamically set storefront languages (Edit & Delete supported)',
          actionButton: _buildAddButton('+ Add Language', () => _showAddMethodDialog('Add Language', 'Language Name *', 'e.g. French, Spanish', (val) {
            setState(() => _languages.add(val));
          })),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _languages.map((lang) => _buildItemChip(lang, Icons.language, () {
              // Edit
              _showAddMethodDialog('Edit Language', 'Language Name *', 'e.g. French', (val) {
                setState(() {
                  int idx = _languages.indexOf(lang);
                  if (idx != -1) _languages[idx] = val;
                });
              }, initialValue: lang);
            }, () {
              // Delete
              setState(() => _languages.remove(lang));
            })).toList(),
          ),
        ),
        
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Previous', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Save & Finish', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== Helpers =====================

  Widget _buildSectionCard({required IconData icon, required String title, required String subtitle, required Widget child, Widget? actionButton}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: const Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (actionButton != null) actionButton,
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildAddButton(String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6366F1),
        side: const BorderSide(color: Color(0xFF6366F1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
    );
  }

  Widget _buildItemChip(String text, IconData leadingIcon, VoidCallback onEdit, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, color: const Color(0xFF6366F1), size: 16),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined, color: Colors.black45, size: 16),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline, color: Colors.black45, size: 16),
          ),
        ],
      ),
    );
  }

  void _showAddMethodDialog(String title, String label, String hint, Function(String) onAdd, {String? initialValue}) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Color(0xFF6366F1), size: 20),
                        const SizedBox(width: 8),
                        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black45, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildLabel(label),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF6366F1)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          onAdd(controller.text.trim());
                          Navigator.pop(context); // Close dialog explicitly
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(initialValue == null ? 'Add Method' : 'Save', style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.replaceAll('*', '').trim(), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
          if (text.contains('*')) TextSpan(text: ' *', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          _buildLabel(label),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
                    child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              errorText: errorText,
              errorStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFF6366F1)),
              ),
            ),
          ),

        ),
      ],
    );
  }

  Widget _buildTextFieldWithSub(String label, String hint, String sub, {TextEditingController? controller, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(label, hint, controller: controller, errorText: errorText),
        const SizedBox(height: 4),
        if (errorText != null) Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.error_outline, size: 12, color: Colors.red), const SizedBox(width: 4), Text(errorText, style: GoogleFonts.poppins(fontSize: 10, color: Colors.red))])) else Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
      ],
    );
  }

  Widget _buildDropdownWithSub(String label, String hint, String sub, List<String> items, String? value, Function(String?) onChanged, {String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: errorText != null ? Colors.red : Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(hint, style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13)),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
      ],
    );
  }

  Widget _buildDottedUploadBox(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5, style: BorderStyle.solid), // Fallback for dotted
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
            child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Click to upload', style: GoogleFonts.poppins(color: const Color(0xFF6366F1), fontWeight: FontWeight.w600, fontSize: 13)),
                TextSpan(text: title.replaceAll('Click to upload', ''), style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.article_outlined, size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(Widget child1, Widget child2, [Widget? child3]) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: child1),
              const SizedBox(width: 24),
              Expanded(child: child2),
              if (child3 != null) ...[
                const SizedBox(width: 24),
                Expanded(child: child3),
              ],
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              child1,
              const SizedBox(height: 16),
              child2,
              if (child3 != null) ...[
                const SizedBox(height: 16),
                child3,
              ],
            ],
          );
        }
      },
    );
  }
}
