import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_create_screen.dart');
  String content = file.readAsStringSync();

  // 1. Add validation state variables
  final validationVars = '''
  bool _showStep1Errors = false;
  bool _showStep2Errors = false;
  bool _showStep3Errors = false;
  ''';
  content = content.replaceFirst('bool _isLoading = false;', 'bool _isLoading = false;\n$validationVars');

  // 2. Add Branch Management Model options
  content = content.replaceFirst(
    "['Single Branch (Automatic Single Setup)']",
    "['Single Branch (Automatic Single Setup)', 'Multiple Branch']"
  );

  // 3. Update _buildTextField signature and body to handle errorText
  content = content.replaceFirst(
    "Widget _buildTextField(String label, String hint, {TextEditingController? controller}) {",
    "Widget _buildTextField(String label, String hint, {TextEditingController? controller, String? errorText}) {"
  );
  content = content.replaceAll(
    "border: OutlineInputBorder(",
    "border: OutlineInputBorder("
  ); // Just to anchor
  
  // Replace the TextField with one that handles errorText
  final newTextField = '''
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
''';

  content = content.replaceFirst(RegExp(r'child: TextField\([\s\S]*?,\n          \),'), newTextField);

  // 4. Update _buildTextFieldWithSub signature
  content = content.replaceFirst(
    "Widget _buildTextFieldWithSub(String label, String hint, String sub, {TextEditingController? controller}) {",
    "Widget _buildTextFieldWithSub(String label, String hint, String sub, {TextEditingController? controller, String? errorText}) {"
  );
  content = content.replaceFirst(
    "_buildTextField(label, hint, controller: controller),",
    "_buildTextField(label, hint, controller: controller, errorText: errorText),"
  );
  
  // 5. Update _buildDropdownWithSub signature
  content = content.replaceFirst(
    "Widget _buildDropdownWithSub(String label, String hint, String sub, List<String> items, String? value, Function(String?) onChanged) {",
    "Widget _buildDropdownWithSub(String label, String hint, String sub, List<String> items, String? value, Function(String?) onChanged, {String? errorText}) {"
  );
  // Add errorText logic to dropdown
  content = content.replaceFirst(
    "border: Border.all(color: Colors.grey.shade200),",
    "border: Border.all(color: errorText != null ? Colors.red : Colors.grey.shade200),"
  );
  content = content.replaceFirst(
    "Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),",
    "if (errorText != null) Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.error_outline, size: 12, color: Colors.red), const SizedBox(width: 4), Text(errorText, style: GoogleFonts.poppins(fontSize: 10, color: Colors.red))])) else Text(sub, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black45)),"
  );


  // 6. Update Step 1 fields
  content = content.replaceFirst(
    "_buildTextFieldWithSub('Store Name / Store Title *', 'Enter store name', 'Enter official storefront or business trading title', controller: _storeNameController)",
    "_buildTextFieldWithSub('Store Name / Store Title *', 'Enter store name', 'Enter official storefront or business trading title', controller: _storeNameController, errorText: _showStep1Errors && _storeNameController.text.trim().isEmpty ? 'Store Name is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildDropdownWithSub('Branch Management Model *', 'Single Branch (Automatic Single Setup)', 'Select branch operation and management model', ['Single Branch (Automatic Single Setup)', 'Multiple Branch'], _selectedBranchModel, (val) => setState(() => _selectedBranchModel = val))",
    "_buildDropdownWithSub('Branch Management Model *', 'Single Branch (Automatic Single Setup)', 'Select branch operation and management model', ['Single Branch (Automatic Single Setup)', 'Multiple Branch'], _selectedBranchModel, (val) => setState(() => _selectedBranchModel = val), errorText: _showStep1Errors && _selectedBranchModel == null ? 'Branch Management Model is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextFieldWithSub('Customer Care Contact Name *', 'Enter customer care contact name', 'Enter customer care or support contact name', controller: _customerCareNameController)",
    "_buildTextFieldWithSub('Customer Care Contact Name *', 'Enter customer care contact name', 'Enter customer care or support contact name', controller: _customerCareNameController, errorText: _showStep1Errors && _customerCareNameController.text.trim().isEmpty ? 'Customer Care Contact Name is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextFieldWithSub('Customer Care Phone Number *', 'Enter customer care phone number', 'Enter customer care or support phone number', controller: _customerCarePhoneController)",
    "_buildTextFieldWithSub('Customer Care Phone Number *', 'Enter customer care phone number', 'Enter customer care or support phone number', controller: _customerCarePhoneController, errorText: _showStep1Errors && _customerCarePhoneController.text.trim().isEmpty ? 'Customer Care Phone Number is required.' : null)"
  );

  // 7. Update Step 2 fields
  content = content.replaceFirst(
    "_buildTextField('Country *', 'India', controller: _countryController)",
    "_buildTextField('Country *', 'India', controller: _countryController, errorText: _showStep2Errors && _countryController.text.trim().isEmpty ? 'Country is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextField('State *', 'e.g. Tamil Nadu', controller: _stateController)",
    "_buildTextField('State *', 'e.g. Tamil Nadu', controller: _stateController, errorText: _showStep2Errors && _stateController.text.trim().isEmpty ? 'State is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextField('District *', 'e.g. Chennai', controller: _districtController)",
    "_buildTextField('District *', 'e.g. Chennai', controller: _districtController, errorText: _showStep2Errors && _districtController.text.trim().isEmpty ? 'District is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextField('Taluk *', 'e.g. Guindy', controller: _talukController)",
    "_buildTextField('Taluk *', 'e.g. Guindy', controller: _talukController, errorText: _showStep2Errors && _talukController.text.trim().isEmpty ? 'Taluk is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextField('City / Village *', 'e.g. Chennai City', controller: _cityVillageController)",
    "_buildTextField('City / Village *', 'e.g. Chennai City', controller: _cityVillageController, errorText: _showStep2Errors && _cityVillageController.text.trim().isEmpty ? 'City / Village is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextField('Pincode *', 'e.g. 600020', controller: _pincodeController)",
    "_buildTextField('Pincode *', 'e.g. 600020', controller: _pincodeController, errorText: _showStep2Errors && _pincodeController.text.trim().isEmpty ? 'Pincode is required.' : null)"
  );

  // 8. Update Step 3 fields
  content = content.replaceFirst(
    "_buildTextField('Opening Time *', '09:00 AM', controller: _openingTimeController)",
    "_buildTextField('Opening Time *', '09:00 AM', controller: _openingTimeController, errorText: _showStep3Errors && _openingTimeController.text.trim().isEmpty ? 'Opening Time is required.' : null)"
  );
  content = content.replaceFirst(
    "_buildTextField('Closing Time *', '09:00 PM', controller: _closingTimeController)",
    "_buildTextField('Closing Time *', '09:00 PM', controller: _closingTimeController, errorText: _showStep3Errors && _closingTimeController.text.trim().isEmpty ? 'Closing Time is required.' : null)"
  );

  // 9. Update _nextStep
  final newNextStep = '''
  void _nextStep() {
    setState(() {
      if (_currentStep == 1) {
        _showStep1Errors = true;
        if (_storeNameController.text.trim().isNotEmpty &&
            _selectedBranchModel != null &&
            _customerCareNameController.text.trim().isNotEmpty &&
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
''';
  content = content.replaceFirst(
    'void _nextStep() {\n    if (_currentStep < 3) {\n      setState(() => _currentStep++);\n    }\n  }',
    newNextStep
  );

  // 10. Update _submitForm validation
  final newSubmitValidation = '''
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
''';
  content = content.replaceFirst(
    "Future<void> _submitForm() async {\n    if (_storeNameController.text.isEmpty) {\n      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Store Name')));\n      return;\n    }",
    newSubmitValidation
  );


  file.writeAsStringSync(content);
  print('Validation and UI updates applied successfully!');
}
