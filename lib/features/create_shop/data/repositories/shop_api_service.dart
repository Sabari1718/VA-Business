import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/shop_model.dart';

class ShopApiService {
  final ApiClient _client;

  ShopApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<String> _resolveUserId([String? userId]) async {
    if (userId != null && userId.isNotEmpty && userId != '2146610213') {
      return userId;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('user_main_id') ?? prefs.getString('user_id');
      if (id != null && id.isNotEmpty && id != '2146610213') {
        return id;
      }
    } catch (_) {}
    return ApiConstants.defaultUserId;
  }

  /// Map platform name to ID (matching backend schema)
  static int getPlatformId(String platformName) {
    switch (platformName.trim().toLowerCase()) {
      case 'shop':
      case 'physical shop':
        return 1;
      case 'local online':
        return 2;
      case 'online - pan india':
      case 'pan india':
      case 'online':
        return 3;
      case 'export':
        return 4;
      default:
        return 1;
    }
  }

  /// Map store type name to ID
  static int getStoreTypeId(String typeName) {
    switch (typeName.trim().toLowerCase()) {
      case 'retail shop':
        return 1;
      case 'showroom':
        return 2;
      case 'dealer / reseller':
      case 'dealer':
      case 'reseller':
        return 3;
      case 'wholesale shop':
      case 'wholesale':
        return 4;
      case 'distributor':
        return 5;
      case 'warehouse':
        return 6;
      case 'manufacturer':
        return 7;
      default:
        return 1;
    }
  }

  /// Map payment method to ID
  static int getPaymentMethodId(String method) {
    switch (method.trim().toLowerCase()) {
      case 'cash':
        return 1;
      case 'upi':
        return 2;
      case 'credit/debit card':
      case 'card':
        return 3;
      case 'net banking':
        return 4;
      case 'store credit':
        return 5;
      case 'wallet':
        return 6;
      default:
        return 1;
    }
  }

  /// Map language name to ID
  static int getLanguageId(String lang) {
    switch (lang.trim().toLowerCase()) {
      case 'english':
        return 1;
      case 'tamil':
        return 2;
      case 'hindi':
        return 3;
      case 'telugu':
        return 4;
      case 'malayalam':
        return 5;
      case 'kannada':
        return 6;
      default:
        return 1;
    }
  }

  /// Step 1: Create Propagator Store
  /// POST /api/propagator-store/create
  Future<Map<String, dynamic>> createPropagatorStore({
    required int propagatorId,
    required String storeName,
    required String platformName,
    required List<String> selectedStoreTypes,
    required String branchModel,
    required String customerCareName,
    required String customerCarePhone,
    required String altContactName,
    required String altPhone,
    required String country,
    required String state,
    required String district,
    required String taluk,
    required String cityVillage,
    required String pincode,
    required double latitude,
    required double longitude,
    required List<String> workingDays,
    required String sundayClosingReason,
    Map<String, String>? closedDayReasons,
    required String openingTime,
    required String closingTime,
    required List<String> paymentMethods,
    required List<String> languages,
    String? userId,
  }) async {
    final platformId = getPlatformId(platformName);

    // Build store_types array
    final storeTypesPayload = selectedStoreTypes.map((typeName) {
      return {
        'store_type_id': getStoreTypeId(typeName),
        'store_type_name': typeName,
      };
    }).toList();

    // If empty, default to at least one
    if (storeTypesPayload.isEmpty) {
      storeTypesPayload.add({
        'store_type_id': 1,
        'store_type_name': 'Retail Shop',
      });
    }

    // Build offDayReasons
    final offDayReasons = <String, String>{};
    const allWeekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    for (final day in allWeekDays) {
      if (!workingDays.contains(day)) {
        final customReason = closedDayReasons?[day]?.trim();
        if (customReason != null && customReason.isNotEmpty) {
          offDayReasons[day] = customReason;
        } else if (day == 'Sunday') {
          offDayReasons['Sunday'] = sundayClosingReason.isNotEmpty ? sundayClosingReason : 'Weekly Holiday';
        } else if (day == 'Saturday') {
          offDayReasons['Saturday'] = 'Weekend Off';
        } else if (day == 'Friday') {
          offDayReasons['Friday'] = 'Weekly Off';
        } else {
          offDayReasons[day] = 'Weekly Holiday';
        }
      }
    }
    if (offDayReasons.isEmpty && !workingDays.contains('Sunday')) {
      offDayReasons['Sunday'] = sundayClosingReason.isNotEmpty ? sundayClosingReason : 'Weekly Holiday';
    }

    // Build payment methods array
    final paymentMethodsPayload = paymentMethods.map((m) {
      return {
        'payment_method_id': getPaymentMethodId(m),
        'payment_method_name': m,
        'is_custom': false,
      };
    }).toList();

    // Build languages array
    final languagesPayload = languages.map((l) {
      return {
        'language_id': getLanguageId(l),
        'language_name': l,
        'is_custom': false,
      };
    }).toList();

    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'user_id': effectiveUserId,
      'propagator_id': propagatorId,
      'platform_id': platformId,
      'platform_name': platformName,
      'store_name': storeName,
      'branch_management_model': branchModel,
      'store_types': storeTypesPayload,
      'address': {
        'country': country.isNotEmpty ? country : 'India',
        'state': state,
        'district': district,
        'taluk': taluk,
        'city_village': cityVillage,
        'pincode': pincode,
        'latitude': latitude.toStringAsFixed(8),
        'longitude': longitude.toStringAsFixed(8),
      },
      'customer_care_contact_name': customerCareName,
      'customer_care_phone': customerCarePhone,
      'alternate_contact_name': altContactName,
      'alternate_phone': altPhone,
      'working_days': workingDays,
      'offDayReasons': offDayReasons,
      'hours': {
        'opening_time': openingTime,
        'closing_time': closingTime,
      },
      'payment_methods': paymentMethodsPayload,
      'languages': languagesPayload,
    };

