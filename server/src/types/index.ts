// ─── Domain Types ────────────────────────────────────────────────────────────

export type UserRole = 'client' | 'staff' | 'admin';

export interface User {
  id: string;
  name: string;
  email: string;
  passwordHash: string;
  role: UserRole;
  membershipTier: string;
  membershipExpiry: string; // ISO date string
  phone: string;
  avatarUrl: string;
}

export interface ClassSession {
  id: string;
  title: string;
  instructor: string;
  startTime: string; // ISO date string
  durationMinutes: number;
  capacity: number;
  enrolled: number;
  category: string;
  description: string;
}

export interface ClassBooking {
  userId: string;
  classId: string;
}

export interface WorkoutSession {
  id: string;
  userId: string;
  title: string;
  date: string; // ISO date string
  durationMinutes: number;
  notes: string;
}

export interface Exercise {
  id: string;
  workoutId: string;
  name: string;
  sets: number;
  reps: number;
  weightKg: number;
  notes: string;
}

export interface Post {
  id: string;
  userId: string;
  userName: string;
  userAvatarUrl: string;
  content: string;
  imageUrl: string;
  createdAt: string; // ISO date string
  likes: number;
  isPinned: boolean;
  isFlagged: boolean;
}

export interface PostLike {
  userId: string;
  postId: string;
}

export interface Comment {
  id: string;
  postId: string;
  userId: string;
  userName: string;
  content: string;
  createdAt: string; // ISO date string
}

export interface StaffReport {
  id: string;
  staffId: string;
  staffName: string;
  date: string; // ISO date string
  summary: string;
  details: string;
  isReviewed: boolean;
  adminNotes: string;
}

export interface PunchRecord {
  id: string;
  staffId: string;
  punchIn: string; // ISO date string
  punchOut: string; // ISO date string, empty string if active
}

// ─── Auth ────────────────────────────────────────────────────────────────────

export interface TokenPayload {
  userId: string;
  role: UserRole;
}

// ─── Express Augmentation ────────────────────────────────────────────────────

declare global {
  namespace Express {
    interface Request {
      user?: TokenPayload;
    }
  }
}
