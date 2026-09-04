import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/captcha_category.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final captchaProvider = FutureProvider.autoDispose<List<CaptchaCategory>>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.fetchCaptchaCategories();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> verifyCredentials(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(email, password, 0);
      state = const AsyncValue.data(null);
      return true; // Unlikely, but just in case
    } catch (e, st) {
      if (e.toString().contains('Invalid captcha image selection')) {
        // Credentials are valid, just missing captcha!
        state = const AsyncValue.data(null);
        return true;
      } else {
        // "Invalid credentials" or other errors
        state = AsyncValue.error(e, st);
        return false;
      }
    }
  }

  Future<bool> login(String email, String password, int captchaId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.login(email, password, captchaId);
      
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final authControllerProvider = StateNotifierProvider.autoDispose<AuthController, AsyncValue<void>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
