import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/user_service.dart';
import '../../../business_setup/presentation/screens/business_home_screen.dart';
import 'secret_image_verification_page.dart';
import 'secret_image_setup_page.dart';
import 'reset_access_selection_page.dart';

class PasswordPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String email;
  final bool isExistingUser;
  final String passedIdentifier; // exact input from login page

  const PasswordPage({
    super.key,
    required this.phoneNumber,
    this.email = '',
    this.isExistingUser = false,
    this.passedIdentifier = '',
  });

  @override
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  double _strength = 0;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String val) {
    setState(() {
      _strength = (val.length / 10).clamp(0, 1);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final String password = passwordController.text.trim();

      if (widget.isExistingUser) {
        // ==========================================
        // EXISTING USER LOGIN FLOW
        // ==========================================
        debugPrint("EXISTING USER LOGIN => Attempting API verification");

        // Use exact identifier from login page
        final String identifier = widget.passedIdentifier.isNotEmpty
            ? widget.passedIdentifier.trim()
            : (widget.phoneNumber.isNotEmpty
                  ? widget.phoneNumber.trim()
                  : widget.email.trim());

        debugPrint("ENTERED PASSWORD => $password");

        try {
          final response = await AuthService().login(
            identifier: identifier,
            password: password,
          );

          if (!mounted) return;

          // Navigate to SecretImageVerificationPage for existing user
          final userData = response['data']?['data'];

          if (userData != null) {
            await ref.read(userServiceProvider).saveFromApiUser(userData);
          }

          // Check API response to determine if captcha is required (already set up)
          final innerData = response['data'] ?? {};
          final bool isCaptchaRequired = innerData['captcha_required'] == true;

          if (!mounted) return;

          if (!isCaptchaRequired) {
            // No captcha found -> route to setup
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SecretImageSetupPage(identifier: identifier, password: password, isExistingUser: true),
              ),
              (route) => false,
            );
          } else {
            // Captcha is required -> route to verify
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => SecretImageVerificationPage(
                  identifier: identifier,
                  password: password,
                ),
              ),
              (route) => false,
            );
          }
          return;
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e
                    .toString()
                    .replaceAll('Exception: ', '')
                    .replaceAll('AuthException: ', ''),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      } else {
        // ==========================================
        // NEW USER FLOW
        // ==========================================
        // NOTE:
        // Nee current flow la new user direct SetPinPage ku poguthu.
        // DB save new user registration flow separate page la irundha
        // adha later connect pannalam.
        await userService.saveUserData(isLoggedIn: true);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BusinessHomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<_LoginResult> _loginExistingUser({
    required String identifier,
    required String password,
  }) async {
    // 🔥 EMULATOR URL
    // Real mobile use panna: http://YOUR_PC_IP/login_api/login_or_register.php
    const String apiUrl = "http://10.0.2.2/login_api/login_or_register.php";

    try {
      final Map<String, String> body = {'password': password};

      // mobile ah? email ah?
      if (identifier.contains('@')) {
        body['email'] = identifier;
      } else {
        body['mobile'] = identifier;
      }

      debugPrint("API URL => $apiUrl");
      debugPrint("API BODY => $body");

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      debugPrint("API STATUS => ${response.statusCode}");
      debugPrint("API RESPONSE => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data;

        try {
          data = jsonDecode(response.body);
        } catch (e) {
          return const _LoginResult(
            success: false,
            message: 'Invalid server response',
          );
        }

        bool success = data['status'] == true || data['success'] == true;

        if (success) {
          if (data != null && data['user_main_id'] != null) {
            await UserService().saveUserData(
              userMainId: data['user_main_id'].toString(),
            );
          }
          return _LoginResult(
            success: true,
            message: data['message']?.toString() ?? 'Login successful',
          );
        } else {
          return _LoginResult(
            success: false,
            message: data['message']?.toString() ?? 'Invalid credentials',
          );
        }
      } else {
        return _LoginResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return _LoginResult(success: false, message: 'Login request failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExistingUser = widget.isExistingUser;
    final String identifier = widget.passedIdentifier.isNotEmpty
        ? widget.passedIdentifier
        : (widget.phoneNumber.isNotEmpty
            ? widget.phoneNumber
            : widget.email);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background ambient gradient glow orbs
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enterprise Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 36,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: const Color(0xFF1D4ED8).withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Top Bar with Back Button & App Logo
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: Color(0xFF475569),
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  tooltip: 'Back to Login',
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/icon/app_icon.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.business_center_rounded,
                                        color: Color(0xFF1D4ED8),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 36), // balances the back button
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Platform Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isExistingUser
                                        ? Icons.lock_open_rounded
                                        : Icons.lock_person_rounded,
                                    size: 14,
                                    color: const Color(0xFF2563EB),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isExistingUser
                                        ? 'CREDENTIAL VERIFICATION'
                                        : 'MASTER PASSWORD SETUP',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D4ED8),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Title & Subtitle
                            Text(
                              isExistingUser ? 'Enter Password' : 'Create Password',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isExistingUser
                                  ? 'Enter your master credentials to continue to your dashboard.'
                                  : 'Choose a strong master password to secure your account.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF64748B),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // User Identifier Pill
                            if (identifier.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.account_circle_outlined,
                                      size: 17,
                                      color: Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      identifier,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 15,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isExistingUser ? 'PASSWORD' : 'NEW PASSWORD',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _obscurePassword,
                                    onChanged: isExistingUser
                                        ? null
                                        : _onPasswordChanged,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    decoration: _inputDecoration(
                                      isExistingUser
                                          ? 'Enter your password'
                                          : 'Create a strong password',
                                      Icons.lock_outline_rounded,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 20,
                                          color: const Color(0xFF64748B),
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Password required';
                                      }
                                      if (!isExistingUser && val.trim().length < 6) {
                                        return 'Min 6 characters required';
                                      }
                                      return null;
                                    },
                                  ),

                                  // Password Strength Bar (New user)
                                  if (!isExistingUser) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: _strength,
                                              backgroundColor: const Color(0xFFE2E8F0),
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                _strength < 0.4
                                                    ? const Color(0xFFEF4444)
                                                    : (_strength < 0.7
                                                        ? const Color(0xFFF59E0B)
                                                        : const Color(0xFF10B981)),
                                              ),
                                              minHeight: 5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _strength < 0.4
                                              ? 'Weak'
                                              : (_strength < 0.7 ? 'Fair' : 'Strong'),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: _strength < 0.4
                                                ? const Color(0xFFEF4444)
                                                : (_strength < 0.7
                                                    ? const Color(0xFFF59E0B)
                                                    : const Color(0xFF10B981)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Confirm Password
                                    const Text(
                                      'CONFIRM PASSWORD',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF475569),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      style: const TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                      decoration: _inputDecoration(
                                        'Repeat your password',
                                        Icons.lock_reset_rounded,
                                        suffix: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: const Color(0xFF64748B),
                                          ),
                                          onPressed: () => setState(
                                            () => _obscureConfirmPassword = !_obscureConfirmPassword,
                                          ),
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Confirm password required';
                                        }
                                        if (val != passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],

                                  // Forgot Password link for existing user
                                  if (isExistingUser) ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const ResetAccessSelectionPage(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                        ),
                                        child: const Text(
                                          'Reset Password / Captcha Image?',
                                          style: TextStyle(
                                            color: Color(0xFF2563EB),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ] else ...[
                                    const SizedBox(height: 28),
                                  ],

                                  // Submit Button
                                  _buildGradientButton(
                                    text: _isSubmitting
                                        ? 'Authenticating...'
                                        : (isExistingUser ? 'Sign In' : 'Finalize Account'),
                                    onPressed: _isSubmitting ? null : _submit,
                                    isLoading: _isSubmitting,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Trust & Security Footer
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Enterprise Security • 256-Bit SSL Encrypted Gateway',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFEF4444),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

class _LoginResult {
  final bool success;
  final String message;

  const _LoginResult({required this.success, required this.message});
}
