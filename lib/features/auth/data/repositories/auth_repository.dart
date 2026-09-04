import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/captcha_category.dart';
import '../models/login_response.dart';

class AuthRepository {
  Future<List<CaptchaCategory>> fetchCaptchaCategories() async {
    final url = Uri.parse('https://managelogin.jobes24x7.com/api/outsideapis/captcha/category');
    
    print('-----------------------------------------');
    print('🚀 API REQUEST: GET $url');
    
    final response = await http.get(url);

    print('📦 API RESPONSE (${response.statusCode}): ${response.body}');
    print('-----------------------------------------');

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody['success'] == true && jsonBody['data'] != null) {
        final List data = jsonBody['data'];
        return data.map((e) => CaptchaCategory.fromJson(e)).toList();
      } else {
        throw Exception(jsonBody['message'] ?? 'Failed to fetch categories');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<LoginResponse> login(String email, String password, int captchaId) async {
    final url = Uri.parse('https://business-setup.srivagroups.in/api/auth/login');
    final payload = {
      'email': email,
      'password': password,
      'captcha_image_id': captchaId,
    };
    
    print('-----------------------------------------');
    print('🚀 API REQUEST: POST $url');
    print('📨 PAYLOAD: $payload');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    
    print('📦 API RESPONSE (${response.statusCode}): ${response.body}');
    print('-----------------------------------------');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonBody = json.decode(response.body);
      final data = jsonBody['data'];
      
      if (data != null && data['code'] == 200) {
        return LoginResponse.fromJson(data);
      } else {
        // Handle API specific error
        final msg = data != null ? data['message'] : jsonBody['message'];
        throw Exception(msg ?? 'Login failed.');
      }
    } else {
      // General error fallback
      final jsonBody = json.decode(response.body);
      final data = jsonBody['data'];
      final msg = data != null ? data['message'] : jsonBody['message'];
      throw Exception(msg ?? 'Login failed. Please register in the VA Business User app first.');
    }
  }
}
