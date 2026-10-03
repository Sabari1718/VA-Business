import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_constants.dart';
import '../data/models/business_entity_model.dart';
import '../data/models/business_step_model.dart';
import '../data/models/business_structure_model.dart';
import '../data/repositories/business_repository.dart';
import '../data/repositories/business_api_service.dart';

final businessApiServiceProvider = Provider<BusinessApiService>((ref) {
  return BusinessApiService();
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final apiService = ref.watch(businessApiServiceProvider);
  return BusinessRepository(apiService: apiService);
});

final setupStepsProvider = Provider<List<BusinessStepModel>>((ref) {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.getSetupSteps();
});

class BusinessListNotifier extends Notifier<List<BusinessProfile>> {
  @override
  List<BusinessProfile> build() {
    Future.microtask(() => refreshBusinesses());
    return ref.watch(businessRepositoryProvider).getBusinesses();
  }

  Future<void> refreshBusinesses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ?? ApiConstants.defaultUserId;
      final repo = ref.read(businessRepositoryProvider);
      final list = await repo.fetchBusinessesFromApi(userId: effectiveUserId);
      state = List.from(list);

      if (list.isNotEmpty) {
        final currentSelected = ref.read(selectedBusinessIdProvider);
        final hasCurrent = list.any((b) => b.id == currentSelected);

        final activeBiz = hasCurrent
            ? list.firstWhere((b) => b.id == currentSelected)
            : list.first;

        ref.read(selectedBusinessIdProvider.notifier).select(activeBiz.id);

        final pId = int.tryParse(activeBiz.id.replaceAll('#', ''));
        if (pId != null && pId > 0) {
          await prefs.setString('propagator_id', pId.toString());
          ref.read(businessSetupProvider.notifier).setPropagatorId(pId);
          await repo.fetchSingleBusinessDetails(pId);
          state = List.from(repo.getBusinesses());
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error refreshing businesses: $e');
    }
  }

  void addBusiness(BusinessProfile profile) {
    ref.read(businessRepositoryProvider).addBusiness(profile);
    state = List.from(ref.read(businessRepositoryProvider).getBusinesses());
  }

  void updateBusiness(BusinessProfile profile) {
    ref.read(businessRepositoryProvider).updateBusiness(profile);
    state = List.from(ref.read(businessRepositoryProvider).getBusinesses());
  }

  Future<BusinessProfile?> loadBusinessOnLogin(dynamic propagatorId) async {
    final intId = propagatorId is int
        ? propagatorId
        : int.tryParse(propagatorId.toString().replaceAll('#', ''));
    if (intId == null) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('propagator_id', intId.toString());
      ref.read(businessSetupProvider.notifier).setPropagatorId(intId);
      ref.read(selectedBusinessIdProvider.notifier).select(intId.toString());

      final repo = ref.read(businessRepositoryProvider);
      final updated = await repo.fetchSingleBusinessDetails(intId);
      if (updated != null) {
        state = List.from(repo.getBusinesses());
      }
      return updated;
    } catch (e) {
      debugPrint('⚠️ Error loading business on login: $e');
      return null;
    }
  }
}

final businessListProvider =
    NotifierProvider<BusinessListNotifier, List<BusinessProfile>>(
  BusinessListNotifier.new,
);

class SelectedBusinessIdNotifier extends Notifier<String> {
  @override
  String build() => '';

  void select(String id) {
    state = id;
  }
}

final selectedBusinessIdProvider =
    NotifierProvider<SelectedBusinessIdNotifier, String>(SelectedBusinessIdNotifier.new);

final activeBusinessProvider = Provider<BusinessProfile>((ref) {
  final list = ref.watch(businessListProvider);
  final selectedId = ref.watch(selectedBusinessIdProvider);
  if (list.isNotEmpty) {
    final match = list.where((b) => b.id == selectedId);
    if (match.isNotEmpty) return match.first;
    return list.first;
  }
  return BusinessProfile(
    id: '#26',
    brandName: 'circuit',
    tradeName: 'circuit',
    businessName: 'circuit',
    entityType: EntityType.proprietorship,
    gstPreference: GstPreference.required,
    createdAt: DateTime.now(),
  );
});

