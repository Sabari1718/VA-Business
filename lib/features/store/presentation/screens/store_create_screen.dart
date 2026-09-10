import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:va_business/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/store_providers.dart';
import '../../data/models/store_model.dart';
import 'package:va_business/features/business/presentation/providers/business_providers.dart';
import 'package:va_business/core/utils/safe_base64_decode.dart';

class SelectableBusiness {
  final String id;
  final String name;
  final String category;
  final String categoryKey;
  final String phone;
  final String email;
  final String website;
  final String? logo;
  final Map<String, dynamic> raw;

  SelectableBusiness({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryKey,
    required this.phone,
    required this.email,
    required this.website,
    this.logo,
    required this.raw,
  });
}

class StoreCreateScreen extends ConsumerStatefulWidget {
  final StoreModel? store;
  const StoreCreateScreen({super.key, this.store});

  @override
  ConsumerState<StoreCreateScreen> createState() => _StoreCreateScreenState();
}

class _StoreCreateScreenState extends ConsumerState<StoreCreateScreen> {
  int _currentStep = 1;
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _customerCarePhoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  
  final TextEditingController _customerCareNameController = TextEditingController();
  final TextEditingController _altContactNameController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  
  final TextEditingController _countryController = TextEditingController(text: 'India');
  final TextEditingController _stateController = TextEditingController(text: 'Tamil Nadu');
  final TextEditingController _districtController = TextEditingController(text: 'Chennai');
  final TextEditingController _talukController = TextEditingController(text: 'Guindy');
  final TextEditingController _cityVillageController = TextEditingController(text: 'Chennai City');
  final TextEditingController _pincodeController = TextEditingController(text: '600020');
  
  final TextEditingController _openingTimeController = TextEditingController(text: '09:00 AM');
  final TextEditingController _closingTimeController = TextEditingController(text: '09:00 PM');
  
  String? _storeLogoBase64;
  bool _isLoading = false;
  bool _showStep1Errors = false;
  bool _showStep2Errors = false;
  bool _showStep3Errors = false;
  
  String? _selectedBranchModel = 'Single Branch (Automatic Single Setup)';
  SelectableBusiness? _selectedBusiness;
  bool _hasAutoFilled = false;

