import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/platform_repository.dart';
import '../../data/models/business_response_model.dart';

final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  return PlatformRepository();
});

// All platforms (no userId filter)
final platformsProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getPlatforms();
});

// Shop types for a specific platform (by platform_id)
final shopTypesByPlatformProvider = FutureProvider.family<BusinessResponseModel, String>((ref, platformId) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getShopTypesByPlatformId(platformId);
});

// All platform assignments
final platformAssignmentsProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getPlatformAssignments();
});

// Legacy - used by shop type in supplier screen (all assignments at once)
final shopTypesProvider = FutureProvider<BusinessResponseModel>((ref) async {
  final repository = ref.read(platformRepositoryProvider);
  return repository.getPlatformAssignments();
});
