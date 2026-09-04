import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_response_model.dart';

class BusinessRepository {
  static const String baseUrl = 'https://business-setup.srivagroups.in/api/business';

  Future<BusinessResponseModel> getPropagatorBusinesses(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/propagator?userId=$userId'));
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load propagator businesses');
    }
  }

  Future<BusinessResponseModel> getUserBusinesses(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user businesses');
    }
  }

  Future<BusinessResponseModel> getPartnerBusinesses(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/partner-business?userId=$userId'));
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load partner businesses');
    }
  }

  Future<BusinessResponseModel> getSupplierBusinesses(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/supplier-business?userId=$userId'));
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load supplier businesses');
    }
  }

  // --- Propagator Business API ---
  Future<BusinessResponseModel> createPropagatorBusiness(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/propagator'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('CREATE PROPAGATOR API STATUS: ${response.statusCode}');
    print('CREATE PROPAGATOR API BODY: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create propagator business: ${response.body}');
    }
  }

  Future<void> deletePropagatorBusiness(String id) async {
    final url = Uri.parse('$baseUrl/propagator/$id');
    print('DELETE API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': '2146610213'}),
    );
    
    print('DELETE API STATUS: ${response.statusCode}');
    print('DELETE API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete propagator business. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<BusinessResponseModel> updatePropagatorBusiness(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/propagator/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('UPDATE PROPAGATOR API STATUS: ${response.statusCode}');
    print('UPDATE PROPAGATOR API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update propagator business: ${response.body}');
    }
  }

  // --- Partner Business API ---
  Future<void> deletePartnerBusiness(String id) async {
    final url = Uri.parse('$baseUrl/partner-business/$id');
    print('DELETE PARTNER API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': '2146610213'}),
    );
    
    print('DELETE PARTNER API STATUS: ${response.statusCode}');
    print('DELETE PARTNER API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete partner business. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<BusinessResponseModel> updatePartnerBusiness(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/partner-business/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('UPDATE PARTNER API STATUS: ${response.statusCode}');
    print('UPDATE PARTNER API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update partner business: ${response.body}');
    }
  }

  // --- Supplier Business API ---
  Future<void> deleteSupplierBusiness(String id) async {
    final url = Uri.parse('$baseUrl/supplier-business/$id');
    print('DELETE SUPPLIER API CALLING: $url');
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': '2146610213'}),
    );
    
    print('DELETE SUPPLIER API STATUS: ${response.statusCode}');
    print('DELETE SUPPLIER API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete supplier business. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<BusinessResponseModel> updateSupplierBusiness(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/supplier-business/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('UPDATE SUPPLIER API STATUS: ${response.statusCode}');
    print('UPDATE SUPPLIER API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update supplier business: ${response.body}');
    }
  }

  // --- Business Type API ---
  static const String baseApiUrl = 'https://business-setup.srivagroups.in/api';

  Future<BusinessResponseModel> getBusinessTypes(String userId) async {
    final response = await http.get(Uri.parse('$baseApiUrl/business-type?userId=$userId'));
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load business types');
    }
  }

  Future<BusinessResponseModel> createBusinessType(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseApiUrl/business-type'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('CREATE BUSINESS TYPE API STATUS: ${response.statusCode}');
    print('CREATE BUSINESS TYPE API BODY: ${response.body}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create business type: ${response.body}');
    }
  }

  Future<BusinessResponseModel> updateBusinessType(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseApiUrl/business-type/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('UPDATE BUSINESS TYPE API STATUS: ${response.statusCode}');
    print('UPDATE BUSINESS TYPE API BODY: ${response.body}');
    
    if (response.statusCode == 200) {
      return BusinessResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update business type: ${response.body}');
    }
  }

  Future<void> deleteBusinessType(String id) async {
    final url = Uri.parse('$baseApiUrl/business-type/$id');
    print('DELETE BUSINESS TYPE API CALLING: $url');
    final response = await http.delete(url);
    
    print('DELETE BUSINESS TYPE API STATUS: ${response.statusCode}');
    print('DELETE BUSINESS TYPE API BODY: ${response.body}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete business type. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
