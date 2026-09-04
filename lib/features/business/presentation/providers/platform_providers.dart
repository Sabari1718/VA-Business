import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/platform_repository.dart';
import '../../data/models/business_response_model.dart';

final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  return PlatformRepository();
});

final platformsProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getPlatforms();
});

final shopTypesProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getShopTypes();
});

final platformAssignmentsProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getPlatformAssignments();
});
