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

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weightKg: (json['weightKg'] as num).toDouble(),
      notes: (json['notes'] as String?)?.isEmpty == true
          ? null
          : json['notes'] as String?,
    );
  }

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

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    return WorkoutSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: Duration(minutes: (json['durationMinutes'] as num).toInt()),
      notes: (json['notes'] as String?)?.isEmpty == true
          ? null
          : json['notes'] as String?,
      exercises: rawExercises
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
