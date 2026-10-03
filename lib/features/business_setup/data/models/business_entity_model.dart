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
  final int? addressId;
  final int? contactId;

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
    this.addressId,
    this.contactId,
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
    int? addressId,
    int? contactId,
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
      addressId: addressId ?? this.addressId,
      contactId: contactId ?? this.contactId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BusinessProfile.fromApi(
    Map<String, dynamic> json, {
    Map<String, dynamic>? address,
    Map<String, dynamic>? contact,
    Map<String, dynamic>? company,
    Map<String, dynamic>? businessTypeData,
    Map<String, dynamic>? bank,
    Map<String, dynamic>? document,
  }) {
    final bName = json['business_name']?.toString() ??
        json['brand_name']?.toString() ??
        'Business #${json['id']}';

    final structureStr = json['business_structure']?.toString().toLowerCase() ?? '';
    EntityType entity = EntityType.proprietorship;
    if (structureStr.contains('partnership') && !structureStr.contains('llp')) {
      entity = EntityType.partnership;
    } else if (structureStr.contains('pvt') || structureStr.contains('private')) {
      entity = EntityType.pvtLtd;
    } else if (structureStr.contains('opc') || structureStr.contains('one person')) {
      entity = EntityType.opc;
    } else if (structureStr.contains('llp')) {
      entity = EntityType.llp;
    }

    final gstStatus = json['gst_registration_status']?.toString().toLowerCase() ?? '';
    final gstPref = gstStatus.contains('reg') && !gstStatus.contains('un')
        ? GstPreference.required
        : GstPreference.notApplicable;

    DateTime created = DateTime.now();
    if (json['created_at'] != null) {
      try {
        created = DateTime.parse(json['created_at'].toString());
      } catch (_) {}
    }

    int? parsedAddressId;
    if (address?['id'] != null) {
      if (address!['id'] is int) {
        parsedAddressId = address['id'] as int;
      } else {
        parsedAddressId = int.tryParse(address['id'].toString());
      }
    }

    int? parsedContactId;
    if (contact?['id'] != null) {
      if (contact!['id'] is int) {
        parsedContactId = contact['id'] as int;
      } else {
        parsedContactId = int.tryParse(contact['id'].toString());
      }
    }

    return BusinessProfile(
      id: '#${json['id']}',
      brandName: bName,
      tradeName: json['trade_name']?.toString() ?? bName,
      businessName: bName,
      businessType: businessTypeData?['business_type']?.toString() ??
          json['business_type']?.toString() ??
          'Retail & Wholesale',
      entityType: entity,
      gstPreference: gstPref,
      registrationStatus: 'Active',
      tier: company?['company_tier']?.toString() ?? 'Startup',
      establishmentYear: company?['establishment_year']?.toString() ?? '2024',
      employeeCount: company?['number_of_employees']?.toString() ?? '1-10 Employees',
      turnoverRange: company?['turnover_income']?.toString() ?? 'Up to 20 Lakhs',
      phone: contact?['phone_number']?.toString() ?? '+91 9965437236',
      email: contact?['primary_email']?.toString() ?? 'contact@${bName.toLowerCase().replaceAll(' ', '')}.com',
      website: contact?['company_website_url']?.toString() ?? 'https://${bName.toLowerCase().replaceAll(' ', '')}.com',
      pincode: address?['pincode']?.toString() ?? '600001',
      city: address?['city_taluk']?.toString() ?? address?['city']?.toString() ?? 'Chennai',
      district: address?['district']?.toString() ?? 'Chennai',
      stateName: address?['state']?.toString() ?? 'Tamil Nadu',
      country: address?['country']?.toString() ?? 'India',
      fullAddress: address?['full_address']?.toString() ?? 'Official Business Address',
      latitude: address?['latitude']?.toString() ?? '13.0827',
      longitude: address?['longitude']?.toString() ?? '80.2707',
      gstNumber: json['gst_number']?.toString() ?? '33AAAAA0000A1Z5',
      udyamNumber: json['udyam_registration_number']?.toString() ?? 'UDYAM-TN-01-0012345',
      cinNumber: json['cin_number']?.toString() ?? '',
      accountHolderName: bank?['account_holder_name']?.toString() ?? bName,
      bankName: bank?['bank_name']?.toString() ?? 'HDFC Bank',
      branchName: bank?['branch_name']?.toString() ?? 'Adyar',
      accountNumber: bank?['account_number']?.toString() ?? '50100456789012',
      ifscCode: bank?['ifsc_code']?.toString() ?? 'HDFC0001234',
      accountType: bank?['account_type']?.toString() ?? 'Current',
      accountStatus: bank?['account_status']?.toString() ?? 'Active',
      addressId: parsedAddressId,
      contactId: parsedContactId,
      createdAt: created,
    );
  }
}
