import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../business_setup/presentation/screens/business_home_screen.dart';
import '../providers/auth_providers.dart';
import 'login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStatusProvider);

    return authState.when(
      data: (isLoggedIn) {
        if (isLoggedIn) {
          return const BusinessHomeScreen();
        }
        return const LoginPage();
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Checking session...',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => const LoginPage(),
    );
  }
}
