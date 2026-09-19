import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/business_entity_model.dart';
import '../data/models/business_step_model.dart';
import '../data/repositories/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});

final setupStepsProvider = Provider<List<BusinessStepModel>>((ref) {
  final repo = ref.watch(businessRepositoryProvider);
  return repo.getSetupSteps();
});

class BusinessListNotifier extends Notifier<List<BusinessProfile>> {
  @override
  List<BusinessProfile> build() {
    return ref.watch(businessRepositoryProvider).getBusinesses();
  }

  void addBusiness(BusinessProfile profile) {
    ref.read(businessRepositoryProvider).addBusiness(profile);
    state = List.from(ref.read(businessRepositoryProvider).getBusinesses());
  }

  void updateBusiness(BusinessProfile profile) {
    ref.read(businessRepositoryProvider).updateBusiness(profile);
    state = List.from(ref.read(businessRepositoryProvider).getBusinesses());
  }
}

final businessListProvider =
    NotifierProvider<BusinessListNotifier, List<BusinessProfile>>(
  BusinessListNotifier.new,
);

class SelectedBusinessIdNotifier extends Notifier<String> {
  @override
  String build() => '#21';

  void select(String id) {
    state = id;
  }
}

final selectedBusinessIdProvider =
    NotifierProvider<SelectedBusinessIdNotifier, String>(SelectedBusinessIdNotifier.new);

final activeBusinessProvider = Provider<BusinessProfile>((ref) {
  final list = ref.watch(businessListProvider);
  final selectedId = ref.watch(selectedBusinessIdProvider);
  return list.firstWhere(
    (b) => b.id == selectedId,
    orElse: () => list.isNotEmpty
        ? list.first
        : BusinessProfile(
            id: '#21',
            brandName: 'sabari',
            tradeName: 'sabari',
            entityType: EntityType.proprietorship,
            gstPreference: GstPreference.required,
            createdAt: DateTime.now(),
          ),
  );
});

// Setup Form State
class BusinessSetupState {
  final int currentStepIndex;
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

  const BusinessSetupState({
    this.currentStepIndex = 0,
    this.businessName = 'sabari',
    this.brandName = '',
    this.tradeName = '',
    this.isWithGst = true,
    this.udyamNumber = 'UDYAM-TN-01-0012345',
    this.gstNumber = '33AAAAA0000A1Z5',
    this.cinNumber = 'U12345TN2026PTC000000',
    this.selectedStructureIndex = 0,
    this.selectedEntityType = EntityType.proprietorship,
    this.selectedGst = GstPreference.required,
    this.pincode = '600001',
    this.fullAddress = '',
    this.city = 'Chennai',
    this.district = 'Chennai',
    this.stateName = 'Tamil Nadu',
    this.country = 'India',
    this.latitude = '13.0827',
    this.longitude = '80.2707',
    this.isSubmitting = false,
    // Step 2
    this.primaryEmail = 'contact@mycompany.com',
    this.phoneNumber = '9876543210',
    this.websiteUrl = 'https://www.mycompany.com',
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
    this.establishmentYear = '2024',
    this.employeeCount = '1 - 10 Employees (Micro)',
    this.turnoverRange = 'Select Turnover Range',
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
  });

  BusinessSetupState copyWith({
    int? currentStepIndex,
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
  }) {
    return BusinessSetupState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
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
    );
  }
}

class BusinessSetupController extends Notifier<BusinessSetupState> {
  @override
  BusinessSetupState build() => const BusinessSetupState();

  void setStep(int step) {
    state = state.copyWith(currentStepIndex: step);
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

  Future<bool> completeSetup() async {
    state = state.copyWith(isSubmitting: true);
    await Future.delayed(const Duration(milliseconds: 300));

    final newProfile = BusinessProfile(
      id: 'biz-${DateTime.now().millisecondsSinceEpoch}',
      brandName: state.businessName.isNotEmpty
          ? state.businessName
          : (state.brandName.isEmpty ? 'My New Business' : state.brandName),
      tradeName: state.tradeName.isEmpty ? '${state.businessName} Enterprise' : state.tradeName,
      entityType: state.selectedEntityType,
      gstPreference: state.isWithGst ? GstPreference.required : GstPreference.notApplicable,
      registrationStatus: 'Submitted',
      createdAt: DateTime.now(),
    );

    ref.read(businessListProvider.notifier).addBusiness(newProfile);
    state = state.copyWith(isSubmitting: false);
    return true;
  }
}

final businessSetupControllerProvider =
    NotifierProvider<BusinessSetupController, BusinessSetupState>(
  BusinessSetupController.new,
);

final businessSetupProvider = businessSetupControllerProvider;
