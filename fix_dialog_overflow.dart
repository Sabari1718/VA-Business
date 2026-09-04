import 'dart:io';

void main() {
  final file = File('lib/features/business/presentation/screens/platform_screen.dart');
  String content = file.readAsStringSync();
  
  // Find and replace the Row containing Cancel and Save buttons for Platform Dialog
  String platformRowStr = '''                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),''';
                            
  String platformWrapStr = '''                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),''';
                            
  content = content.replaceFirst(platformRowStr, platformWrapStr);
  
  // Find and replace the Row containing Cancel and Save buttons for Shop Type Dialog
  // It's literally the exact same code, so replaceFirst should work again on the second instance, 
  // or we can just replaceAll if they are identical. Let's just do replaceAll.
  
  content = content.replaceAll(platformRowStr, platformWrapStr);
  
  file.writeAsStringSync(content);
  print('Fixed overflow by converting button Rows to Wraps!');
}
