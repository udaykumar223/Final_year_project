import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// SmartCrop AI — Confidence Badge Widget
/// Displays confidence as a color-coded percentage with label
class ConfidenceBadge extends StatelessWidget {
  final double confidencePercent;
  final String confidenceLabel;
  final bool compact;

  const ConfidenceBadge({
    super.key,
    required this.confidencePercent,
    required this.confidenceLabel,
    this.compact = false,
  });

  Color get _color {
    if (confidencePercent >= 75) return AppColors.success;
    if (confidencePercent >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: _color.withValues(alpha: 0.3)),
        ),
        child: Text(
          '${confidencePercent.toStringAsFixed(0)}% $confidenceLabel',
          style: AppTextStyles.labelMedium.copyWith(
            color: _color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          '${confidencePercent.toStringAsFixed(0)}%',
          style: AppTextStyles.displayLarge.copyWith(
            color: _color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            confidenceLabel.toUpperCase(),
            style: AppTextStyles.labelMedium.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
