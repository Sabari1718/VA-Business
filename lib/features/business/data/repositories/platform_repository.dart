import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_response_model.dart';

class PlatformRepository {
  static const String baseApiUrl = 'https://business-setup.srivagroups.in/api';
  final String userId = '2146610213'; // Default userId used in this app

  // --- Platform API ---
  Future<BusinessResponseModel> getPlatforms() async {
    final url = Uri.parse('$baseApiUrl/platform?userId=$userId');
    print('GET PLATFORMS API CALLING: $url');
    final response = await http.get(url);
    
    print('GET PLATFORMS API STATUS: ${response.statusCode}');
    print('GET PLATFORMS API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load platforms');
    }
  }

  Future<BusinessResponseModel> createPlatform(Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/platform');
    print('CREATE PLATFORM API CALLING: $url WITH BODY: $data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('CREATE PLATFORM API STATUS: ${response.statusCode}');
    print('CREATE PLATFORM API BODY: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create platform');
    }
  }

  Future<BusinessResponseModel> updatePlatform(String id, Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/platform/$id');
    print('UPDATE PLATFORM API CALLING: $url WITH BODY: $data');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('UPDATE PLATFORM API STATUS: ${response.statusCode}');
    print('UPDATE PLATFORM API BODY: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update platform');
    }
  }
  
  Future<void> deletePlatform(String id) async {
    final url = Uri.parse('$baseApiUrl/platform/$id');
    print('DELETE PLATFORM API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );
    
    print('DELETE PLATFORM API STATUS: ${response.statusCode}');
    print('DELETE PLATFORM API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete platform');
    }
  }

  // --- Shop Type API ---
  Future<BusinessResponseModel> getShopTypes() async {
    final url = Uri.parse('$baseApiUrl/shop-type?userId=$userId');
    print('GET SHOP TYPES API CALLING: $url');
    final response = await http.get(url);
    
    print('GET SHOP TYPES API STATUS: ${response.statusCode}');
    print('GET SHOP TYPES API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load shop types');
    }
  }

  Future<BusinessResponseModel> createShopType(Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/shop-type');
    print('CREATE SHOP TYPE API CALLING: $url WITH BODY: $data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('CREATE SHOP TYPE API STATUS: ${response.statusCode}');
    print('CREATE SHOP TYPE API BODY: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create shop type');
    }
  }

  Future<BusinessResponseModel> updateShopType(String id, Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/shop-type/$id');
    print('UPDATE SHOP TYPE API CALLING: $url WITH BODY: $data');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('UPDATE SHOP TYPE API STATUS: ${response.statusCode}');
    print('UPDATE SHOP TYPE API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update shop type');
    }
  }

  
  Future<void> deleteShopType(String id) async {
    final url = Uri.parse('$baseApiUrl/shop-type/$id');
    print('DELETE SHOP TYPE API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );
    
    print('DELETE SHOP TYPE API STATUS: ${response.statusCode}');
    print('DELETE SHOP TYPE API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete shop type');
    }
  }

  // --- Platform Assign API ---
  Future<BusinessResponseModel> getPlatformAssignments() async {
    final url = Uri.parse('$baseApiUrl/platform-assign?userId=$userId');
    print('GET PLATFORM ASSIGNMENTS API CALLING: $url');
    final response = await http.get(url);
    
    print('GET PLATFORM ASSIGNMENTS API STATUS: ${response.statusCode}');
    print('GET PLATFORM ASSIGNMENTS API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load platform assignments');
    }
  }

  Future<BusinessResponseModel> assignPlatform(Map<String, dynamic> data) async {
    data['userId'] = userId;
    final url = Uri.parse('$baseApiUrl/platform-assign');
    print('CREATE PLATFORM ASSIGNMENT API CALLING: $url WITH BODY: $data');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('CREATE PLATFORM ASSIGNMENT API STATUS: ${response.statusCode}');
    print('CREATE PLATFORM ASSIGNMENT API BODY: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to assign platform');
    }
  }
  
  Future<void> deletePlatformAssignment(String id) async {
    final url = Uri.parse('$baseApiUrl/platform-assign/$id');
    print('DELETE PLATFORM ASSIGNMENT API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );
    
    print('DELETE PLATFORM ASSIGNMENT API STATUS: ${response.statusCode}');
    print('DELETE PLATFORM ASSIGNMENT API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete platform assignment');
    }
  }
}
