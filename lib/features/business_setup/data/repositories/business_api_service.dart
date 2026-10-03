import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';

class BusinessApiService {
  final ApiClient _client;

  BusinessApiService({ApiClient? client}) : _client = client ?? ApiClient();

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

  /// Step 0: Create Propagator Details
  Future<Map<String, dynamic>> createPropagatorDetails({
    required String businessName,
    required String gstStatus,
    String? udyamNumber,
    String? gstNumber,
    String? cinNumber,
    required String businessStructure,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'user_id': effectiveUserId,
      'business_name': businessName,
      'gst_registration_status': gstStatus,
      'udyam_registration_number': udyamNumber?.trim().isEmpty ?? true ? null : udyamNumber,
      'gst_number': gstNumber?.trim().isEmpty ?? true ? null : gstNumber,
      'cin_number': cinNumber?.trim().isEmpty ?? true ? null : cinNumber,
      'business_structure': businessStructure,
    };

    final response = await _client.post(
      ApiConstants.propagatorDetailsCreate,
      body: payload,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return {'data': response};
  }

  /// Get list of Propagator details by user_id
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

  List<Map<String, dynamic>> _extractList(dynamic response) {
    List rawList = [];
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final innerData = data['data'];
        if (innerData is List) {
          rawList = innerData;
        } else if (innerData is Map<String, dynamic>) {
          rawList = [innerData];
        }
      } else if (data is List) {
        rawList = data;
      }
    } else if (response is List) {
      rawList = response;
    }

