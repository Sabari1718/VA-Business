import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/shop_model.dart';

class ShopState {
  final String selectedPlatform; // 'Shop', 'Local Online', 'Online - Pan India', 'Export'
  final String selectedStoreType; // 'Retail Shop', 'Showroom', etc.
  final List<String> selectedStoreTypes; // Multi-select list
  final int wizardStep; // 1 to 5
  final List<ShopPlatform> shops;
  final bool isCreating;

  // Step 1
  final String storeName;
  final String branchModel;
  final String customerCareName;
  final String customerCarePhone;
  final String altContactName;
  final String altPhone;

  // Step 2
  final String addressMode; // 'auto' | 'map'
  final String pincode;
  final String country;
  final String stateName;
  final String district;
  final String taluk;
  final String cityVillage;
  final String mapSearch;
  final double latitude;
  final double longitude;

  // Step 3
  final String openingTime;
  final String closingTime;
  final List<String> workingDays;
  final String sundayClosingReason;
  final List<String> paymentMethods;
  final List<String> supportedLanguages;

  const ShopState({
    this.selectedPlatform = 'Shop',
    this.selectedStoreType = 'Retail Shop',
    this.selectedStoreTypes = const ['Retail Shop'],
    this.wizardStep = 1,
    this.shops = const [],
    this.isCreating = false,
    this.storeName = '',
    this.branchModel = 'Multi-Branch Franchise',
    this.customerCareName = '',
    this.customerCarePhone = '',
    this.altContactName = '',
    this.altPhone = '',
    this.addressMode = 'auto',
    this.pincode = '600020',
    this.country = 'India',
    this.stateName = 'Tamil Nadu',
    this.district = 'Chennai',
    this.taluk = 'Guindy',
    this.cityVillage = 'Adyar',
    this.mapSearch = 'Adyar, Chennai',
    this.latitude = 13.0064,
    this.longitude = 80.2564,
    this.openingTime = '09:00 AM',
    this.closingTime = '09:00 PM',
    this.workingDays = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ],
    this.sundayClosingReason = 'Weekly Holiday',
    this.paymentMethods = const [
      'Cash',
      'UPI',
      'Credit/Debit Card',
      'Net Banking',
      'Store Credit',
      'Wallet',
    ],
    this.supportedLanguages = const [
      'English',
      'Tamil',
      'Hindi',
      'Telugu',
      'Malayalam',
      'Kannada',
    ],
  });

  ShopState copyWith({
    String? selectedPlatform,
    String? selectedStoreType,
    List<String>? selectedStoreTypes,
    int? wizardStep,
    List<ShopPlatform>? shops,
    bool? isCreating,
    String? storeName,
    String? branchModel,
    String? customerCareName,
    String? customerCarePhone,
    String? altContactName,
    String? altPhone,
    String? addressMode,
    String? pincode,
    String? country,
    String? stateName,
    String? district,
    String? taluk,
    String? cityVillage,
    String? mapSearch,
    double? latitude,
    double? longitude,
    String? openingTime,
    String? closingTime,
    List<String>? workingDays,
    String? sundayClosingReason,
    List<String>? paymentMethods,
    List<String>? supportedLanguages,
  }) {
    return ShopState(
      selectedPlatform: selectedPlatform ?? this.selectedPlatform,
      selectedStoreType: selectedStoreType ?? this.selectedStoreType,
      selectedStoreTypes: selectedStoreTypes ?? this.selectedStoreTypes,
      wizardStep: wizardStep ?? this.wizardStep,
      shops: shops ?? this.shops,
      isCreating: isCreating ?? this.isCreating,
      storeName: storeName ?? this.storeName,
      branchModel: branchModel ?? this.branchModel,
      customerCareName: customerCareName ?? this.customerCareName,
      customerCarePhone: customerCarePhone ?? this.customerCarePhone,
      altContactName: altContactName ?? this.altContactName,
      altPhone: altPhone ?? this.altPhone,
      addressMode: addressMode ?? this.addressMode,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      stateName: stateName ?? this.stateName,
      district: district ?? this.district,
      taluk: taluk ?? this.taluk,
      cityVillage: cityVillage ?? this.cityVillage,
      mapSearch: mapSearch ?? this.mapSearch,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      workingDays: workingDays ?? this.workingDays,
      sundayClosingReason: sundayClosingReason ?? this.sundayClosingReason,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
    );
  }
}

class ShopNotifier extends Notifier<ShopState> {
  @override
  ShopState build() => const ShopState();

  void selectPlatform(String platform) {
    state = state.copyWith(selectedPlatform: platform);
  }

  void toggleStoreType(String storeType) {
    final current = List<String>.from(state.selectedStoreTypes);
    if (current.contains(storeType)) {
      if (current.length > 1) {
        current.remove(storeType);
      }
    } else {
      current.add(storeType);
    }
    state = state.copyWith(
      selectedStoreTypes: current,
      selectedStoreType: current.join(', '),
    );
  }

  void selectStoreType(String storeType) {
    toggleStoreType(storeType);
  }

  void setWizardStep(int step) {
    state = state.copyWith(wizardStep: step.clamp(1, 5));
  }

  void updateStep1({
    String? storeName,
    String? branchModel,
    String? customerCareName,
    String? customerCarePhone,
    String? altContactName,
    String? altPhone,
  }) {
    state = state.copyWith(
      storeName: storeName,
      branchModel: branchModel,
      customerCareName: customerCareName,
      customerCarePhone: customerCarePhone,
      altContactName: altContactName,
      altPhone: altPhone,
    );
  }

