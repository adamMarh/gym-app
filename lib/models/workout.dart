class Exercise {
  final String name;
  final int sets;
  final int reps;
  final double weightKg;
  final String? notes;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.notes,
  });

  double get volume => sets * reps * weightKg;

  Exercise copyWith({
    String? name,
    int? sets,
    int? reps,
    double? weightKg,
    String? notes,
  }) {
    return Exercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      notes: notes ?? this.notes,
    );
  }
}

class WorkoutSession {
  final String id;
  final String userId;
  final String title;
  final DateTime date;
  final List<Exercise> exercises;
  final Duration duration;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.exercises,
    required this.duration,
    this.notes,
  });

  double get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.volume);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  static List<WorkoutSession> mockSessions = [
    WorkoutSession(
      id: 'w1',
      userId: 'u1',
      title: 'PUSH DAY',
      date: DateTime.now().subtract(const Duration(days: 1)),
      duration: const Duration(hours: 1, minutes: 15),
      exercises: [
        const Exercise(name: 'Bench Press', sets: 4, reps: 8, weightKg: 100),
        const Exercise(name: 'Shoulder Press', sets: 3, reps: 10, weightKg: 60),
        const Exercise(name: 'Tricep Dips', sets: 3, reps: 12, weightKg: 0),
      ],
    ),
    WorkoutSession(
      id: 'w2',
      userId: 'u1',
      title: 'LEG DAY',
      date: DateTime.now().subtract(const Duration(days: 3)),
      duration: const Duration(hours: 1, minutes: 30),
      exercises: [
        const Exercise(name: 'Squat', sets: 5, reps: 5, weightKg: 150),
        const Exercise(name: 'Romanian DL', sets: 3, reps: 8, weightKg: 110),
        const Exercise(name: 'Leg Press', sets: 3, reps: 12, weightKg: 200),
      ],
    ),
    WorkoutSession(
      id: 'w3',
      userId: 'u1',
      title: 'PULL DAY',
      date: DateTime.now().subtract(const Duration(days: 5)),
      duration: const Duration(hours: 1, minutes: 10),
      exercises: [
        const Exercise(name: 'Deadlift', sets: 4, reps: 5, weightKg: 160),
        const Exercise(name: 'Pull-ups', sets: 3, reps: 8, weightKg: 0),
        const Exercise(name: 'Barbell Row', sets: 3, reps: 10, weightKg: 80),
      ],
    ),
  ];
}
