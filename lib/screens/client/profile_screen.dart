import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common/kinetic_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _showEditSheet(context, user),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          _ProfileHeader(user: user),
          const SizedBox(height: 24),

          // Membership card
          _MembershipCard(user: user),
          const SizedBox(height: 24),

          // Billing section
          Text('BILLING', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          _BillingSection(),
          const SizedBox(height: 24),

          // Settings
          Text('SETTINGS', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            label: 'Privacy & Security',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            label: 'Help & Support',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          KineticButton(
            label: 'SIGN OUT',
            isSecondary: true,
            fullWidth: true,
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, User user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');

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
            Text('EDIT PROFILE', style: AppTextStyles.headlineSm),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: AppTextStyles.bodyLg
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'FULL NAME'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyLg
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(labelText: 'PHONE NUMBER'),
            ),
            const SizedBox(height: 24),
            KineticButton(
              label: 'SAVE CHANGES',
              fullWidth: true,
              onPressed: () {
                ctx.read<AuthProvider>().updateProfile(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            user.name[0].toUpperCase(),
            style: AppTextStyles.displaySm.copyWith(
              color: AppColors.onPrimaryContainer,
              fontSize: 28,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name, style: AppTextStyles.headlineSm),
            const SizedBox(height: 4),
            Text(user.email, style: AppTextStyles.labelMd),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                user.role.name.toUpperCase(),
                style: AppTextStyles.labelSmCaps.copyWith(
                  color: AppColors.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final User user;

  const _MembershipCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        user.membershipExpiry.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.4),
            AppColors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MEMBERSHIP', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.membershipTier, style: AppTextStyles.headlineSm),
                  Text(
                    'ACTIVE',
                    style: AppTextStyles.labelSmCaps
                        .copyWith(color: AppColors.success),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysLeft',
                    style: AppTextStyles.displaySm
                        .copyWith(color: AppColors.primary),
                  ),
                  Text('DAYS LEFT', style: AppTextStyles.labelSmCaps),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'EXPIRES ${DateFormat('MMMM d, y').format(user.membershipExpiry).toUpperCase()}',
            style: AppTextStyles.labelSmCaps,
          ),
        ],
      ),
    );
  }
}

class _BillingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VISA •••• 4242', style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.onBackground,
                  )),
                  Text('EXPIRES 12/27', style: AppTextStyles.labelSmCaps),
                ],
              ),
              Icon(Icons.credit_card,
                  color: AppColors.primary, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'NEXT BILLING DATE: ',
                style: AppTextStyles.labelSmCaps,
              ),
              Text(
                DateFormat('MMM d, y')
                    .format(DateTime.now().add(const Duration(days: 30)))
                    .toUpperCase(),
                style: AppTextStyles.labelSmCaps
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: AppColors.surfaceContainerLow,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMd),
            const Spacer(),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
