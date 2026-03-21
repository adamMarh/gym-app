import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// "Power Stats" Component – editorial look with large numbers + all-caps label.
class PowerStatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color? accentColor;

  const PowerStatCard({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.displayMd.copyWith(color: color),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: AppTextStyles.titleMd.copyWith(
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmCaps,
          ),
        ],
      ),
    );
  }
}

/// Small data chip with rounded-full shape.
class DataChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const DataChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color ?? AppColors.onSecondaryContainer),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmCaps.copyWith(
              color: color ?? AppColors.onSecondaryContainer,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
