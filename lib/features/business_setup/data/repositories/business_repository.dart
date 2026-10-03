import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../models/business_step_model.dart';
import '../models/business_entity_model.dart';
import 'business_api_service.dart';
import '../../../../core/network/api_constants.dart';

class BusinessRepository {
  final BusinessApiService apiService;

  BusinessRepository({BusinessApiService? apiService})
      : apiService = apiService ?? BusinessApiService();

  List<BusinessStepModel> getSetupSteps() {
    return const [
      BusinessStepModel(
        stepNumber: '01',
        title: 'Basic Business Info',
        description:
            'Define your official brand or trade name and choose your GST registration preference.',
        icon: Icons.edit_note_rounded,
        badgeText: 'STEP 01',
        bgLightColor: AppColors.step1Bg,
        iconColor: AppColors.step1Icon,
        badgeBorderColor: AppColors.step1BadgeBorder,
        badgeTextColor: AppColors.step1BadgeText,
        badgeBgColor: AppColors.step1BadgeBg,
      ),
      BusinessStepModel(
        stepNumber: '02',
        title: 'Entity Structure',
        description:
            'Choose from Proprietorship, Partnership, Pvt Ltd, OPC, or LLP legal models.',
        icon: Icons.account_tree_outlined,
        badgeText: 'STEP 02',
        bgLightColor: AppColors.step2Bg,
        iconColor: AppColors.step2Icon,
        badgeBorderColor: AppColors.step2BadgeBorder,
        badgeTextColor: AppColors.step2BadgeText,
        badgeBgColor: AppColors.step2BadgeBg,
      ),
      BusinessStepModel(
        stepNumber: '03',
        title: 'Legal Insights',
        description:
            'Understand key rights, tax benefits, and compliance requirements instantly.',
        icon: Icons.verified_user_outlined,
        badgeText: 'STEP 03',
        bgLightColor: AppColors.step3Bg,
        iconColor: AppColors.step3Icon,
        badgeBorderColor: AppColors.step3BadgeBorder,
        badgeTextColor: AppColors.step3BadgeText,
        badgeBgColor: AppColors.step3BadgeBg,
      ),
    ];
  }

