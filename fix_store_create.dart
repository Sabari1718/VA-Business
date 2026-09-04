import 'dart:io';

void main() {
  final file = File('lib/features/store/presentation/screens/store_create_screen.dart');
  String content = file.readAsStringSync();

  // 1. Remove the first initState
  content = content.replaceFirst(RegExp(r'  @override\n  void initState\(\) \{\n    super\.initState\(\);\n    if \(widget\.store != null\) \{[\s\S]*?    \}\n  \}\n\n'), '');
  
  // 2. Update the second initState
  final newInitState = '''
  @override
  void initState() {
    super.initState();
    for (var day in _workingDays) {
      _weeklyOffNotesControllers[day] = TextEditingController(text: '\$day weekly off');
    }
    
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
''';
  content = content.replaceFirst(RegExp(r"  @override\n  void initState\(\) \{\n    super\.initState\(\);\n    for \(var day in _workingDays\) \{\n      _weeklyOffNotesControllers\[day\] = TextEditingController\(text: '\$day weekly off'\);\n    \}\n  \}"), newInitState);

  // 3. Update the submit form logic
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
    RegExp(r"      await ref\.read\(storeRepositoryProvider\)\.createStore\(payload\);\n      ref\.invalidate\(storesProvider\);\n      if \(mounted\) \{\n        ScaffoldMessenger\.of\(context\)\.showSnackBar\(const SnackBar\(content: Text\('Store created successfully!'\)\)\);\n        Navigator\.pop\(context\);\n      \}"),
    submitCode
  );

  file.writeAsStringSync(content);
  print('Fixed StoreCreateScreen successfully!');
}
