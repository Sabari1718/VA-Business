import 'dart:io';

void main() {
  final file = File('lib/features/store/data/repositories/store_repository.dart');
  String content = file.readAsStringSync();

  final deleteAndUpdateMethods = '''
  Future<void> deleteStore(String id) async {
    final token = await _getToken();
    final url = Uri.parse('\$baseUrl/store/\$id');
    print('DELETE STORE API CALLING: \$url');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
      body: jsonEncode({'userId': '2146610213'}),
    );
    
    print('DELETE STORE API STATUS: \${response.statusCode}');
    print('DELETE STORE API BODY: \${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete store. Status: \${response.statusCode}, Body: \${response.body}');
    }
  }

  Future<BusinessResponseModel> updateStore(String id, StoreModel store) async {
    final token = await _getToken();
    final url = Uri.parse('\$baseUrl/store/\$id');
    print('UPDATE STORE API CALLING: \$url');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer \$token',
      },
      body: jsonEncode(store.toJson()),
    );
    
    print('UPDATE STORE API STATUS: \${response.statusCode}');
    print('UPDATE STORE API BODY: \${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BusinessResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update store: \${response.body}');
    }
  }
''';

  content = content.replaceFirst(
    "  Future<List<StoreModel>> getStores() async {",
    deleteAndUpdateMethods + "\n  Future<List<StoreModel>> getStores() async {"
  );

  file.writeAsStringSync(content);
  print('Updated StoreRepository successfully!');
}
