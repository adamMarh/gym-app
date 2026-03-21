import fs from 'fs';
import path from 'path';
import bcrypt from 'bcryptjs';
import { stringify } from 'csv-stringify/sync';
import { DB_PATH, writeAll } from './csvService';
import {
  User,
  ClassSession,
  WorkoutSession,
  Exercise,
  Post,
  Comment,
  StaffReport,
} from '../types';

const file = (name: string) => path.join(DB_PATH, name);

/**
 * Creates a header-only CSV for tables that start empty at boot.
 * The dummy row defines the schema; hasData() treats header-only as empty.
 */
function initEmptyCsv(filename: string, dummy: Record<string, string>): void {
  const fp = file(filename);
  const header = stringify([dummy], { header: true }).split('\n')[0];
  fs.writeFileSync(fp, header + '\n', 'utf-8');
}

/** Returns true if the given CSV file already has data (not empty, not header-only). */
function hasData(filename: string): boolean {
  const fp = file(filename);
  if (!fs.existsSync(fp)) return false;
  const lines = fs.readFileSync(fp, 'utf-8').trim().split('\n').filter(Boolean);
  return lines.length > 1; // more than just the header
}

function addDays(d: Date, n: number): Date {
  return new Date(d.getTime() + n * 86_400_000);
}
function addHours(d: Date, n: number): Date {
  return new Date(d.getTime() + n * 3_600_000);
}
function subDays(d: Date, n: number): Date {
  return addDays(d, -n);
}

