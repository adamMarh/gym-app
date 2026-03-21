import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/workout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common/kinetic_button.dart';
import '../../widgets/common/power_stat_card.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final workoutDates = provider.datesWithWorkouts;
    final selected = _selectedDay ?? DateTime.now();
    final selectedWorkouts = provider.sessionsForDate(selected);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('WORKOUT LOG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddWorkoutSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          Container(
            color: AppColors.surfaceContainerLow,
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                final normalized = DateTime(day.year, day.month, day.day);
                return workoutDates.contains(normalized) ? [true] : [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onSurface),
                weekendTextStyle: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onSurface),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.rectangle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.rectangle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.labelSmCaps,
                weekendStyle: AppTextStyles.labelSmCaps,
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: AppTextStyles.titleMd,
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.onSurfaceVariant,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                ),
              ),
            ),
          ),

          const SizedBox(height: 2),

          // Workouts for selected day
          Expanded(
            child: selectedWorkouts.isEmpty
                ? _EmptyDay(onAdd: () => _showAddWorkoutSheet(context))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: selectedWorkouts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (ctx, i) =>
                        _WorkoutCard(session: selectedWorkouts[i]),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      builder: (_) => const _AddWorkoutSheet(),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyDay({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center_outlined,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('NO WORKOUT LOGGED', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 8),
          Text(
            'Rest day or add a new session.',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 24),
          KineticButton(label: 'LOG WORKOUT', onPressed: onAdd),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutSession session;

  const _WorkoutCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: title + duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(session.title, style: AppTextStyles.headlineSm),
              Text(
                '${session.duration.inMinutes} MIN',
                style: AppTextStyles.labelSmCaps
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: PowerStatCard(
                  value: '${session.totalSets}',
                  unit: '',
                  label: 'Total Sets',
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: PowerStatCard(
                  value: '${session.totalVolume.toStringAsFixed(0)}',
                  unit: 'KG',
                  label: 'Total Volume',
                  accentColor: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Exercises list
          Text('EXERCISES', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 8),
          ...session.exercises.map((e) => _ExerciseRow(exercise: e)),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(exercise.name, style: AppTextStyles.bodyMd),
          Row(
            children: [
              Text(
                '${exercise.sets} × ${exercise.reps}',
                style: AppTextStyles.labelMd,
              ),
              if (exercise.weightKg > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${exercise.weightKg}KG',
                  style: AppTextStyles.labelMd
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AddWorkoutSheet extends StatefulWidget {
  const _AddWorkoutSheet();

  @override
  State<_AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

class _AddWorkoutSheetState extends State<_AddWorkoutSheet> {
  final _titleCtrl = TextEditingController();
  final List<Map<String, TextEditingController>> _exercises = [];

  @override
  void initState() {
    super.initState();
    _addExerciseRow();
  }

  void _addExerciseRow() {
    setState(() {
      _exercises.add({
        'name': TextEditingController(),
        'sets': TextEditingController(text: '3'),
        'reps': TextEditingController(text: '10'),
        'weight': TextEditingController(text: '0'),
      });
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final row in _exercises) {
      row.values.forEach((c) => c.dispose());
    }
    super.dispose();
  }

  Future<void> _save(BuildContext ctx) async {
    final user = ctx.read<AuthProvider>().currentUser!;
    final exercises = _exercises
        .where((row) => row['name']!.text.trim().isNotEmpty)
        .map((row) => Exercise(
              name: row['name']!.text.trim(),
              sets: int.tryParse(row['sets']!.text) ?? 3,
              reps: int.tryParse(row['reps']!.text) ?? 10,
              weightKg: double.tryParse(row['weight']!.text) ?? 0,
            ))
        .toList();

    if (_titleCtrl.text.trim().isEmpty || exercises.isEmpty) return;

    final session = WorkoutSession(
      id: '',  // assigned by server
      userId: user.id,
      title: _titleCtrl.text.trim().toUpperCase(),
      date: DateTime.now(),
      exercises: exercises,
      duration: const Duration(hours: 1),
    );

    await ctx.read<WorkoutProvider>().addSession(session);
    if (ctx.mounted) Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LOG NEW WORKOUT', style: AppTextStyles.headlineSm),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onBackground),
            decoration: const InputDecoration(labelText: 'WORKOUT TITLE'),
          ),
          const SizedBox(height: 20),
          Text('EXERCISES', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          ..._exercises.asMap().entries.map((entry) =>
              _ExerciseInput(controllers: entry.value)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addExerciseRow,
            icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
            label: Text('ADD EXERCISE',
                style: AppTextStyles.labelMd
                    .copyWith(color: AppColors.primary)),
          ),
          const SizedBox(height: 20),
          KineticButton(
            label: 'SAVE WORKOUT',
            onPressed: () async => _save(context),
            fullWidth: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExerciseInput extends StatelessWidget {
  final Map<String, TextEditingController> controllers;

  const _ExerciseInput({required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: controllers['name'],
              textCapitalization: TextCapitalization.words,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Exercise'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: TextField(
              controller: controllers['sets'],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Sets'),
            ),
          ),
          const SizedBox(width: 4),
          Text('×', style: AppTextStyles.bodyMd),
          const SizedBox(width: 4),
          SizedBox(
            width: 48,
            child: TextField(
              controller: controllers['reps'],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'Reps'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controllers['weight'],
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(hintText: 'KG'),
            ),
          ),
        ],
      ),
    );
  }
}
