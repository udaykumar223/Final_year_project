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
            // Guidance Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Select the target crop you want to inspect. The AI Vision Transformer is optimized for these categories.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Active Supported Crops',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
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

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