export async function seedDatabase(): Promise<void> {
  const now = new Date();
  const password = await bcrypt.hash('password', 10);

  // ── Users ───────────────────────────────────────────────────────────────────
  if (!hasData('users.csv')) {
    const users: User[] = [
      {
        id: 'u1',
        name: 'Alex Rivera',
        email: 'alex@example.com',
        passwordHash: password,
        role: 'client',
        membershipTier: 'Elite',
        membershipExpiry: addDays(now, 90).toISOString(),
        phone: '',
        avatarUrl: '',
      },
      {
        id: 'u2',
        name: 'Jordan Smith',
        email: 'jordan@example.com',
        passwordHash: password,
        role: 'staff',
        membershipTier: 'Staff',
        membershipExpiry: addDays(now, 365).toISOString(),
        phone: '',
        avatarUrl: '',
      },
      {
        id: 'u3',
        name: 'Sam Chen',
        email: 'sam@example.com',
        passwordHash: password,
        role: 'admin',
        membershipTier: 'Admin',
        membershipExpiry: addDays(now, 365).toISOString(),
        phone: '',
        avatarUrl: '',
      },
    ];
    writeAll('users.csv', users);
    console.log('✔ Seeded users.csv');
  }

  // ── Class Sessions ──────────────────────────────────────────────────────────
  if (!hasData('class_sessions.csv')) {
    const classes: ClassSession[] = [
      {
        id: 'c1',
        title: 'HIIT BLAST',
        instructor: 'Marcus T.',
        startTime: addHours(now, 2).toISOString(),
        durationMinutes: 45,
        capacity: 20,
        enrolled: 14,
        category: 'HIIT',
        description: 'High-intensity interval training to torch calories.',
      },
      {
        id: 'c2',
        title: 'POWER YOGA',
        instructor: 'Priya M.',
        startTime: addHours(now, 5).toISOString(),
        durationMinutes: 60,
        capacity: 15,
        enrolled: 15,
        category: 'YOGA',
        description: 'Strength-focused yoga flow for athletes.',
      },
      {
        id: 'c3',
        title: 'HEAVY LIFTING',
        instructor: 'Bruno K.',
        startTime: addHours(addDays(now, 1), 7).toISOString(),
        durationMinutes: 60,
        capacity: 12,
        enrolled: 8,
        category: 'STRENGTH',
        description: 'Compound movements to build raw strength.',
      },
      {
        id: 'c4',
        title: 'SPIN CYCLE',
        instructor: 'Zara L.',
        startTime: addHours(addDays(now, 1), 10).toISOString(),
        durationMinutes: 50,
        capacity: 25,
        enrolled: 19,
        category: 'CARDIO',
        description: '',
      },
      {
        id: 'c5',
        title: 'BOXING BASICS',
        instructor: 'Dom R.',
        startTime: addHours(addDays(now, 2), 8).toISOString(),
        durationMinutes: 60,
        capacity: 18,
        enrolled: 10,
        category: 'BOXING',
        description: '',
      },
      {
        id: 'c6',
        title: 'CORE & MORE',
        instructor: 'Emma S.',
        startTime: addHours(addDays(now, 2), 12).toISOString(),
        durationMinutes: 30,
        capacity: 20,
        enrolled: 5,
        category: 'CORE',
        description: '',
      },
    ];
    writeAll('class_sessions.csv', classes);
    console.log('✔ Seeded class_sessions.csv');
  }

  // ── Class Bookings ─────────────────────────────────────────────────────────
  // Bookings are live user state; start empty so the CSV schema exists on disk.
  if (!hasData('class_bookings.csv')) {
    initEmptyCsv('class_bookings.csv', { userId: '__init__', classId: '__init__' });
    console.log('✔ Initialized class_bookings.csv');
  }

  // ── Workout Sessions ────────────────────────────────────────────────────────
  if (!hasData('workout_sessions.csv')) {
    const workouts: WorkoutSession[] = [
      {
        id: 'w1',
        userId: 'u1',
        title: 'PUSH DAY',
        date: subDays(now, 1).toISOString(),
        durationMinutes: 75,
        notes: '',
      },
      {
        id: 'w2',
        userId: 'u1',
        title: 'LEG DAY',
        date: subDays(now, 3).toISOString(),
        durationMinutes: 90,
        notes: '',
      },
      {
        id: 'w3',
        userId: 'u1',
        title: 'PULL DAY',
        date: subDays(now, 5).toISOString(),
        durationMinutes: 70,
        notes: '',
      },
    ];
    writeAll('workout_sessions.csv', workouts);
    console.log('✔ Seeded workout_sessions.csv');
  }

  // ── Exercises ───────────────────────────────────────────────────────────────
  if (!hasData('exercises.csv')) {
    const exercises: Exercise[] = [
      // w1 — Push Day
      { id: 'e1', workoutId: 'w1', name: 'Bench Press', sets: 4, reps: 8, weightKg: 100, notes: '' },
      { id: 'e2', workoutId: 'w1', name: 'Shoulder Press', sets: 3, reps: 10, weightKg: 60, notes: '' },
      { id: 'e3', workoutId: 'w1', name: 'Tricep Dips', sets: 3, reps: 12, weightKg: 0, notes: '' },
      // w2 — Leg Day
      { id: 'e4', workoutId: 'w2', name: 'Squat', sets: 5, reps: 5, weightKg: 150, notes: '' },
      { id: 'e5', workoutId: 'w2', name: 'Romanian DL', sets: 3, reps: 8, weightKg: 110, notes: '' },
      { id: 'e6', workoutId: 'w2', name: 'Leg Press', sets: 3, reps: 12, weightKg: 200, notes: '' },
      // w3 — Pull Day
      { id: 'e7', workoutId: 'w3', name: 'Deadlift', sets: 4, reps: 5, weightKg: 160, notes: '' },
      { id: 'e8', workoutId: 'w3', name: 'Pull-ups', sets: 3, reps: 8, weightKg: 0, notes: '' },
      { id: 'e9', workoutId: 'w3', name: 'Barbell Row', sets: 3, reps: 10, weightKg: 80, notes: '' },
    ];
    writeAll('exercises.csv', exercises);
    console.log('✔ Seeded exercises.csv');
  }

  // ── Posts ───────────────────────────────────────────────────────────────────
  if (!hasData('posts.csv')) {
    const posts: Post[] = [
      {
        id: 'p1',
        userId: 'u1',
        userName: 'Alex Rivera',
        userAvatarUrl: '',
        content: 'NEW PR TODAY 🔥 Hit 150KG on the squat. Consistent training pays off. #CSEE #PRAlert',
        imageUrl: '',
        createdAt: addHours(now, -2).toISOString(),
        likes: 42,
        isPinned: false,
        isFlagged: false,
      },
      {
        id: 'p2',
        userId: 'u2',
        userName: 'Jordan Smith',
        userAvatarUrl: '',
        content: "Morning HIIT class was absolutely brutal today. If you weren't sweating, you weren't trying. See you tomorrow at 6AM 💪",
        imageUrl: '',
        createdAt: addHours(now, -5).toISOString(),
        likes: 28,
        isPinned: false,
        isFlagged: false,
      },
      {
        id: 'p3',
        userId: 'u3',
        userName: 'Sam Chen',
        userAvatarUrl: '',
        content: '📢 New boxing classes starting next Monday. Limited spots available — book now in the Classes tab!',
        imageUrl: '',
        createdAt: addHours(now, -12).toISOString(),
        likes: 67,
        isPinned: true,
        isFlagged: false,
      },
      {
        id: 'p4',
        userId: 'u1',
        userName: 'Alex Rivera',
        userAvatarUrl: '',
        content: 'Week 8 of my strength program done. Volume is up 40% from where I started. The grind is real. 📈',
        imageUrl: '',
        createdAt: addHours(now, -26).toISOString(),
        likes: 19,
        isPinned: false,
        isFlagged: false,
      },
    ];
    writeAll('posts.csv', posts);
    console.log('✔ Seeded posts.csv');
  }

  // ── Post Likes ──────────────────────────────────────────────────────────────
  // Likes are live per-user state; start empty so the CSV schema exists on disk.
  if (!hasData('post_likes.csv')) {
    initEmptyCsv('post_likes.csv', { userId: '__init__', postId: '__init__' });
    console.log('✔ Initialized post_likes.csv');
  }

  // ── Comments ────────────────────────────────────────────────────────────────
  if (!hasData('comments.csv')) {
    const comments: Comment[] = [
      {
        id: 'cm1',
        postId: 'p1',
        userId: 'u2',
        userName: 'Jordan Smith',
        content: 'BEAST MODE 🏆',
        createdAt: addHours(now, -1).toISOString(),
      },
    ];
    writeAll('comments.csv', comments);
    console.log('✔ Seeded comments.csv');
  }

  // ── Staff Reports ───────────────────────────────────────────────────────────
  if (!hasData('staff_reports.csv')) {
    const reports: StaffReport[] = [
      {
        id: 'r1',
        staffId: 'u2',
        staffName: 'Jordan Smith',
        date: subDays(now, 1).toISOString(),
        summary: 'Completed morning HIIT and afternoon yoga sessions.',
        details:
          'HIIT class had 14 participants — all completed the full session. ' +
          'Equipment check performed. Minor repair needed on treadmill #3. ' +
          'Yoga class had 12 participants. Overall smooth day.',
        isReviewed: true,
        adminNotes: 'Good work. Please follow up on treadmill repair.',
      },
      {
        id: 'r2',
        staffId: 'u2',
        staffName: 'Jordan Smith',
        date: now.toISOString(),
        summary: 'Managed front desk and led boxing intro class.',
        details:
          'Front desk was busy this morning with 8 new member sign-ups. ' +
          'Boxing intro class had 10 participants, all beginners. ' +
          'Reported a faulty locker to maintenance.',
        isReviewed: false,
        adminNotes: '',
      },
    ];
    writeAll('staff_reports.csv', reports);
    console.log('✔ Seeded staff_reports.csv');
  }

  // ── Punch Records ───────────────────────────────────────────────────────────
  // Punch records are live; start empty so the CSV schema exists on disk.
  if (!hasData('punch_records.csv')) {
    initEmptyCsv('punch_records.csv', { id: '__init__', staffId: '__init__', punchIn: '__init__', punchOut: '__init__' });
    console.log('✔ Initialized punch_records.csv');
  }
}
