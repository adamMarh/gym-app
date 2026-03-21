import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/class_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/user_provider.dart';
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
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final users = userProvider.users;
    final clients = users.where((u) => u.role == UserRole.client).length;
    final staff = users.where((u) => u.role == UserRole.staff).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: PowerStatCard(
                value: clients.toString(),
                unit: '',
                label: 'Clients',
                accentColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: PowerStatCard(
                value: staff.toString(),
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
                    style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w700)),
                Text(user.email, style: AppTextStyles.labelMd),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        ],
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
              onTap: () => _showAddClassSheet(context),
              child: Text(
                '+ ADD CLASS',
                style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.primary),
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

  void _showAddClassSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      isScrollControlled: true,
      builder: (_) => const _AddClassSheet(),
    );
  }
}

class _AddClassSheet extends StatefulWidget {
  const _AddClassSheet();

  @override
  State<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<_AddClassSheet> {
  final _titleCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '20');
  final _durationCtrl = TextEditingController(text: '60');
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    for (final c in [_titleCtrl, _instructorCtrl, _categoryCtrl,
        _descCtrl, _capacityCtrl, _durationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(BuildContext ctx) async {
    if (_titleCtrl.text.trim().isEmpty ||
        _instructorCtrl.text.trim().isEmpty ||
        _categoryCtrl.text.trim().isEmpty) return;

    await ctx.read<ClassProvider>().addClass(
          _buildSession(),
        );
    if (ctx.mounted) Navigator.pop(ctx);
  }

  _buildSession() {
    // Return a dummy ClassSession; ClassProvider.addClass() sends the fields
    // to the API and replaces it with the server response.
    return _DraftClass(
      title: _titleCtrl.text.trim().toUpperCase(),
      instructor: _instructorCtrl.text.trim(),
      startTime: _startTime,
      durationMinutes: int.tryParse(_durationCtrl.text) ?? 60,
      capacity: int.tryParse(_capacityCtrl.text) ?? 20,
      category: _categoryCtrl.text.trim().toUpperCase(),
      description: _descCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADD CLASS', style: AppTextStyles.headlineSm),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'TITLE'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructorCtrl,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'INSTRUCTOR'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'CATEGORY (e.g. HIIT)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _capacityCtrl,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onBackground),
                    decoration: const InputDecoration(labelText: 'CAPACITY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onBackground),
                    decoration: const InputDecoration(labelText: 'DURATION (min)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'DESCRIPTION (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _save(context),
              child: Text('CREATE CLASS',
                  style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onPrimary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Lightweight data holder used by _AddClassSheet
class _DraftClass {
  final String title;
  final String instructor;
  final DateTime startTime;
  final int durationMinutes;
  final int capacity;
  final String category;
  final String description;

  _DraftClass({
    required this.title,
    required this.instructor,
    required this.startTime,
    required this.durationMinutes,
    required this.capacity,
    required this.category,
    required this.description,
  });
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
                accentColor: flagged.isNotEmpty
                    ? AppColors.error
                    : AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (flagged.isNotEmpty) ...[
          Text('FLAGGED POSTS',
              style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.error)),
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
