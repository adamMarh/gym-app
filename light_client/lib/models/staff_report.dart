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

  factory StaffReport.fromJson(Map<String, dynamic> json) {
    return StaffReport(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      date: DateTime.parse(json['date'] as String),
      summary: json['summary'] as String,
      details: json['details'] as String,
      isReviewed: json['isReviewed'] as bool? ?? false,
      adminNotes: (json['adminNotes'] as String?)?.isEmpty == true
          ? null
          : json['adminNotes'] as String?,
    );
  }

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
}

class PunchRecord {
  final String id;
  final String staffId;
  final DateTime punchIn;
  DateTime? punchOut;

  PunchRecord({
    required this.id,
    required this.staffId,
    required this.punchIn,
    this.punchOut,
  });

  Duration? get duration {
    if (punchOut == null) return null;
    return punchOut!.difference(punchIn);
  }

  bool get isActive => punchOut == null;

  factory PunchRecord.fromJson(Map<String, dynamic> json) {
    final punchOutStr = json['punchOut'] as String? ?? '';
    return PunchRecord(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      punchIn: DateTime.parse(json['punchIn'] as String),
      punchOut: punchOutStr.isEmpty ? null : DateTime.parse(punchOutStr),
    );
  }
}
