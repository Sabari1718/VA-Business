class SupplierModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String branch;
  final bool withGst;
  final String gstNumber;
  final String? companyLogoPath;
  final String? gstCertificatePath;
  final List<String> selectedPlatformIds;
  final List<String> selectedShopTypeIds;
  final String address;

  SupplierModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.branch,
    required this.withGst,
    required this.gstNumber,
    this.companyLogoPath,
    this.gstCertificatePath,
    required this.selectedPlatformIds,
    required this.selectedShopTypeIds,
    required this.address,
  });

  SupplierModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? branch,
    bool? withGst,
    String? gstNumber,
    String? companyLogoPath,
    String? gstCertificatePath,
    List<String>? selectedPlatformIds,
    List<String>? selectedShopTypeIds,
    String? address,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      branch: branch ?? this.branch,
      withGst: withGst ?? this.withGst,
      gstNumber: gstNumber ?? this.gstNumber,
      companyLogoPath: companyLogoPath ?? this.companyLogoPath,
      gstCertificatePath: gstCertificatePath ?? this.gstCertificatePath,
      selectedPlatformIds: selectedPlatformIds ?? this.selectedPlatformIds,
      selectedShopTypeIds: selectedShopTypeIds ?? this.selectedShopTypeIds,
      address: address ?? this.address,
    );
  }
}
