import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/supplier_repository.dart';

class SupplierNotifier extends StateNotifier<AsyncValue<List<SupplierApiModel>>> {
  SupplierNotifier() : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    state = const AsyncValue.loading();
    try {
      final suppliers = await SupplierRepository.getSuppliers();
      state = AsyncValue.data(suppliers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSupplier({
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
    await SupplierRepository.addSupplier(
      withGst: withGst,
      gstNumber: gstNumber,
      gstCertificate: gstCertificate,
      businessName: businessName,
      businessEmail: businessEmail,
      phone: phone,
      companyLogo: companyLogo,
      doorNo: doorNo,
      streetName: streetName,
      buildingName: buildingName,
      landmark: landmark,
      area: area,
      district: district,
      pincode: pincode,
      state: state,
      country: country,
      platformNames: platformNames,
      shopTypeNames: shopTypeNames,
    );
    await loadSuppliers();
  }

  Future<void> updateSupplier({
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
    await SupplierRepository.updateSupplier(
      supplierId: supplierId,
      withGst: withGst,
      gstNumber: gstNumber,
      gstCertificate: gstCertificate,
      existingGstCertificate: existingGstCertificate,
      businessName: businessName,
      businessEmail: businessEmail,
      phone: phone,
      companyLogo: companyLogo,
      existingCompanyLogo: existingCompanyLogo,
      doorNo: doorNo,
      streetName: streetName,
      buildingName: buildingName,
      landmark: landmark,
      area: area,
      district: district,
      pincode: pincode,
      state: state,
      country: country,
      platformNames: platformNames,
      shopTypeNames: shopTypeNames,
    );
    await loadSuppliers();
  }

  Future<void> deleteSupplier(int supplierId) async {
    await SupplierRepository.deleteSupplier(supplierId);
    await loadSuppliers();
  }
}

final supplierNotifierProvider =
    StateNotifierProvider<SupplierNotifier, AsyncValue<List<SupplierApiModel>>>((ref) {
  return SupplierNotifier();
});
