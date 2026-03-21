import 'package:flutter/foundation.dart';
import '../models/class_session.dart';
import '../services/api_service.dart';

class ClassProvider extends ChangeNotifier {
  List<ClassSession> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<ClassSession> get classes => List.unmodifiable(_classes);
  List<ClassSession> get bookedClasses =>
      _classes.where((c) => c.isBooked).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.instance.get('/classes') as List<dynamic>;
      _classes = data
          .map((e) => ClassSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load classes.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookClass(String classId) async {
    // Optimistic update
    _updateLocal(classId, isBooked: true, enrolledDelta: 1);
    notifyListeners();

    try {
      final json = await ApiService.instance
          .post('/classes/$classId/book') as Map<String, dynamic>;
      _replaceLocal(ClassSession.fromJson(json));
    } catch (_) {
      // Rollback on failure
      _updateLocal(classId, isBooked: false, enrolledDelta: -1);
    }
    notifyListeners();
  }

  Future<void> cancelBooking(String classId) async {
    // Optimistic update
    _updateLocal(classId, isBooked: false, enrolledDelta: -1);
    notifyListeners();

    try {
      final json = await ApiService.instance
          .delete('/classes/$classId/book') as Map<String, dynamic>;
      _replaceLocal(ClassSession.fromJson(json));
    } catch (_) {
      // Rollback on failure
      _updateLocal(classId, isBooked: true, enrolledDelta: 1);
    }
    notifyListeners();
  }

  /// Accepts either a [ClassSession] or a _DraftClass-like object (duck-typed via Map).
  Future<void> addClass(dynamic session) async {
    try {
      final json = await ApiService.instance.post('/classes', {
        'title': session.title as String,
        'instructor': session.instructor as String,
        'startTime': (session.startTime as DateTime).toIso8601String(),
        'durationMinutes': session.durationMinutes is int
            ? session.durationMinutes as int
            : (session.duration as Duration).inMinutes,
        'capacity': session.capacity as int,
        'category': session.category as String,
        'description': session.description as String? ?? '',
      }) as Map<String, dynamic>;
      _classes.add(ClassSession.fromJson(json));
      notifyListeners();
    } catch (_) {
      // Silently ignore add errors
    }
  }

  Future<void> removeClass(String classId) async {
    final removed = _classes.where((c) => c.id == classId).toList();
    _classes.removeWhere((c) => c.id == classId);
    notifyListeners();

    try {
      await ApiService.instance.delete('/classes/$classId');
    } catch (_) {
      // Rollback
      _classes.addAll(removed);
      notifyListeners();
    }
  }

  void _updateLocal(String classId,
      {required bool isBooked, required int enrolledDelta}) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx == -1) return;
    final cls = _classes[idx];
    _classes[idx] = cls.copyWith(
      isBooked: isBooked,
      enrolled: cls.enrolled + enrolledDelta,
    );
  }

  void _replaceLocal(ClassSession updated) {
    final idx = _classes.indexWhere((c) => c.id == updated.id);
    if (idx != -1) _classes[idx] = updated;
  }

  void clear() {
    _classes = [];
    notifyListeners();
  }
}
