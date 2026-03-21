import { Router, Request, Response } from 'express';
import { v4 as uuid } from 'uuid';
import {
  readAll,
  findOne,
  findWhere,
  insert,
  updateWhere,
} from '../services/csvService';
import { authenticate, requireRole } from '../middleware/auth';
import { PunchRecord, StaffReport } from '../types';

const router = Router();

// ─────────────────────────────────────────────────────────────────────────────
// PUNCH CLOCK
// ─────────────────────────────────────────────────────────────────────────────

// ── GET /api/staff/punch/status ───────────────────────────────────────────────
router.get(
  '/punch/status',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const staffId = req.user!.userId;

    const active = findOne<PunchRecord>(
      'punch_records.csv',
      (p) => p.staffId === staffId && p.punchOut === '',
    );

    res.json({ isPunchedIn: !!active, activePunch: active ?? null });
  },
);

// ── POST /api/staff/punch/in ──────────────────────────────────────────────────
router.post(
  '/punch/in',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const staffId = req.user!.userId;

    const alreadyActive = findOne<PunchRecord>(
      'punch_records.csv',
      (p) => p.staffId === staffId && p.punchOut === '',
    );

    if (alreadyActive) {
      res.status(409).json({ error: 'Already punched in' });
      return;
    }

    const record: PunchRecord = {
      id: uuid(),
      staffId,
      punchIn: new Date().toISOString(),
      punchOut: '',
    };

    insert<PunchRecord>('punch_records.csv', record);
    res.status(201).json(record);
  },
);

// ── POST /api/staff/punch/out ─────────────────────────────────────────────────
router.post(
  '/punch/out',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const staffId = req.user!.userId;

    const active = findOne<PunchRecord>(
      'punch_records.csv',
      (p) => p.staffId === staffId && p.punchOut === '',
    );

    if (!active) {
      res.status(409).json({ error: 'Not currently punched in' });
      return;
    }

    const punchOut = new Date().toISOString();

    updateWhere<PunchRecord>(
      'punch_records.csv',
      (p) => p.id === active.id,
      (p) => ({ ...p, punchOut }),
    );

    res.json({ ...active, punchOut });
  },
);

// ── GET /api/staff/punch/history ──────────────────────────────────────────────
router.get(
  '/punch/history',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const staffId = req.user!.userId;
    const history = findWhere<PunchRecord>(
      'punch_records.csv',
      (p) => p.staffId === staffId && p.punchOut !== '',
    ).sort((a, b) => new Date(b.punchIn).getTime() - new Date(a.punchIn).getTime());

    res.json(history);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// STAFF REPORTS
// ─────────────────────────────────────────────────────────────────────────────

// ── GET /api/staff/reports ────────────────────────────────────────────────────
// Staff sees their own; admin sees all
router.get(
  '/reports',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const { userId, role } = req.user!;

    const reports =
      role === 'admin'
        ? readAll<StaffReport>('staff_reports.csv')
        : findWhere<StaffReport>('staff_reports.csv', (r) => r.staffId === userId);

    reports.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    res.json(reports);
  },
);

// ── GET /api/staff/reports/unreviewed  (admin only) ───────────────────────────
router.get(
  '/reports/unreviewed',
  authenticate,
  requireRole('admin'),
  (_req: Request, res: Response): void => {
    const unreviewed = findWhere<StaffReport>(
      'staff_reports.csv',
      (r) => r.isReviewed === false,
    ).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    res.json(unreviewed);
  },
);

// ── POST /api/staff/reports ───────────────────────────────────────────────────
router.post(
  '/reports',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const staffId = req.user!.userId;
    const { summary, details } = req.body as { summary?: string; details?: string };

    if (!summary || !details) {
      res.status(400).json({ error: 'summary and details are required' });
      return;
    }

    // Resolve staff name from users.csv
    const { readAll: ra } = require('../services/csvService');
    const users = ra('users.csv') as Array<{ id: string; name: string }>;
    const staffMember = users.find((u) => u.id === staffId);

    const report: StaffReport = {
      id: uuid(),
      staffId,
      staffName: staffMember?.name ?? 'Unknown',
      date: new Date().toISOString(),
      summary: summary.trim(),
      details: details.trim(),
      isReviewed: false,
      adminNotes: '',
    };

    insert<StaffReport>('staff_reports.csv', report);
    res.status(201).json(report);
  },
);

// ── PATCH /api/staff/reports/:id/review  (admin only) ────────────────────────
router.patch(
  '/reports/:id/review',
  authenticate,
  requireRole('admin'),
  (req: Request, res: Response): void => {
    const reportId = req.params['id'];
    const { adminNotes } = req.body as { adminNotes?: string };

    const report = findOne<StaffReport>('staff_reports.csv', (r) => r.id === reportId);
    if (!report) {
      res.status(404).json({ error: 'Report not found' });
      return;
    }

    updateWhere<StaffReport>(
      'staff_reports.csv',
      (r) => r.id === reportId,
      (r) => ({ ...r, isReviewed: true, adminNotes: adminNotes ?? r.adminNotes }),
    );

    const updated = findOne<StaffReport>('staff_reports.csv', (r) => r.id === reportId);
    res.json(updated);
  },
);

export default router;
