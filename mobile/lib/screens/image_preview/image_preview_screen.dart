import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';

/// SmartCrop AI — Image Preview Screen
/// Shows the captured/selected image before verification
class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final Crop crop;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    required this.crop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review Photo', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Crop info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Container(
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
                  Text(crop.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanning: ${crop.displayName}',
                        style: AppTextStyles.titleSmall,
                      ),
                      Text(
                        'This photo will be analyzed by AI',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Row(
              children: [
                // Retake
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('Retake',
                        style: AppTextStyles.buttonMedium
                            .copyWith(color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                          double.infinity, AppSpacing.buttonHeight),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Verify
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/verification',
                        arguments: {
                          'imagePath': imagePath,
                          'crop': crop,
                        },
                      );
                    },
                    icon: const Icon(Icons.verified_rounded),
                    label: Text('Verify Image',
                        style: AppTextStyles.buttonLarge
                            .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
