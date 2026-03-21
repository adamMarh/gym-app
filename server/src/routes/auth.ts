import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { findOne, updateWhere } from '../services/csvService';
import { authenticate, signToken } from '../middleware/auth';
import { User } from '../types';

const router = Router();

/** Strip password hash before sending user to client */
function safeUser(u: User) {
  const { passwordHash: _pw, ...rest } = u;
  void _pw;
  return rest;
}

// ── POST /api/auth/login ─────────────────────────────────────────────────────
router.post('/login', (req: Request, res: Response): void => {
  const { email, password } = req.body as { email?: string; password?: string };

  if (!email || !password) {
    res.status(400).json({ error: 'Email and password are required' });
    return;
  }

  const user = findOne<User>('users.csv', (u) => u.email.toLowerCase() === email.toLowerCase());

  if (!user) {
    res.status(401).json({ error: 'Invalid credentials' });
    return;
  }

  const valid = bcrypt.compareSync(password, user.passwordHash);
  if (!valid) {
    res.status(401).json({ error: 'Invalid credentials' });
    return;
  }

  const token = signToken({ userId: user.id, role: user.role });
  res.json({ token, user: safeUser(user) });
});

// ── GET /api/auth/me ─────────────────────────────────────────────────────────
router.get('/me', authenticate, (req: Request, res: Response): void => {
  const user = findOne<User>('users.csv', (u) => u.id === req.user!.userId);
  if (!user) {
    res.status(404).json({ error: 'User not found' });
    return;
  }
  res.json(safeUser(user));
});

// ── PATCH /api/auth/me ───────────────────────────────────────────────────────
router.patch('/me', authenticate, (req: Request, res: Response): void => {
  const { name, phone } = req.body as { name?: string; phone?: string };
  const userId = req.user!.userId;

  updateWhere<User>(
    'users.csv',
    (u) => u.id === userId,
    (u) => ({
      ...u,
      name: name !== undefined ? name : u.name,
      phone: phone !== undefined ? phone : u.phone,
    }),
  );

  const updated = findOne<User>('users.csv', (u) => u.id === userId);
  if (!updated) {
    res.status(404).json({ error: 'User not found' });
    return;
  }
  res.json(safeUser(updated));
});

export default router;
