import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/store_model.dart';
import '../../../business/data/models/business_response_model.dart';

class StoreRepository {
  static const String baseUrl = 'https://business-setup.srivagroups.in/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<BusinessResponseModel> createStore(StoreModel store) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/store'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(store.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('API Response: ${response.body}');
      return BusinessResponseModel.fromJson(jsonDecode(response.body));
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to create store: ${response.body}');
    }
  }

  Future<String> deleteStore(String id) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/store/$id');
    print('DELETE STORE API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'userId': '2146610213'}),
    );
    
    print('DELETE STORE API STATUS: ${response.statusCode}');
    print('DELETE STORE API BODY: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Store deleted successfully!';
      } catch (e) {
        return 'Store deleted successfully!';
      }
    } else {
      String errorMessage = 'Failed to delete store.';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null) {
          errorMessage = data['message'];
        }
      } catch (e) {
        errorMessage = 'Failed to delete store. Status: ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  Future<BusinessResponseModel> updateStore(String id, StoreModel store) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/store/$id');
    print('UPDATE STORE API CALLING: $url');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(store.toJson()),
    );
    
    print('UPDATE STORE API STATUS: ${response.statusCode}');
    print('UPDATE STORE API BODY: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BusinessResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update store: ${response.body}');
    }
  }

  Future<List<StoreModel>> getStores() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/store'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final responseModel = BusinessResponseModel.fromJson(jsonResponse);
      
      final allStores = responseModel.data.map((json) => StoreModel.fromJson(json)).toList();
      // Filter locally to ensure we only show the current user's stores
      return allStores.where((store) => store.userId == '2146610213').toList();
    } else {
      throw Exception('Failed to fetch stores: ${response.body}');
    }
  }
}
