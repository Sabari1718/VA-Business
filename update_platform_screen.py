import re
import os

filepath = r"lib\features\business\presentation\screens\platform_screen.dart"

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports
imports = """
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/platform_model.dart';
import '../providers/platform_providers.dart';
import 'package:va_business/core/utils/safe_base64_decode.dart';
"""
content = re.sub(r'(import \'package:image_picker/image_picker\.dart\';)', r'\1\n' + imports.strip(), content)

# Remove local model definitions (PlatformModel and ShopTypeModel)
content = re.sub(r'class PlatformModel \{.*?\n\}\n\nclass ShopTypeModel \{.*?\n\}\n\n', '', content, flags=re.DOTALL)

# 2. Change StatefulWidget to ConsumerStatefulWidget
content = content.replace('class PlatformScreen extends StatefulWidget', 'class PlatformScreen extends ConsumerStatefulWidget')
content = content.replace('State<PlatformScreen> createState() => _PlatformScreenState();', 'ConsumerState<PlatformScreen> createState() => _PlatformScreenState();')
content = content.replace('class _PlatformScreenState extends State<PlatformScreen>', 'class _PlatformScreenState extends ConsumerState<PlatformScreen>')

# 3. Handle save Platform
old_save_platform = """
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
"""
new_save_platform = """
                              final repo = ref.read(platformRepositoryProvider);
                              final data = {
                                'name': nameController.text.trim(),
                                'description': descController.text.trim(),
                                'image': localImagePath != null && !localImagePath!.startsWith('http') && !localImagePath!.startsWith('data') 
                                    ? 'data:image/jpeg;base64,${base64Encode(File(localImagePath!).readAsBytesSync())}' 
                                    : localImagePath,
                              };
                              // TODO: Implement update/create logic in repo and invalidate provider
                              repo.createPlatform(data).then((_) {
                                ref.invalidate(platformsProvider);
                                if (mounted) Navigator.pop(context);
                              });
"""
content = content.replace(old_save_platform, new_save_platform)

# 4. Handle save ShopType
old_save_shop_type = """
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
"""
new_save_shop_type = """
                              final repo = ref.read(platformRepositoryProvider);
                              final data = {
                                'name': nameController.text.trim(),
                                'description': descController.text.trim(),
                                'platformId': selectedPlatformId,
                                'image': localImagePath != null && !localImagePath!.startsWith('http') && !localImagePath!.startsWith('data') 
                                    ? 'data:image/jpeg;base64,${base64Encode(File(localImagePath!).readAsBytesSync())}' 
                                    : localImagePath,
                              };
                              repo.createShopType(data).then((_) {
                                ref.invalidate(shopTypesProvider);
                                if (mounted) Navigator.pop(context);
                              });
"""
content = content.replace(old_save_shop_type, new_save_shop_type)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated successfully")