  final List<BusinessProfile> _sampleBusinesses = [
    BusinessProfile(
      id: '#14',
      brandName: 'sabari',
      tradeName: 'sabari',
      businessName: 'sabari',
      businessType: 'Retail & Wholesale',
      entityType: EntityType.proprietorship,
      gstPreference: GstPreference.required,
      registrationStatus: 'Active',
      tier: 'Startup',
      establishmentYear: '2024',
      employeeCount: '1-10 Employees',
      turnoverRange: 'Up to 20 Lakhs',
      phone: '+91 9965437236',
      email: 'contact@sabari.com',
      website: 'https://sabari.com',
      pincode: '600001',
      city: 'Chennai',
      district: 'Chennai',
      stateName: 'Tamil Nadu',
      country: 'India',
      fullAddress: 'No 12, Main Road, Industrial Estate, Adyar',
      latitude: '13.0827',
      longitude: '80.2707',
      gstNumber: '33AAAAA0000A1Z5',
      udyamNumber: 'UDYAM-TN-01-0012345',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<BusinessProfile> getBusinesses() => List.unmodifiable(_sampleBusinesses);

  Future<List<BusinessProfile>> fetchBusinessesFromApi({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetUserId = userId ??
          prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final list = await apiService.getPropagatorDetails(
        userId: targetUserId,
      );
      if (list.isNotEmpty) {
        final List<BusinessProfile> apiProfiles = [];
        for (final item in list) {
          apiProfiles.add(BusinessProfile.fromApi(item));
        }
        _sampleBusinesses.clear();
        _sampleBusinesses.addAll(apiProfiles);

        // Asynchronously enrich the first (active) business with contacts/addresses in background
        final firstId = int.tryParse(list.first['id']?.toString() ?? '');
        if (firstId != null) {
          try {
            final results = await Future.wait([
              apiService.getPropagatorAddresses(firstId),
              apiService.getPropagatorContacts(firstId),
              apiService.getPropagatorCompanies(firstId),
              apiService.getPropagatorBusinessTypes(firstId),
            ]);
            final addresses = results[0];
            final contacts = results[1];
            final companies = results[2];
            final types = results[3];

            // Web reads t[t.length - 1] from propagator-addresses, so we use addresses.last
            final selectedAddress = addresses.isNotEmpty ? addresses.last : null;
            final selectedContact = contacts.isNotEmpty ? contacts.last : null;

            if (companies.isNotEmpty) companies.sort(_compareByDateOrId);
            if (types.isNotEmpty) types.sort(_compareByDateOrId);

            final enriched = BusinessProfile.fromApi(
              list.first,
              address: selectedAddress,
              contact: selectedContact,
              company: companies.isNotEmpty ? companies.first : null,
              businessTypeData: types.isNotEmpty ? types.first : null,
            );
            if (_sampleBusinesses.isNotEmpty) {
              _sampleBusinesses[0] = enriched;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching businesses from API: $e');
    }
    return getBusinesses();
  }

  /// Fetches all 6 details APIs for a propagator when user logs into a business
  Future<BusinessProfile?> fetchSingleBusinessDetails(int propagatorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;

      // 1. Fetch live propagator details so edits on Web reflect immediately
      Map<String, dynamic> propItem = {};
      try {
        final propList = await apiService.getPropagatorDetails(userId: effectiveUserId);
        propItem = propList.firstWhere(
          (p) => p['id']?.toString() == propagatorId.toString(),
          orElse: () => <String, dynamic>{},
        );
      } catch (e) {
        debugPrint('⚠️ Error fetching prop list for single business: $e');
      }

      // 2. Fetch all 6 related details (addresses, contacts, banks, etc.)
      final fullData = await apiService.getPropagatorFullDetails(propagatorId);
      final contacts = fullData['contacts'] as List<Map<String, dynamic>>? ?? [];
      final addresses = fullData['addresses'] as List<Map<String, dynamic>>? ?? [];
      final companies = fullData['companies'] as List<Map<String, dynamic>>? ?? [];
      final types = fullData['business_types'] as List<Map<String, dynamic>>? ?? [];
      final documents = fullData['documents'] as List<Map<String, dynamic>>? ?? [];
      final banks = fullData['bank_details'] as List<Map<String, dynamic>>? ?? [];

      // Web explicitly accesses t[t.length - 1] (the primary record), so we use addresses.last / contacts.last
      final selectedAddress = addresses.isNotEmpty ? addresses.last : null;
      final selectedContact = contacts.isNotEmpty ? contacts.last : null;

      if (companies.isNotEmpty) companies.sort(_compareByDateOrId);
      if (types.isNotEmpty) types.sort(_compareByDateOrId);
      if (banks.isNotEmpty) banks.sort(_compareByDateOrId);

      final existingIndex = _sampleBusinesses.indexWhere(
        (b) => b.id == '#$propagatorId' || b.id == '$propagatorId',
      );

      final Map<String, dynamic> baseJson = propItem.isNotEmpty
          ? propItem
          : (existingIndex != -1
              ? {
                  'id': propagatorId,
                  'business_name': _sampleBusinesses[existingIndex].businessName,
                  'trade_name': _sampleBusinesses[existingIndex].tradeName,
                  'gst_number': _sampleBusinesses[existingIndex].gstNumber,
                  'udyam_registration_number': _sampleBusinesses[existingIndex].udyamNumber,
                  'cin_number': _sampleBusinesses[existingIndex].cinNumber,
                  'business_structure': _sampleBusinesses[existingIndex].entityType.label,
                  'gst_registration_status': _sampleBusinesses[existingIndex].gstPreference.label,
                  'created_at': _sampleBusinesses[existingIndex].createdAt.toIso8601String(),
                }
              : {
                  'id': propagatorId,
                  'business_name': 'Business #$propagatorId',
                });

      final updatedProfile = BusinessProfile.fromApi(
        baseJson,
        contact: selectedContact,
        address: selectedAddress,
        company: companies.isNotEmpty ? companies.first : null,
        businessTypeData: types.isNotEmpty ? types.first : null,
        bank: banks.isNotEmpty ? banks.first : null,
        document: documents.isNotEmpty ? documents.first : null,
      );

      if (existingIndex != -1) {
        _sampleBusinesses[existingIndex] = updatedProfile;
      } else {
        _sampleBusinesses.insert(0, updatedProfile);
      }

      return updatedProfile;
    } catch (e) {
      debugPrint('⚠️ Error fetching single business details: $e');
      return null;
    }
  }

  int _compareByDateOrId(Map<String, dynamic> a, Map<String, dynamic> b) {
    final aDate = a['updated_at']?.toString() ?? a['created_at']?.toString() ?? '';
    final bDate = b['updated_at']?.toString() ?? b['created_at']?.toString() ?? '';
    if (aDate.isNotEmpty && bDate.isNotEmpty) {
      final comp = bDate.compareTo(aDate);
      if (comp != 0) return comp;
    }
    final aId = int.tryParse(a['id']?.toString() ?? '') ?? 0;
    final bId = int.tryParse(b['id']?.toString() ?? '') ?? 0;
    return bId.compareTo(aId);
  }

  void addBusiness(BusinessProfile profile) {
    _sampleBusinesses.insert(0, profile);
  }

  void updateBusiness(BusinessProfile updated) {
    final idx = _sampleBusinesses.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _sampleBusinesses[idx] = updated;
    }
  }
}