    return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Step 1: Create Propagator Address
  Future<Map<String, dynamic>> createPropagatorAddress({
    required int propagatorId,
    required String pincode,
    required String fullAddress,
    required String cityTaluk,
    required String district,
    required String state,
    String country = 'India',
    double? latitude,
    double? longitude,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = <String, dynamic>{
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'pincode': pincode,
      'full_address': fullAddress,
      'city_taluk': cityTaluk,
      'district': district,
      'state': state,
      'country': country,
      'latitude': latitude ?? 13.0827,
      'longitude': longitude ?? 80.2707,
    };

    final response = await _client.post(
      ApiConstants.propagatorAddressCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Update Propagator Address (matches Web PUT /propagator-address/update/:id)
  Future<Map<String, dynamic>> updatePropagatorAddress({
    required int addressId,
    required int propagatorId,
    required String pincode,
    required String fullAddress,
    required String cityTaluk,
    required String district,
    required String state,
    String country = 'India',
    double? latitude,
    double? longitude,
  }) async {
    final payload = <String, dynamic>{
      'propagator_id': propagatorId,
      'pincode': pincode,
      'full_address': fullAddress,
      'city_taluk': cityTaluk,
      'district': district,
      'state': state,
      'country': country,
      'latitude': latitude ?? 13.0827,
      'longitude': longitude ?? 80.2707,
    };

    final response = await _client.put(
      ApiConstants.propagatorAddressUpdate(addressId),
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Save or Update Propagator Address matching Web logic
  Future<Map<String, dynamic>> saveOrUpdatePropagatorAddress({
    int? addressId,
    required int propagatorId,
    required String pincode,
    required String fullAddress,
    required String cityTaluk,
    required String district,
    required String state,
    String country = 'India',
    double? latitude,
    double? longitude,
  }) async {
    int? targetId = addressId;
    if (targetId == null || targetId <= 0) {
      try {
        final existingList = await getPropagatorAddresses(propagatorId);
        if (existingList.isNotEmpty) {
          // Web reads t[t.length - 1], which is existingList.last
          final lastId = int.tryParse(existingList.last['id']?.toString() ?? '');
          if (lastId != null && lastId > 0) {
            targetId = lastId;
          }
        }
      } catch (_) {}
    }

    if (targetId != null && targetId > 0) {
      try {
        final res = await updatePropagatorAddress(
          addressId: targetId,
          propagatorId: propagatorId,
          pincode: pincode,
          fullAddress: fullAddress,
          cityTaluk: cityTaluk,
          district: district,
          state: state,
          country: country,
          latitude: latitude,
          longitude: longitude,
        );
        return res;
      } catch (e) {
        debugPrint('⚠️ Update address failed, falling back to create: $e');
      }
    }

    return createPropagatorAddress(
      propagatorId: propagatorId,
      pincode: pincode,
      fullAddress: fullAddress,
      cityTaluk: cityTaluk,
      district: district,
      state: state,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get addresses for a propagator
  Future<List<Map<String, dynamic>>> getPropagatorAddresses(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorAddresses,
        queryParams: {'propagator_id': propagatorId},
      );
      return _extractList(response);
    } catch (_) {
      return [];
    }
  }

  /// Step 2: Create Propagator Contact
  Future<Map<String, dynamic>> createPropagatorContact({
    required int propagatorId,
    required String primaryEmail,
    required String phoneNumber,
    String? companyWebsiteUrl,
    String? companyLogo,
    String? companyIcon,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final formattedPhone = phoneNumber.startsWith('+91')
        ? phoneNumber
        : '+91 $phoneNumber';

    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'primary_email': primaryEmail,
      'phone_number': formattedPhone,
      'company_website_url': companyWebsiteUrl?.trim().isEmpty ?? true ? null : companyWebsiteUrl,
      'company_logo': companyLogo,
      'company_icon': companyIcon,
    };

    final response = await _client.post(
      ApiConstants.propagatorContactCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Update Propagator Contact (matches Web PUT /propagator-contact/update/:id)
  Future<Map<String, dynamic>> updatePropagatorContact({
    required int contactId,
    required int propagatorId,
    required String primaryEmail,
    required String phoneNumber,
    String? companyWebsiteUrl,
    String? companyLogo,
    String? companyIcon,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final formattedPhone = phoneNumber.startsWith('+91')
        ? phoneNumber
        : '+91 $phoneNumber';

    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'primary_email': primaryEmail,
      'phone_number': formattedPhone,
      'company_website_url': companyWebsiteUrl?.trim().isEmpty ?? true ? null : companyWebsiteUrl,
      'company_logo': companyLogo,
      'company_icon': companyIcon,
    };

    final response = await _client.put(
      ApiConstants.propagatorContactUpdate(contactId),
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Save or Update Propagator Contact matching Web logic
  Future<Map<String, dynamic>> saveOrUpdatePropagatorContact({
    int? contactId,
    required int propagatorId,
    required String primaryEmail,
    required String phoneNumber,
    String? companyWebsiteUrl,
    String? companyLogo,
    String? companyIcon,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    int? targetId = contactId;
    if (targetId == null || targetId <= 0) {
      try {
        final existingList = await getPropagatorContacts(propagatorId);
        if (existingList.isNotEmpty) {
          final lastId = int.tryParse(existingList.last['id']?.toString() ?? '');
          if (lastId != null && lastId > 0) {
            targetId = lastId;
          }
        }
      } catch (_) {}
    }

    if (targetId != null && targetId > 0) {
      try {
        return await updatePropagatorContact(
          contactId: targetId,
          propagatorId: propagatorId,
          primaryEmail: primaryEmail,
          phoneNumber: phoneNumber,
          companyWebsiteUrl: companyWebsiteUrl,
          companyLogo: companyLogo,
          companyIcon: companyIcon,
          userId: effectiveUserId,
        );
      } catch (e) {
        debugPrint('⚠️ Update contact failed, falling back to create: $e');
      }
    }

    return createPropagatorContact(
      propagatorId: propagatorId,
      primaryEmail: primaryEmail,
      phoneNumber: phoneNumber,
      companyWebsiteUrl: companyWebsiteUrl,
      companyLogo: companyLogo,
      companyIcon: companyIcon,
      userId: effectiveUserId,
    );
  }

  /// Get contacts for a propagator
  Future<List<Map<String, dynamic>>> getPropagatorContacts(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorContacts,
        queryParams: {'propagator_id': propagatorId},
      );
      return _extractList(response);
    } catch (_) {
      return [];
    }
  }

  /// Step 3: Create Propagator Documents
  Future<Map<String, dynamic>> createPropagatorDocuments({
    required int propagatorId,
    String? udyamCertificate,
    String? gstCertificate,
    String? cinCertificate,
    String? geotaggedStorePhoto,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'udyam_certificate': udyamCertificate ?? 'https://example.com/docs/udyam_cert.pdf',
      'gst_certificate': gstCertificate ?? 'https://example.com/docs/gst_cert.pdf',
      'cin_certificate': cinCertificate ?? 'https://example.com/docs/cin_cert.pdf',
      'geotagged_store_photo': geotaggedStorePhoto ?? 'https://example.com/photos/store_front.jpg',
    };

    final response = await _client.post(
      ApiConstants.propagatorDocumentsCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Get documents for a propagator
  Future<List<Map<String, dynamic>>> getPropagatorDocuments(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorDocuments,
        queryParams: {'propagator_id': propagatorId},
      );
      return _extractList(response);
    } catch (_) {
      return [];
    }
  }

  /// Step 4: Create Propagator Bank Details
  Future<Map<String, dynamic>> createPropagatorBankDetails({
    required int propagatorId,
    required String accountHolderName,
    required String bankName,
    required String branchName,
    required String accountNumber,
    required String ifscCode,
    required String accountType,
    String accountStatus = 'Active',
    String? bankAddress,
    String? supportingDocument,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode.toUpperCase(),
      'account_type': accountType,
      'account_status': accountStatus,
      'bank_address': bankAddress,
      'supporting_document': supportingDocument,
    };

    final response = await _client.post(
      ApiConstants.propagatorBankDetailsCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Get bank details for a propagator
  Future<List<Map<String, dynamic>>> getPropagatorBankDetails(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorBankDetails,
        queryParams: {'propagator_id': propagatorId},
      );
      return _extractList(response);
    } catch (_) {
      return [];
    }
  }

  /// Step 5: Create Propagator Company Scale & Tier
  Future<Map<String, dynamic>> createPropagatorCompanyScale({
    required int propagatorId,
    required int establishmentYear,
    String? numberOfEmployees,
    String turnoverIncome = '20 Lakhs to 50 Lakhs',
    String companyTier = 'Tier 1',
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'establishment_year': establishmentYear,
      'number_of_employees': numberOfEmployees,
      'turnover_income': turnoverIncome,
      'company_tier': companyTier,
    };

    final response = await _client.post(
      ApiConstants.propagatorCompanyCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Get company scale & tier for a propagator
  Future<List<Map<String, dynamic>>> getPropagatorCompanies(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorCompanies,
        queryParams: {'propagator_id': propagatorId},
      );
      return _extractList(response);
    } catch (_) {
      return [];
    }
  }

  /// Step 6: Create Propagator Business Type
  Future<Map<String, dynamic>> createPropagatorBusinessType({
    required int propagatorId,
    required String businessType,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'business_type': businessType,
    };

    final response = await _client.post(
      ApiConstants.propagatorBusinessTypeCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Get business types for a propagator
  Future<List<Map<String, dynamic>>> getPropagatorBusinessTypes(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorBusinessTypes,
        queryParams: {'propagator_id': propagatorId},
      );
      return _extractList(response);
    } catch (_) {
      return [];
    }
  }

  /// Fetches all 6 related details for a propagator in parallel
  Future<Map<String, dynamic>> getPropagatorFullDetails(int propagatorId) async {
    final results = await Future.wait([
      getPropagatorContacts(propagatorId),
      getPropagatorAddresses(propagatorId),
      getPropagatorCompanies(propagatorId),
      getPropagatorBusinessTypes(propagatorId),
      getPropagatorDocuments(propagatorId),
      getPropagatorBankDetails(propagatorId),
    ]);

    return {
      'contacts': results[0],
      'addresses': results[1],
      'companies': results[2],
      'business_types': results[3],
      'documents': results[4],
      'bank_details': results[5],
    };
  }

  /// Step 7: Create Propagator Business Mapping
  Future<Map<String, dynamic>> createPropagatorBusinessMapping({
    required int propagatorId,
    required int sectorTitleId,
    required int sectorId,
    required int subSectorId,
    required List<dynamic> primaryCategories,
    Map<String, dynamic>? brands,
    List<String>? brandNames,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      'sector_title_id': sectorTitleId,
      'sector_id': sectorId,
      'sub_sector_id': subSectorId,
      'primary_categories': primaryCategories,
      if (brands != null) ...{'brands': brands},
      if (brandNames != null) ...{'brand_names': brandNames},
    };

    final response = await _client.post(
      ApiConstants.propagatorBusinessMappingCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Step 8: Create Propagator Brand Mapping
  Future<Map<String, dynamic>> createPropagatorBrandMapping({
    required int propagatorId,
    required Map<String, dynamic> brands,
    required List<String> brandNames,
    List<int>? brandIds,
    String? userId,
  }) async {
    final effectiveUserId = await _resolveUserId(userId);
    final payload = {
      'propagator_id': propagatorId,
      'user_id': effectiveUserId,
      if (brandIds != null) ...{'brand_ids': brandIds},
      'brand_names': brandNames,
      'brands': brands,
    };

    final response = await _client.post(
      ApiConstants.propagatorBrandMappingCreate,
      body: payload,
    );

    return response is Map<String, dynamic> ? response : {'data': response};
  }

  /// Fetch Pincode Details with fallback
  Future<Map<String, String>?> fetchPincodeDetails(String pincode) async {
    final cleanPin = pincode.trim();
    if (cleanPin.length != 6) return null;

    try {
      final response = await _client.get(
        ApiConstants.pincodeDetails,
        queryParams: {'pincode': cleanPin},
      );

      dynamic data = response;
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }
      if (data is Map && data.containsKey('data')) {
        data = data['data'];
      }

      Map? item;
      if (data is List && data.isNotEmpty) {
        item = data.first as Map?;
      } else if (data is Map) {
        item = data;
      }

      if (item != null && item['state'] != null) {
        return {
          'district': item['district']?.toString() ?? item['district_name']?.toString() ?? '',
          'state': item['state']?.toString() ?? item['state_name']?.toString() ?? '',
          'city': item['city_name']?.toString() ?? item['city']?.toString() ?? item['taluk']?.toString() ?? '',
          'country': item['country']?.toString() ?? 'India',
        };
      }
    } catch (e) {
      debugPrint('⚠️ Main pincode API issue, checking postal fallback: $e');
    }

    // Public Postal Fallback
    try {
      final postalUri = Uri.parse('https://api.postalpincode.in/pincode/$cleanPin');
      debugPrint('📡 [POSTAL FALLBACK] GET $postalUri');
      final res = await http.get(postalUri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List && decoded.isNotEmpty) {
          final firstResult = decoded[0];
          if (firstResult['Status'] == 'Success') {
            final postOffices = firstResult['PostOffice'] as List?;
            if (postOffices != null && postOffices.isNotEmpty) {
              final po = postOffices[0];
              final resMap = {
                'district': po['District']?.toString() ?? '',
                'state': po['State']?.toString() ?? '',
                'city': po['Name']?.toString() ?? po['Block']?.toString() ?? '',
                'country': po['Country']?.toString() ?? 'India',
              };
              debugPrint('✅ [POSTAL FALLBACK SUCCESS]: $resMap');
              return resMap;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Postal fallback error: $e');
    }

    return null;
  }

  /// Get Sector Titles: /api/sector-title with fallback to ApiConstants.sectorTitleList
  Future<List<Map<String, dynamic>>> getSectorTitles() async {
    try {
      final response = await _client.get(ApiConstants.sectorTitle);
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['data']?['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } else if (response is List) {
        return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}

    try {
      final response = await _client.get(ApiConstants.sectorTitleList);
      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['data']?['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } else if (response is List) {
        return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching sector titles: $e');
    }
    return [];
  }

  /// Get Sectors: calls /sector/{sectorTitleId} (e.g. /api/sector/1) with fallback to ApiConstants.sectorList
  Future<List<Map<String, dynamic>>> getSectors(dynamic sectorTitleId) async {
    if (sectorTitleId != null) {
      try {
        final response = await _client.get(ApiConstants.sectorByTitleId(sectorTitleId));
        if (response is Map<String, dynamic>) {
          final data = response['data'];
          if (data is List) {
            return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        } else if (response is List) {
          return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching /sector/$sectorTitleId: $e');
      }
    }

    try {
      final response = await _client.get(
        ApiConstants.sectorList,
        queryParams: sectorTitleId != null ? {'sector_title_id': sectorTitleId} : null,
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      } else if (response is List) {
        return response.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching sectors fallback: $e');
    }
    return [];
  }

  /// Get Sub Sectors
  Future<List<Map<String, dynamic>>> getSubSectors({
    dynamic sectorId,
    dynamic sectorTitleId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (sectorId != null) params['sector_id'] = sectorId;
      if (sectorTitleId != null) params['sector_title_id'] = sectorTitleId;

      final response = await _client.get(
        ApiConstants.subSectorList,
        queryParams: params,
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching sub-sectors: $e');
    }
    return [];
  }

  /// Get Primary Categories
  Future<List<Map<String, dynamic>>> getPrimaryCategories({
    dynamic subSectorId,
    dynamic sectorId,
    dynamic sectorTitleId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (subSectorId != null) params['sub_sector_id'] = subSectorId;
      if (sectorId != null) params['sector_id'] = sectorId;
      if (sectorTitleId != null) params['sector_title_id'] = sectorTitleId;

      final response = await _client.get(
        ApiConstants.primaryCategories,
        queryParams: params,
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching primary categories: $e');
    }
    return [];
  }

  /// Get Secondary Categories
  Future<List<Map<String, dynamic>>> getSecondaryCategories({
    dynamic primaryCategoryId,
    dynamic subSectorId,
    dynamic sectorId,
    dynamic sectorTitleId,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (primaryCategoryId != null) params['primary_category_id'] = primaryCategoryId;
      if (subSectorId != null) params['sub_sector_id'] = subSectorId;
      if (sectorId != null) params['sector_id'] = sectorId;
      if (sectorTitleId != null) params['sector_title_id'] = sectorTitleId;

      final response = await _client.get(
        ApiConstants.secondaryCategories,
        queryParams: params,
      );
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is List) {
          return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching secondary categories: $e');
    }
    return [];
  }

  /// Get Secondary Categories by Primary Category ID matching web API: /api/secondary/{primary_id}
  Future<List<Map<String, dynamic>>> getSecondaryCategoriesByPrimaryId(dynamic primaryCategoryId) async {
    if (primaryCategoryId == null) return [];
    try {
      final response = await _client.get(
        ApiConstants.secondaryCategoryById(primaryCategoryId),
      );
      final list = _extractList(response);
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('⚠️ Note: /secondary/$primaryCategoryId response: $e');
    }

    // Fallback to /outsideapis/secondary-categories
    try {
      final response = await _client.get(
        ApiConstants.secondaryCategories,
        queryParams: {'primary_category_id': primaryCategoryId},
      );
      return _extractList(response);
    } catch (e) {
      debugPrint('⚠️ Error fetching secondary categories fallback: $e');
      return [];
    }
  }

  /// Get Propagator Configurations (Unified configurations with saved mappings)
  Future<Map<String, dynamic>> getPropagatorConfigurations(int propagatorId) async {
    try {
      final response = await _client.get(
        ApiConstants.propagatorConfigurations(propagatorId),
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
      return {'data': response};
    } catch (e) {
      debugPrint('⚠️ Error fetching propagator configurations: $e');
      return {};
    }
  }


  /// Get Propagator Business Mappings: calls /propagator-business-mappings?propagator_id={id}&user_main_id={userId}
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
      debugPrint('⚠️ Error fetching propagator business mappings: $e');
      return {};
    }
  }

  /// Get Brands by Primary ID and Secondary (Sub-category) ID
  Future<List<Map<String, dynamic>>> getBrands({
    dynamic primaryId,
    dynamic secondaryId,
  }) async {
    // 1. Try web API: /api/brand/{primary_id}/{secondary_id}
    if (primaryId != null && secondaryId != null) {
      try {
        final endpoint = ApiConstants.brandByPrimaryAndSecondary(primaryId, secondaryId);
        final response = await _client.get(endpoint);
        final list = _extractList(response);
        if (list.isNotEmpty) return list;
      } catch (e) {
        debugPrint('⚠️ Error fetching brands from /brand/$primaryId/$secondaryId: $e');
      }
    }

    // 2. Fallback to /outsideapis/brands
    try {
      final params = <String, dynamic>{};
      if (primaryId != null) params['primary_id'] = primaryId;
      if (secondaryId != null) params['secondary_id'] = secondaryId;

      final response = await _client.get(
        ApiConstants.brands,
        queryParams: params,
      );
      return _extractList(response);
    } catch (e) {
      debugPrint('⚠️ Error fetching brands fallback: $e');
    }
    return [];
  }

  /// Get Propagator Details by User ID: /api/propagator-details?user_id={user_id}
  Future<List<Map<String, dynamic>>> getPropagatorDetailsByUser([String? userId]) async {
    try {
      final effectiveUserId = await _resolveUserId(userId);
      final response = await _client.get(
        ApiConstants.propagatorDetails,
        queryParams: {'user_id': effectiveUserId},
      );
      return _extractList(response);
    } catch (e) {
      debugPrint('⚠️ Error fetching propagator details for user $userId: $e');
      return [];
    }
  }
}
