import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/staff_report.dart';
import '../../providers/staff_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common/kinetic_button.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffProvider = context.watch<StaffProvider>();
    final reports = staffProvider.reports;
    final unreviewed = staffProvider.unreviewedReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('STAFF REPORTS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary
          Row(
            children: [
              _StatBox(
                value: reports.length.toString(),
                label: 'TOTAL',
                color: AppColors.primary,
              ),
              const SizedBox(width: 2),
              _StatBox(
                value: unreviewed.length.toString(),
                label: 'PENDING',
                color: unreviewed.isNotEmpty
                    ? AppColors.error
                    : AppColors.secondary,
              ),
              const SizedBox(width: 2),
              _StatBox(
                value:
                    (reports.length - unreviewed.length).toString(),
                label: 'REVIEWED',
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (unreviewed.isNotEmpty) ...[
            Text(
              'NEEDS REVIEW',
              style: AppTextStyles.labelSmCaps
                  .copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 12),
            ...unreviewed.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _ReportCard(
                  report: r,
                  onReview: (notes) =>
                      staffProvider.markReviewed(r.id, adminNotes: notes),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text('ALL REPORTS', style: AppTextStyles.labelSmCaps),
          const SizedBox(height: 12),
          ...reports.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _ReportCard(
                report: r,
                onReview: r.isReviewed
                    ? null
                    : (notes) =>
                        staffProvider.markReviewed(r.id, adminNotes: notes),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.surfaceContainerHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.displaySm.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelSmCaps),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final StaffReport report;
  final void Function(String?)? onReview;

  const _ReportCard({required this.report, this.onReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.staffName.toUpperCase(),
                    style: AppTextStyles.titleMd,
                  ),
                  Text(
                    DateFormat('EEE, MMM d • h:mm a')
                        .format(report.date)
                        .toUpperCase(),
                    style: AppTextStyles.labelSmCaps,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: report.isReviewed
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                ),
                child: Text(
                  report.isReviewed ? 'REVIEWED' : 'PENDING',
                  style: AppTextStyles.labelSmCaps.copyWith(
                    color: report.isReviewed
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary
          Text(
            report.summary,
            style: AppTextStyles.bodyLg
                .copyWith(color: AppColors.onBackground),
          ),
          const SizedBox(height: 8),
          Text(report.details, style: AppTextStyles.bodyMd),

          // Admin notes
          if (report.isReviewed && report.adminNotes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border(
                    left: BorderSide(
                        color: AppColors.primary, width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ADMIN NOTES',
                      style: AppTextStyles.labelSmCaps
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(report.adminNotes!, style: AppTextStyles.bodyMd),
                ],
              ),
            ),
          ],

          // Review action
          if (!report.isReviewed && onReview != null) ...[
            const SizedBox(height: 16),
            KineticButton(
              label: 'MARK AS REVIEWED',
              onPressed: () => _showReviewSheet(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showReviewSheet(BuildContext context) {
    final notesCtrl = TextEditingController();

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
            Text('REVIEW REPORT', style: AppTextStyles.headlineSm),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 4,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onBackground),
              decoration: const InputDecoration(
                labelText: 'ADMIN NOTES (OPTIONAL)',
                hintText: 'Add feedback for the staff member...',
              ),
            ),
            const SizedBox(height: 20),
            KineticButton(
              label: 'CONFIRM REVIEW',
              fullWidth: true,
              onPressed: () {
                onReview!(notesCtrl.text.trim().isEmpty
                    ? null
                    : notesCtrl.text.trim());
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
