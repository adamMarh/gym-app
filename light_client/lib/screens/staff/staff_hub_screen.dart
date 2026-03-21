import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/staff_report.dart';
import '../../providers/auth_provider.dart';
import '../../providers/staff_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common/kinetic_button.dart';
import '../../widgets/common/power_stat_card.dart';

class StaffHubScreen extends StatefulWidget {
  const StaffHubScreen({super.key});

  @override
  State<StaffHubScreen> createState() => _StaffHubScreenState();
}

class _StaffHubScreenState extends State<StaffHubScreen> {
  final _summaryCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  @override
  void dispose() {
    _summaryCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final user = context.watch<AuthProvider>().currentUser!;
    final isPunchedIn = staffProvider.isPunchedIn;
    final punch = staffProvider.activePunch;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('STAFF HUB')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('PUNCH CLOCK', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          _PunchClockCard(
            isPunchedIn: isPunchedIn,
            punchIn: punch?.punchIn,
            onPunchIn: () => staffProvider.punchIn(user.id),
            onPunchOut: () => staffProvider.punchOut(),
          ),

          const SizedBox(height: 28),

          if (isPunchedIn && punch != null) ...[
            Text('ACTIVE SESSION', style: AppTextStyles.labelSmCaps),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PowerStatCard(
                    value: DateFormat('h:mm').format(punch.punchIn),
                    unit: DateFormat('a').format(punch.punchIn),
                    label: 'Punched In',
                    accentColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _LiveDurationCard(punchIn: punch.punchIn),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],

          Text('DAILY REPORT', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          Container(
            color: AppColors.surfaceContainerHigh,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d')
                      .format(DateTime.now())
                      .toUpperCase(),
                  style: AppTextStyles.labelSmCaps
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _summaryCtrl,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onBackground),
                  decoration: const InputDecoration(
                    labelText: 'BRIEF SUMMARY',
                    hintText: 'e.g. Completed morning HIIT sessions.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _detailCtrl,
                  maxLines: 5,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onBackground),
                  decoration: const InputDecoration(
                    labelText: 'DETAILED NOTES',
                    hintText: 'Add details about today\'s activities...',
                  ),
                ),
                const SizedBox(height: 20),
                KineticButton(
                  label: 'SUBMIT REPORT',
                  fullWidth: true,
                  onPressed: () => _submitReport(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text('MY RECENT REPORTS', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          ...staffProvider.reports
              .where((r) => r.staffId == user.id)
              .take(5)
              .map((r) => _ReportRow(report: r)),
        ],
      ),
    );
  }

  Future<void> _submitReport(BuildContext context) async {
    if (_summaryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a summary')),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser!;

    await context.read<StaffProvider>().submitReport(
          StaffReport(
            id: '',
            staffId: user.id,
            staffName: user.name,
            date: DateTime.now(),
            summary: _summaryCtrl.text.trim(),
            details: _detailCtrl.text.trim(),
          ),
        );

    _summaryCtrl.clear();
    _detailCtrl.clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'REPORT SUBMITTED',
            style:
                AppTextStyles.labelMd.copyWith(color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}

class _PunchClockCard extends StatelessWidget {
  final bool isPunchedIn;
  final DateTime? punchIn;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  const _PunchClockCard({
    required this.isPunchedIn,
    required this.punchIn,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surfaceContainerHigh,
      child: Column(
        children: [
          Text(
            DateFormat('h:mm').format(DateTime.now()),
            style: AppTextStyles.displayLg.copyWith(
              color: isPunchedIn ? AppColors.success : AppColors.onBackground,
            ),
          ),
          Text(
            DateFormat('a • EEE, MMM d').format(DateTime.now()).toUpperCase(),
            style: AppTextStyles.labelSmCaps,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isPunchedIn
                ? AppColors.success.withValues(alpha: 0.15)
                : AppColors.outline.withValues(alpha: 0.3),
            child: Text(
              isPunchedIn ? '● ON DUTY' : '○ OFF DUTY',
              style: AppTextStyles.labelSmCaps.copyWith(
                color: isPunchedIn
                    ? AppColors.success
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          KineticButton(
            label: isPunchedIn ? 'PUNCH OUT' : 'PUNCH IN',
            onPressed: isPunchedIn ? onPunchOut : onPunchIn,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _LiveDurationCard extends StatefulWidget {
  final DateTime punchIn;

  const _LiveDurationCard({required this.punchIn});

  @override
  State<_LiveDurationCard> createState() => _LiveDurationCardState();
}

class _LiveDurationCardState extends State<_LiveDurationCard> {
  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(widget.punchIn);
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    return PowerStatCard(
      value: '${h}H ${m}M',
      unit: '',
      label: 'Duration',
      accentColor: AppColors.primary,
    );
  }
}

class _ReportRow extends StatelessWidget {
  final StaffReport report;

  const _ReportRow({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg
                      .copyWith(color: AppColors.onBackground),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEE, MMM d').format(report.date).toUpperCase(),
                  style: AppTextStyles.labelSmCaps,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: report.isReviewed
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.outline.withValues(alpha: 0.3),
            ),
            child: Text(
              report.isReviewed ? 'REVIEWED' : 'PENDING',
              style: AppTextStyles.labelSmCaps.copyWith(
                color: report.isReviewed
                    ? AppColors.success
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
