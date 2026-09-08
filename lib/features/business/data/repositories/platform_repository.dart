import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_response_model.dart';

class PlatformRepository {
  static const String baseApiUrl = 'https://business-setup.srivagroups.in/api';
  final String userId = '2146610213';

  // --- Platform API --- Fetch ALL platforms (no userId filter)
  Future<BusinessResponseModel> getPlatforms() async {
    final url = Uri.parse('$baseApiUrl/platform');
    print('GET PLATFORMS API CALLING: $url');
    final response = await http.get(url);
    
    print('GET PLATFORMS API STATUS: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load platforms');
    }
  }

  Future<BusinessResponseModel> createPlatform(Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/platform');
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create platform');
    }
  }

  Future<BusinessResponseModel> updatePlatform(String id, Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/platform/$id');
    final response = await http.put(url, headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update platform');
    }
  }
  
  Future<void> deletePlatform(String id) async {
    final url = Uri.parse('$baseApiUrl/platform/$id');
    final response = await http.delete(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': userId}));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete platform');
    }
  }

  // --- Shop Type API --- Fetch ALL shop types by platform_id via platform-assign
  Future<BusinessResponseModel> getShopTypesByPlatformId(String platformId) async {
    final url = Uri.parse('$baseApiUrl/platform-assign?platform_id=$platformId');
    print('GET SHOP TYPES FOR PLATFORM $platformId: $url');
    final response = await http.get(url);
    
    print('GET SHOP TYPES STATUS: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load shop types for platform $platformId');
    }
  }

  /// Get ALL platform assignments (used to derive unique platforms/shop types)
  Future<BusinessResponseModel> getPlatformAssignments() async {
    final url = Uri.parse('$baseApiUrl/platform-assign');
    print('GET PLATFORM ASSIGNMENTS API CALLING: $url');
    final response = await http.get(url);
    
    print('GET PLATFORM ASSIGNMENTS API STATUS: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load platform assignments');
    }
  }

  Future<BusinessResponseModel> getShopTypes() async {
    // Fallback: get all shop types from all platform assignments
    return getPlatformAssignments();
  }

  Future<BusinessResponseModel> createShopType(Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/shop-type');
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create shop type');
    }
  }

  Future<BusinessResponseModel> updateShopType(String id, Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/shop-type/$id');
    final response = await http.put(url, headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update shop type');
    }
  }
  
  Future<void> deleteShopType(String id) async {
    final url = Uri.parse('$baseApiUrl/shop-type/$id');
    final response = await http.delete(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': userId}));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete shop type');
    }
  }

  Future<BusinessResponseModel> assignPlatform(Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/platform-assign');
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to assign platform');
    }
  }
  
  Future<void> deletePlatformAssignment(String id) async {
    final url = Uri.parse('$baseApiUrl/platform-assign/$id');
    final response = await http.delete(url, headers: {'Content-Type': 'application/json'}, body: json.encode({'userId': userId}));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete platform assignment');
    }
  }
}
