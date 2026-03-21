import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/class_session.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../common/power_stat_card.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final VoidCallback? onBook;
  final VoidCallback? onCancel;
  final bool isAdminView;
  final VoidCallback? onDelete;

  const ClassCard({
    super.key,
    required this.session,
    this.onBook,
    this.onCancel,
    this.isAdminView = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(session.startTime);
    final dateStr = DateFormat('EEE, MMM d').format(session.startTime);
    final durationStr =
        '${session.duration.inMinutes} MIN';

    return Container(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + category chip
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: AppTextStyles.headlineSm,
                ),
              ),
              DataChip(label: session.category),
            ],
          ),
          const SizedBox(height: 12),

          // Instructor & time info
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(session.instructor, style: AppTextStyles.labelMd),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('$dateStr • $timeStr', style: AppTextStyles.labelMd),
              const SizedBox(width: 8),
              Text(durationStr,
                  style: AppTextStyles.labelSmCaps.copyWith(
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),

          // Spots + action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Spots indicator
              _SpotsBar(
                enrolled: session.enrolled,
                capacity: session.capacity,
              ),
              const SizedBox(width: 16),

              // Action button
              if (isAdminView)
                _AdminActions(onDelete: onDelete)
              else if (session.isBooked)
                _CancelButton(onCancel: onCancel)
              else if (session.isFull)
                _FullBadge()
              else
                _BookButton(onBook: onBook),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotsBar extends StatelessWidget {
  final int enrolled;
  final int capacity;

  const _SpotsBar({required this.enrolled, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final spotsLeft = capacity - enrolled;
    final fraction = enrolled / capacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$spotsLeft SPOTS LEFT',
          style: AppTextStyles.labelSmCaps.copyWith(
            color: spotsLeft <= 3 ? AppColors.error : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 120,
          height: 3,
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: AppColors.outline,
            valueColor: AlwaysStoppedAnimation<Color>(
              spotsLeft <= 3 ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookButton extends StatelessWidget {
  final VoidCallback? onBook;
  const _BookButton({this.onBook});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBook,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
        ),
        child: Text(
          'BOOK',
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback? onCancel;
  const _CancelButton({this.onCancel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCancel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
        ),
        child: Text(
          'CANCEL',
          style: AppTextStyles.labelLg.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class _FullBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.surfaceContainerHighest,
      child: Text(
        'FULL',
        style: AppTextStyles.labelLg.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _AdminActions extends StatelessWidget {
  final VoidCallback? onDelete;
  const _AdminActions({this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
          onPressed: () {},
          tooltip: 'Edit class',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
          onPressed: onDelete,
          tooltip: 'Remove class',
        ),
      ],
    );
  }
}
