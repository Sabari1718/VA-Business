enum EntityType {
  proprietorship('Proprietorship'),
  partnership('Partnership'),
  pvtLtd('Private Limited (Pvt Ltd)'),
  opc('One Person Company (OPC)'),
  llp('Limited Liability Partnership (LLP)');

  final String label;
  const EntityType(this.label);
}

enum GstPreference {
  required('Regular GST'),
  composition('Composition Scheme'),
  notApplicable('Not Required / Below Threshold');

  final String label;
  const GstPreference(this.label);
}

class BusinessProfile {
  final String id;
  final String brandName;
  final String tradeName;
  final String businessName;
  final String businessType;
  final EntityType entityType;
  final GstPreference gstPreference;
  final String registrationStatus;
  final String tier;
  final String establishmentYear;
  final String employeeCount;
  final String turnoverRange;
  final String phone;
  final String email;
  final String website;
  final String pincode;
  final String city;
  final String district;
  final String stateName;
  final String country;
  final String fullAddress;
  final String latitude;
  final String longitude;
  final String gstNumber;
  final String udyamNumber;
  final String cinNumber;
  final String accountHolderName;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String ifscCode;
  final String accountType;
  final String accountStatus;
  final bool isGstVerified;
  final bool isUdyamVerified;
  final DateTime createdAt;

  const BusinessProfile({
    required this.id,
    required this.brandName,
    required this.tradeName,
    String? businessName,
    this.businessType = 'Retail & Wholesale',
    required this.entityType,
    required this.gstPreference,
    this.registrationStatus = 'Active',
    this.tier = 'Startup',
    this.establishmentYear = '2024',
    this.employeeCount = '1-10 Employees',
    this.turnoverRange = 'Up to 20 Lakhs',
    this.phone = '+91 9965437236',
    this.email = 'contact@sabari.com',
    this.website = 'https://sabari.com',
    this.pincode = '600001',
    this.city = 'Chennai',
    this.district = 'Chennai',
    this.stateName = 'Tamil Nadu',
    this.country = 'India',
    this.fullAddress = 'No 12, Main Road, Industrial Estate, Adyar',
    this.latitude = '13.0827',
    this.longitude = '80.2707',
    this.gstNumber = '33AAAAA0000A1Z5',
    this.udyamNumber = 'UDYAM-TN-01-0012345',
    this.cinNumber = '',
    this.accountHolderName = 'sabari',
    this.bankName = 'HDFC Bank',
    this.branchName = 'Adyar',
    this.accountNumber = '50100456789012',
    this.ifscCode = 'HDFC0001234',
    this.accountType = 'Current',
    this.accountStatus = 'Active',
    this.isGstVerified = true,
    this.isUdyamVerified = true,
    required this.createdAt,
  }) : businessName = businessName ?? brandName;

  BusinessProfile copyWith({
    String? id,
    String? brandName,
    String? tradeName,
    String? businessName,
    String? businessType,
    EntityType? entityType,
    GstPreference? gstPreference,
    String? registrationStatus,
    String? tier,
    String? establishmentYear,
    String? employeeCount,
    String? turnoverRange,
    String? phone,
    String? email,
    String? website,
    String? pincode,
    String? city,
    String? district,
    String? stateName,
    String? country,
    String? fullAddress,
    String? latitude,
    String? longitude,
    String? gstNumber,
    String? udyamNumber,
    String? cinNumber,
    String? accountHolderName,
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? ifscCode,
    String? accountType,
    String? accountStatus,
    bool? isGstVerified,
    bool? isUdyamVerified,
    DateTime? createdAt,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      tradeName: tradeName ?? this.tradeName,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      entityType: entityType ?? this.entityType,
      gstPreference: gstPreference ?? this.gstPreference,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      tier: tier ?? this.tier,
      establishmentYear: establishmentYear ?? this.establishmentYear,
      employeeCount: employeeCount ?? this.employeeCount,
      turnoverRange: turnoverRange ?? this.turnoverRange,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      district: district ?? this.district,
      stateName: stateName ?? this.stateName,
      country: country ?? this.country,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gstNumber: gstNumber ?? this.gstNumber,
      udyamNumber: udyamNumber ?? this.udyamNumber,
      cinNumber: cinNumber ?? this.cinNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      accountStatus: accountStatus ?? this.accountStatus,
      isGstVerified: isGstVerified ?? this.isGstVerified,
      isUdyamVerified: isUdyamVerified ?? this.isUdyamVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
