import 'package:flutter/foundation.dart';
import '../models/class_session.dart';

class ClassProvider extends ChangeNotifier {
  final List<ClassSession> _classes = List.from(ClassSession.mockClasses);

  List<ClassSession> get classes => List.unmodifiable(_classes);

  List<ClassSession> get bookedClasses =>
      _classes.where((c) => c.isBooked).toList();

  void bookClass(String classId) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx == -1) return;
    final cls = _classes[idx];
    if (cls.isFull || cls.isBooked) return;
    _classes[idx] = cls.copyWith(isBooked: true, enrolled: cls.enrolled + 1);
    notifyListeners();
  }

  void cancelBooking(String classId) {
    final idx = _classes.indexWhere((c) => c.id == classId);
    if (idx == -1) return;
    final cls = _classes[idx];
    if (!cls.isBooked) return;
    _classes[idx] = cls.copyWith(isBooked: false, enrolled: cls.enrolled - 1);
    notifyListeners();
  }

  void addClass(ClassSession session) {
    _classes.add(session);
    notifyListeners();
  }

  void removeClass(String classId) {
    _classes.removeWhere((c) => c.id == classId);
    notifyListeners();
  }
}
