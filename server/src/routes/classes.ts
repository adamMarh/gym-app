import { Router, Request, Response } from 'express';
import { v4 as uuid } from 'uuid';
import {
  readAll,
  findOne,
  insert,
  updateWhere,
  deleteWhere,
  findWhere,
} from '../services/csvService';
import { authenticate, requireRole } from '../middleware/auth';
import { ClassSession, ClassBooking } from '../types';

const router = Router();

// ── GET /api/classes ─────────────────────────────────────────────────────────
router.get('/', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const classes = readAll<ClassSession>('class_sessions.csv');
  const bookings = findWhere<ClassBooking>('class_bookings.csv', (b) => b.userId === userId);
  const bookedIds = new Set(bookings.map((b) => b.classId));

  const result = classes.map((cls) => ({
    ...cls,
    isBooked: bookedIds.has(cls.id),
  }));

  // Sort by startTime ascending
  result.sort((a, b) => new Date(a.startTime).getTime() - new Date(b.startTime).getTime());

  res.json(result);
});

// ── POST /api/classes  (staff or admin) ──────────────────────────────────────
router.post('/', authenticate, requireRole('staff', 'admin'), (req: Request, res: Response): void => {
  const { title, instructor, startTime, durationMinutes, capacity, category, description } =
    req.body as Partial<ClassSession>;

  if (!title || !instructor || !startTime || !durationMinutes || !capacity || !category) {
    res.status(400).json({ error: 'Missing required fields' });
    return;
  }

  const newClass: ClassSession = {
    id: uuid(),
    title,
    instructor,
    startTime,
    durationMinutes: Number(durationMinutes),
    capacity: Number(capacity),
    enrolled: 0,
    category,
    description: description ?? '',
  };

  insert('class_sessions.csv', newClass);
  res.status(201).json({ ...newClass, isBooked: false });
});

// ── DELETE /api/classes/:id  (admin) ─────────────────────────────────────────
router.delete('/:id', authenticate, requireRole('admin'), (req: Request, res: Response): void => {
  const { id } = req.params;
  const cls = findOne<ClassSession>('class_sessions.csv', (c) => c.id === id);

  if (!cls) {
    res.status(404).json({ error: 'Class not found' });
    return;
  }

  deleteWhere<ClassSession>('class_sessions.csv', (c) => c.id === id);
  // Also remove all bookings for this class
  deleteWhere<ClassBooking>('class_bookings.csv', (b) => b.classId === id);

  res.json({ message: 'Class deleted' });
});

// ── POST /api/classes/:id/book ───────────────────────────────────────────────
router.post('/:id/book', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const classId = req.params['id'];

  const cls = findOne<ClassSession>('class_sessions.csv', (c) => c.id === classId);
  if (!cls) {
    res.status(404).json({ error: 'Class not found' });
    return;
  }

  const alreadyBooked = findOne<ClassBooking>(
    'class_bookings.csv',
    (b) => b.userId === userId && b.classId === classId,
  );
  if (alreadyBooked) {
    res.status(409).json({ error: 'Already booked' });
    return;
  }

  if (cls.enrolled >= cls.capacity) {
    res.status(409).json({ error: 'Class is full' });
    return;
  }

  // Insert booking and increment enrolled count
  insert<ClassBooking>('class_bookings.csv', { userId, classId });
  updateWhere<ClassSession>(
    'class_sessions.csv',
    (c) => c.id === classId,
    (c) => ({ ...c, enrolled: c.enrolled + 1 }),
  );

  const updated = findOne<ClassSession>('class_sessions.csv', (c) => c.id === classId);
  res.json({ ...(updated ?? cls), isBooked: true });
});

// ── DELETE /api/classes/:id/book ─────────────────────────────────────────────
router.delete('/:id/book', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const classId = req.params['id'];

  const booking = findOne<ClassBooking>(
    'class_bookings.csv',
    (b) => b.userId === userId && b.classId === classId,
  );
  if (!booking) {
    res.status(404).json({ error: 'Booking not found' });
    return;
  }

  deleteWhere<ClassBooking>(
    'class_bookings.csv',
    (b) => b.userId === userId && b.classId === classId,
  );
  updateWhere<ClassSession>(
    'class_sessions.csv',
    (c) => c.id === classId,
    (c) => ({ ...c, enrolled: Math.max(0, c.enrolled - 1) }),
  );

  const updated = findOne<ClassSession>('class_sessions.csv', (c) => c.id === classId);
  res.json({ ...(updated ?? {}), isBooked: false });
});

export default router;