// Setup Form State
class BusinessSetupState {
  final int currentStepIndex;
  final int? propagatorId;
  final String businessName;
  final String brandName;
  final String tradeName;
  final bool isWithGst;
  final String udyamNumber;
  final String gstNumber;
  final String cinNumber;
  final int selectedStructureIndex;
  final EntityType selectedEntityType;
  final GstPreference selectedGst;
  final String pincode;
  final String fullAddress;
  final String city;
  final String district;
  final String stateName;
  final String country;
  final String latitude;
  final String longitude;
  final bool isSubmitting;
  final bool isPincodeLoading;
  final String? apiErrorMessage;

  // Step 2: Contact & Branding
  final String primaryEmail;
  final String phoneNumber;
  final String websiteUrl;
  final String? companyLogoName;
  final String? companyLogoPath;
  final String? companyIconName;
  final String? companyIconPath;

  // Step 3: Document Uploads
  final String? udyamFileName;
  final String? udyamFilePath;
  final bool isUdyamUploaded;
  final String? gstFileName;
  final String? gstFilePath;
  final bool isGstUploaded;
  final String? cinFileName;
  final String? cinFilePath;
  final bool isCinUploaded;
  final String? gpsFileName;
  final String? gpsFilePath;
  final bool isGpsUploaded;

  // Step 4: Bank Account Details
  final String accountHolderName;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String accountType; // Savings, Current, Other
  final String accountStatus; // Active
  final String bankAddress;
  final String? chequeFileName;
  final String? chequeFilePath;

  // Step 5: Company Scale & Tier Selection
  final String establishmentYear;
  final String employeeCount;
  final String turnoverRange;
  final String selectedTier; // STARTUP, STANDARD, CORPORATE

  // Step 6: Business Type
  final List<String> selectedBusinessTypes;

  // Step 7: Business Category Classification
  final String? selectedSectorTitle;
  final String? selectedSector;
  final String? selectedSubSector;
  final List<String> selectedPrimaryCategories;

  // Step 8: Brand Selection & Configuration
  final bool isConfigurationSaved;
  final List<String> selectedBrands;
  final List<Map<String, dynamic>> savedCategoryConfigurations;

  const BusinessSetupState({
    this.currentStepIndex = 0,
    this.propagatorId,
    this.businessName = '',
    this.brandName = '',
    this.tradeName = '',
    this.isWithGst = true,
    this.udyamNumber = '',
    this.gstNumber = '',
    this.cinNumber = '',
    this.selectedStructureIndex = 0,
    this.selectedEntityType = EntityType.proprietorship,
    this.selectedGst = GstPreference.required,
    this.pincode = '',
    this.fullAddress = '',
    this.city = '',
    this.district = '',
    this.stateName = '',
    this.country = '',
    this.latitude = '13.0827',
    this.longitude = '80.2707',
    this.isSubmitting = false,
    this.isPincodeLoading = false,
    this.apiErrorMessage,
    // Step 2
    this.primaryEmail = '',
    this.phoneNumber = '',
    this.websiteUrl = '',
    this.companyLogoName,
    this.companyLogoPath,
    this.companyIconName,
    this.companyIconPath,
    // Step 3
    this.udyamFileName,
    this.udyamFilePath,
    this.isUdyamUploaded = false,
    this.gstFileName,
    this.gstFilePath,
    this.isGstUploaded = false,
    this.cinFileName,
    this.cinFilePath,
    this.isCinUploaded = false,
    this.gpsFileName,
    this.gpsFilePath,
    this.isGpsUploaded = false,
    // Step 4
    this.accountHolderName = '',
    this.bankName = '',
    this.branchName = '',
    this.accountNumber = '',
    this.confirmAccountNumber = '',
    this.ifscCode = '',
    this.accountType = 'Savings',
    this.accountStatus = 'Active',
    this.bankAddress = '',
    this.chequeFileName,
    this.chequeFilePath,
    // Step 5
    this.establishmentYear = '',
    this.employeeCount = '1 - 10 Employees (Micro)',
    this.turnoverRange = 'Up to 20 Lakhs',
    this.selectedTier = 'STARTUP',
    // Step 6
    this.selectedBusinessTypes = const ['Trade', 'Retail'],
    // Step 7
    this.selectedSectorTitle,
    this.selectedSector,
    this.selectedSubSector,
    this.selectedPrimaryCategories = const [],
    // Step 8
    this.isConfigurationSaved = false,
    this.selectedBrands = const [],
    this.savedCategoryConfigurations = const [],
  });

