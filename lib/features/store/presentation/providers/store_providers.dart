import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/models/store_model.dart';

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository();
});

final storesProvider = FutureProvider<List<StoreModel>>((ref) async {
  final repository = ref.read(storeRepositoryProvider);
  return repository.getStores();
});
