import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_create_screen.dart');
  String content = file.readAsStringSync();

  // 1. Update Constructor
  content = content.replaceFirst(
    'class StoreCreateScreen extends ConsumerStatefulWidget {\n  const StoreCreateScreen({super.key});',
    'class StoreCreateScreen extends ConsumerStatefulWidget {\n  final StoreModel? store;\n  const StoreCreateScreen({super.key, this.store});'
  );

  // 2. Add initState to pre-fill fields
  final initStateCode = '''
  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      final s = widget.store!;
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
      
      // Try to parse working days
      if (s.workingDays.isNotEmpty) {
        _selectedWorkingDays = s.workingDays.split(', ').toList();
      }
      
      // Try to parse payment methods
      if (s.paymentMethods.isNotEmpty) {
        _paymentMethods = s.paymentMethods.split(', ').toList();
      }
      
      // Try to parse languages
      if (s.supportedLanguages.isNotEmpty) {
        _languages = s.supportedLanguages.split(', ').toList();
      }
    }
  }

''';

  content = content.replaceFirst(
    '  Future<void> _pickImage() async {',
    initStateCode + '  Future<void> _pickImage() async {'
  );

  // 3. Update Title to change dynamically
  content = content.replaceFirst(
    "'Create Store Setup'",
    "widget.store != null ? 'Edit Store Setup (#' + widget.store!.id.toString() + ')' : 'Create Store Setup'"
  );

  // 4. Update Submit Form Logic
  final submitCode = '''
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
''';

  content = content.replaceFirst(
    RegExp(r'final repository = ref\.read\(storeRepositoryProvider\);[\s\S]*?Navigator\.pop\(context\);\n      }'),
    submitCode
  );

  file.writeAsStringSync(content);
  print('Updated StoreCreateScreen successfully!');
}
