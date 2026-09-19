import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/user_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final authStatusProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);
  final route = await authService.checkAuthOnStartup();
  final isLoggedIn = (route == AuthService.resultDashboard) && (await userService.isUserLoggedIn());
  return isLoggedIn;
});
