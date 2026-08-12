import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// SmartCrop AI — Verification Status Widget
/// Shows a single verification check item
class VerificationStatus extends StatelessWidget {
  final String label;
  final String description;
  final bool passed;
  final IconData icon;

  const VerificationStatus({
    super.key,
    required this.label,
    required this.description,
    required this.passed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: passed ? AppColors.successLight : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18,
              color: passed ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.titleSmall),
                Text(description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: passed ? AppColors.success : AppColors.danger,
            size: 22,
          ),
        ],
      ),
    );
  }
}
