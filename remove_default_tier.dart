import 'dart:io';

void fixTierDefault(String path) {
  final file = File(path);
  if (!file.existsSync()) return;
  
  String content = file.readAsStringSync();
  
  // Change String _selectedTier = 'STANDARD'; to String? _selectedTier;
  content = content.replaceFirst("String _selectedTier = 'STANDARD';", "String? _selectedTier;");
  
  // Just in case it was 'STARTUP' or something else
  content = content.replaceFirst("String _selectedTier = 'STARTUP';", "String? _selectedTier;");
  
  file.writeAsStringSync(content);
}

void main() {
  fixTierDefault('lib/features/business/presentation/screens/create_propagator_screen.dart');
  fixTierDefault('lib/features/business/presentation/screens/create_partner_screen.dart');
  fixTierDefault('lib/features/business/presentation/screens/create_supplier_screen.dart');
  print('Removed default tier selection');
}
