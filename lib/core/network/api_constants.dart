class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://business-setup.jobes24x7.com/api';
  static const String defaultUserId = '4282284422';

  // Propagator Business Endpoints
  static const String propagatorDetailsCreate = '/propagator-details/create';
  static const String propagatorDetails = '/propagator-details';
  static const String propagatorAddressCreate = '/propagator-address/create';
  static String propagatorAddressUpdate(dynamic id) => '/propagator-address/update/$id';
  static const String propagatorAddresses = '/propagator-addresses';
  static const String propagatorContactCreate = '/propagator-contact/create';
  static String propagatorContactUpdate(dynamic id) => '/propagator-contact/update/$id';
  static const String propagatorContacts = '/propagator-contacts';
  static const String propagatorDocumentsCreate = '/propagator-documents/create';
  static const String propagatorDocuments = '/propagator-documents';
  static const String propagatorBankDetailsCreate = '/propagator-bank-details/create';
  static const String propagatorBankDetails = '/propagator-bank-details';
  static const String propagatorCompanyCreate = '/propagator-company/create';
  static const String propagatorCompanies = '/propagator-companies';
  static const String propagatorBusinessTypeCreate = '/propagator-business-type/create';
  static const String propagatorBusinessTypes = '/propagator-business-types';
  static const String propagatorBusinessMappingCreate = '/propagator-business-mapping/create';
  static const String propagatorBrandMappingCreate = '/propagator-brand-mapping/create';

  // Propagator Store Endpoints
  static const String propagatorStoreCreate = '/propagator-store/create';
  static const String propagatorStoreMappingCreate = '/propagator-store/mapping/create';
  static const String propagatorStores = '/propagator-stores';
  static String propagatorStoreUpdate(dynamic storeId) => '/propagator-store/update/$storeId';
  static String propagatorStoreDelete(dynamic storeId) => '/propagator-store/delete/$storeId';
  static String propagatorStoreDetails(dynamic storeId) => '/propagator-store/$storeId';
  static String propagatorConfigurations(dynamic propagatorId) => '/propagator/$propagatorId/configurations';

  // Outside / Metadata APIs
  static const String sectorTitle = '/sector-title';
  static const String pincodeDetails = '/outsideapis/pincode/details';
  static const String sectorTitleList = '/outsideapis/sector-title/list';
  static const String sectorList = '/outsideapis/sector/list';
  static String sectorByTitleId(dynamic sectorTitleId) => '/sector/$sectorTitleId';
  static const String subSectorList = '/outsideapis/sub-sector/list';
  static const String primaryCategories = '/outsideapis/primary-categories';
  static const String secondaryCategories = '/outsideapis/secondary-categories';
  static String secondaryCategoryById(dynamic primaryCategoryId) => '/secondary/$primaryCategoryId';
  static String brandByPrimaryAndSecondary(dynamic primaryId, dynamic secondaryId) => '/brand/$primaryId/$secondaryId';
  static const String propagatorBusinessMappings = '/propagator-business-mappings';
  static const String brands = '/outsideapis/brands';
}