  void setAddressMode(String mode) {
    state = state.copyWith(addressMode: mode);
  }

  void updateAddress({
    String? pincode,
    String? country,
    String? stateName,
    String? district,
    String? taluk,
    String? cityVillage,
    String? mapSearch,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      pincode: pincode,
      country: country,
      stateName: stateName,
      district: district,
      taluk: taluk,
      cityVillage: cityVillage,
      mapSearch: mapSearch,
      latitude: latitude,
      longitude: longitude,
    );
  }

  void updateStoreTimes({String? openingTime, String? closingTime}) {
    state = state.copyWith(
      openingTime: openingTime,
      closingTime: closingTime,
    );
  }

  void toggleWorkingDay(String day) {
    final current = List<String>.from(state.workingDays);
    if (current.contains(day)) {
      if (current.length > 1) {
        current.remove(day);
      }
    } else {
      current.add(day);
    }
    state = state.copyWith(workingDays: current);
  }

  void updateSundayClosingReason(String reason) {
    state = state.copyWith(sundayClosingReason: reason);
  }

  void addPaymentMethod(String method) {
    final trimmed = method.trim();
    if (trimmed.isNotEmpty && !state.paymentMethods.contains(trimmed)) {
      state = state.copyWith(
        paymentMethods: [...state.paymentMethods, trimmed],
      );
    }
  }

  void removePaymentMethod(String method) {
    state = state.copyWith(
      paymentMethods: state.paymentMethods.where((m) => m != method).toList(),
    );
  }

  void addSupportedLanguage(String lang) {
    final trimmed = lang.trim();
    if (trimmed.isNotEmpty && !state.supportedLanguages.contains(trimmed)) {
      state = state.copyWith(
        supportedLanguages: [...state.supportedLanguages, trimmed],
      );
    }
  }

  void removeSupportedLanguage(String lang) {
    state = state.copyWith(
      supportedLanguages:
          state.supportedLanguages.where((l) => l != lang).toList(),
    );
  }

  void createShop({
    required String storeName,
    required String businessName,
    required String city,
  }) {
    final newShop = ShopPlatform(
      id: 'shop-${DateTime.now().millisecondsSinceEpoch}',
      storeName: storeName.isNotEmpty ? storeName : '$businessName Outlet',
      platformType: state.selectedPlatform,
      storeType: state.selectedStoreType,
      businessName: businessName,
      branchModel: state.branchModel,
      customerCareName: state.customerCareName,
      customerCarePhone: state.customerCarePhone,
      altContactName: state.altContactName,
      altPhone: state.altPhone,
      pincode: state.pincode,
      country: state.country,
      stateName: state.stateName,
      district: state.district,
      taluk: state.taluk,
      cityVillage: city.isNotEmpty ? city : state.cityVillage,
      latitude: state.latitude,
      longitude: state.longitude,
      openingTime: state.openingTime,
      closingTime: state.closingTime,
      workingDays: state.workingDays,
      paymentMethods: state.paymentMethods,
      supportedLanguages: state.supportedLanguages,
      status: 'Active',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      shops: [newShop, ...state.shops],
    );
  }

  void createShopFromState({
    required String businessName,
  }) {
    final newShop = ShopPlatform(
      id: 'shop-${DateTime.now().millisecondsSinceEpoch}',
      storeName: state.storeName.isNotEmpty ? state.storeName : '$businessName Outlet',
      platformType: state.selectedPlatform,
      storeType: state.selectedStoreType,
      businessName: businessName,
      branchModel: state.branchModel,
      customerCareName: state.customerCareName,
      customerCarePhone: state.customerCarePhone,
      altContactName: state.altContactName,
      altPhone: state.altPhone,
      pincode: state.pincode,
      country: state.country,
      stateName: state.stateName,
      district: state.district,
      taluk: state.taluk,
      cityVillage: state.cityVillage,
      latitude: state.latitude,
      longitude: state.longitude,
      openingTime: state.openingTime,
      closingTime: state.closingTime,
      workingDays: state.workingDays,
      paymentMethods: state.paymentMethods,
      supportedLanguages: state.supportedLanguages,
      status: 'Active',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      shops: [newShop, ...state.shops],
    );
  }

  void deleteShop(String id) {
    state = state.copyWith(
      shops: state.shops.where((s) => s.id != id).toList(),
    );
  }

  void loadShopForEdit(ShopPlatform shop) {
    state = state.copyWith(
      selectedPlatform: shop.platformType,
      selectedStoreType: shop.storeType,
      wizardStep: 1,
      storeName: shop.storeName,
      branchModel: shop.branchModel,
      customerCareName: shop.customerCareName,
      customerCarePhone: shop.customerCarePhone,
      altContactName: shop.altContactName,
      altPhone: shop.altPhone,
      pincode: shop.pincode,
      country: shop.country,
      stateName: shop.stateName,
      district: shop.district,
      taluk: shop.taluk,
      cityVillage: shop.cityVillage,
      latitude: shop.latitude,
      longitude: shop.longitude,
      openingTime: shop.openingTime,
      closingTime: shop.closingTime,
      workingDays: shop.workingDays,
      paymentMethods: shop.paymentMethods,
      supportedLanguages: shop.supportedLanguages,
    );
  }
}

final shopProvider = NotifierProvider<ShopNotifier, ShopState>(ShopNotifier.new);

