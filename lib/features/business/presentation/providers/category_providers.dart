import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/models/category_model.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

final sectorTitlesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  final response = await repository.getSectorTitles();
  return response.data;
});

final sectorsProvider = FutureProvider.family<List<CategoryModel>, int>((ref, sectorTitleId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final response = await repository.getSectors(sectorTitleId);
  return response.data;
});

final subSectorsProvider = FutureProvider.family<List<CategoryModel>, int>((ref, sectorId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final response = await repository.getSubSectors(sectorId);
  return response.data;
});

final primaryCategoriesProvider = FutureProvider.family<List<CategoryModel>, int>((ref, subSectorId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final response = await repository.getPrimaryCategories(subSectorId);
  return response.data;
});

final secondaryCategoriesProvider = FutureProvider.family<List<CategoryModel>, int>((ref, primaryCategoryId) async {
  final repository = ref.read(categoryRepositoryProvider);
  final response = await repository.getSecondaryCategories(primaryCategoryId);
  return response.data;
});

// A provider that takes a list of selected primary category IDs, fetches secondary categories for each, and combines them
final combinedSecondaryCategoriesProvider = FutureProvider.family<List<CategoryModel>, List<int>>((ref, primaryCategoryIds) async {
  if (primaryCategoryIds.isEmpty) return [];
  
  final repository = ref.read(categoryRepositoryProvider);
  final List<CategoryModel> combined = [];
  
  for (final id in primaryCategoryIds) {
    try {
      final response = await repository.getSecondaryCategories(id);
      combined.addAll(response.data);
    } catch (e) {
      // Ignore errors for individual fetch if one fails
      print('Error fetching secondary categories for primary $id: $e');
    }
  }
  
  return combined;
});
