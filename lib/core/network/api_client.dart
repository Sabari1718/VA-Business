import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException [$statusCode]: $message';
}

class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiConstants.baseUrl).replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, String>> _buildHeaders({Map<String, String>? extraHeaders}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_main_id') ?? prefs.getString('user_id') ?? ApiConstants.defaultUserId;
      headers['user-main-id'] = userId;

      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      if (token != null && token.isNotEmpty && token != 'null' && token != 'undefined') {
        headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
      }

      final businessId = prefs.getString('business_id');
      if (businessId != null && businessId.isNotEmpty && businessId != 'null') {
        headers['business_id'] = businessId;
        headers['account_id'] = businessId;
        headers['id'] = businessId;
      }
    } catch (_) {
      headers['user-main-id'] = ApiConstants.defaultUserId;
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  void _logRequest(String method, Uri uri, Map<String, String> headers, dynamic body) {
    print('\n╔══════════════════════════════════════════════════════════════════════');
    print('║ 🚀 [API CALL TRIGGERED]');
    print('║ 📡 METHOD  : $method');
    print('║ 🌐 URL     : $uri');
    print('║ 🏷️ HEADERS : $headers');
    if (body != null) {
      print('║ 📦 BODY / PAYLOAD :');
      final formatted = _formatJson(body);
      for (final line in formatted.split('\n')) {
        print('║    $line');
      }
    }
    print('╚══════════════════════════════════════════════════════════════════════\n');
  }

  void _logResponse(String method, Uri uri, int statusCode, int durationMs, String responseBody) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final icon = isSuccess ? '✅' : '❌';
    print('\n┌──────────────────────────────────────────────────────────────────────');
    print('│ $icon [API RESPONSE $statusCode] (${durationMs}ms) -> $method $uri');
    print('│ 📄 RESPONSE BODY:');
    try {
      final decoded = jsonDecode(responseBody);
      final formatted = _formatJson(decoded);
      for (final line in formatted.split('\n')) {
        print('│    $line');
      }
    } catch (_) {
      print('│    ${responseBody.length > 500 ? '${responseBody.substring(0, 500)}...' : responseBody}');
    }
    print('└──────────────────────────────────────────────────────────────────────\n');
  }

  void _logError(String method, Uri uri, dynamic error, [StackTrace? stackTrace]) {
    print('\n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('┃ 🚨 [API ERROR] -> $method $uri');
    print('┃ ⚠️ Details: $error');
    if (stackTrace != null) {
      print('┃ 🔍 StackTrace: $stackTrace');
    }
    print('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  Uri _resolveUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    String cleanEndpoint = endpoint.trim();
    if (!cleanEndpoint.startsWith('/')) {
      cleanEndpoint = '/$cleanEndpoint';
    }

    final fullUrl = '$_baseUrl$cleanEndpoint';
    final uri = Uri.parse(fullUrl);

    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }

    final existingParams = Map<String, dynamic>.from(uri.queryParameters);
    queryParams.forEach((key, value) {
      if (value != null) {
        existingParams[key] = value.toString();
      }
    });

    return uri.replace(queryParameters: existingParams.map((k, v) => MapEntry(k, v.toString())));
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final uri = _resolveUri(endpoint, queryParams);
    final allHeaders = await _buildHeaders(extraHeaders: headers);

    _logRequest('GET', uri, allHeaders, null);
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(uri, headers: allHeaders).timeout(timeout);
      stopwatch.stop();

      _logResponse('GET', uri, response.statusCode, stopwatch.elapsedMilliseconds, response.body);
      return _processResponse(response);
    } catch (e, stack) {
      _logError('GET', uri, e, stack);
      rethrow;
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _resolveUri(endpoint, queryParams);
    final allHeaders = await _buildHeaders(extraHeaders: headers);

    _logRequest('POST', uri, allHeaders, body);
    final stopwatch = Stopwatch()..start();

    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client.post(
        uri,
        headers: allHeaders,
        body: encodedBody,
      ).timeout(timeout);
      stopwatch.stop();

      _logResponse('POST', uri, response.statusCode, stopwatch.elapsedMilliseconds, response.body);
      return _processResponse(response);
    } catch (e, stack) {
      _logError('POST', uri, e, stack);
      rethrow;
    }
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _resolveUri(endpoint, queryParams);
    final allHeaders = await _buildHeaders(extraHeaders: headers);

    _logRequest('PUT', uri, allHeaders, body);
    final stopwatch = Stopwatch()..start();

    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client.put(
        uri,
        headers: allHeaders,
        body: encodedBody,
      ).timeout(timeout);
      stopwatch.stop();

      _logResponse('PUT', uri, response.statusCode, stopwatch.elapsedMilliseconds, response.body);
      return _processResponse(response);
    } catch (e, stack) {
      _logError('PUT', uri, e, stack);
      rethrow;
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _resolveUri(endpoint, queryParams);
    final allHeaders = await _buildHeaders(extraHeaders: headers);

    _logRequest('DELETE', uri, allHeaders, body);
    final stopwatch = Stopwatch()..start();

    try {
      final encodedBody = body != null ? jsonEncode(body) : null;
      final response = await _client.delete(
        uri,
        headers: allHeaders,
        body: encodedBody,
      ).timeout(timeout);
      stopwatch.stop();

      _logResponse('DELETE', uri, response.statusCode, stopwatch.elapsedMilliseconds, response.body);
      return _processResponse(response);
    } catch (e, stack) {
      _logError('DELETE', uri, e, stack);
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic decoded;
    try {
      if (response.body.isNotEmpty) {
        decoded = jsonDecode(response.body);
      }
    } catch (_) {
      decoded = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String errorMsg = 'HTTP ${response.statusCode}: Request failed';
    if (decoded is Map) {
      final msg = decoded['message'] ?? decoded['error'] ?? decoded['result'];
      if (msg is Map && msg['message'] != null) {
        errorMsg = msg['message'].toString();
      } else if (msg != null) {
        errorMsg = msg.toString();
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMsg,
      data: decoded,
    );
  }
}
