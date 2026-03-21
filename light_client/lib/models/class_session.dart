class ClassSession {
  final String id;
  final String title;
  final String instructor;
  final DateTime startTime;
  final Duration duration;
  final int capacity;
  final int enrolled;
  final String category;
  final String? description;
  final bool isBooked;

  const ClassSession({
    required this.id,
    required this.title,
    required this.instructor,
    required this.startTime,
    required this.duration,
    required this.capacity,
    required this.enrolled,
    required this.category,
    this.description,
    this.isBooked = false,
  });

  int get spotsLeft => capacity - enrolled;
  bool get isFull => spotsLeft <= 0;

  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['id'] as String,
      title: json['title'] as String,
      instructor: json['instructor'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      duration: Duration(minutes: (json['durationMinutes'] as num).toInt()),
      capacity: (json['capacity'] as num).toInt(),
      enrolled: (json['enrolled'] as num).toInt(),
      category: json['category'] as String,
      description: (json['description'] as String?)?.isEmpty == true
          ? null
          : json['description'] as String?,
      isBooked: json['isBooked'] as bool? ?? false,
    );
  }

  ClassSession copyWith({bool? isBooked, int? enrolled}) {
    return ClassSession(
      id: id,
      title: title,
      instructor: instructor,
      startTime: startTime,
      duration: duration,
      capacity: capacity,
      enrolled: enrolled ?? this.enrolled,
      category: category,
      description: description,
      isBooked: isBooked ?? this.isBooked,
    );
  }
}
