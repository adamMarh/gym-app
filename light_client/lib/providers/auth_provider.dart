import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Called on app start — restores session from stored token.
  Future<void> tryRestoreSession() async {
    await ApiService.instance.loadToken();
    if (!ApiService.instance.hasToken) return;

    try {
      final json = await ApiService.instance.get('/auth/me')
          as Map<String, dynamic>;
      _currentUser = User.fromJson(json);
    } catch (_) {
      // Token expired or invalid — clear it silently.
      await ApiService.instance.clearToken();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.instance.post('/auth/login', {
        'email': email,
        'password': password,
      }) as Map<String, dynamic>;

      await ApiService.instance.saveToken(data['token'] as String);
      _currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not connect to server.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiService.instance.clearToken();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    if (_currentUser == null) return;
    try {
      final json = await ApiService.instance.patch('/auth/me', {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      }) as Map<String, dynamic>;
      _currentUser = User.fromJson(json);
      notifyListeners();
    } catch (_) {
      // Profile update errors are non-critical; ignore silently.
    }
  }
}
