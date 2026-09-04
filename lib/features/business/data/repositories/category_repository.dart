import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryRepository {
  static const String baseUrl = 'https://business-setup.srivagroups.in/api/categories';

  Future<CategoryResponseModel> getSectorTitles() async {
    final response = await http.get(Uri.parse('$baseUrl/sector-titles'));
    if (response.statusCode == 200) {
      return CategoryResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load sector titles');
    }
  }

  Future<CategoryResponseModel> getSectors(int sectorTitleId) async {
    final response = await http.get(Uri.parse('$baseUrl/sectors/$sectorTitleId'));
    if (response.statusCode == 200) {
      return CategoryResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load sectors');
    }
  }

  Future<CategoryResponseModel> getSubSectors(int sectorId) async {
    final response = await http.get(Uri.parse('$baseUrl/sub-sectors/$sectorId'));
    if (response.statusCode == 200) {
      return CategoryResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load sub sectors');
    }
  }

  Future<CategoryResponseModel> getPrimaryCategories(int subSectorId) async {
    final response = await http.get(Uri.parse('$baseUrl/primary/$subSectorId'));
    if (response.statusCode == 200) {
      return CategoryResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load primary categories');
    }
  }

  Future<CategoryResponseModel> getSecondaryCategories(int primaryCategoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/secondary/$primaryCategoryId'));
    if (response.statusCode == 200) {
      return CategoryResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load secondary categories');
    }
  }
}
