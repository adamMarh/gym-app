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

  static List<ClassSession> mockClasses = [
    ClassSession(
      id: 'c1',
      title: 'HIIT BLAST',
      instructor: 'Marcus T.',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      duration: const Duration(minutes: 45),
      capacity: 20,
      enrolled: 14,
      category: 'HIIT',
      description: 'High-intensity interval training to torch calories.',
    ),
    ClassSession(
      id: 'c2',
      title: 'POWER YOGA',
      instructor: 'Priya M.',
      startTime: DateTime.now().add(const Duration(hours: 5)),
      duration: const Duration(minutes: 60),
      capacity: 15,
      enrolled: 15,
      category: 'YOGA',
      description: 'Strength-focused yoga flow for athletes.',
    ),
    ClassSession(
      id: 'c3',
      title: 'HEAVY LIFTING',
      instructor: 'Bruno K.',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 7)),
      duration: const Duration(hours: 1),
      capacity: 12,
      enrolled: 8,
      category: 'STRENGTH',
      description: 'Compound movements to build raw strength.',
      isBooked: true,
    ),
    ClassSession(
      id: 'c4',
      title: 'SPIN CYCLE',
      instructor: 'Zara L.',
      startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      duration: const Duration(minutes: 50),
      capacity: 25,
      enrolled: 19,
      category: 'CARDIO',
    ),
    ClassSession(
      id: 'c5',
      title: 'BOXING BASICS',
      instructor: 'Dom R.',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 8)),
      duration: const Duration(hours: 1),
      capacity: 18,
      enrolled: 10,
      category: 'BOXING',
    ),
    ClassSession(
      id: 'c6',
      title: 'CORE & MORE',
      instructor: 'Emma S.',
      startTime: DateTime.now().add(const Duration(days: 2, hours: 12)),
      duration: const Duration(minutes: 30),
      capacity: 20,
      enrolled: 5,
      category: 'CORE',
    ),
  ];
}