    final response = await _client.post(
      ApiConstants.propagatorStoreCreate,
      body: payload,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  /// Step 2: Create Propagator Store Mapping
  /// POST /api/propagator-store/mapping/create
  Future<Map<String, dynamic>> createStoreMapping({
    required int storeId,
    required int propagatorId,
    String? userId,
    List<dynamic>? primaryCategories,
    List<dynamic>? subCategories,
    Map<String, dynamic>? brands,
    List<dynamic>? mappings,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'store_id': storeId,
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'primary_categories': primaryCategories ?? [],
      'sub_categories': subCategories ?? [],
      'brands': brands ?? {},
      'mappings': mappings ?? [],
    };

    final response = await _client.post(
      ApiConstants.propagatorStoreMappingCreate,
      body: payload,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  /// Step 3: Fetch all stores for a propagator
  /// GET /api/propagator-stores?propagator_id={propagatorId}
  Future<List<ShopPlatform>> getPropagatorStores({
    required int propagatorId,
    String fallbackBusinessName = '',
  }) async {
    final response = await _client.get(
      ApiConstants.propagatorStores,
      queryParams: {'propagator_id': propagatorId},
    );

    List rawList = [];
    String businessName = fallbackBusinessName;

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        if (data['business'] is Map && data['business']['name'] != null) {
          businessName = data['business']['name'].toString();
        }
        if (data['stores'] is List) {
          rawList = data['stores'] as List;
        } else if (data['data'] is List) {
          rawList = data['data'] as List;
        }
      } else if (data is List) {
        rawList = data;
      }
    } else if (response is List) {
      rawList = response;
    }

    if (rawList.isEmpty) {
      rawList = _extractList(response);
    }

    return rawList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['propagator_id'] == null) {
        map['propagator_id'] = propagatorId;
      }
      return ShopPlatform.fromJson(
        map,
        fallbackBusinessName: businessName,
      );
    }).toList();
  }

  /// Update Propagator Store
  /// PUT /api/propagator-store/update/{storeId}
  Future<Map<String, dynamic>> updatePropagatorStore({
    required int storeId,
    required int propagatorId,
    required String storeName,
    required String platformName,
    required List<String> selectedStoreTypes,
    required String branchModel,
    required String customerCareName,
    required String customerCarePhone,
    required String altContactName,
    required String altPhone,
    required String country,
    required String state,
    required String district,
    required String taluk,
    required String cityVillage,
    required String pincode,
    required double latitude,
    required double longitude,
    required List<String> workingDays,
    required String sundayClosingReason,
    Map<String, String>? closedDayReasons,
    required String openingTime,
    required String closingTime,
    required List<String> paymentMethods,
    required List<String> languages,
    String? userId,
  }) async {
    const allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final workingDaysPayload = allDays.map((day) {
      final isWorking = workingDays.contains(day);
      String? reason;
      if (!isWorking) {
        final customReason = closedDayReasons?[day]?.trim();
        if (customReason != null && customReason.isNotEmpty) {
          reason = customReason;
        } else if (day == 'Sunday') {
          reason = sundayClosingReason.isNotEmpty ? sundayClosingReason : 'Weekly Off';
        } else if (day == 'Saturday') {
          reason = 'Weekend Off';
        } else {
          reason = 'Weekly Off';
        }
      }
      return {
        'day_of_week': day,
        'is_working_day': isWorking,
        'closed_reason': reason,
      };
    }).toList();

    final paymentsPayload = paymentMethods.map((m) {
      return {
        'payment_method_id': getPaymentMethodId(m),
        'payment_method_name': m,
      };
    }).toList();

    final languagesPayload = languages.map((l) {
      return {
        'language_id': getLanguageId(l),
        'language_name': l,
      };
    }).toList();

    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'id': storeId,
      'store_name': storeName,
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'platform_id': platformName.toLowerCase(),
      'platform_name': platformName,
      'store_types': selectedStoreTypes.isNotEmpty ? selectedStoreTypes : ['Retail Shop'],
      'branch_management_model': branchModel,
      'customer_care_contact_name': customerCareName,
      'customer_care_phone': customerCarePhone,
      'alternate_contact_name': altContactName,
      'alternate_phone': altPhone,
      'address': {
        'country': country.isNotEmpty ? country : 'India',
        'state': state,
        'district': district,
        'taluk': taluk,
        'city_village': cityVillage,
        'pincode': pincode,
        'latitude': latitude.toStringAsFixed(8),
        'longitude': longitude.toStringAsFixed(8),
      },
      'hours': {
        'opening_time': formatTimeForApi(openingTime),
        'closing_time': formatTimeForApi(closingTime),
      },
      'working_days': workingDaysPayload,
      'payments': paymentsPayload,
      'languages': languagesPayload,
    };

    final response = await _client.put(
      ApiConstants.propagatorStoreUpdate(storeId),
      body: payload,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  /// Delete Propagator Store
  /// DELETE /api/propagator-store/delete/{storeId}
  Future<Map<String, dynamic>> deletePropagatorStore({
    required dynamic storeId,
  }) async {
    final response = await _client.delete(
      ApiConstants.propagatorStoreDelete(storeId),
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  /// Get Propagator details for a user
  /// GET /api/propagator-details?user_id={userId}
  Future<List<Map<String, dynamic>>> getPropagatorDetails({
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final response = await _client.get(
      ApiConstants.propagatorDetails,
      queryParams: {'user_id': effectiveUserId},
    );

    return _extractList(response);
  }

  static String formatTimeForApi(String timeStr) {
    if (timeStr.contains(':') && timeStr.length >= 8 && !timeStr.contains(' ')) {
      return timeStr;
    }
    try {
      final clean = timeStr.trim().toUpperCase();
      final isPm = clean.contains('PM');
      final isAm = clean.contains('AM');
      final parts = clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0].trim());
        final min = int.parse(parts[1].trim());
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        return '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}:00';
      }
    } catch (_) {}
    return timeStr.isNotEmpty ? timeStr : '09:00:00';
  }

  /// Optional / Pre-check: Fetch configurations
  /// GET /api/propagator/{propagatorId}/configurations
  Future<Map<String, dynamic>> getConfigurations(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorConfigurations(propagatorId),
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'data': response};
    } catch (e) {
      debugPrint('⚠️ Warning fetching configurations: $e');
      return {};
    }
  }

  /// Get Propagator Store by storeId
  /// GET /api/propagator-store/{storeId}
  Future<Map<String, dynamic>> getPropagatorStore(dynamic storeId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorStoreDetails(storeId),
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'data': response};
    } catch (e) {
      debugPrint('⚠️ Warning fetching propagator store #$storeId: $e');
      return {};
    }
  }

  /// Get Propagator Business Mappings
  /// GET /api/propagator-business-mappings?propagator_id={id}&user_main_id={userId}
  Future<Map<String, dynamic>> getPropagatorBusinessMappings(int propagatorId, {String? userId}) async {
    try {
      final effectiveUserId = await _resolveUserId(userId);
      final response = await _client.get(
        ApiConstants.propagatorBusinessMappings,
        queryParams: {
          'propagator_id': propagatorId,
          'user_main_id': effectiveUserId,
        },
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'data': response};
    } catch (e) {
      debugPrint('⚠️ Warning fetching business mappings: $e');
      return {};
    }
  }

  /// Get All Brands from /outsideapis/brands
  Future<List<Map<String, dynamic>>> getAllBrands() async {
    try {
      final response = await _client.get(ApiConstants.brands);
      return _extractList(response);
    } catch (e) {
      debugPrint('⚠️ Warning fetching brands: $e');
      return [];
    }
  }

  /// Get Pincode Details
  /// GET /api/outsideapis/pincode/details?pincode={pincode}
  Future<Map<String, String>?> getPincodeDetails(String pincode) async {
    try {
      final response = await _client.get(
        ApiConstants.pincodeDetails,
        queryParams: {'pincode': pincode.trim()},
      );
      final list = _extractList(response);
      if (list.isNotEmpty) {
        final item = list.first;
        return {
          'country': item['country_name']?.toString() ?? 'India',
          'state': item['state_name']?.toString() ?? '',
          'district': item['district_name']?.toString() ?? '',
          'taluk': item['taluk_name']?.toString() ?? '',
          'cityVillage': item['city_name']?.toString() ?? '',
          'pincode': item['pincode']?.toString() ?? pincode,
        };
      }
    } catch (e) {
      debugPrint('⚠️ Warning fetching pincode details: $e');
    }
    return null;
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    List rawList = [];
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        if (data['stores'] is List) {
          rawList = data['stores'] as List;
        } else {
          final innerData = data['data'];
          if (innerData is List) {
            rawList = innerData;
          } else if (innerData is Map<String, dynamic>) {
            rawList = [innerData];
          }
        }
      } else if (data is List) {
        rawList = data;
      }
    } else if (response is List) {
      rawList = response;
    }

    return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
