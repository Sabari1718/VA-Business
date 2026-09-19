class ShopPlatform {
  final String id;
  final String storeName;
  final String platformType; // 'Shop', 'Local Online', 'Online - Pan India', 'Export'
  final String storeType; // 'Retail Shop', 'Showroom', etc.
  final String businessName;
  final String branchModel;
  final String customerCareName;
  final String customerCarePhone;
  final String altContactName;
  final String altPhone;
  final String pincode;
  final String country;
  final String stateName;
  final String district;
  final String taluk;
  final String cityVillage;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final List<String> workingDays;
  final List<String> paymentMethods;
  final List<String> supportedLanguages;
  final String status;
  final DateTime createdAt;

  const ShopPlatform({
    required this.id,
    required this.storeName,
    required this.platformType,
    this.storeType = 'Retail Shop',
    required this.businessName,
    this.branchModel = 'Single Branch (Automatic Single Setup)',
    this.customerCareName = '',
    this.customerCarePhone = '',
    this.altContactName = '',
    this.altPhone = '',
    this.pincode = '600020',
    this.country = 'India',
    this.stateName = 'Tamil Nadu',
    this.district = 'Chennai',
    this.taluk = 'Guindy',
    this.cityVillage = 'Adyar',
    this.latitude = 13.0064,
    this.longitude = 80.2564,
    this.openingTime = '09:00 AM',
    this.closingTime = '09:00 PM',
    this.workingDays = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    this.paymentMethods = const ['Cash', 'UPI', 'Credit/Debit Card'],
    this.supportedLanguages = const ['English', 'Tamil', 'Hindi'],
    this.status = 'Active',
    required this.createdAt,
  });

  String get fullAddress {
    final parts = [cityVillage, taluk, district, stateName]
        .where((p) => p.isNotEmpty)
        .toList();
    final addr = parts.join(', ');
    return pincode.isNotEmpty ? '$addr - $pincode' : addr;
  }
}

