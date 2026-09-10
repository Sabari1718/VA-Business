class CategoryModel {
  final int id;
  final String name;
  final List<CategoryModel>? secondaryCategories;
  final String? parentName;

  CategoryModel({
    required this.id,
    required this.name,
    this.secondaryCategories,
    this.parentName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, {String? parentName}) {
    List<CategoryModel>? secondaryCats;
    final currentName = json['name'] ?? '';
    if (json['secondaryCategories'] != null && json['secondaryCategories'] is List) {
      secondaryCats = (json['secondaryCategories'] as List)
          .map((e) => CategoryModel.fromJson(e, parentName: currentName))
          .toList();
    }

    return CategoryModel(
      id: json['id'] ?? 0,
      name: currentName,
      secondaryCategories: secondaryCats,
      parentName: parentName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CategoryModel &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class CategoryResponseModel {
  final String result;
  final int code;
  final String message;
  final List<CategoryModel> data;

  CategoryResponseModel({
    required this.result,
    required this.code,
    required this.message,
    required this.data,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    List<CategoryModel> parsedData = [];
    if (json['data'] != null && json['data'] is List) {
      parsedData = (json['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    }
    
    return CategoryResponseModel(
      result: json['result'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: parsedData,
    );
  }
}
