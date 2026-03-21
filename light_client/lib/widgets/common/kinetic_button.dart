import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

/// Electric Brutalism primary button with gradient background.
class KineticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final IconData? icon;
  final bool fullWidth;

  const KineticButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isSecondary = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: isSecondary ? AppColors.secondary : AppColors.onPrimaryContainer),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelLg.copyWith(
            color: isSecondary ? AppColors.secondary : AppColors.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    if (isSecondary) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
