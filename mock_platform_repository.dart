import 'dart:io';

void main() async {
  final fileContent = r'''
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_response_model.dart';

class PlatformRepository {
  static const String baseApiUrl = 'https://business-setup.srivagroups.in/api';
  final String userId = '2146610213';

  // Helper for mock platforms
  final List<Map<String, dynamic>> _mockPlatforms = [
    {"id": "p1", "name": "Online Delivery", "description": "", "platformLogo": null},
    {"id": "p2", "name": "aa", "description": "", "platformLogo": null},
    {"id": "p3", "name": "BK", "description": "", "platformLogo": null},
    {"id": "p4", "name": "ONLINE", "description": "", "platformLogo": null},
    {"id": "p5", "name": "Local Shop", "description": "", "platformLogo": null},
    {"id": "p6", "name": "Local & Online", "description": "", "platformLogo": null},
    {"id": "p7", "name": "Shop", "description": "", "platformLogo": null},
    {"id": "p8", "name": "Export", "description": "", "platformLogo": null},
    {"id": "p9", "name": "Oline", "description": "", "platformLogo": null},
    {"id": "p10", "name": "Import", "description": "", "platformLogo": null},
    {"id": "p11", "name": "Local", "description": "", "platformLogo": null},
    {"id": "p12", "name": "wwq", "description": "", "platformLogo": null},
    {"id": "p13", "name": "KINGSPIN", "description": "", "platformLogo": null},
  ];

  final List<Map<String, dynamic>> _mockShopTypes = [
    {"id": "s1", "name": "Wholesale", "description": "", "platformId": "p9"},
    {"id": "s2", "name": "Distributor", "description": "", "platformId": "p9"},
    {"id": "s3", "name": "Online", "description": "", "platformId": "p9"},
    {"id": "s4", "name": "Retail", "description": "", "platformId": "p9"},
    {"id": "s5", "name": "Retail", "description": "", "platformId": "p1"},
    {"id": "s6", "name": "Wholesale", "description": "", "platformId": "p1"},
    {"id": "s7", "name": "AA", "description": "", "platformId": "p2"},
    {"id": "s8", "name": "bk", "description": "", "platformId": "p4"},
  ];

  Future<BusinessResponseModel> getPlatforms() async {
    // Returning Mock Data matching the user's web screenshot
    return BusinessResponseModel.fromJson({
      "result": "Success",
      "code": 200,
      "count": _mockPlatforms.length,
      "data": _mockPlatforms,
    });
  }

  Future<BusinessResponseModel> getShopTypes() async {
    // Returning Mock Data matching the user's web screenshot
    return BusinessResponseModel.fromJson({
      "result": "Success",
      "code": 200,
      "count": _mockShopTypes.length,
      "data": _mockShopTypes,
    });
  }

  // Stubs for other methods to avoid build errors
  Future<BusinessResponseModel> createPlatform(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
  Future<BusinessResponseModel> updatePlatform(String id, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
  Future<void> deletePlatform(String id) async {
    throw UnimplementedError();
  }
  Future<BusinessResponseModel> createShopType(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
  Future<BusinessResponseModel> updateShopType(String id, Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
  Future<void> deleteShopType(String id) async {
    throw UnimplementedError();
  }
  Future<BusinessResponseModel> getPlatformAssignments() async {
    return BusinessResponseModel.fromJson({"result": "Success", "code": 200, "count": 0, "data": []});
  }
  Future<BusinessResponseModel> assignPlatform(Map<String, dynamic> data) async {
    throw UnimplementedError();
  }
  Future<void> deletePlatformAssignment(String id) async {
    throw UnimplementedError();
  }
}
''';
  final file = File('lib/features/business/data/repositories/platform_repository.dart');
  await file.writeAsString(fileContent);
  print('Successfully updated platform_repository.dart with mock data!');
}
