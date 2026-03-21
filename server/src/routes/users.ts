import { Router, Request, Response } from 'express';
import { readAll, findOne } from '../services/csvService';
import { authenticate, requireRole } from '../middleware/auth';
import { User } from '../types';

const router = Router();

function safeUser(u: User) {
  const { passwordHash: _pw, ...rest } = u;
  void _pw;
  return rest;
}

// ── GET /api/users  (admin only) ─────────────────────────────────────────────
router.get('/', authenticate, requireRole('admin'), (_req: Request, res: Response): void => {
  const users = readAll<User>('users.csv').map(safeUser);
  res.json(users);
});

// ── GET /api/users/:id ───────────────────────────────────────────────────────
router.get('/:id', authenticate, (req: Request, res: Response): void => {
  const user = findOne<User>('users.csv', (u) => u.id === req.params['id']);
  if (!user) {
    res.status(404).json({ error: 'User not found' });
    return;
  }
  res.json(safeUser(user));
});

export default router;