  // Configuration State
  final List<String> _workingDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final Set<String> _selectedWorkingDays = {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
  final Map<String, TextEditingController> _weeklyOffNotesControllers = {};

  final List<String> _paymentMethods = ['Cash on Delivery', 'Credit / Debit Card', 'UPI / Google Pay', 'Net Banking'];
  final List<String> _languages = ['English', 'Tamil', 'Hindi', 'Spanish'];

  @override
  void initState() {
    super.initState();
    for (var day in _workingDays) {
      _weeklyOffNotesControllers[day] = TextEditingController(text: '$day weekly off');
    }
    
    if (widget.store != null) {
      final s = widget.store!;
      _storeNameController.text = s.storeName;
      _selectedBranchModel = s.branchManagementModel.isNotEmpty ? s.branchManagementModel : 'Single Branch (Automatic Single Setup)';
      _customerCareNameController.text = s.customerCareName.isNotEmpty ? s.customerCareName : 'Sabari';
      _customerCarePhoneController.text = s.customerCarePhone;
      _altContactNameController.text = s.altContactName;
      _altPhoneController.text = s.altPhone;
      _countryController.text = s.country.isNotEmpty ? s.country : 'India';
      _stateController.text = s.state;
      _districtController.text = s.district;
      _talukController.text = s.taluk;
      _cityVillageController.text = s.cityVillage;
      _pincodeController.text = s.pincode;
      _openingTimeController.text = s.openingTime.isNotEmpty ? s.openingTime : '09:00 AM';
      _closingTimeController.text = s.closingTime.isNotEmpty ? s.closingTime : '09:00 PM';
      
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
    _storeNameController.dispose();
    _customerCarePhoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _customerCareNameController.dispose();
    _altContactNameController.dispose();
    _altPhoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _talukController.dispose();
    _cityVillageController.dispose();
    _pincodeController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    for (var controller in _weeklyOffNotesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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

  void _selectBusiness(SelectableBusiness b, {bool forceFill = true}) {
    setState(() {
      _selectedBusiness = b;
      if (forceFill) {
        if (b.name.isNotEmpty) {
          _storeNameController.text = b.name;
          _customerCareNameController.text = b.name;
        }
        if (b.phone.isNotEmpty) {
          _customerCarePhoneController.text = b.phone;
        }
        if (b.email.isNotEmpty) {
          _emailController.text = b.email;
        }
        if (b.website.isNotEmpty) {
          _websiteController.text = b.website;
        }
        if (b.logo != null && b.logo!.isNotEmpty) {
          _storeLogoBase64 = b.logo;
        }
      }
    });
  }

  Widget _buildStoreLogoPreview() {
    if (_storeLogoBase64 == null || _storeLogoBase64!.isEmpty) {
      return _buildDottedUploadBox(
        'Click to upload, or drag & drop store image here',
        'Tip: You can also copy & paste (Ctrl + V) any image directly',
      );
    }

    if (_storeLogoBase64!.startsWith('http')) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(_storeLogoBase64!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final bytes = safeBase64Decode(_storeLogoBase64!);
    if (bytes.isNotEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: MemoryImage(bytes),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return _buildDottedUploadBox(
      'Click to upload, or drag & drop store image here',
      'Tip: You can also copy & paste (Ctrl + V) any image directly',
    );
  }

  Widget _buildSwitchBusinessPill(List<SelectableBusiness> allBusinesses) {
    final name = _selectedBusiness?.name ?? 'Select Business';
    return InkWell(
      onTap: allBusinesses.isEmpty
          ? null
          : () => _showSwitchBusinessDialog(allBusinesses),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_rounded, size: 13, color: Color(0xFF6366F1)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                'Business: $name',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF6366F1),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }

  void _showSwitchBusinessDialog(List<SelectableBusiness> allBusinesses) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Switch Business',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${allBusinesses.length} Available',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: allBusinesses.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final b = allBusinesses[index];
                      final isSelected = _selectedBusiness?.id == b.id &&
                          _selectedBusiness?.categoryKey == b.categoryKey;

                      Color catColor;
                      IconData catIcon;
                      if (b.categoryKey == 'partner') {
                        catColor = const Color(0xFFF97316);
                        catIcon = Icons.handshake_outlined;
                      } else if (b.categoryKey == 'supplier') {
                        catColor = const Color(0xFF10B981);
                        catIcon = Icons.local_shipping_outlined;
                      } else {
                        catColor = const Color(0xFF4C8DFB);
                        catIcon = Icons.storefront_rounded;
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _selectBusiness(b, forceFill: true);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF5F7FF) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(catIcon, color: catColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      b.category,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_rounded, color: Color(0xFF6366F1), size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _nextStep() {
    setState(() {
      if (_currentStep == 1) {
        _showStep1Errors = true;
        if (_storeNameController.text.trim().isNotEmpty &&
            _customerCarePhoneController.text.trim().isNotEmpty) {
          _currentStep++;
        }
      } else if (_currentStep == 2) {
        _showStep2Errors = true;
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

  Future<void> _submitForm() async {
    setState(() {
      _showStep1Errors = true;
      _showStep2Errors = true;
      _showStep3Errors = true;
    });
    
    if (_storeNameController.text.trim().isEmpty ||
        _customerCarePhoneController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _districtController.text.trim().isEmpty ||
        _talukController.text.trim().isEmpty ||
        _cityVillageController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = StoreModel(
        id: widget.store?.id,
        userId: widget.store?.userId,
        storeName: _storeNameController.text.trim(),
        branchManagementModel: _selectedBranchModel ?? 'Single Branch (Automatic Single Setup)',
        customerCareName: _customerCareNameController.text.trim().isNotEmpty
            ? _customerCareNameController.text.trim()
            : (_selectedBusiness?.name ?? 'Sabari'),
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
        businessId: _selectedBusiness?.id ?? (widget.store?.businessId.isNotEmpty == true ? widget.store!.businessId : '1'),
        platformId: widget.store?.platformId.isNotEmpty == true ? widget.store!.platformId : '1',
        shopType: widget.store?.shopType,
        platformModule: widget.store?.platformModule,
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

  @override
  Widget build(BuildContext context) {
    final propagatorAsync = ref.watch(propagatorBusinessProvider);
    final partnerAsync = ref.watch(partnerBusinessProvider);
    final supplierAsync = ref.watch(supplierBusinessProvider);

    final List<SelectableBusiness> allBusinesses = [];

    propagatorAsync.whenData((resp) {
      for (var item in resp.data) {
        if (item is Map) {
          allBusinesses.add(SelectableBusiness(
            id: item['id']?.toString() ?? '',
            name: item['businessName'] ?? item['name'] ?? '',
            category: 'Propagator Business',
            categoryKey: 'propagator',
            phone: item['businessPhone'] ?? item['phone'] ?? '',
            email: item['businessEmail'] ?? item['email'] ?? '',
            website: item['website'] ?? '',
            logo: item['companyLogo'] ?? item['logo'],
            raw: Map<String, dynamic>.from(item),
          ));
        }
      }
    });

    partnerAsync.whenData((resp) {
      for (var item in resp.data) {
        if (item is Map) {
          allBusinesses.add(SelectableBusiness(
            id: item['id']?.toString() ?? '',
            name: item['businessName'] ?? item['name'] ?? '',
            category: 'Partner Business',
            categoryKey: 'partner',
            phone: item['businessPhone'] ?? item['phone'] ?? '',
            email: item['businessEmail'] ?? item['email'] ?? '',
            website: item['website'] ?? '',
            logo: item['companyLogo'] ?? item['logo'],
            raw: Map<String, dynamic>.from(item),
          ));
        }
      }
    });

    supplierAsync.whenData((resp) {
      for (var item in resp.data) {
        if (item is Map) {
          allBusinesses.add(SelectableBusiness(
            id: item['id']?.toString() ?? '',
            name: item['businessName'] ?? item['name'] ?? '',
            category: 'Supplier Business',
            categoryKey: 'supplier',
            phone: item['businessPhone'] ?? item['phone'] ?? '',
            email: item['businessEmail'] ?? item['email'] ?? '',
            website: item['website'] ?? '',
            logo: item['companyLogo'] ?? item['logo'] ?? item['companyLogoPath'],
            raw: Map<String, dynamic>.from(item),
          ));
        }
      }
    });

    if (!_hasAutoFilled && allBusinesses.isNotEmpty) {
      _hasAutoFilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SelectableBusiness? initial;
        if (widget.store != null && widget.store!.businessId.isNotEmpty) {
          initial = allBusinesses.firstWhere(
            (b) => b.id == widget.store!.businessId,
            orElse: () => allBusinesses.first,
          );
        } else {
          initial = allBusinesses.first;
        }
        _selectBusiness(initial, forceFill: widget.store == null);
      });
    }

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

              // Custom Stepper (3 Steps matching web)
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
                      _buildStepTab(1, 'Store Information', Icons.store_outlined, _currentStep >= 1),
                      _buildStepTab(2, 'Address Details', Icons.location_on_outlined, _currentStep >= 2),
                      _buildStepTab(3, 'Store Configuration', Icons.tune_outlined, _currentStep >= 3),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Step Content
              if (_currentStep == 1) _buildStep1(allBusinesses),
              if (_currentStep == 2) _buildStep2(),
              if (_currentStep == 3) _buildStep3(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTab(int step, String title, IconData icon, bool isCompletedOrActive) {
    final isActive = _currentStep == step;
    return SizedBox(
      width: 180,
      child: GestureDetector(
        onTap: () {
          setState(() => _currentStep = step);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6366F1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : (isCompletedOrActive ? const Color(0xFF10B981) : Colors.grey.shade300),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('$step', style: GoogleFonts.poppins(color: isActive ? const Color(0xFF6366F1) : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
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

  // ===================== STEP 1: Store Information =====================
  Widget _buildStep1(List<SelectableBusiness> allBusinesses) {
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
                    Text('Manage your store identity and contact details', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLabel('Store Logo / Showcase Image'),
              Text('Supports Drag & Drop, Copy-Paste (Ctrl+V), or Click to Browse', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickImage,
            child: _buildStoreLogoPreview(),
          ),
          const SizedBox(height: 20),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildLabel('Store Name / Store Title *'),
                  _buildSwitchBusinessPill(allBusinesses),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  hintText: 'Enter store name',
                  hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  errorText: _showStep1Errors && _storeNameController.text.trim().isEmpty ? 'Store Name is required.' : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedBusiness != null
                    ? 'Auto-filled from your business "${_selectedBusiness!.name}" — you can edit if needed'
                    : 'Enter your store or business title',
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildResponsiveRow(
            _buildTextFieldWithSub('Contact Number *', 'Enter contact phone number', 'Enter store customer care or support phone number', controller: _customerCarePhoneController, errorText: _showStep1Errors && _customerCarePhoneController.text.trim().isEmpty ? 'Contact Number is required.' : null),
            _buildTextFieldWithSub('Email ID', 'Enter store email address', 'Enter store or business email for customer communication', controller: _emailController),
          ),
          const SizedBox(height: 20),
          
          _buildTextFieldWithSub('Website Link (optional)', 'https://www.yourstore.com', 'Enter your store or business website URL', controller: _websiteController),

          const SizedBox(height: 32),
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

  // ===================== STEP 2: Address Details =====================
  Widget _buildStep2() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF4C8DFB), shape: BoxShape.circle),
                child: const Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Configure store physical location and address', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildResponsiveRow(
            _buildTextField('Country *', 'India', controller: _countryController, errorText: _showStep2Errors && _countryController.text.trim().isEmpty ? 'Country is required.' : null),
            _buildTextField('State *', 'e.g. Tamil Nadu', controller: _stateController, errorText: _showStep2Errors && _stateController.text.trim().isEmpty ? 'State is required.' : null),
            _buildTextField('District *', 'e.g. Chennai', controller: _districtController, errorText: _showStep2Errors && _districtController.text.trim().isEmpty ? 'District is required.' : null),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildTextField('Taluk *', 'e.g. Guindy', controller: _talukController, errorText: _showStep2Errors && _talukController.text.trim().isEmpty ? 'Taluk is required.' : null),
            _buildTextField('City / Village *', 'e.g. Chennai City', controller: _cityVillageController, errorText: _showStep2Errors && _cityVillageController.text.trim().isEmpty ? 'City / Village is required.' : null),
            _buildTextField('Pincode *', 'e.g. 600020', controller: _pincodeController, errorText: _showStep2Errors && _pincodeController.text.trim().isEmpty ? 'Pincode is required.' : null),
          ),
          const SizedBox(height: 24),

          // GPS Location Picker Box matching web screenshot (Fully mobile-optimized)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Search & Refresh
                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, size: 18, color: Colors.black45),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Detecting GPS coordinates...', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                                label: Text('Refresh Location', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search, size: 18, color: Colors.black45),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('Detecting GPS coordinates...', style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                                label: Text('Refresh Location', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // Warning Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Location permission is required to automatically detect your business location.', style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFFDC2626))),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFDC2626),
                                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    child: Text('Try Again', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text('Location permission is required to automatically detect your business location.', style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFFDC2626))),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: Text('Try Again', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Map & Details Grid/Row
                    _buildResponsiveRow(
                      // Left: Store Premises & Coordinates
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('sabari', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                Text('Store Premises', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                                Text('•', style: GoogleFonts.poppins(fontSize: 11, color: Colors.green)),
                                Text('Verified Location', style: GoogleFonts.poppins(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMapActionButton(Icons.refresh, 'Refresh', () {}),
                                _buildMapActionButton(Icons.check_circle, 'Confirm', () {}, isPrimary: true),
                                _buildMapActionButton(Icons.copy_outlined, 'Copy', () {}),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.my_location, size: 12, color: Color(0xFF6366F1)),
                                      const SizedBox(width: 4),
                                      Text('Current Location', style: GoogleFonts.poppins(fontSize: 11, color: Color(0xFF6366F1), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.place_outlined, size: 12, color: Colors.black54),
                                      const SizedBox(width: 4),
                                      Text('Map Marker', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildCoordItem('LATITUDE', '—'),
                                  _buildCoordItem('LONGITUDE', '—'),
                                  _buildCoordItem('ACCURACY', '—'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('ADDRESS:', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text('Address will display once GPS coordinates are acquired', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                            const SizedBox(height: 16),
                            isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                        label: Text('Confirm Location', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6366F1),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.refresh, size: 14, color: Colors.black87),
                                        label: Text('Refresh Location', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.grey.shade300),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.check, size: 14, color: Colors.white),
                                          label: Text('Confirm Location', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6366F1),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.refresh, size: 14, color: Colors.black87),
                                        label: Text('Refresh Location', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.grey.shade300),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  ),
                            
                            // Added requested Address, GPS Coordinates, & Manual Coordinate Tuning Section below Confirm/Refresh Location
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6366F1)),
                                const SizedBox(width: 8),
                                Text('ADDRESS', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Detecting address via GPS...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.gps_fixed, size: 16, color: Color(0xFF6366F1)),
                                const SizedBox(width: 8),
                                Text('GPS COORDINATES & ACCURACY', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('—', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MANUAL COORDINATE TUNING', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                                  const SizedBox(height: 12),
                                  _buildResponsiveRow(
                                    _buildTextField('Latitude', 'e.g. 11.061861'),
                                    _buildTextField('Longitude', 'e.g. 77.086250'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: Map Placeholder / GPS Acquiring Box
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6366F1)),
                                ),
                                const SizedBox(height: 12),
                                Text('Acquiring High-Accuracy GPS...', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                                const SizedBox(height: 4),
                                Text('Requesting fresh coordinates from device GPS', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _buildGpsStep('1. Request GPS', true),
                                    const Text('->', style: TextStyle(color: Colors.black38, fontSize: 10)),
                                    _buildGpsStep('2. Receive', false),
                                    const Text('->', style: TextStyle(color: Colors.black38, fontSize: 10)),
                                    _buildGpsStep('3. Center', false),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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

  // ===================== STEP 3: Store Configuration =====================
  Widget _buildStep3() {
    return Column(
      children: [
        Container(
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF4C8DFB), shape: BoxShape.circle),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Store Configuration', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('Branch management model, operating hours, and preferences', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildResponsiveRow(
                _buildDropdownWithSub('Branch Management Model *', 'Single Branch (Automatic Single Setup)', 'Select branch operation and management model', ['Single Branch (Automatic Single Setup)', 'Multiple Branch'], _selectedBranchModel, (val) => setState(() => _selectedBranchModel = val)),
                _buildTextFieldWithSub('Customer Care Contact Name', 'Enter contact name', 'Customer care contact name', controller: _customerCareNameController),
              ),
              const SizedBox(height: 20),
              _buildResponsiveRow(
                _buildTextFieldWithSub('Alternate Contact Name', 'Enter alternate contact name', 'Alternate contact name', controller: _altContactNameController),
                _buildTextFieldWithSub('Alternate Phone Number', 'Enter alternate phone number', 'Alternate phone number', controller: _altPhoneController),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Operating Hours
        _buildSectionCard(
          icon: Icons.access_time,
          title: 'Store Operating Hours',
          subtitle: 'Set daily opening and closing schedule for customer visits & orders',
          child: _buildResponsiveRow(
            _buildTextField('Opening Time *', '09:00 AM', controller: _openingTimeController),
            _buildTextField('Closing Time *', '09:00 PM', controller: _closingTimeController),
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
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Payment Methods
        _buildSectionCard(
          icon: Icons.credit_card,
          title: 'Supported Payment Methods',
          subtitle: 'Dynamically manage accepted checkout payment options',
          actionButton: _buildAddButton('+ Add Payment Method', () => _showAddMethodDialog('Add Payment Method', 'Payment Method Name *', 'e.g. Apple Pay, Crypto, Bank Transfer', (val) {
            setState(() => _paymentMethods.add(val));
          })),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _paymentMethods.map((method) => _buildItemChip(method, Icons.money, () {
              _showAddMethodDialog('Edit Payment Method', 'Payment Method Name *', 'e.g. Apple Pay', (val) {
                setState(() {
                  int idx = _paymentMethods.indexOf(method);
                  if (idx != -1) _paymentMethods[idx] = val;
                });
              }, initialValue: method);
            }, () {
              setState(() => _paymentMethods.remove(method));
            })).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Supported Languages
        _buildSectionCard(
          icon: Icons.language,
          title: 'Supported Languages',
          subtitle: 'Dynamically set storefront languages',
          actionButton: _buildAddButton('+ Add Language', () => _showAddMethodDialog('Add Language', 'Language Name *', 'e.g. French, Spanish', (val) {
            setState(() => _languages.add(val));
          })),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _languages.map((lang) => _buildItemChip(lang, Icons.language, () {
              _showAddMethodDialog('Edit Language', 'Language Name *', 'e.g. French', (val) {
                setState(() {
                  int idx = _languages.indexOf(lang);
                  if (idx != -1) _languages[idx] = val;
                });
              }, initialValue: lang);
            }, () {
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

  Widget _buildMapActionButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF6366F1) : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.black54),
        onPressed: onTap,
        tooltip: label,
      ),
    );
  }

  Widget _buildCoordItem(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black45)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildGpsStep(String text, bool isActive) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        color: isActive ? const Color(0xFF6366F1) : Colors.black45,
      ),
    );
  }

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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
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
                          Navigator.pop(context);
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: errorText != null ? Colors.red : const Color(0xFF6366F1))),
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
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
