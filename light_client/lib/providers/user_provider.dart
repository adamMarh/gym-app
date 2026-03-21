import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Used by the admin panel to list all users.
class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.instance.get('/users') as List<dynamic>;
      _users = data
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load users.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _users = [];
    notifyListeners();
  }
}
