import 'dotenv/config';
import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';

import { seedDatabase } from './services/seedService';

import authRoutes from './routes/auth';
import usersRoutes from './routes/users';
import classesRoutes from './routes/classes';
import workoutsRoutes from './routes/workouts';
import feedRoutes from './routes/feed';
import staffRoutes from './routes/staff';

const app = express();
const PORT = process.env['PORT'] ?? 3000;

// ── Global Middleware ─────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/classes', classesRoutes);
app.use('/api/workouts', workoutsRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/staff', staffRoutes);

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((_req: Request, res: Response) => {
  res.status(404).json({ error: 'Route not found' });
});

// ── Global error handler ──────────────────────────────────────────────────────
app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// ── Bootstrap ─────────────────────────────────────────────────────────────────
async function bootstrap(): Promise<void> {
  try {
    await seedDatabase();
    app.listen(PORT, () => {
      console.log(`\n🏋️  Gym Backend running on http://localhost:${PORT}`);
      console.log(`📁  DB files in: backend/DB/`);
      console.log(`\nRoutes:`);
      console.log(`  POST   /api/auth/login`);
      console.log(`  GET    /api/auth/me`);
      console.log(`  PATCH  /api/auth/me`);
      console.log(`  GET    /api/users              (admin)`);
      console.log(`  GET    /api/classes`);
      console.log(`  POST   /api/classes             (staff/admin)`);
      console.log(`  DELETE /api/classes/:id         (admin)`);
      console.log(`  POST   /api/classes/:id/book`);
      console.log(`  DELETE /api/classes/:id/book`);
      console.log(`  GET    /api/workouts`);
      console.log(`  GET    /api/workouts/dates`);
      console.log(`  GET    /api/workouts/by-date?date=YYYY-MM-DD`);
      console.log(`  POST   /api/workouts`);
      console.log(`  GET    /api/feed`);
      console.log(`  POST   /api/feed`);
      console.log(`  DELETE /api/feed/:id`);
      console.log(`  POST   /api/feed/:id/like`);
      console.log(`  POST   /api/feed/:id/flag       (staff/admin)`);
      console.log(`  POST   /api/feed/:id/pin        (admin)`);
      console.log(`  GET    /api/feed/:id/comments`);
      console.log(`  POST   /api/feed/:id/comments`);
      console.log(`  GET    /api/staff/punch/status  (staff/admin)`);
      console.log(`  POST   /api/staff/punch/in      (staff/admin)`);
      console.log(`  POST   /api/staff/punch/out     (staff/admin)`);
      console.log(`  GET    /api/staff/punch/history (staff/admin)`);
      console.log(`  GET    /api/staff/reports       (staff/admin)`);
      console.log(`  POST   /api/staff/reports       (staff/admin)`);
      console.log(`  PATCH  /api/staff/reports/:id/review (admin)`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

bootstrap();
