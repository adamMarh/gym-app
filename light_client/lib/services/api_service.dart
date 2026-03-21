import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Change this to your machine's IP when running on a physical device.
/// Android emulator: use 10.0.2.2 instead of localhost.
/// iOS simulator / web: localhost works directly.
const String kBaseUrl = 'http://localhost:3000/api';

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

  dynamic _parse(http.Response resp) {
    final body = utf8.decode(resp.bodyBytes);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return body.isEmpty ? null : jsonDecode(body);
    }
    String message = 'Request failed';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      message = json['error'] as String? ?? message;
    } catch (_) {}
    throw ApiException(resp.statusCode, message);
  }

  Future<dynamic> get(String path) async {
    final resp = await http.get(
      Uri.parse('$kBaseUrl$path'),
      headers: _headers,
    );
    return _parse(resp);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final resp = await http.post(
      Uri.parse('$kBaseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(resp);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final resp = await http.patch(
      Uri.parse('$kBaseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(resp);
  }

  Future<dynamic> delete(String path) async {
    final resp = await http.delete(
      Uri.parse('$kBaseUrl$path'),
      headers: _headers,
    );
    return _parse(resp);
  }
}
