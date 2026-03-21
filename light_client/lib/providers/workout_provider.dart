import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class WorkoutProvider extends ChangeNotifier {
  List<WorkoutSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await ApiService.instance.get('/workouts') as List<dynamic>;
      _sessions = data
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load workouts.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<WorkoutSession> sessionsForDate(DateTime date) {
    return _sessions.where((s) {
      return s.date.year == date.year &&
          s.date.month == date.month &&
          s.date.day == date.day;
    }).toList();
  }

  Set<DateTime> get datesWithWorkouts {
    return _sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
  }

  Future<void> addSession(WorkoutSession session) async {
    try {
      final json = await ApiService.instance.post('/workouts', {
        'title': session.title,
        'date': session.date.toIso8601String(),
        'durationMinutes': session.duration.inMinutes,
        'notes': session.notes ?? '',
        'exercises': session.exercises
            .map((e) => {
                  'name': e.name,
                  'sets': e.sets,
                  'reps': e.reps,
                  'weightKg': e.weightKg,
                  'notes': e.notes ?? '',
                })
            .toList(),
      }) as Map<String, dynamic>;

      final created = WorkoutSession.fromJson(json);
      _sessions.insert(0, created);
      notifyListeners();
    } catch (_) {
      // Silently ignore — could add error feedback here
    }
  }

  void clear() {
    _sessions = [];
    notifyListeners();
  }
}
