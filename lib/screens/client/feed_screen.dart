import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/client/post_card.dart';
import '../../widgets/common/kinetic_button.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final user = context.watch<AuthProvider>().currentUser!;
    final posts = feed.posts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('COMMUNITY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _showPostSheet(context, user.id, user.name),
          ),
        ],
      ),
      body: posts.isEmpty
          ? Center(
              child: Text('NO POSTS YET', style: AppTextStyles.labelSmCaps),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 2),
              itemBuilder: (ctx, i) {
                final post = posts[i];
                return PostCard(
                  post: post,
                  onLike: () => feed.toggleLike(post.id),
                  onComment: () => _showComments(context, post, feed, user),
                  isAdminView: user.isAdmin,
                  onDelete:
                      user.isAdmin ? () => feed.deletePost(post.id) : null,
                  onFlag: user.isAdmin ? () => feed.flagPost(post.id) : null,
                  onPin: user.isAdmin ? () => feed.pinPost(post.id) : null,
                );
              },
            ),
    );
  }

  void _showPostSheet(BuildContext context, String userId, String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      builder: (_) => _NewPostSheet(userId: userId, userName: userName),
    );
  }

  void _showComments(
      BuildContext context, Post post, FeedProvider feed, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      builder: (_) => _CommentsSheet(
        post: post,
        onSubmit: (text) {
          final comment = Comment(
            id: 'cm${DateTime.now().millisecondsSinceEpoch}',
            userId: user.id,
            userName: user.name,
            content: text,
            createdAt: DateTime.now(),
          );
          feed.addComment(post.id, comment);
        },
      ),
    );
  }
}

class _NewPostSheet extends StatefulWidget {
  final String userId;
  final String userName;

  const _NewPostSheet({required this.userId, required this.userName});

  @override
  State<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<_NewPostSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  widget.userName[0],
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(widget.userName, style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onBackground,
              )),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            autofocus: true,
            style: AppTextStyles.bodyLg.copyWith(color: AppColors.onBackground),
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind?',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: 16),
          KineticButton(
            label: 'POST',
            fullWidth: true,
            onPressed: () {
              if (_ctrl.text.trim().isEmpty) return;
              context.read<FeedProvider>().addPost(Post(
                    id: 'p${DateTime.now().millisecondsSinceEpoch}',
                    userId: widget.userId,
                    userName: widget.userName,
                    content: _ctrl.text.trim(),
                    createdAt: DateTime.now(),
                  ));
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final Post post;
  final void Function(String) onSubmit;

  const _CommentsSheet({required this.post, required this.onSubmit});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMMENTS', style: AppTextStyles.headlineSm),
          const SizedBox(height: 16),
          if (widget.post.comments.isEmpty)
            Text('No comments yet.', style: AppTextStyles.bodyMd)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.post.comments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final c = widget.post.comments[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.secondaryContainer,
                        child: Text(c.userName[0],
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.onSecondaryContainer)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.userName,
                                style: AppTextStyles.labelLg.copyWith(
                                    color: AppColors.onBackground)),
                            Text(c.content, style: AppTextStyles.bodyMd),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onBackground),
                  decoration: const InputDecoration(hintText: 'Add a comment...'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  widget.onSubmit(_ctrl.text.trim());
                  setState(() {});
                  _ctrl.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
