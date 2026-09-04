import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/create_propagator_screen.dart');
  String content = file.readAsStringSync();

  // Rename class
  content = content.replaceAll('CreatePropagatorScreen', 'CreateSupplierScreen');
  content = content.replaceAll('_CreatePropagatorScreenState', '_CreateSupplierScreenState');
  
  // Replace texts
  content = content.replaceAll('Create Propagator Business', 'Create Supplier Business');
  content = content.replaceAll('register your propagator business', 'register your supplier business');

  File('lib/features/business/presentation/screens/create_supplier_screen.dart').writeAsStringSync(content);
  print('Done creating create_supplier_screen.dart');
}
