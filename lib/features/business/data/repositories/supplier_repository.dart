import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

const String _baseUrl = 'https://business-setup.srivagroups.in/api';
const String _userId = '2146610213';
const String _businessId = '1';
const String _storeId = '1';

class SupplierApiModel {
  final int id;
  final String? userid;
  final String? businessid;
  final String? storeId;
  final String? gstType;
  final String? gstNumber;
  final String? gstCertificate;
  final String? businessName;
  final String? businessEmail;
  final String? phone;
  final String? companyLogo;
  final String? doorNo;
  final String? streetName;
  final String? buildingName;
  final String? landmark;
  final String? area;
  final String? district;
  final String? pincode;
  final String? state;
  final String? country;
  final String? platform;
  final String? type;

  SupplierApiModel({
    required this.id,
    this.userid,
    this.businessid,
    this.storeId,
    this.gstType,
    this.gstNumber,
    this.gstCertificate,
    this.businessName,
    this.businessEmail,
    this.phone,
    this.companyLogo,
    this.doorNo,
    this.streetName,
    this.buildingName,
    this.landmark,
    this.area,
    this.district,
    this.pincode,
    this.state,
    this.country,
    this.platform,
    this.type,
  });

  factory SupplierApiModel.fromJson(Map<String, dynamic> json) {
    return SupplierApiModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userid: json['userid']?.toString(),
      businessid: json['businessid']?.toString(),
      storeId: json['store_id']?.toString(),
      gstType: json['gst_type']?.toString(),
      gstNumber: json['gst_number']?.toString(),
      gstCertificate: json['gst_certificate']?.toString(),
      businessName: json['business_name']?.toString(),
      businessEmail: json['business_email']?.toString(),
      phone: json['phone']?.toString(),
      companyLogo: json['company_logo']?.toString(),
      doorNo: json['door_no']?.toString(),
      streetName: json['street_name']?.toString(),
      buildingName: json['building_name']?.toString(),
      landmark: json['landmark']?.toString(),
      area: json['area']?.toString(),
      district: json['district']?.toString(),
      pincode: json['pincode']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      platform: json['platform']?.toString(),
      type: json['type']?.toString(),
    );
  }

  String get fullAddress {
    final parts = [doorNo, streetName, buildingName, landmark, area, district, pincode, state, country]
        .where((p) => p != null && p.isNotEmpty && p != 'null')
        .toList();
    return parts.join(', ');
  }

  String? get fullCompanyLogoUrl {
    if (companyLogo == null || companyLogo!.isEmpty) return null;
    if (companyLogo!.startsWith('http://localhost:5092')) {
      return companyLogo!.replaceFirst('http://localhost:5092', 'https://business-setup.srivagroups.in');
    }
    if (companyLogo!.startsWith('/')) {
      return 'https://business-setup.srivagroups.in$companyLogo';
    }
    return companyLogo;
  }

  String? get fullGstCertificateUrl {
    if (gstCertificate == null || gstCertificate!.isEmpty) return null;
    if (gstCertificate!.startsWith('http://localhost:5092')) {
      return gstCertificate!.replaceFirst('http://localhost:5092', 'https://business-setup.srivagroups.in');
    }
    if (gstCertificate!.startsWith('/')) {
      return 'https://business-setup.srivagroups.in$gstCertificate';
    }
    return gstCertificate;
  }

  bool get withGst => gstType == 'with_gst';
}