  BusinessSetupState copyWith({
    int? currentStepIndex,
    int? propagatorId,
    String? businessName,
    String? brandName,
    String? tradeName,
    bool? isWithGst,
    String? udyamNumber,
    String? gstNumber,
    String? cinNumber,
    int? selectedStructureIndex,
    EntityType? selectedEntityType,
    GstPreference? selectedGst,
    String? pincode,
    String? fullAddress,
    String? city,
    String? district,
    String? stateName,
    String? country,
    String? latitude,
    String? longitude,
    bool? isSubmitting,
    bool? isPincodeLoading,
    String? apiErrorMessage,
    String? primaryEmail,
    String? phoneNumber,
    String? websiteUrl,
    String? companyLogoName,
    String? companyLogoPath,
    String? companyIconName,
    String? companyIconPath,
    String? udyamFileName,
    String? udyamFilePath,
    bool? isUdyamUploaded,
    String? gstFileName,
    String? gstFilePath,
    bool? isGstUploaded,
    String? cinFileName,
    String? cinFilePath,
    bool? isCinUploaded,
    String? gpsFileName,
    String? gpsFilePath,
    bool? isGpsUploaded,
    String? accountHolderName,
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? accountType,
    String? accountStatus,
    String? bankAddress,
    String? chequeFileName,
    String? chequeFilePath,
    String? establishmentYear,
    String? employeeCount,
    String? turnoverRange,
    String? selectedTier,
    List<String>? selectedBusinessTypes,
    String? selectedSectorTitle,
    String? selectedSector,
    String? selectedSubSector,
    List<String>? selectedPrimaryCategories,
    bool? isConfigurationSaved,
    List<String>? selectedBrands,
    List<Map<String, dynamic>>? savedCategoryConfigurations,
  }) {
    return BusinessSetupState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      propagatorId: propagatorId ?? this.propagatorId,
      businessName: businessName ?? this.businessName,
      brandName: brandName ?? this.brandName,
      tradeName: tradeName ?? this.tradeName,
      isWithGst: isWithGst ?? this.isWithGst,
      udyamNumber: udyamNumber ?? this.udyamNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      cinNumber: cinNumber ?? this.cinNumber,
      selectedStructureIndex: selectedStructureIndex ?? this.selectedStructureIndex,
      selectedEntityType: selectedEntityType ?? this.selectedEntityType,
      selectedGst: selectedGst ?? this.selectedGst,
      pincode: pincode ?? this.pincode,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      district: district ?? this.district,
      stateName: stateName ?? this.stateName,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isPincodeLoading: isPincodeLoading ?? this.isPincodeLoading,
      apiErrorMessage: apiErrorMessage,
      primaryEmail: primaryEmail ?? this.primaryEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      companyLogoName: companyLogoName ?? this.companyLogoName,
      companyLogoPath: companyLogoPath ?? this.companyLogoPath,
      companyIconName: companyIconName ?? this.companyIconName,
      companyIconPath: companyIconPath ?? this.companyIconPath,
      udyamFileName: udyamFileName ?? this.udyamFileName,
      udyamFilePath: udyamFilePath ?? this.udyamFilePath,
      isUdyamUploaded: isUdyamUploaded ?? this.isUdyamUploaded,
      gstFileName: gstFileName ?? this.gstFileName,
      gstFilePath: gstFilePath ?? this.gstFilePath,
      isGstUploaded: isGstUploaded ?? this.isGstUploaded,
      cinFileName: cinFileName ?? this.cinFileName,
      cinFilePath: cinFilePath ?? this.cinFilePath,
      isCinUploaded: isCinUploaded ?? this.isCinUploaded,
      gpsFileName: gpsFileName ?? this.gpsFileName,
      gpsFilePath: gpsFilePath ?? this.gpsFilePath,
      isGpsUploaded: isGpsUploaded ?? this.isGpsUploaded,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
      accountStatus: accountStatus ?? this.accountStatus,
      bankAddress: bankAddress ?? this.bankAddress,
      chequeFileName: chequeFileName ?? this.chequeFileName,
      chequeFilePath: chequeFilePath ?? this.chequeFilePath,
      establishmentYear: establishmentYear ?? this.establishmentYear,
      employeeCount: employeeCount ?? this.employeeCount,
      turnoverRange: turnoverRange ?? this.turnoverRange,
      selectedTier: selectedTier ?? this.selectedTier,
      selectedBusinessTypes: selectedBusinessTypes ?? this.selectedBusinessTypes,
      selectedSectorTitle: selectedSectorTitle ?? this.selectedSectorTitle,
      selectedSector: selectedSector ?? this.selectedSector,
      selectedSubSector: selectedSubSector ?? this.selectedSubSector,
      selectedPrimaryCategories: selectedPrimaryCategories ?? this.selectedPrimaryCategories,
      isConfigurationSaved: isConfigurationSaved ?? this.isConfigurationSaved,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      savedCategoryConfigurations: savedCategoryConfigurations ?? this.savedCategoryConfigurations,
    );
  }
}

