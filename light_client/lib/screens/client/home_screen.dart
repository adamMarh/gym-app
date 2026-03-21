import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../models/workout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common/power_stat_card.dart';
import '../../widgets/client/class_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;
    final workouts = context.watch<WorkoutProvider>().sessions;
    final classes = context.watch<ClassProvider>();
    final nextClass = classes.bookedClasses.isNotEmpty
        ? classes.bookedClasses.first
        : classes.classes.isNotEmpty
            ? classes.classes.first
            : null;

    final daysUntilExpiry =
        user.membershipExpiry.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AppBar(user: user),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Membership Status
                _MembershipBanner(
                  tier: user.membershipTier,
                  daysLeft: daysUntilExpiry,
                ),
                const SizedBox(height: 24),

                // Power Stats Row
                Text('YOUR STATS', style: AppTextStyles.labelSmCaps),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PowerStatCard(
                        value: workouts.length.toString(),
                        unit: '',
                        label: 'Workouts\nThis Month',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: PowerStatCard(
                        value: workouts.isNotEmpty
                            ? '${workouts.first.totalSets}'
                            : '0',
                        unit: 'SETS',
                        label: 'Last Session',
                        accentColor: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: PowerStatCard(
                        value: classes.bookedClasses.length.toString(),
                        unit: '',
                        label: 'Classes\nBooked',
                        accentColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Next Class
                if (nextClass != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NEXT CLASS', style: AppTextStyles.labelSmCaps),
                      Text(
                        DateFormat('EEE, MMM d').format(nextClass.startTime).toUpperCase(),
                        style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClassCard(
                    session: nextClass,
                    onBook: nextClass.isBooked
                        ? null
                        : () => context.read<ClassProvider>().bookClass(nextClass.id),
                    onCancel: nextClass.isBooked
                        ? () => context.read<ClassProvider>().cancelBooking(nextClass.id)
                        : null,
                  ),
                  const SizedBox(height: 28),
                ],

                // Recent Workouts
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RECENT WORKOUTS', style: AppTextStyles.labelSmCaps),
                    Text(
                      'VIEW ALL',
                      style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...workouts.take(3).map((w) => _WorkoutRow(session: w)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final User user;

  const _AppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.glassNavBar,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.toUpperCase(),
                  style: AppTextStyles.labelSmCaps,
                ),
                Text(
                  user.name.split(' ').first.toUpperCase(),
                  style: AppTextStyles.headlineMd,
                ),
              ],
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                user.name[0],
                style: AppTextStyles.titleMd
                    .copyWith(color: AppColors.onPrimaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

class _MembershipBanner extends StatelessWidget {
  final String tier;
  final int daysLeft;

  const _MembershipBanner({required this.tier, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.3),
            AppColors.background,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$tier MEMBER',
                style: AppTextStyles.titleMd,
              ),
              const SizedBox(height: 4),
              Text(
                'ACTIVE',
                style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.success),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$daysLeft',
                style: AppTextStyles.displaySm.copyWith(color: AppColors.primary),
              ),
              Text(
                'DAYS LEFT',
                style: AppTextStyles.labelSmCaps,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final WorkoutSession session;

  const _WorkoutRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.title, style: AppTextStyles.labelLg.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEE, MMM d').format(session.date).toUpperCase(),
                style: AppTextStyles.labelSmCaps,
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${session.exercises.length} EXERCISES',
            style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
