import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:va_business/features/business/data/repositories/supplier_repository.dart';
import 'package:va_business/features/business/presentation/providers/platform_providers.dart';
import 'package:va_business/features/business/presentation/providers/supplier_providers.dart';
import 'dart:io';

class CreateSupplierScreen extends ConsumerStatefulWidget {
  final SupplierApiModel? supplierToEdit;
  const CreateSupplierScreen({super.key, this.supplierToEdit});

  @override
  ConsumerState<CreateSupplierScreen> createState() => _CreateSupplierScreenState();
}

class _CreateSupplierScreenState extends ConsumerState<CreateSupplierScreen> {
  int _currentStep = 1;
  bool _withGst = true;
  bool _isLoading = false;

  // Step 1
  final TextEditingController _gstNumberController = TextEditingController();
  XFile? _gstCertificateFile;
  String? _existingGstCertificate;

  // Step 2
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  XFile? _companyLogoFile;
  String? _existingCompanyLogo;

  // Step 3
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'India');

  // Step 4 - Store platform/shop type names (not IDs, since API uses names)
  Set<String> _selectedPlatformNames = {};
  Set<String> _selectedShopTypeNames = {};

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final s = widget.supplierToEdit;
    if (s != null) {
      _withGst = s.withGst;
      _gstNumberController.text = s.gstNumber ?? '';
      _businessNameController.text = s.businessName ?? '';
      _businessEmailController.text = s.businessEmail ?? '';
      _phoneController.text = s.phone ?? '';
      _doorNoController.text = s.doorNo ?? '';
      _streetNameController.text = s.streetName ?? '';
      _buildingNameController.text = s.buildingName ?? '';
      _landmarkController.text = s.landmark ?? '';
      _areaController.text = s.area ?? '';
      _districtController.text = s.district ?? '';
      _pincodeController.text = s.pincode ?? '';
      _stateController.text = s.state ?? '';
      _countryController.text = s.country ?? 'India';
      _existingCompanyLogo = s.companyLogo;
      _existingGstCertificate = s.gstCertificate;
      if (s.platform != null) {
        _selectedPlatformNames = s.platform!.split(', ').map((e) => e.trim()).where((p) => p.isNotEmpty).toSet();
      }
      if (s.type != null) {
        _selectedShopTypeNames = s.type!.split(', ').map((e) => e.trim()).where((t) => t.isNotEmpty).toSet();
      }
    }
  }

  @override
  void dispose() {
    _gstNumberController.dispose();
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _phoneController.dispose();
    _doorNoController.dispose();
    _streetNameController.dispose();
    _buildingNameController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickGstFile() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _gstCertificateFile = file);
  }

  Future<void> _pickLogoFile() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _companyLogoFile = file);
  }

  String _getFileSize(XFile file) {
    try {
      final bytes = File(file.path).lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return 'Local file';
    }
  }

  Future<void> _saveSupplier() async {
    setState(() => _isLoading = true);
    try {
      if (widget.supplierToEdit != null) {
        await ref.read(supplierNotifierProvider.notifier).updateSupplier(
          supplierId: widget.supplierToEdit!.id,
          withGst: _withGst,
          gstNumber: _gstNumberController.text,
          gstCertificate: _gstCertificateFile,
          existingGstCertificate: _existingGstCertificate,
          businessName: _businessNameController.text,
          businessEmail: _businessEmailController.text,
          phone: _phoneController.text,
          companyLogo: _companyLogoFile,
          existingCompanyLogo: _existingCompanyLogo,
          doorNo: _doorNoController.text,
          streetName: _streetNameController.text,
          buildingName: _buildingNameController.text,
          landmark: _landmarkController.text,
          area: _areaController.text,
          district: _districtController.text,
          pincode: _pincodeController.text,
          state: _stateController.text,
          country: _countryController.text,
          platformNames: _selectedPlatformNames.toList(),
          shopTypeNames: _selectedShopTypeNames.toList(),
        );
      } else {
        await ref.read(supplierNotifierProvider.notifier).addSupplier(
          withGst: _withGst,
          gstNumber: _gstNumberController.text,
          gstCertificate: _gstCertificateFile,
          businessName: _businessNameController.text,
          businessEmail: _businessEmailController.text,
          phone: _phoneController.text,
          companyLogo: _companyLogoFile,
          doorNo: _doorNoController.text,
          streetName: _streetNameController.text,
          buildingName: _buildingNameController.text,
          landmark: _landmarkController.text,
          area: _areaController.text,
          district: _districtController.text,
          pincode: _pincodeController.text,
          state: _stateController.text,
          country: _countryController.text,
          platformNames: _selectedPlatformNames.toList(),
          shopTypeNames: _selectedShopTypeNames.toList(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.supplierToEdit != null ? 'Supplier updated!' : 'Supplier saved!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.poppins()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                if (_currentStep == 1) _buildStep1(),
                if (_currentStep == 2) _buildStep2(),
                if (_currentStep == 3) _buildStep3(),
                if (_currentStep == 4) _buildStep4(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF4C4DDC))),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF4C4DDC), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.business, color: Colors.white, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.supplierToEdit != null ? 'Edit Supplier' : 'Add Supplier', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text('Add and manage supplier business information', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 14, color: Colors.black54),
                label: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _stepIndicator(1, 'Tax & Registration', Icons.description_outlined),
                _stepLine(1),
                _stepIndicator(2, 'Business Details', Icons.business_center_outlined),
                _stepLine(2),
                _stepIndicator(3, 'Address Details', Icons.location_on_outlined),
                _stepLine(3),
                _stepIndicator(4, 'Business Type', Icons.category_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepIndicator(int num, String title, IconData icon) {
    final done = _currentStep > num;
    final active = _currentStep == num;
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? Colors.green : (active ? const Color(0xFF4C4DDC) : Colors.white),
            border: Border.all(color: done ? Colors.green : (active ? const Color(0xFF4C4DDC) : Colors.grey.shade300), width: 2),
          ),
          child: Center(child: done ? const Icon(Icons.check, color: Colors.white, size: 18) : Icon(icon, color: active ? Colors.white : Colors.grey.shade400, size: 16)),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('STEP 0$num', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: done ? Colors.green : (active ? const Color(0xFF4C4DDC) : Colors.grey.shade400))),
            Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: active || done ? FontWeight.w600 : FontWeight.normal, color: active || done ? Colors.black87 : Colors.grey.shade500)),
          ],
        ),
      ],
    );
  }

  Widget _stepLine(int num) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 32, height: 2, color: _currentStep > num ? Colors.green : Colors.grey.shade200);
  }

  Widget _buildStep1() {
    return _stepCard(
      title: 'Tax Information & Registration',
      subtitle: 'Configure GST status, number, and compliance documents',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GST Status *', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFF4F7FB), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _gstBtn(true, 'With GST'),
                _gstBtn(false, 'Without GST'),
              ],
            ),
          ),
          if (_withGst) ...[
            const SizedBox(height: 24),
            _textField('GST Number *', _gstNumberController, hint: 'Enter 15-digit GST number'),
            const SizedBox(height: 24),
            Text('GST Certificate *', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _gstCertificateFile != null
                ? _fileChip(_gstCertificateFile!, () => setState(() => _gstCertificateFile = null))
                : (_existingGstCertificate != null && _existingGstCertificate!.isNotEmpty
                    ? _existingFileChip(_existingGstCertificate!, () => setState(() => _existingGstCertificate = null))
                    : _uploadBox('Drag & drop certificate here', _pickGstFile)),
          ] else ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF8AB4F8).withOpacity(0.5))),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF4285F4)),
                  const SizedBox(width: 12),
                  Expanded(child: Text('GST Registration Not Required for this supplier.', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1967D2)))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          _bottomButtons(onNext: () => setState(() => _currentStep = 2)),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _stepCard(
      title: 'Business Details',
      subtitle: 'Enter basic identification and organizational details',
      icon: Icons.business_center_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(width: _fieldWidth, child: _textField('Business Name *', _businessNameController, hint: 'Enter business name')),
            SizedBox(width: _fieldWidth, child: _textField('Business Email', _businessEmailController, hint: 'Enter email', keyboardType: TextInputType.emailAddress)),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: _fieldWidth, child: _textField('Phone', _phoneController, hint: 'Enter phone number', keyboardType: TextInputType.phone)),
          const SizedBox(height: 24),
          Text('Company Logo', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _companyLogoFile != null
              ? _logoPreview()
              : (_existingCompanyLogo != null && _existingCompanyLogo!.isNotEmpty
                  ? _existingLogoPreview()
                  : _uploadBox('Drag & drop company logo here', _pickLogoFile)),
          const SizedBox(height: 32),
          _bottomButtons(onBack: () => setState(() => _currentStep = 1), onNext: () => setState(() => _currentStep = 3)),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _stepCard(
      title: 'Address Details',
      subtitle: 'Registered office and physical dispatch location',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(width: _fieldWidth, child: _textField('Door No', _doorNoController, hint: 'Door no')),
            SizedBox(width: _fieldWidth, child: _textField('Street Name', _streetNameController, hint: 'Street name')),
            SizedBox(width: _fieldWidth, child: _textField('Building Name', _buildingNameController, hint: 'Building')),
            SizedBox(width: _fieldWidth, child: _textField('Landmark', _landmarkController, hint: 'Landmark')),
            SizedBox(width: _fieldWidth, child: _textField('Area', _areaController, hint: 'Area')),
            SizedBox(width: _fieldWidth, child: _textField('District', _districtController, hint: 'District')),
            SizedBox(width: _fieldWidth, child: _textField('Pincode', _pincodeController, hint: 'Pincode', keyboardType: TextInputType.number)),
            SizedBox(width: _fieldWidth, child: _textField('State', _stateController, hint: 'State')),
            SizedBox(width: _fieldWidth, child: _textField('Country', _countryController)),
          ]),
          const SizedBox(height: 32),
          _bottomButtons(onBack: () => setState(() => _currentStep = 2), onNext: () => setState(() => _currentStep = 4)),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final platformAssignAsync = ref.watch(platformAssignmentsProvider);

    return _stepCard(
      title: 'Business Type & Platform',
      subtitle: 'Select operating platforms and business classifications (Multiple selections supported)',
      icon: Icons.category_outlined,
      child: platformAssignAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFF4C4DDC)),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400, size: 36),
                const SizedBox(height: 8),
                Text('Error loading platforms: $e', style: GoogleFonts.poppins(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(platformAssignmentsProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C4DDC)),
                  child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
        data: (res) {
          // Parse platform-assign data
          final Map<String, _PlatformGroup> platformsMap = {};
          final list = res.data as List<dynamic>? ?? [];
          for (final raw in list) {
            if (raw is! Map<String, dynamic>) continue;
            final pName = (raw['platformName'] ?? raw['platform_name'] ?? '').toString().trim();
            final sName = (raw['shopTypeName'] ?? raw['shop_type_name'] ?? '').toString().trim();
            final status = (raw['status'] ?? 'Active').toString().trim();
            if (pName.isEmpty) continue;

            if (!platformsMap.containsKey(pName)) {
              platformsMap[pName] = _PlatformGroup(
                platformName: pName,
                status: status.isNotEmpty ? status : 'Active',
                shopTypes: {},
              );
            }
            if (sName.isNotEmpty) {
              platformsMap[pName]!.shopTypes.add(sName);
            }
          }
          final allPlatforms = platformsMap.values.toList();

          // Gather shop types for selected platforms
          final visibleShopTypes = <Map<String, String>>[];
          for (final pName in _selectedPlatformNames) {
            final group = platformsMap[pName];
            if (group != null) {
              for (final st in group.shopTypes) {
                visibleShopTypes.add({'name': st, 'platform': pName});
              }
            }
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 520
                  ? 170.0
                  : ((constraints.maxWidth - 10) / 2).floorToDouble();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PLATFORMS HEADER
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Platforms *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _badge('${_selectedPlatformNames.length} selected'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPlatformNames = platformsMap.keys.toSet();
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text('Select All', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C4DDC), fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text('•', style: TextStyle(color: Colors.grey)),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPlatformNames.clear();
                                _selectedShopTypeNames.clear();
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text('Clear', style: GoogleFonts.poppins(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose channels and marketplaces where your supplier distributes products',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // PLATFORMS GRID
                  if (allPlatforms.isEmpty)
                    Text('No platforms found', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: allPlatforms.map((p) {
                        final isSelected = _selectedPlatformNames.contains(p.platformName);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedPlatformNames.remove(p.platformName);
                                final remainingShopTypes = <String>{};
                                for (final rName in _selectedPlatformNames) {
                                  remainingShopTypes.addAll(platformsMap[rName]?.shopTypes ?? {});
                                }
                                _selectedShopTypeNames.removeWhere((st) => !remainingShopTypes.contains(st));
                              } else {
                                _selectedPlatformNames.add(p.platformName);
                              }
                            });
                          },
                          child: _platformCard(p.platformName, p.status, isSelected, cardWidth),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 32),

                  // SHOP TYPES HEADER
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Shop Type *', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _badge('${_selectedShopTypeNames.length} selected'),
                        ],
                      ),
                      if (visibleShopTypes.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedShopTypeNames = visibleShopTypes.map((e) => e['name']!).toSet();
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Text('Select All', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C4DDC), fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('•', style: TextStyle(color: Colors.grey)),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedShopTypeNames.clear();
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Text('Clear', style: GoogleFonts.poppins(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select operating shop types assigned to your chosen sales platform(s)',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // SHOP TYPES CONTENT
                  if (_selectedPlatformNames.isEmpty)
                    _emptyShopTypeBox()
                  else if (visibleShopTypes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Text('No shop types assigned to selected platform(s)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: visibleShopTypes.map((item) {
                        final name = item['name']!;
                        final platformName = item['platform']!;
                        final isSelected = _selectedShopTypeNames.contains(name);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedShopTypeNames.remove(name);
                              } else {
                                _selectedShopTypeNames.add(name);
                              }
                            });
                          },
                          child: _shopTypeCard(name, platformName, isSelected, cardWidth),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 32),
                  _bottomButtons(
                    onBack: () => setState(() => _currentStep = 3),
                    isSave: true,
                    onSave: _saveSupplier,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _platformCard(String name, String status, bool isSelected, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F2FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF4C4DDC) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storefront_outlined, color: Color(0xFF3B82F6), size: 16),
              ),
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isSelected ? const Color(0xFF4C4DDC) : const Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Sales Platform • $status',
            style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _shopTypeCard(String name, String platformName, bool isSelected, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_mall_outlined, color: Color(0xFFEA580C), size: 16),
              ),
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: isSelected ? const Color(0xFFEA580C) : const Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Platform: $platformName',
              style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF2563EB), fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyShopTypeBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(Icons.layers_outlined, color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 12),
          Text('Select a Sales Platform above', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Click on any platform to view its shop types.', style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _bottomButtons({VoidCallback? onBack, VoidCallback? onNext, bool isSave = false, VoidCallback? onSave}) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey.shade300)),
          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black87)),
        ),
        Wrap(spacing: 12, runSpacing: 12, children: [
          if (onBack != null)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text('Back', style: GoogleFonts.poppins()),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: BorderSide(color: Colors.grey.shade300)),
            ),
          if (isSave)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : onSave,
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 16),
              label: Text(widget.supplierToEdit != null ? 'Update Supplier' : 'Save Supplier', style: GoogleFonts.poppins(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C4DDC), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            )
          else if (onNext != null)
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C4DDC), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Next', style: GoogleFonts.poppins(color: Colors.white)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ]),
            ),
        ]),
      ],
    );
  }

  double get _fieldWidth {
    final w = MediaQuery.of(context).size.width;
    return w > 600 ? (w - 140) / 2 : w - 80;
  }

  Widget _stepCard({required String title, required String subtitle, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF4F7FB), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF4C4DDC), size: 22)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54)),
            ])),
          ]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
          child,
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF4C4DDC), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _gstBtn(bool value, String label) {
    final selected = _withGst == value;
    return GestureDetector(
      onTap: () => setState(() => _withGst = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (selected) ...[const Icon(Icons.check_circle_outline, color: Color(0xFF4C4DDC), size: 14), const SizedBox(width: 6)],
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? const Color(0xFF4C4DDC) : Colors.black54)),
        ]),
      ),
    );
  }

  Widget _uploadBox(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(children: [
          Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text('or tap to browse', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4C4DDC))),
        ]),
      ),
    );
  }

  Widget _fileChip(XFile file, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]), child: const Icon(Icons.insert_drive_file, color: Color(0xFF4C4DDC))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(file.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(_getFileSize(file), style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
        ])),
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
      ]),
    );
  }

  Widget _logoPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4C4DDC).withOpacity(0.4))),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_companyLogoFile!.path), width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Logo uploaded', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(_companyLogoFile!.name, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                onPressed: _pickLogoFile,
                icon: const Icon(Icons.sync, size: 12, color: Color(0xFF4C4DDC)),
                label: Text('Change', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4C4DDC))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF4C4DDC)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _companyLogoFile = null),
                icon: const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                label: Text('Remove', style: GoogleFonts.poppins(fontSize: 11, color: Colors.red)),
              ),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _existingLogoPreview() {
    final rawUrl = _existingCompanyLogo!;
    final logoUrl = rawUrl.startsWith('http://localhost:5092')
        ? rawUrl.replaceFirst('http://localhost:5092', 'https://business-setup.srivagroups.in')
        : (rawUrl.startsWith('/') ? 'https://business-setup.srivagroups.in$rawUrl' : rawUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4C4DDC).withOpacity(0.4))),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              logoUrl,
              width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.business, color: Color(0xFF4C4DDC))),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Current Logo', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(logoUrl.split('/').last, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                onPressed: _pickLogoFile,
                icon: const Icon(Icons.sync, size: 12, color: Color(0xFF4C4DDC)),
                label: Text('Change', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF4C4DDC))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF4C4DDC)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _existingCompanyLogo = null),
                icon: const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                label: Text('Remove', style: GoogleFonts.poppins(fontSize: 11, color: Colors.red)),
              ),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _existingFileChip(String url, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FE), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]), child: const Icon(Icons.insert_drive_file, color: Color(0xFF4C4DDC))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(url.split('/').last, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('Existing certificate', style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54)),
        ])),
        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
      ]),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF1967D2), fontWeight: FontWeight.bold)),
    );
  }
}

class _PlatformGroup {
  final String platformName;
  final String status;
  final Set<String> shopTypes;

  _PlatformGroup({
    required this.platformName,
    required this.status,
    required this.shopTypes,
  });
}

