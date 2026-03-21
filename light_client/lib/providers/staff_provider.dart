import 'package:flutter/foundation.dart';
import '../models/staff_report.dart';

class StaffProvider extends ChangeNotifier {
  PunchRecord? _activePunch;
  final List<StaffReport> _reports = List.from(StaffReport.mockReports);
  final List<PunchRecord> _punchHistory = [];

  PunchRecord? get activePunch => _activePunch;
  List<StaffReport> get reports => List.unmodifiable(_reports);

  bool get isPunchedIn => _activePunch != null && _activePunch!.isActive;

  void punchIn(String staffId) {
    if (isPunchedIn) return;
    _activePunch = PunchRecord(staffId: staffId, punchIn: DateTime.now());
    notifyListeners();
  }

  void punchOut() {
    if (!isPunchedIn) return;
    _activePunch!.punchOut = DateTime.now();
    _punchHistory.add(_activePunch!);
    _activePunch = null;
    notifyListeners();
  }

  void submitReport(StaffReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void markReviewed(String reportId, {String? adminNotes}) {
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx == -1) return;
    _reports[idx] = _reports[idx].copyWith(
      isReviewed: true,
      adminNotes: adminNotes,
    );
    notifyListeners();
  }

  List<StaffReport> get unreviewedReports =>
      _reports.where((r) => !r.isReviewed).toList();
}