class SupplierRepository {
  /// Get all suppliers for this user
  static Future<List<SupplierApiModel>> getSuppliers() async {
    final url = Uri.parse('$_baseUrl/add-supplier?userid=$_userId');
    print('GET SUPPLIERS: $url');
    final response = await http.get(url);
    print('GET SUPPLIERS STATUS: ${response.statusCode}');
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => SupplierApiModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load suppliers: ${response.body}');
  }

/// Helper: get MIME type from file extension
static MediaType _getMimeType(String path) {
  final ext = path.split('.').last.toLowerCase();
  switch (ext) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');
    case 'png':
      return MediaType('image', 'png');
    case 'webp':
      return MediaType('image', 'webp');
    case 'svg':
      return MediaType('image', 'svg+xml');
    case 'pdf':
      return MediaType('application', 'pdf');
    default:
      return MediaType('image', 'jpeg'); // Fallback to JPEG
  }
}

  /// Add a new supplier via multipart/form-data
  static Future<void> addSupplier({
    required bool withGst,
    required String gstNumber,
    XFile? gstCertificate,
    required String businessName,
    required String businessEmail,
    required String phone,
    XFile? companyLogo,
    required String doorNo,
    required String streetName,
    required String buildingName,
    required String landmark,
    required String area,
    required String district,
    required String pincode,
    required String state,
    required String country,
    required List<String> platformNames,
    required List<String> shopTypeNames,
  }) async {
    final url = Uri.parse('$_baseUrl/add-supplier');
    print('POST SUPPLIER: $url');

    final request = http.MultipartRequest('POST', url);
    request.fields['userid'] = _userId;
    request.fields['businessid'] = _businessId;
    request.fields['store_id'] = _storeId;
    request.fields['gst_type'] = withGst ? 'with_gst' : 'without_gst';
    // Only send gst_number when with_gst is selected
    if (withGst && gstNumber.trim().isNotEmpty) {
      request.fields['gst_number'] = gstNumber.trim();
    }
    request.fields['business_name'] = businessName.trim();
    request.fields['business_email'] = businessEmail.trim();
    // Clean phone: keep only digits and leading +
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    request.fields['phone'] = cleanPhone;
    request.fields['door_no'] = doorNo.trim();
    request.fields['street_name'] = streetName.trim();
    request.fields['building_name'] = buildingName.trim();
    request.fields['landmark'] = landmark.trim();
    request.fields['area'] = area.trim();
    request.fields['district'] = district.trim();
    request.fields['pincode'] = pincode.trim();
    request.fields['state'] = state.trim();
    request.fields['country'] = country.trim();
    request.fields['platform'] = platformNames.join(', ');
    request.fields['type'] = shopTypeNames.join(', ');

    if (companyLogo != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'company_logo', companyLogo.path,
        contentType: _getMimeType(companyLogo.path),
      ));
    }
    if (gstCertificate != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'gst_certificate', gstCertificate.path,
        contentType: _getMimeType(gstCertificate.path),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('POST SUPPLIER STATUS: ${response.statusCode}');
    print('POST SUPPLIER BODY: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      // Parse validation errors for user-friendly message
      try {
        final json = jsonDecode(response.body);
        final errors = json['errors'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.join('\n'));
        }
        throw Exception(json['message'] ?? 'Failed to create supplier');
      } catch (parseErr) {
        if (parseErr is Exception) rethrow;
        throw Exception('Failed to create supplier: ${response.body}');
      }
    }
  }

  /// Update supplier via multipart/form-data
  static Future<void> updateSupplier({
    required int supplierId,
    required bool withGst,
    required String gstNumber,
    XFile? gstCertificate,
    String? existingGstCertificate,
    required String businessName,
    required String businessEmail,
    required String phone,
    XFile? companyLogo,
    String? existingCompanyLogo,
    required String doorNo,
    required String streetName,
    required String buildingName,
    required String landmark,
    required String area,
    required String district,
    required String pincode,
    required String state,
    required String country,
    required List<String> platformNames,
    required List<String> shopTypeNames,
  }) async {
    final url = Uri.parse('$_baseUrl/add-supplier/$supplierId');
    print('PUT SUPPLIER: $url');

    final request = http.MultipartRequest('PUT', url);
    request.fields['userid'] = _userId;
    request.fields['businessid'] = _businessId;
    request.fields['store_id'] = _storeId;
    request.fields['gst_type'] = withGst ? 'with_gst' : 'without_gst';
    // Only send gst_number when with_gst is selected
    if (withGst && gstNumber.trim().isNotEmpty) {
      request.fields['gst_number'] = gstNumber.trim();
    }
    request.fields['business_name'] = businessName.trim();
    request.fields['business_email'] = businessEmail.trim();
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    request.fields['phone'] = cleanPhone;
    request.fields['door_no'] = doorNo.trim();
    request.fields['street_name'] = streetName.trim();
    request.fields['building_name'] = buildingName.trim();
    request.fields['landmark'] = landmark.trim();
    request.fields['area'] = area.trim();
    request.fields['district'] = district.trim();
    request.fields['pincode'] = pincode.trim();
    request.fields['state'] = state.trim();
    request.fields['country'] = country.trim();
    request.fields['platform'] = platformNames.join(', ');
    request.fields['type'] = shopTypeNames.join(', ');

    if (companyLogo != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'company_logo', companyLogo.path,
        contentType: _getMimeType(companyLogo.path),
      ));
    } else if (existingCompanyLogo != null && existingCompanyLogo.isNotEmpty) {
      request.fields['company_logo'] = existingCompanyLogo;
    }

    if (gstCertificate != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'gst_certificate', gstCertificate.path,
        contentType: _getMimeType(gstCertificate.path),
      ));
    } else if (existingGstCertificate != null && existingGstCertificate.isNotEmpty) {
      request.fields['gst_certificate'] = existingGstCertificate;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('PUT SUPPLIER STATUS: ${response.statusCode}');
    print('PUT SUPPLIER BODY: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final json = jsonDecode(response.body);
        final errors = json['errors'] as List<dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.join('\n'));
        }
        throw Exception(json['message'] ?? 'Failed to update supplier');
      } catch (parseErr) {
        if (parseErr is Exception) rethrow;
        throw Exception('Failed to update supplier: ${response.body}');
      }
    }
  }

  /// Delete supplier
  static Future<void> deleteSupplier(int supplierId) async {
    final url = Uri.parse('$_baseUrl/add-supplier/$supplierId');
    print('DELETE SUPPLIER: $url');
    final response = await http.delete(url);
    print('DELETE SUPPLIER STATUS: ${response.statusCode}');
    print('DELETE SUPPLIER BODY: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to delete supplier');
      } catch (parseErr) {
        if (parseErr is Exception) rethrow;
        throw Exception('Failed to delete supplier: ${response.body}');
      }
    }
  }
}
