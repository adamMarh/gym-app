import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/class_provider.dart';
import '../../providers/feed_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/client/class_card.dart';
import '../../widgets/client/post_card.dart';
import '../../widgets/common/power_stat_card.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('ADMIN CENTER'),
          bottom: TabBar(
            labelStyle: AppTextStyles.labelSmCaps
                .copyWith(color: AppColors.primary, fontSize: 10),
            unselectedLabelStyle: AppTextStyles.labelSmCaps.copyWith(fontSize: 10),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            tabs: const [
              Tab(text: 'USERS'),
              Tab(text: 'CLASSES'),
              Tab(text: 'MODERATION'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UsersTab(),
            _ClassesTab(),
            _ModerationTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Users Tab ────────────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final users = User.mockUsers;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Summary stats
        Row(
          children: [
            Expanded(
              child: PowerStatCard(
                value: users
                    .where((u) => u.role == UserRole.client)
                    .length
                    .toString(),
                unit: '',
                label: 'Clients',
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: PowerStatCard(
                value: users
                    .where((u) => u.role == UserRole.staff)
                    .length
                    .toString(),
                unit: '',
                label: 'Staff',
                accentColor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text('ALL MEMBERS', style: AppTextStyles.labelSmCaps),
        const SizedBox(height: 12),

        ...users.map((u) => _UserRow(user: u)),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final User user;

  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              user.name[0].toUpperCase(),
              style: AppTextStyles.titleMd
                  .copyWith(color: AppColors.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w700)),
                Text(user.email, style: AppTextStyles.labelMd),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.secondaryContainer,
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: AppTextStyles.labelSmCaps
                      .copyWith(color: AppColors.onSecondaryContainer),
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 16, color: AppColors.primary),
                onPressed: () => _showEditUser(context, user),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditUser(BuildContext context, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EDIT CLIENT', style: AppTextStyles.headlineSm),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: AppTextStyles.bodyLg
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'FULL NAME'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              style: AppTextStyles.bodyLg
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'EMAIL'),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Classes Tab ──────────────────────────────────────────────────────────────

class _ClassesTab extends StatelessWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ALL CLASSES', style: AppTextStyles.labelSmCaps),
            GestureDetector(
              onTap: () {},
              child: Text(
                '+ ADD CLASS',
                style: AppTextStyles.labelSmCaps
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...classProvider.classes.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: ClassCard(
              session: c,
              isAdminView: true,
              onDelete: () => classProvider.removeClass(c.id),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Moderation Tab ───────────────────────────────────────────────────────────

class _ModerationTab extends StatelessWidget {
  const _ModerationTab();

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final flagged = feed.posts.where((p) => p.isFlagged).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: PowerStatCard(
                value: feed.posts.length.toString(),
                unit: '',
                label: 'Total Posts',
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: PowerStatCard(
                value: flagged.length.toString(),
                unit: '',
                label: 'Flagged',
                accentColor: flagged.isNotEmpty ? AppColors.error : AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (flagged.isNotEmpty) ...[
          Text('FLAGGED POSTS', style: AppTextStyles.labelSmCaps
              .copyWith(color: AppColors.error)),
          const SizedBox(height: 12),
          ...flagged.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: PostCard(
                post: post,
                isAdminView: true,
                onLike: () => feed.toggleLike(post.id),
                onDelete: () => feed.deletePost(post.id),
                onFlag: () => feed.flagPost(post.id),
                onPin: () => feed.pinPost(post.id),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        Text('ALL POSTS', style: AppTextStyles.labelSmCaps),
        const SizedBox(height: 12),
        ...feed.posts.map(
          (post) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: PostCard(
              post: post,
              isAdminView: true,
              onLike: () => feed.toggleLike(post.id),
              onDelete: () => feed.deletePost(post.id),
              onFlag: () => feed.flagPost(post.id),
              onPin: () => feed.pinPost(post.id),
            ),
          ),
        ),
      ],
    );
  }
}
