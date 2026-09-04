import 'dart:io';

void main() {
  final filepath = 'lib/features/business/presentation/screens/platform_screen.dart';
  final file = File(filepath);
  var content = file.readAsStringSync();

  // 1. Imports
  final imports = '''
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/platform_model.dart';
import '../providers/platform_providers.dart';
import 'package:va_business/core/utils/safe_base64_decode.dart';
''';
  content = content.replaceFirst("import 'package:image_picker/image_picker.dart';", "import 'package:image_picker/image_picker.dart';\n$imports");

  // Remove local models (regex)
  content = content.replaceAll(RegExp(r'class PlatformModel \{.*?\n\}\n\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'class ShopTypeModel \{.*?\n\}\n\n', dotAll: true), '');

  // 2. Change StatefulWidget to ConsumerStatefulWidget
  content = content.replaceAll('class PlatformScreen extends StatefulWidget', 'class PlatformScreen extends ConsumerStatefulWidget');
  content = content.replaceAll('State<PlatformScreen> createState() => _PlatformScreenState();', 'ConsumerState<PlatformScreen> createState() => _PlatformScreenState();');
  content = content.replaceAll('class _PlatformScreenState extends State<PlatformScreen>', 'class _PlatformScreenState extends ConsumerState<PlatformScreen>');

  // 3. Handle save Platform
  final old_save_platform = '''
                              setState(() {
                                if (isEditing) {
                                  platform.name = nameController.text.trim();
                                  platform.description = descController.text.trim();
                                  platform.imagePath = localImagePath;
                                } else {
                                  _platforms.add(PlatformModel(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: nameController.text.trim(),
                                    description: descController.text.trim(),
                                    imagePath: localImagePath,
                                  ));
                                }
                              });
                              Navigator.pop(context);
''';
  final new_save_platform = '''
                              final repo = ref.read(platformRepositoryProvider);
                              final data = {
                                'name': nameController.text.trim(),
                                'description': descController.text.trim(),
                                'image': localImagePath != null && !localImagePath!.startsWith('http') && !localImagePath!.startsWith('data') 
                                    ? 'data:image/jpeg;base64,\${base64Encode(File(localImagePath!).readAsBytesSync())}' 
                                    : localImagePath,
                              };
                              repo.createPlatform(data).then((_) {
                                ref.invalidate(platformsProvider);
                                if (mounted) Navigator.pop(context);
                              });
''';
  content = content.replaceAll(old_save_platform, new_save_platform);

  // 4. Handle save ShopType
  final old_save_shop_type = '''
                              setState(() {
                                if (isEditing) {
                                  shopType.name = nameController.text.trim();
                                  shopType.description = descController.text.trim();
                                  shopType.platformId = selectedPlatformId;
                                  shopType.imagePath = localImagePath;
                                } else {
                                  _shopTypes.add(ShopTypeModel(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: nameController.text.trim(),
                                    description: descController.text.trim(),
                                    platformId: selectedPlatformId,
                                    imagePath: localImagePath,
                                  ));
                                }
                              });
                              Navigator.pop(context);
''';
  final new_save_shop_type = '''
                              final repo = ref.read(platformRepositoryProvider);
                              final data = {
                                'name': nameController.text.trim(),
                                'description': descController.text.trim(),
                                'platformId': selectedPlatformId,
                                'image': localImagePath != null && !localImagePath!.startsWith('http') && !localImagePath!.startsWith('data') 
                                    ? 'data:image/jpeg;base64,\${base64Encode(File(localImagePath!).readAsBytesSync())}' 
                                    : localImagePath,
                              };
                              repo.createShopType(data).then((_) {
                                ref.invalidate(shopTypesProvider);
                                if (mounted) Navigator.pop(context);
                              });
''';
  content = content.replaceAll(old_save_shop_type, new_save_shop_type);

  file.writeAsStringSync(content);
  print('Updated successfully');
}
