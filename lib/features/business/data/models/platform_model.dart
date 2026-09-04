class PlatformModel {
  final String id;
  String name;
  String description;
  String? image; 

  PlatformModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      id: json['id']?.toString() ?? '',
      name: json['platformName'] ?? json['name'] ?? '',
      description: json['integrationDescription'] ?? json['description'] ?? '',
      image: json['platformLogo'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platformName': name,
      'integrationDescription': description,
      'platformLogo': image,
    };
  }
}

class ShopTypeModel {
  final String id;
  String name;
  String description;
  String platformId;
  String? image; // Changed from imagePath to image

  ShopTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.platformId,
    this.image,
  });

  factory ShopTypeModel.fromJson(Map<String, dynamic> json) {
    return ShopTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['shopTypeName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      platformId: json['platform_id']?.toString() ?? json['platformId']?.toString() ?? '',
      image: json['shopTypeLogo'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopTypeName': name,
      'description': description,
      'platformId': platformId,
      'shopTypeLogo': image,
      'categoryLabel': 'Custom Business Model',
    };
  }
}

class PlatformAssignModel {
  final String id;
  String platformId;
  String shopTypeId;
  String? platformName;
  String? shopTypeName;

  PlatformAssignModel({
    required this.id,
    required this.platformId,
    required this.shopTypeId,
    this.platformName,
    this.shopTypeName,
  });

  factory PlatformAssignModel.fromJson(Map<String, dynamic> json) {
    return PlatformAssignModel(
      id: json['id']?.toString() ?? '',
      platformId: json['platform_id']?.toString() ?? json['platformId']?.toString() ?? '',
      shopTypeId: json['shop_type_id']?.toString() ?? json['shopTypeId']?.toString() ?? '',
      platformName: json['platform_name']?.toString() ?? json['platformName']?.toString(),
      shopTypeName: json['shop_type_name']?.toString() ?? json['shopTypeName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platformId': platformId,
      'shopTypeId': shopTypeId,
      if (platformName != null) 'platform_name': platformName,
      if (shopTypeName != null) 'shop_type_name': shopTypeName,
    };
  }
}
