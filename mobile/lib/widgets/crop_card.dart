import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';

/// SmartCrop AI — Premium Crop Selection Card
class CropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onTap;

  const CropCard({
    super.key,
    required this.crop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: crop.isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: crop.isEnabled ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: crop.isEnabled
                ? AppColors.border.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.3),
          ),
          boxShadow: crop.isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              // Emoji avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCropColor(crop.id).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Center(
                  child: Text(
                    crop.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.base),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.displayName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: crop.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      crop.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: crop.isEnabled
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!crop.isEnabled) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              if (crop.isEnabled)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCropColor(String id) {
    switch (id) {
      case 'banana':
        return AppColors.bananaAccent;
      case 'groundnut':
        return AppColors.groundnutAccent;
      case 'radish':
        return AppColors.radishAccent;
      default:
        return AppColors.secondary;
    }
  }
}
