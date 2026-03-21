import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/post.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onFlag;
  final VoidCallback? onPin;
  final bool isAdminView;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onDelete,
    this.onFlag,
    this.onPin,
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned badge
          if (post.isPinned) ...[
            Row(
              children: [
                const Icon(Icons.push_pin, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'PINNED',
                  style: AppTextStyles.labelSmCaps
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Flagged badge
          if (post.isFlagged) ...[
            Row(
              children: [
                const Icon(Icons.flag, size: 12, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  'FLAGGED FOR REVIEW',
                  style: AppTextStyles.labelSmCaps
                      .copyWith(color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  post.userName[0].toUpperCase(),
                  style: AppTextStyles.titleMd
                      .copyWith(color: AppColors.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w700,
                    )),
                    Text(
                      _timeAgo(post.createdAt),
                      style: AppTextStyles.labelSmCaps,
                    ),
                  ],
                ),
              ),
              if (isAdminView)
                _AdminMenu(
                  onDelete: onDelete,
                  onFlag: onFlag,
                  onPin: onPin,
                  isPinned: post.isPinned,
                  isFlagged: post.isFlagged,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text(post.content, style: AppTextStyles.bodyLg),

          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              height: 200,
              color: AppColors.surfaceContainerHighest,
              child: const Center(
                child: Icon(Icons.image_outlined,
                    size: 48, color: AppColors.onSurfaceVariant),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Actions row
          Row(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likes}',
                color: post.isLiked ? AppColors.primary : AppColors.onSurfaceVariant,
                onTap: onLike,
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments.length}',
                color: AppColors.onSurfaceVariant,
                onTap: onComment,
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'SHARE',
                color: AppColors.onSurfaceVariant,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
    if (diff.inHours < 24) return '${diff.inHours}H AGO';
    return DateFormat('MMM d').format(dt).toUpperCase();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _AdminMenu extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onFlag;
  final VoidCallback? onPin;
  final bool isPinned;
  final bool isFlagged;

  const _AdminMenu({
    this.onDelete,
    this.onFlag,
    this.onPin,
    required this.isPinned,
    required this.isFlagged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.onSurfaceVariant),
      color: AppColors.surfaceContainerHighest,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'pin',
          child: Text(
            isPinned ? 'UNPIN' : 'PIN POST',
            style: AppTextStyles.labelMd,
          ),
        ),
        PopupMenuItem(
          value: 'flag',
          child: Text(
            isFlagged ? 'UNFLAG' : 'FLAG POST',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'DELETE',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'delete') onDelete?.call();
        if (val == 'flag') onFlag?.call();
        if (val == 'pin') onPin?.call();
      },
    );
  }
}
