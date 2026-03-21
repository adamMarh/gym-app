import { Router, Request, Response } from 'express';
import { v4 as uuid } from 'uuid';
import { readAll, findWhere, insert } from '../services/csvService';
import { authenticate } from '../middleware/auth';
import { WorkoutSession, Exercise } from '../types';

const router = Router();

interface WorkoutWithExercises extends WorkoutSession {
  exercises: Exercise[];
}

function buildWorkoutsWithExercises(userId: string): WorkoutWithExercises[] {
  const sessions = findWhere<WorkoutSession>('workout_sessions.csv', (w) => w.userId === userId);
  const allExercises = readAll<Exercise>('exercises.csv');

  const result: WorkoutWithExercises[] = sessions.map((session) => ({
    ...session,
    exercises: allExercises.filter((e) => e.workoutId === session.id),
  }));

  result.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  return result;
}

// ── GET /api/workouts ─────────────────────────────────────────────────────────
router.get('/', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  res.json(buildWorkoutsWithExercises(userId));
});

// ── GET /api/workouts/dates ───────────────────────────────────────────────────
// Returns array of ISO date strings for days that have at least one workout
router.get('/dates', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const sessions = findWhere<WorkoutSession>('workout_sessions.csv', (w) => w.userId === userId);

  const uniqueDates = [
    ...new Set(
      sessions.map((s) => {
        const d = new Date(s.date);
        return new Date(d.getFullYear(), d.getMonth(), d.getDate()).toISOString();
      }),
    ),
  ];

  res.json(uniqueDates);
});

// ── GET /api/workouts/by-date?date=YYYY-MM-DD ─────────────────────────────────
router.get('/by-date', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const { date } = req.query as { date?: string };

  if (!date) {
    res.status(400).json({ error: 'date query parameter is required (YYYY-MM-DD)' });
    return;
  }

  const target = new Date(date);
  if (isNaN(target.getTime())) {
    res.status(400).json({ error: 'Invalid date format' });
    return;
  }

  const all = buildWorkoutsWithExercises(userId);
  const filtered = all.filter((w) => {
    const d = new Date(w.date);
    return (
      d.getFullYear() === target.getFullYear() &&
      d.getMonth() === target.getMonth() &&
      d.getDate() === target.getDate()
    );
  });

  res.json(filtered);
});

// ── GET /api/workouts/:id ─────────────────────────────────────────────────────
router.get('/:id', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const workoutId = req.params['id'];

  const session = findWhere<WorkoutSession>(
    'workout_sessions.csv',
    (w) => w.id === workoutId && w.userId === userId,
  )[0];

  if (!session) {
    res.status(404).json({ error: 'Workout not found' });
    return;
  }

  const exercises = findWhere<Exercise>('exercises.csv', (e) => e.workoutId === workoutId);
  res.json({ ...session, exercises });
});

// ── POST /api/workouts ────────────────────────────────────────────────────────
// Body: { title, date, durationMinutes, notes?, exercises: [{ name, sets, reps, weightKg, notes? }] }
router.post('/', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const {
    title,
    date,
    durationMinutes,
    notes,
    exercises,
  } = req.body as {
    title?: string;
    date?: string;
    durationMinutes?: number;
    notes?: string;
    exercises?: Array<{
      name: string;
      sets: number;
      reps: number;
      weightKg: number;
      notes?: string;
    }>;
  };

  if (!title || !date || durationMinutes === undefined) {
    res.status(400).json({ error: 'title, date, and durationMinutes are required' });
    return;
  }

  const workoutId = uuid();

  const newSession: WorkoutSession = {
    id: workoutId,
    userId,
    title,
    date,
    durationMinutes: Number(durationMinutes),
    notes: notes ?? '',
  };

  insert<WorkoutSession>('workout_sessions.csv', newSession);

  const savedExercises: Exercise[] = [];
  if (Array.isArray(exercises)) {
    for (const ex of exercises) {
      if (!ex.name || ex.sets === undefined || ex.reps === undefined || ex.weightKg === undefined) {
        continue;
      }
      const newEx: Exercise = {
        id: uuid(),
        workoutId,
        name: ex.name,
        sets: Number(ex.sets),
        reps: Number(ex.reps),
        weightKg: Number(ex.weightKg),
        notes: ex.notes ?? '',
      };
      insert<Exercise>('exercises.csv', newEx);
      savedExercises.push(newEx);
    }
  }

  res.status(201).json({ ...newSession, exercises: savedExercises });
});

export default router;
