import 'package:flutter/foundation.dart';
import '../models/staff_report.dart';
import '../services/api_service.dart';

class StaffProvider extends ChangeNotifier {
  PunchRecord? _activePunch;
  List<StaffReport> _reports = [];
  bool _isLoading = false;
  String? _error;

  PunchRecord? get activePunch => _activePunch;
  List<StaffReport> get reports => List.unmodifiable(_reports);
  bool get isPunchedIn => _activePunch != null && _activePunch!.isActive;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<StaffReport> get unreviewedReports =>
      _reports.where((r) => !r.isReviewed).toList();

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([_loadPunchStatus(), _loadReports()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPunchStatus() async {
    try {
      final json = await ApiService.instance
          .get('/staff/punch/status') as Map<String, dynamic>;
      final active = json['activePunch'];
      _activePunch = active != null
          ? PunchRecord.fromJson(active as Map<String, dynamic>)
          : null;
    } catch (_) {}
  }

  Future<void> _loadReports() async {
    try {
      final data =
          await ApiService.instance.get('/staff/reports') as List<dynamic>;
      _reports = data
          .map((e) => StaffReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> punchIn(String staffId) async {
    if (isPunchedIn) return;
    try {
      final json = await ApiService.instance
          .post('/staff/punch/in') as Map<String, dynamic>;
      _activePunch = PunchRecord.fromJson(json);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> punchOut() async {
    if (!isPunchedIn) return;
    try {
      final json = await ApiService.instance
          .post('/staff/punch/out') as Map<String, dynamic>;
      _activePunch = PunchRecord.fromJson(json);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> submitReport(StaffReport report) async {
    try {
      final json = await ApiService.instance.post('/staff/reports', {
        'summary': report.summary,
        'details': report.details,
      }) as Map<String, dynamic>;
      _reports.insert(0, StaffReport.fromJson(json));
      notifyListeners();
    } catch (_) {}
  }

    Future<void> markReviewed(String reportId, {String? adminNotes}) async {
    try {
      final body = adminNotes != null ? {'adminNotes': adminNotes} : null;
      final json = await ApiService.instance.patch(
        '/staff/reports/$reportId/review',
        body,
      ) as Map<String, dynamic>;
      final idx = _reports.indexWhere((r) => r.id == reportId);
      if (idx != -1) {
        _reports[idx] = StaffReport.fromJson(json);
        notifyListeners();
      }
    } catch (_) {}
  }

  void clear() {
    _activePunch = null;
    _reports = [];
    notifyListeners();
  }
}
