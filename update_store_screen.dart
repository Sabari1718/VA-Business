import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_create_screen.dart');
  String content = file.readAsStringSync();

  // 1. Add imports
  content = content.replaceFirst(
    "import 'package:va_business/core/theme/app_colors.dart';",
    "import 'package:va_business/core/theme/app_colors.dart';\nimport 'dart:convert';\nimport 'dart:io';\nimport 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:image_picker/image_picker.dart';\nimport '../providers/store_providers.dart';\nimport '../../data/models/store_model.dart';"
  );

  // 2. Change StatefulWidget to ConsumerStatefulWidget
  content = content.replaceAll('class StoreCreateScreen extends StatefulWidget', 'class StoreCreateScreen extends ConsumerStatefulWidget');
  content = content.replaceAll('State<StoreCreateScreen> createState() => _StoreCreateScreenState();', 'ConsumerState<StoreCreateScreen> createState() => _StoreCreateScreenState();');
  content = content.replaceAll('class _StoreCreateScreenState extends State<StoreCreateScreen>', 'class _StoreCreateScreenState extends ConsumerState<StoreCreateScreen>');

  // 3. Add state variables
  final stateVars = '''
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
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        _storeLogoBase64 = 'data:image/jpeg;base64,\$base64Image';
      });
    }
  }
  
  Future<void> _submitForm() async {
    if (_storeNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Store Name')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final payload = StoreModel(
        storeName: _storeNameController.text.trim(),
        branchManagementModel: _selectedBranchModel ?? 'Single Branch',
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
        holidayNotes: _weeklyOffNotesControllers.entries.map((e) => "\${e.key}: \${e.value.text}").join('; '),
        paymentMethods: _paymentMethods.join(', '),
        supportedLanguages: _languages.join(', '),
        businessId: '1',
        platformId: '1',
        status: 'Active',
        storeLogo: _storeLogoBase64 ?? '',
      );
      
      await ref.read(storeRepositoryProvider).createStore(payload);
      ref.invalidate(storesProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store created successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }
''';

  content = content.replaceFirst('int _currentStep = 1;', 'int _currentStep = 1;\n$stateVars');

  // 4. Hook up TextFields in Step 1
  content = content.replaceFirst("_buildTextFieldWithSub('Store Name / Store Title *', 'Enter store name', 'Enter official storefront or business trading title')", "_buildTextFieldWithSub('Store Name / Store Title *', 'Enter store name', 'Enter official storefront or business trading title', controller: _storeNameController)");
  content = content.replaceFirst("_buildTextFieldWithSub('Customer Care Contact Name *', 'Enter customer care contact name', 'Enter customer care or support contact name')", "_buildTextFieldWithSub('Customer Care Contact Name *', 'Enter customer care contact name', 'Enter customer care or support contact name', controller: _customerCareNameController)");
  content = content.replaceFirst("_buildTextFieldWithSub('Customer Care Phone Number *', 'Enter customer care phone number', 'Enter customer care or support phone number')", "_buildTextFieldWithSub('Customer Care Phone Number *', 'Enter customer care phone number', 'Enter customer care or support phone number', controller: _customerCarePhoneController)");
  content = content.replaceFirst("_buildTextFieldWithSub('Alternate Contact Name', 'Enter alternate contact name', 'Enter alternate or secondary contact name')", "_buildTextFieldWithSub('Alternate Contact Name', 'Enter alternate contact name', 'Enter alternate or secondary contact name', controller: _altContactNameController)");
  content = content.replaceFirst("_buildTextFieldWithSub('Alternate Phone Number', 'Enter alternate phone number', 'Enter alternate or secondary phone number')", "_buildTextFieldWithSub('Alternate Phone Number', 'Enter alternate phone number', 'Enter alternate or secondary phone number', controller: _altPhoneController)");

  // 5. Hook up TextFields in Step 2
  content = content.replaceFirst("_buildTextField('Country *', 'India')", "_buildTextField('Country *', 'India', controller: _countryController)");
  content = content.replaceFirst("_buildTextField('State *', 'e.g. Tamil Nadu')", "_buildTextField('State *', 'e.g. Tamil Nadu', controller: _stateController)");
  content = content.replaceFirst("_buildTextField('District *', 'e.g. Chennai')", "_buildTextField('District *', 'e.g. Chennai', controller: _districtController)");
  content = content.replaceFirst("_buildTextField('Taluk *', 'e.g. Guindy')", "_buildTextField('Taluk *', 'e.g. Guindy', controller: _talukController)");
  content = content.replaceFirst("_buildTextField('City / Village *', 'e.g. Chennai City')", "_buildTextField('City / Village *', 'e.g. Chennai City', controller: _cityVillageController)");
  content = content.replaceFirst("_buildTextField('Pincode *', 'e.g. 600020')", "_buildTextField('Pincode *', 'e.g. 600020', controller: _pincodeController)");

  // 6. Hook up TextFields in Step 3
  content = content.replaceFirst("_buildTextField('Opening Time *', '09:00 AM')", "_buildTextField('Opening Time *', '09:00 AM', controller: _openingTimeController)");
  content = content.replaceFirst("_buildTextField('Closing Time *', '09:00 PM')", "_buildTextField('Closing Time *', '09:00 PM', controller: _closingTimeController)");

  // 7. Update _buildTextFieldWithSub to accept controller
  content = content.replaceFirst("Widget _buildTextFieldWithSub(String label, String hint, String sub) {", "Widget _buildTextFieldWithSub(String label, String hint, String sub, {TextEditingController? controller}) {");
  content = content.replaceFirst("_buildTextField(label, hint),", "_buildTextField(label, hint, controller: controller),");

  // 8. Hook up Image Picker
  content = content.replaceFirst("_buildDottedUploadBox('Click to upload, or drag & drop store image here', 'Tip: You can also copy & paste (Ctrl + V) any image directly')", "GestureDetector(onTap: _pickImage, child: _storeLogoBase64 != null ? Container(height: 120, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: MemoryImage(base64Decode(_storeLogoBase64!.split(',')[1])), fit: BoxFit.cover))) : _buildDottedUploadBox('Click to upload, or drag & drop store image here', 'Tip: You can also copy & paste (Ctrl + V) any image directly'))");

  // 9. Change 'Submit' button in step 3
  content = content.replaceFirst("ElevatedButton(\n                onPressed: () {},", "ElevatedButton(\n                onPressed: _isLoading ? null : _submitForm,");
  content = content.replaceFirst("child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),", "child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),");

  file.writeAsStringSync(content);
  print('Updated store_create_screen.dart successfully!');
}
