import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/business_repository.dart';
import '../../data/models/business_response_model.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository();
});

// Using a hardcoded userId for now, as requested
const String _currentUserId = '2146610213';

final selectedBusinessProvider = StateProvider<dynamic>((ref) => null);

final userBusinessesProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getUserBusinesses(_currentUserId);
});

final propagatorBusinessProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getPropagatorBusinesses(_currentUserId);
});

final partnerBusinessProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getPartnerBusinesses(_currentUserId);
});

final supplierBusinessProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getSupplierBusinesses(_currentUserId);
});

final businessTypesProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(businessRepositoryProvider);
  return repository.getBusinessTypes(_currentUserId);
});
