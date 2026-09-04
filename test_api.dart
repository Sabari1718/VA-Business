import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://business-setup.srivagroups.in/api/auth/login');
  
  // 1. Unregistered Email
  final res1 = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': 'somefakeemail123@gmail.com',
      'password': 'anypassword',
      'captcha_image_id': 0,
    }),
  );
  print('Fake Email: ${res1.body}');

  // 2. Registered Email, Wrong Password
  final res2 = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': 'sabarishwaran1718@gmail.com',
      'password': 'wrongpassword123',
      'captcha_image_id': 0,
    }),
  );
  print('Registered Email + Wrong Password: ${res2.body}');
}
