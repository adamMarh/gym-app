import { Router, Request, Response } from 'express';
import { v4 as uuid } from 'uuid';
import {
  readAll,
  findOne,
  findWhere,
  insert,
  updateWhere,
  deleteWhere,
} from '../services/csvService';
import { authenticate, requireRole } from '../middleware/auth';
import { Post, PostLike, Comment } from '../types';

const router = Router();

function buildFeed(requestingUserId: string) {
  const posts = readAll<Post>('posts.csv');
  const likes = readAll<PostLike>('post_likes.csv');
  const comments = readAll<Comment>('comments.csv');

  const likedPostIds = new Set(
    likes.filter((l) => l.userId === requestingUserId).map((l) => l.postId),
  );

  const result = posts.map((post) => ({
    ...post,
    isLiked: likedPostIds.has(post.id),
    comments: comments
      .filter((c) => c.postId === post.id)
      .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()),
  }));

  // Pinned first, then newest
  result.sort((a, b) => {
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;
    return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
  });

  return result;
}

// ── GET /api/feed ─────────────────────────────────────────────────────────────
router.get('/', authenticate, (req: Request, res: Response): void => {
  res.json(buildFeed(req.user!.userId));
});

// ── POST /api/feed ────────────────────────────────────────────────────────────
router.post('/', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const { content, imageUrl } = req.body as { content?: string; imageUrl?: string };

  if (!content || content.trim() === '') {
    res.status(400).json({ error: 'content is required' });
    return;
  }

  // Look up user name
  const { readAll: ra } = require('../services/csvService');
  const users = ra('users.csv') as Array<{ id: string; name: string; avatarUrl: string }>;
  const author = users.find((u) => u.id === userId);

  const newPost: Post = {
    id: uuid(),
    userId,
    userName: author?.name ?? 'Unknown',
    userAvatarUrl: author?.avatarUrl ?? '',
    content: content.trim(),
    imageUrl: imageUrl ?? '',
    createdAt: new Date().toISOString(),
    likes: 0,
    isPinned: false,
    isFlagged: false,
  };

  insert<Post>('posts.csv', newPost);
  res.status(201).json({ ...newPost, isLiked: false, comments: [] });
});

// ── DELETE /api/feed/:id ──────────────────────────────────────────────────────
router.delete('/:id', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const postId = req.params['id'];
  const role = req.user!.role;

  const post = findOne<Post>('posts.csv', (p) => p.id === postId);
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }

  // Only the author or an admin can delete a post
  if (post.userId !== userId && role !== 'admin') {
    res.status(403).json({ error: 'Insufficient permissions' });
    return;
  }

  deleteWhere<Post>('posts.csv', (p) => p.id === postId);
  deleteWhere<Comment>('comments.csv', (c) => c.postId === postId);
  deleteWhere<PostLike>('post_likes.csv', (l) => l.postId === postId);

  res.json({ message: 'Post deleted' });
});

// ── POST /api/feed/:id/like ───────────────────────────────────────────────────
router.post('/:id/like', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const postId = req.params['id'];

  const post = findOne<Post>('posts.csv', (p) => p.id === postId);
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }

  const alreadyLiked = findOne<PostLike>(
    'post_likes.csv',
    (l) => l.userId === userId && l.postId === postId,
  );

  if (alreadyLiked) {
    // Unlike
    deleteWhere<PostLike>('post_likes.csv', (l) => l.userId === userId && l.postId === postId);
    updateWhere<Post>(
      'posts.csv',
      (p) => p.id === postId,
      (p) => ({ ...p, likes: Math.max(0, p.likes - 1) }),
    );
  } else {
    // Like
    insert<PostLike>('post_likes.csv', { userId, postId });
    updateWhere<Post>(
      'posts.csv',
      (p) => p.id === postId,
      (p) => ({ ...p, likes: p.likes + 1 }),
    );
  }

  const updated = findOne<Post>('posts.csv', (p) => p.id === postId);
  const comments = findWhere<Comment>('comments.csv', (c) => c.postId === postId);

  res.json({ ...(updated ?? post), isLiked: !alreadyLiked, comments });
});

// ── POST /api/feed/:id/flag  (staff or admin) ─────────────────────────────────
router.post(
  '/:id/flag',
  authenticate,
  requireRole('staff', 'admin'),
  (req: Request, res: Response): void => {
    const postId = req.params['id'];

    const post = findOne<Post>('posts.csv', (p) => p.id === postId);
    if (!post) {
      res.status(404).json({ error: 'Post not found' });
      return;
    }

    updateWhere<Post>(
      'posts.csv',
      (p) => p.id === postId,
      (p) => ({ ...p, isFlagged: !p.isFlagged }),
    );

    const updated = findOne<Post>('posts.csv', (p) => p.id === postId);
    res.json(updated);
  },
);

// ── POST /api/feed/:id/pin  (admin only) ─────────────────────────────────────
router.post(
  '/:id/pin',
  authenticate,
  requireRole('admin'),
  (req: Request, res: Response): void => {
    const postId = req.params['id'];

    const post = findOne<Post>('posts.csv', (p) => p.id === postId);
    if (!post) {
      res.status(404).json({ error: 'Post not found' });
      return;
    }

    // Unpin all, then pin this one
    updateWhere<Post>(
      'posts.csv',
      () => true,
      (p) => ({ ...p, isPinned: false }),
    );
    updateWhere<Post>(
      'posts.csv',
      (p) => p.id === postId,
      (p) => ({ ...p, isPinned: true }),
    );

    const updated = findOne<Post>('posts.csv', (p) => p.id === postId);
    res.json(updated);
  },
);

// ── POST /api/feed/:id/comments ───────────────────────────────────────────────
router.post('/:id/comments', authenticate, (req: Request, res: Response): void => {
  const userId = req.user!.userId;
  const postId = req.params['id'];
  const { content } = req.body as { content?: string };

  if (!content || content.trim() === '') {
    res.status(400).json({ error: 'content is required' });
    return;
  }

  const post = findOne<Post>('posts.csv', (p) => p.id === postId);
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }

  // Look up user name
  const { readAll: ra } = require('../services/csvService');
  const users = ra('users.csv') as Array<{ id: string; name: string }>;
  const author = users.find((u) => u.id === userId);

  const newComment: Comment = {
    id: uuid(),
    postId,
    userId,
    userName: author?.name ?? 'Unknown',
    content: content.trim(),
    createdAt: new Date().toISOString(),
  };

  insert<Comment>('comments.csv', newComment);
  res.status(201).json(newComment);
});

// ── GET /api/feed/:id/comments ────────────────────────────────────────────────
router.get('/:id/comments', authenticate, (req: Request, res: Response): void => {
  const postId = req.params['id'];
  const post = findOne<Post>('posts.csv', (p) => p.id === postId);
  if (!post) {
    res.status(404).json({ error: 'Post not found' });
    return;
  }

  const comments = findWhere<Comment>('comments.csv', (c) => c.postId === postId).sort(
    (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
  );

  res.json(comments);
});

export default router;
