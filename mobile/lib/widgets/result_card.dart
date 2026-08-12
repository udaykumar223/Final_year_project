import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// SmartCrop AI — Result Card Widget
/// Displays disease prediction result in a premium card
class ResultCard extends StatelessWidget {
  final String diseaseName;
  final String cropName;
  final double confidencePercent;
  final String confidenceLabel;
  final bool isHealthy;

  const ResultCard({
    super.key,
    required this.diseaseName,
    required this.cropName,
    required this.confidencePercent,
    required this.confidenceLabel,
    this.isHealthy = false,
  });

  Color get _confidenceColor {
    if (confidencePercent >= 75) return AppColors.success;
    if (confidencePercent >= 50) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: _confidenceColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _confidenceColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Crop
          Text(
            'CROP',
            style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
          ),
          Text(cropName, style: AppTextStyles.titleLarge),

          const SizedBox(height: AppSpacing.lg),

          // Disease
          Text(
            'DISEASE',
            style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            diseaseName,
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall.copyWith(
              color: isHealthy ? AppColors.success : AppColors.danger,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Confidence
          Text(
            'AI CONFIDENCE',
            style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          Text(
            '${confidencePercent.toStringAsFixed(0)}%',
            style: AppTextStyles.displayLarge.copyWith(
              color: _confidenceColor,
              fontSize: 42,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _confidenceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              confidenceLabel.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: _confidenceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
