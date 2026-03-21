class StaffReport {
  final String id;
  final String staffId;
  final String staffName;
  final DateTime date;
  final String summary;
  final String details;
  final bool isReviewed;
  final String? adminNotes;

  const StaffReport({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.date,
    required this.summary,
    required this.details,
    this.isReviewed = false,
    this.adminNotes,
  });

  StaffReport copyWith({bool? isReviewed, String? adminNotes}) {
    return StaffReport(
      id: id,
      staffId: staffId,
      staffName: staffName,
      date: date,
      summary: summary,
      details: details,
      isReviewed: isReviewed ?? this.isReviewed,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  static List<StaffReport> mockReports = [
    StaffReport(
      id: 'r1',
      staffId: 'u2',
      staffName: 'Jordan Smith',
      date: DateTime.now().subtract(const Duration(days: 1)),
      summary: 'Completed morning HIIT and afternoon yoga sessions.',
      details:
          'HIIT class had 14 participants — all completed the full session. '
          'Equipment check performed. Minor repair needed on treadmill #3. '
          'Yoga class had 12 participants. Overall smooth day.',
      isReviewed: true,
      adminNotes: 'Good work. Please follow up on treadmill repair.',
    ),
    StaffReport(
      id: 'r2',
      staffId: 'u2',
      staffName: 'Jordan Smith',
      date: DateTime.now(),
      summary: 'Managed front desk and led boxing intro class.',
      details:
          'Front desk was busy this morning with 8 new member sign-ups. '
          'Boxing intro class had 10 participants, all beginners. '
          'Reported a faulty locker to maintenance.',
    ),
  ];
}

class PunchRecord {
  final String staffId;
  final DateTime punchIn;
  DateTime? punchOut;

  PunchRecord({
    required this.staffId,
    required this.punchIn,
    this.punchOut,
  });

  Duration? get duration {
    if (punchOut == null) return null;
    return punchOut!.difference(punchIn);
  }

  bool get isActive => punchOut == null;
}
