class StoreModel {
  final String? id;
  final String? userId;
  final String storeName;
  final String branchManagementModel;
  final String customerCareName;
  final String customerCarePhone;
  final String altContactName;
  final String altPhone;
  final String country;
  final String state;
  final String district;
  final String taluk;
  final String cityVillage;
  final String pincode;
  final String openingTime;
  final String closingTime;
  final String workingDays;
  final String holidayNotes;
  final String paymentMethods;
  final String supportedLanguages;
  final String businessId;
  final String platformId;
  final String? shopType;
  final String? platformModule;
  final String status;
  final String storeLogo;
  final String? createdAt;
  final String? updatedAt;

  StoreModel({
    this.id,
    this.userId,
    required this.storeName,
    required this.branchManagementModel,
    required this.customerCareName,
    required this.customerCarePhone,
    required this.altContactName,
    required this.altPhone,
    required this.country,
    required this.state,
    required this.district,
    required this.taluk,
    required this.cityVillage,
    required this.pincode,
    required this.openingTime,
    required this.closingTime,
    required this.workingDays,
    required this.holidayNotes,
    required this.paymentMethods,
    required this.supportedLanguages,
    required this.businessId,
    required this.platformId,
    this.shopType,
    this.platformModule,
    required this.status,
    required this.storeLogo,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      storeName: json['storeName'] ?? '',
      branchManagementModel: json['branchManagementModel'] ?? '',
      customerCareName: json['customerCareName'] ?? '',
      customerCarePhone: json['customerCarePhone'] ?? '',
      altContactName: json['altContactName'] ?? '',
      altPhone: json['altPhone'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      taluk: json['taluk'] ?? '',
      cityVillage: json['cityVillage'] ?? '',
      pincode: json['pincode'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      workingDays: json['workingDays'] ?? '',
      holidayNotes: json['holidayNotes'] ?? '',
      paymentMethods: json['paymentMethods'] ?? '',
      supportedLanguages: json['supportedLanguages'] ?? '',
      businessId: json['businessId']?.toString() ?? '',
      platformId: json['platformId']?.toString() ?? '',
      shopType: json['shopType']?.toString(),
      platformModule: json['platformModule']?.toString(),
      status: json['status'] ?? '',
      storeLogo: json['storeLogo'] ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': userId ?? '2146610213',
      'storeName': storeName,
      'branchManagementModel': branchManagementModel,
      'customerCareName': customerCareName,
      'customerCarePhone': customerCarePhone,
      'altContactName': altContactName,
      'altPhone': altPhone,
      'country': country,
      'state': state,
      'district': district,
      'taluk': taluk,
      'cityVillage': cityVillage,
      'pincode': pincode,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'workingDays': workingDays,
      'holidayNotes': holidayNotes,
      'paymentMethods': paymentMethods,
      'supportedLanguages': supportedLanguages,
      'businessId': businessId,
      'platformId': platformId,
      if (shopType != null) 'shopType': shopType,
      if (platformModule != null) 'platformModule': platformModule,
      'status': status,
      'storeLogo': storeLogo,
      'image': storeLogo,
      'logoUrl': storeLogo,
    };
    return map;
  }
}
