import 'dart:io';

void main() {
  final filepath = 'lib/features/business/presentation/screens/platform_screen.dart';
  final file = File(filepath);
  var content = file.readAsStringSync();

  // 1. Remove final lists
  content = content.replaceAll('final List<PlatformModel> _platforms = [];', '');
  content = content.replaceAll('final List<ShopTypeModel> _shopTypes = [];', '');

  // 2. Add safe delete logic to _buildPlatformCard calls
  // Wait, I will just write Riverpod when() wrappers around the Wraps.
  
  // Platform Step
  final oldPlatformGrid = '''
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ..._platforms.map((platform) => _buildPlatformCard(platform, onEdit: () => _showPlatformDialog(platform: platform), onDelete: () => setState(() => _platforms.remove(platform)))),
            _buildAddCard(
              title: 'Add Custom Platform',
              subtitle: 'Connect proprietary database, custom REST webhook, or legacy ERP system.',
              btnLabel: '+ Add Custom Platform',
              onTap: () => _showPlatformDialog(),
            ),
          ],
        ),
''';
  final newPlatformGrid = '''
        ref.watch(platformsProvider).when(
          data: (data) {
            final platforms = data.data.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>)).toList();
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...platforms.map((platform) => _buildPlatformCard(
                  platform, 
                  onEdit: () => _showPlatformDialog(platform: platform), 
                  onDelete: () {
                    ref.read(platformRepositoryProvider).deletePlatform(platform.id).then((_) {
                      ref.invalidate(platformsProvider);
                    });
                  }
                )),
                _buildAddCard(
                  title: 'Add Custom Platform',
                  subtitle: 'Connect proprietary database, custom REST webhook, or legacy ERP system.',
                  btnLabel: '+ Add Custom Platform',
                  onTap: () => _showPlatformDialog(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: \$e')),
        ),
''';
  content = content.replaceFirst(oldPlatformGrid, newPlatformGrid);

  // Shop Type Step
  final oldShopTypeGrid = '''
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ..._shopTypes.map((st) => _buildPlatformCard(
              PlatformModel(id: st.id, name: st.name, description: st.description, imagePath: st.imagePath),
              onEdit: () => _showShopTypeDialog(shopType: st),
              onDelete: () => setState(() => _shopTypes.remove(st)),
            )),
            _buildAddCard(
              title: 'Add Custom Shop Type',
              subtitle: 'Create custom business model, dynamic option sets, or store configuration.',
              btnLabel: '+ Add Custom Shop Type',
              onTap: () => _showShopTypeDialog(),
            ),
          ],
        ),
''';
  final newShopTypeGrid = '''
        ref.watch(shopTypesProvider).when(
          data: (data) {
            final shopTypes = data.data.map((e) => ShopTypeModel.fromJson(e as Map<String, dynamic>)).toList();
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...shopTypes.map((st) => _buildPlatformCard(
                  PlatformModel(id: st.id, name: st.name, description: st.description, image: st.image),
                  onEdit: () => _showShopTypeDialog(shopType: st),
                  onDelete: () {
                    ref.read(platformRepositoryProvider).deleteShopType(st.id).then((_) {
                      ref.invalidate(shopTypesProvider);
                    });
                  }
                )),
                _buildAddCard(
                  title: 'Add Custom Shop Type',
                  subtitle: 'Create custom business model, dynamic option sets, or store configuration.',
                  btnLabel: '+ Add Custom Shop Type',
                  onTap: () => _showShopTypeDialog(),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: \$e')),
        ),
''';
  content = content.replaceFirst(oldShopTypeGrid, newShopTypeGrid);

  // Update List Step placeholder
  final oldListStep = '''
  Widget _buildListStep() {
    return Container(
''';
  final newListStep = '''
  Widget _buildListStep() {
    return ref.watch(platformAssignmentsProvider).when(
      data: (data) {
        final assignments = data.data.map((e) => PlatformAssignModel.fromJson(e as Map<String, dynamic>)).toList();
        if (assignments.isEmpty) {
          return Container(
''';
  content = content.replaceFirst(oldListStep, newListStep);

  // Finish List Step
  final oldListStepEnd = '''
      ),
    );
  }

  Widget _buildStepIndicator(
''';
  final newListStepEnd = '''
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return ListTile(
              title: Text('Platform ID: \${assignment.platformId}'),
              subtitle: Text('Shop Type ID: \${assignment.shopTypeId}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPath: () {},
                onPressed: () {
                  ref.read(platformRepositoryProvider).deletePlatformAssignment(assignment.id).then((_) {
                    ref.invalidate(platformAssignmentsProvider);
                  });
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: \$e')),
    );
  }

  Widget _buildStepIndicator(
''';
  content = content.replaceFirst(oldListStepEnd, newListStepEnd);

  // Update Dropdown in ShopType Dialog to use platformsProvider!
  // Wait, there's `..._platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),`
  // We need to fetch platforms inside the dialog or use ref.watch beforehand.
  // Actually, since it's a dialog builder, we can use Consumer.
  final oldDropdown = '''
                            items: [
                              const DropdownMenuItem(value: '', child: Text('-- Assign Later in Step 3 --')),
                              ..._platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                            ],
''';
  final newDropdown = '''
                            items: [
                              const DropdownMenuItem(value: '', child: Text('-- Assign Later in Step 3 --')),
                              ...ref.watch(platformsProvider).maybeWhen(
                                data: (data) {
                                  final platforms = data.data.map((e) => PlatformModel.fromJson(e as Map<String, dynamic>)).toList();
                                  return platforms.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)));
                                },
                                orElse: () => [],
                              ),
                            ],
''';
  content = content.replaceFirst(oldDropdown, newDropdown);

  file.writeAsStringSync(content);
  print('Updated 2 successfully');
}
