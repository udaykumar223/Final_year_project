import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../widgets/crop_card.dart';

/// SmartCrop AI — Crop Selection Screen
class CropSelectionScreen extends StatelessWidget {
  const CropSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Select Crop', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Select the crop you want to scan. This helps the AI give you more accurate results.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text('Available Crops', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),

            ...Crop.availableCrops.map((crop) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CropCard(
                crop: crop,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/scan',
                    arguments: crop,
                  );
                },
              ),
            )),

            const SizedBox(height: AppSpacing.xl),

            // Coming soon
            Text(
              'Coming Soon',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            ...Crop.futureCrops.map((crop) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CropCard(crop: crop),
            )),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
