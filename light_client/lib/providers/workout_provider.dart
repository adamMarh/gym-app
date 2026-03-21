import 'package:flutter/foundation.dart';
import '../models/workout.dart';

class WorkoutProvider extends ChangeNotifier {
  final List<WorkoutSession> _sessions = List.from(WorkoutSession.mockSessions);

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

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

  void addSession(WorkoutSession session) {
    _sessions.insert(0, session);
    notifyListeners();
  }
}