class BusinessSetupController extends Notifier<BusinessSetupState> {
  @override
  BusinessSetupState build() {
    _loadSavedPropagatorId();
    return const BusinessSetupState();
  }

  void setSavedCategoryConfigurations(List<Map<String, dynamic>> configs) {
    state = state.copyWith(savedCategoryConfigurations: configs);
  }

  Future<void> _loadSavedPropagatorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('propagator_id');
      if (savedId != null) {
        final parsed = int.tryParse(savedId);
        if (parsed != null) {
          state = state.copyWith(propagatorId: parsed);
        }
      }
    } catch (_) {}
  }

  void setStep(int step) {
    state = state.copyWith(currentStepIndex: step);
  }

  void setPropagatorId(int id) {
    state = state.copyWith(propagatorId: id);
  }

  void updateBusinessName(String name) {
    state = state.copyWith(businessName: name);
  }

  void setWithGst(bool value) {
    state = state.copyWith(isWithGst: value);
  }

  void updateUdyamNumber(String val) {
    state = state.copyWith(udyamNumber: val);
  }

  void updateGstNumber(String val) {
    state = state.copyWith(gstNumber: val);
  }

  void updateCinNumber(String val) {
    state = state.copyWith(cinNumber: val);
  }

  void selectStructure(int index) {
    state = state.copyWith(selectedStructureIndex: index);
  }

  void setSelectedStructure(int index) {
    state = state.copyWith(selectedStructureIndex: index);
  }

  void updatePincode(String val) {
    state = state.copyWith(pincode: val);
  }

  void updateFullAddress(String val) {
    state = state.copyWith(fullAddress: val);
  }

  void updateCity(String val) {
    state = state.copyWith(city: val);
  }

  void updateDistrict(String val) {
    state = state.copyWith(district: val);
  }

  void updateState(String val) {
    state = state.copyWith(stateName: val);
  }

  void updateStateName(String val) {
    state = state.copyWith(stateName: val);
  }

  void updateCountry(String val) {
    state = state.copyWith(country: val);
  }

  void updateLatitude(String val) {
    state = state.copyWith(latitude: val);
  }

  void updateLongitude(String val) {
    state = state.copyWith(longitude: val);
  }

  void updateBrandName(String name) {
    state = state.copyWith(brandName: name);
  }

  void updateTradeName(String name) {
    state = state.copyWith(tradeName: name);
  }

  void updateEntityType(EntityType type) {
    state = state.copyWith(selectedEntityType: type);
  }

  void updateGstPreference(GstPreference gst) {
    state = state.copyWith(selectedGst: gst);
  }

  // Step 2 Updaters
  void updatePrimaryEmail(String val) => state = state.copyWith(primaryEmail: val);
  void updatePhoneNumber(String val) => state = state.copyWith(phoneNumber: val);
  void updateWebsiteUrl(String val) => state = state.copyWith(websiteUrl: val);
  void updateCompanyLogo(String? name, [String? path]) =>
      state = state.copyWith(companyLogoName: name, companyLogoPath: path);
  void updateCompanyIcon(String? name, [String? path]) =>
      state = state.copyWith(companyIconName: name, companyIconPath: path);

  // Step 3 Updaters
  void updateUdyamFile(String? fileName, bool uploaded, [String? path]) =>
      state = state.copyWith(udyamFileName: fileName, isUdyamUploaded: uploaded, udyamFilePath: path);
  void updateGstFile(String? fileName, bool uploaded, [String? path]) =>
      state = state.copyWith(gstFileName: fileName, isGstUploaded: uploaded, gstFilePath: path);
  void updateCinFile(String? fileName, bool uploaded, [String? path]) =>
      state = state.copyWith(cinFileName: fileName, isCinUploaded: uploaded, cinFilePath: path);
  void updateGpsFile(String? fileName, bool uploaded, [String? path]) =>
      state = state.copyWith(gpsFileName: fileName, isGpsUploaded: uploaded, gpsFilePath: path);

  // Step 4 Updaters
  void updateAccountHolder(String val) => state = state.copyWith(accountHolderName: val);
  void updateBankName(String val) => state = state.copyWith(bankName: val);
  void updateBranchName(String val) => state = state.copyWith(branchName: val);
  void updateAccountNumber(String val) => state = state.copyWith(accountNumber: val);
  void updateConfirmAccountNumber(String val) => state = state.copyWith(confirmAccountNumber: val);
  void updateIfscCode(String val) => state = state.copyWith(ifscCode: val);
  void updateAccountType(String val) => state = state.copyWith(accountType: val);
  void updateAccountStatus(String val) => state = state.copyWith(accountStatus: val);
  void updateBankAddress(String val) => state = state.copyWith(bankAddress: val);
  void updateChequeFile(String? val, [String? path]) =>
      state = state.copyWith(chequeFileName: val, chequeFilePath: path);

  // Step 5 Updaters
  void updateEstablishmentYear(String val) => state = state.copyWith(establishmentYear: val);
  void updateEmployeeCount(String val) => state = state.copyWith(employeeCount: val);
  void updateTurnoverRange(String val) => state = state.copyWith(turnoverRange: val);
  void updateSelectedTier(String val) => state = state.copyWith(selectedTier: val);

  // Step 6 Updaters: Business Type
  void toggleBusinessType(String type) {
    final list = List<String>.from(state.selectedBusinessTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    state = state.copyWith(selectedBusinessTypes: list);
  }

  // Step 7 Updaters: Sector & Category
  void updateSectorTitle(String? val) => state = state.copyWith(selectedSectorTitle: val);
  void updateSector(String? val) => state = state.copyWith(selectedSector: val);
  void updateSubSector(String? val) => state = state.copyWith(selectedSubSector: val);
  void togglePrimaryCategory(String category) {
    final list = List<String>.from(state.selectedPrimaryCategories);
    if (list.contains(category)) {
      list.remove(category);
    } else {
      list.add(category);
    }
    state = state.copyWith(selectedPrimaryCategories: list);
  }

  // Step 8 Updaters: Brand Selection & Configuration
  void saveConfigurationCard() {
    state = state.copyWith(isConfigurationSaved: true);
  }

  void toggleBrand(String brand) {
    final list = List<String>.from(state.selectedBrands);
    if (list.contains(brand)) {
      list.remove(brand);
    } else {
      list.add(brand);
    }
    state = state.copyWith(selectedBrands: list);
  }

  void reset() {
    state = const BusinessSetupState();
  }

  // ===========================================================================
  // REAL API CONNECTIVITY METHODS (WITH FULL TERMINAL LOGGING)
  // ===========================================================================

  /// Fetch Pincode Details API
  Future<bool> fetchPincode(String pincode) async {
    state = state.copyWith(isPincodeLoading: true);
    final repo = ref.read(businessRepositoryProvider);
    final details = await repo.apiService.fetchPincodeDetails(pincode);
    state = state.copyWith(isPincodeLoading: false);

    if (details != null) {
      state = state.copyWith(
        district: details['district']?.isNotEmpty ?? false ? details['district'] : state.district,
        stateName: details['state']?.isNotEmpty ?? false ? details['state'] : state.stateName,
        city: details['city']?.isNotEmpty ?? false ? details['city'] : state.city,
        country: details['country']?.isNotEmpty ?? false ? details['country'] : state.country,
      );
      return true;
    }
    return false;
  }

  /// Step 0: Save Propagator Details
  Future<bool> submitStep0Details() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final structureTitle = businessStructuresList[state.selectedStructureIndex.clamp(0, businessStructuresList.length - 1)].title;

      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;

      final res = await repo.apiService.createPropagatorDetails(
        userId: effectiveUserId,
        businessName: state.businessName.isNotEmpty ? state.businessName : 'sabari',
        gstStatus: state.isWithGst ? 'Registered' : 'Unregistered',
        udyamNumber: state.udyamNumber,
        gstNumber: state.isWithGst ? state.gstNumber : null,
        cinNumber: state.cinNumber,
        businessStructure: structureTitle,
      );

      int? newId;
      if (res['data'] is Map) {
        newId = int.tryParse(res['data']['id']?.toString() ?? '');
      } else if (res['data'] is int) {
        newId = res['data'];
      } else if (res['id'] != null) {
        newId = int.tryParse(res['id'].toString());
      }

      final effectiveId = newId ?? state.propagatorId ?? 14;
      state = state.copyWith(propagatorId: effectiveId, isSubmitting: false);

      await prefs.setString('propagator_id', effectiveId.toString());
      await prefs.setString('businessName', state.businessName);

      // Immediately refresh businesses from API so newly created business shows up in list & dropdown
      await ref.read(businessListProvider.notifier).refreshBusinesses();

      return true;
    } catch (e) {
      debugPrint('❌ [Step 0 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 1: Save Propagator Address
  Future<bool> submitStep1Address() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final pId = state.propagatorId ?? 14;

      await repo.apiService.createPropagatorAddress(
        propagatorId: pId,
        pincode: state.pincode.isNotEmpty ? state.pincode : '600001',
        fullAddress: state.fullAddress.isNotEmpty ? state.fullAddress : 'Official Business Address',
        cityTaluk: state.city.isNotEmpty ? state.city : 'Chennai',
        district: state.district.isNotEmpty ? state.district : 'Chennai',
        state: state.stateName.isNotEmpty ? state.stateName : 'Tamil Nadu',
        country: state.country.isNotEmpty ? state.country : 'India',
        latitude: double.tryParse(state.latitude),
        longitude: double.tryParse(state.longitude),
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 1 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 2: Save Propagator Contact
  Future<bool> submitStep2Contact() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final pId = state.propagatorId ?? 14;

      await repo.apiService.createPropagatorContact(
        propagatorId: pId,
        primaryEmail: state.primaryEmail.isNotEmpty ? state.primaryEmail : 'contact@sabari.com',
        phoneNumber: state.phoneNumber.isNotEmpty ? state.phoneNumber : '9876543210',
        companyWebsiteUrl: state.websiteUrl.isNotEmpty ? state.websiteUrl : null,
        companyLogo: state.companyLogoPath,
        companyIcon: state.companyIconPath,
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 2 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 3: Save Propagator Documents
  Future<bool> submitStep3Documents() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final pId = state.propagatorId ?? 14;

      await repo.apiService.createPropagatorDocuments(
        propagatorId: pId,
        udyamCertificate: state.udyamFilePath,
        gstCertificate: state.gstFilePath,
        cinCertificate: state.cinFilePath,
        geotaggedStorePhoto: state.gpsFilePath,
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 3 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 4: Save Propagator Bank Details
  Future<bool> submitStep4Bank() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final pId = state.propagatorId ?? 14;

      await repo.apiService.createPropagatorBankDetails(
        propagatorId: pId,
        accountHolderName: state.accountHolderName.isNotEmpty ? state.accountHolderName : 'sabari',
        bankName: state.bankName.isNotEmpty ? state.bankName : 'HDFC Bank',
        branchName: state.branchName.isNotEmpty ? state.branchName : 'Main Branch',
        accountNumber: state.accountNumber.isNotEmpty ? state.accountNumber : '50100456789012',
        ifscCode: state.ifscCode.isNotEmpty ? state.ifscCode : 'HDFC0001234',
        accountType: state.accountType,
        accountStatus: state.accountStatus,
        bankAddress: state.bankAddress.isNotEmpty ? state.bankAddress : 'Chennai',
        supportingDocument: state.chequeFilePath,
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 4 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 5: Save Propagator Company Scale & Tier
  Future<bool> submitStep5CompanyScale() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final pId = state.propagatorId ?? 14;

      int estYear = int.tryParse(state.establishmentYear) ?? 2024;
      await repo.apiService.createPropagatorCompanyScale(
        propagatorId: pId,
        establishmentYear: estYear,
        numberOfEmployees: state.employeeCount,
        turnoverIncome: state.turnoverRange,
        companyTier: state.selectedTier,
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 5 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 6: Save Propagator Business Type
  Future<bool> submitStep6BusinessType() async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();
      final effectiveUserId = prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          ApiConstants.defaultUserId;
      final pId = state.propagatorId ?? 14;

      final joinedTypes = state.selectedBusinessTypes.join(', ');
      await repo.apiService.createPropagatorBusinessType(
        propagatorId: pId,
        businessType: joinedTypes.isNotEmpty ? joinedTypes : 'Retail, Wholesale',
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 6 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 7: Save Propagator Category Mapping
  Future<bool> submitStep7CategoryMapping({
    int? sectorTitleId,
    int? sectorId,
    int? subSectorId,
    List<dynamic>? primaryCategories,
    Map<String, dynamic>? brands,
    List<String>? brandNames,
    int? propagatorId,
    String? userId,
  }) async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();

      int pId = propagatorId ?? state.propagatorId ?? 0;
      if (pId <= 0) {
        final activeBiz = ref.read(activeBusinessProvider);
        pId = int.tryParse(activeBiz.id.replaceAll('#', '').trim()) ?? 0;
      }
      if (pId <= 0) {
        final saved = prefs.getString('propagator_id');
        if (saved != null) {
          final parsed = int.tryParse(saved);
          if (parsed != null && parsed > 0) pId = parsed;
        }
      }
      if (pId <= 0) {
        pId = 77; // Fallback to active propagator ID
      }

      final effectiveUserId = userId ??
          prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          '4282284422';

      await repo.apiService.createPropagatorBusinessMapping(
        propagatorId: pId,
        sectorTitleId: sectorTitleId ?? 1,
        sectorId: sectorId ?? 1,
        subSectorId: subSectorId ?? 1,
        primaryCategories: primaryCategories ?? state.selectedPrimaryCategories,
        brands: brands,
        brandNames: brandNames,
        userId: effectiveUserId,
      );

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 7 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  /// Step 8: Save Propagator Brand Mapping & Complete Setup
  Future<bool> submitStep8BrandMapping({
    int? propagatorId,
    String? userId,
    List<int>? brandIds,
    List<String>? brandNames,
    Map<String, dynamic>? brands,
  }) async {
    state = state.copyWith(isSubmitting: true, apiErrorMessage: null);
    try {
      final repo = ref.read(businessRepositoryProvider);
      final prefs = await SharedPreferences.getInstance();

      int pId = propagatorId ?? state.propagatorId ?? 0;
      if (pId <= 0) {
        final activeBiz = ref.read(activeBusinessProvider);
        pId = int.tryParse(activeBiz.id.replaceAll('#', '').trim()) ?? 0;
      }
      if (pId <= 0) {
        final saved = prefs.getString('propagator_id');
        if (saved != null) {
          final parsed = int.tryParse(saved);
          if (parsed != null && parsed > 0) pId = parsed;
        }
      }
      if (pId <= 0) {
        pId = 77; // Fallback to active propagator ID
      }

      final effectiveUserId = userId ??
          prefs.getString('user_main_id') ??
          prefs.getString('user_id') ??
          '4282284422';

      final effectiveBrandNames = brandNames ?? state.selectedBrands;
      final effectiveBrands = brands ?? {'default': state.selectedBrands};

      await repo.apiService.createPropagatorBrandMapping(
        propagatorId: pId,
        userId: effectiveUserId,
        brandIds: brandIds,
        brandNames: effectiveBrandNames,
        brands: effectiveBrands,
      );

      // Call GET /propagator-details?user_id={userId} to refresh user businesses
      try {
        await repo.apiService.getPropagatorDetailsByUser(effectiveUserId);
      } catch (_) {}

      // Refresh real business list from backend
      await ref.read(businessListProvider.notifier).refreshBusinesses();

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      debugPrint('❌ [Step 8 API Error]: $e');
      state = state.copyWith(isSubmitting: false, apiErrorMessage: e.toString());
      return false;
    }
  }

  Future<bool> completeSetup({
    int? propagatorId,
    String? userId,
    List<int>? brandIds,
    List<String>? brandNames,
    Map<String, dynamic>? brands,
  }) async {
    return await submitStep8BrandMapping(
      propagatorId: propagatorId,
      userId: userId,
      brandIds: brandIds,
      brandNames: brandNames,
      brands: brands,
    );
  }
}

final businessSetupControllerProvider =
    NotifierProvider<BusinessSetupController, BusinessSetupState>(
  BusinessSetupController.new,
);

final businessSetupProvider = businessSetupControllerProvider;
