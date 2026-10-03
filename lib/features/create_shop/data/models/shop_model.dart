class ShopPlatform {
  final String id;
  final int? propagatorId;
  final String storeName;
  final String platformType; // 'Shop', 'Local Online', 'Online - Pan India', 'Export'
  final String storeType; // 'Retail Shop', 'Showroom', etc.
  final List<String> storeTypesList; // Multiple store types if any
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
  final double rating;
  final DateTime createdAt;

  const ShopPlatform({
    required this.id,
    this.propagatorId,
    required this.storeName,
    required this.platformType,
    this.storeType = 'Retail Shop',
    this.storeTypesList = const [],
    required this.businessName,
    this.branchModel = 'Multi-Branch Franchise',
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
    this.rating = 4.5,
    required this.createdAt,
  });

  String get fullAddress {
    final parts = [cityVillage, taluk, district, stateName]
        .where((p) => p.isNotEmpty)
        .toList();
    final addr = parts.join(', ');
    return pincode.isNotEmpty ? '$addr - $pincode' : addr;
  }

  factory ShopPlatform.fromJson(Map<String, dynamic> json, {String fallbackBusinessName = ''}) {
    // Parse ID
    final rawId = json['id']?.toString() ?? '';

    // Propagator ID
    int? pId;
    if (json['propagator_id'] is int) {
      pId = json['propagator_id'] as int;
    } else if (json['propagator_id'] != null) {
      pId = int.tryParse(json['propagator_id'].toString());
    }

    // Platform Name
    String platName = 'Shop';
    if (json['platform_name'] != null && json['platform_name'].toString().isNotEmpty) {
      platName = json['platform_name'].toString();
    } else if (json['platform'] is Map && json['platform']['name'] != null) {
      platName = json['platform']['name'].toString();
    } else if (json['platform'] is Map && json['platform']['platform_name'] != null) {
      platName = json['platform']['platform_name'].toString();
    }

    // Store Types
    final List<String> sTypesList = [];
    if (json['store_types'] is List) {
      for (final item in json['store_types'] as List) {
        if (item is Map) {
          final name = item['store_type_name'] ?? item['name'] ?? item['title'];
          if (name != null && name.toString().isNotEmpty) {
            sTypesList.add(name.toString());
          }
        } else if (item is String) {
          sTypesList.add(item);
        }
      }
    }
    String sType = 'Retail Shop';
    if (json['store_type'] is Map) {
      sType = json['store_type']['name']?.toString() ?? 'Retail Shop';
      if (sTypesList.isEmpty) sTypesList.add(sType);
    } else if (json['store_type'] != null) {
      sType = json['store_type'].toString();
    }
    if (sTypesList.isNotEmpty && sType == 'Retail Shop') {
      sType = sTypesList.join(', ');
    }

    // Address
    final addr = json['address'] is Map ? json['address'] as Map<String, dynamic> : null;
    final pincode = addr?['pincode']?.toString() ?? json['pincode']?.toString() ?? '';
    final country = addr?['country']?.toString() ?? json['country']?.toString() ?? 'India';
    final stateName = addr?['state']?.toString() ?? json['state']?.toString() ?? '';
    final district = addr?['district']?.toString() ?? json['district']?.toString() ?? '';
    final taluk = addr?['taluk']?.toString() ?? json['taluk']?.toString() ?? '';
    final cityVillage = addr?['city_village']?.toString() ?? json['city_village']?.toString() ?? '';
    final latitude = double.tryParse(addr?['latitude']?.toString() ?? json['latitude']?.toString() ?? '') ?? 0.0;
    final longitude = double.tryParse(addr?['longitude']?.toString() ?? json['longitude']?.toString() ?? '') ?? 0.0;

    // Hours
    final hours = json['hours'] is Map ? json['hours'] as Map<String, dynamic> : null;
    final openingTime = hours?['opening_time']?.toString() ?? json['opening_time']?.toString() ?? '09:00 AM';
    final closingTime = hours?['closing_time']?.toString() ?? json['closing_time']?.toString() ?? '09:00 PM';

    // Working Days
    final List<String> wDays = [];
    if (json['working_days'] is List) {
      for (final item in json['working_days'] as List) {
        if (item is Map) {
          if (item['is_working_day'] == true || item['is_working_day'] == 1) {
            final day = item['day_of_week']?.toString();
            if (day != null && day.isNotEmpty) wDays.add(day);
          }
        } else if (item is String) {
          wDays.add(item);
        }
      }
    }

    // Payment Methods
    final List<String> pMethods = [];
    final payments = json['payments'] ?? json['payment_methods'];
    if (payments is List) {
      for (final item in payments) {
        if (item is Map) {
          final name = item['payment_method_name'] ?? item['name'];
          if (name != null && name.toString().isNotEmpty) {
            pMethods.add(name.toString());
          }
        } else if (item is String) {
          pMethods.add(item);
        }
      }
    }

    // Supported Languages
    final List<String> langs = [];
    if (json['languages'] is List) {
      for (final item in json['languages'] as List) {
        if (item is Map) {
          final name = item['language_name'] ?? item['name'];
          if (name != null && name.toString().isNotEmpty) {
            langs.add(name.toString());
          }
        } else if (item is String) {
          langs.add(item);
        }
      }
    }

    // Created At
    DateTime cDate = DateTime.now();
    if (json['created_at'] != null) {
      cDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    final resolvedStoreName = json['name']?.toString() ?? json['store_name']?.toString() ?? 'Store $rawId';
    String resolvedBusinessName = fallbackBusinessName;
    if (json['business'] is Map && json['business']['name'] != null) {
      resolvedBusinessName = json['business']['name'].toString();
    } else if (json['business_name'] != null && json['business_name'].toString().isNotEmpty) {
      resolvedBusinessName = json['business_name'].toString();
    }

    return ShopPlatform(
      id: rawId,
      propagatorId: pId,
      storeName: resolvedStoreName,
      platformType: platName,
      storeType: sType,
      storeTypesList: sTypesList,
      businessName: resolvedBusinessName,
      branchModel: json['branch_management_model']?.toString() ?? json['branch_model']?.toString() ?? 'Standard Branch',
      customerCareName: json['customer_care_contact_name']?.toString() ?? json['customer_care_name']?.toString() ?? '',
      customerCarePhone: json['customer_care_phone']?.toString() ?? '',
      altContactName: json['alternate_contact_name']?.toString() ?? json['alt_contact_name']?.toString() ?? '',
      altPhone: json['alternate_phone']?.toString() ?? json['alt_phone']?.toString() ?? '',
      pincode: pincode,
      country: country,
      stateName: stateName,
      district: district,
      taluk: taluk,
      cityVillage: cityVillage,
      latitude: latitude,
      longitude: longitude,
      openingTime: openingTime,
      closingTime: closingTime,
      workingDays: wDays.isNotEmpty ? wDays : const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      paymentMethods: pMethods.isNotEmpty ? pMethods : const ['Cash', 'UPI', 'Credit/Debit Card'],
      supportedLanguages: langs.isNotEmpty ? langs : const ['English', 'Tamil'],
      status: 'Active',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : (double.tryParse(json['rating']?.toString() ?? '') ?? 4.5),
      createdAt: cDate,
    );
  }
}
