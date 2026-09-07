import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 👉 CHANGE THIS to your computer's local IP address when testing on a
//    physical device.  To find it:
//      • macOS / Linux : run `ifconfig` → look for en0/wlan0 inet address
//      • Windows       : run `ipconfig` → look for IPv4 Address
//
//    Your computer and the tablet must be on the SAME Wi-Fi network.
//
//    Examples:
//      Physical device  → 'http://192.168.1.42:3000/api'
//      Android emulator → 'http://10.0.2.2:3000/api'
//      iOS simulator    → 'http://localhost:3000/api'
// ─────────────────────────────────────────────────────────────────────────────
const String kServerIp = '192.168.1.1'; // <-- REPLACE with your actual IP
const String kBaseUrl  = 'http://$kServerIp:3000/api';

/// How long to wait for the server before giving up.
const Duration kRequestTimeout = Duration(seconds: 10);

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  String? _token;
  static const String _tokenKey = 'auth_token';

  String? get token => _token;
  bool get hasToken => _token != null;

  // ── Token persistence ────────────────────────────────────────────────────────

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── HTTP helpers ─────────────────────────────────────────────────────────────

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Parses the response or throws a descriptive [ApiException].
  dynamic _parse(http.Response resp) {
    final body = utf8.decode(resp.bodyBytes);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return body.isEmpty ? null : jsonDecode(body);
    }
    String message = 'Server error (${resp.statusCode})';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      message = json['error'] as String? ?? message;
    } catch (_) {}
    throw ApiException(resp.statusCode, message);
  }

  /// Wraps any network-level error into a readable [ApiException].
  ApiException _networkError(Object e) {
    if (e is SocketException) {
      return ApiException(0,
          'Cannot reach server at $kServerIp:3000.\n'
          'Make sure:\n'
          '• The server is running (npm start)\n'
          '• Your tablet and computer are on the same Wi-Fi\n'
          '• kServerIp in api_service.dart matches your computer\'s IP');
    }
    if (e is HttpException) {
      return ApiException(0, 'HTTP error: ${e.message}');
    }
    return ApiException(0, 'Network error: $e');
  }

  Future<dynamic> get(String path) async {
    try {
      final resp = await http
          .get(Uri.parse('$kBaseUrl$path'), headers: _headers)
          .timeout(kRequestTimeout);
      return _parse(resp);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _networkError(e);
    }
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    try {
      final resp = await http
          .post(
            Uri.parse('$kBaseUrl$path'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(kRequestTimeout);
      return _parse(resp);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _networkError(e);
    }
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    try {
      final resp = await http
          .patch(
            Uri.parse('$kBaseUrl$path'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(kRequestTimeout);
      return _parse(resp);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _networkError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final resp = await http
          .delete(Uri.parse('$kBaseUrl$path'), headers: _headers)
          .timeout(kRequestTimeout);
      return _parse(resp);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw _networkError(e);
    }
  }
}
