import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../models/prediction.dart';

/// SmartCrop AI — Result Screen
/// The most important screen. Shows real AI prediction with confidence.
class ResultScreen extends StatelessWidget {
  final PredictionResult prediction;
  final String imagePath;
  final Crop crop;

  const ResultScreen({
    super.key,
    required this.prediction,
    required this.imagePath,
    required this.crop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Result', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.of(context).popUntil(
              (route) => route.settings.name == '/home' || route.isFirst,
            );
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.settings.name == '/home' || route.isFirst,
              );
            },
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Home'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Analyzed image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Crop info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(crop.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CROP',
                        style: AppTextStyles.labelSmall.copyWith(
                          letterSpacing: 1,
                        ),
                      ),
                      Text(prediction.crop, style: AppTextStyles.titleLarge),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // Disease result — the main card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: _getConfidenceColor().withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getConfidenceColor().withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'DISEASE',
                    style: AppTextStyles.labelMedium.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Disease name — visually dominant
                  Text(
                    prediction.predictedDisease,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: _isDiseaseHealthy()
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Confidence
                  Text(
                    'AI CONFIDENCE',
                    style: AppTextStyles.labelSmall.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Large confidence percentage
                  Text(
                    '${prediction.confidencePercent.toStringAsFixed(0)}%',
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 48,
                      color: _getConfidenceColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Confidence label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      prediction.confidenceLabel.toUpperCase(),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _getConfidenceColor(),
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  if (prediction.message.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      prediction.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Top predictions
            if (prediction.topPredictions.length > 1) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Other Possibilities',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              ...prediction.topPredictions.skip(1).map((p) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.disease, style: AppTextStyles.bodyMedium),
                        Text(
                          '${(p.confidence * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Explanation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.infoLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _isDiseaseHealthy()
                          ? 'The image shows a healthy ${prediction.crop} leaf. No disease symptoms detected.'
                          : 'The image shows symptoms consistent with ${prediction.predictedDisease}. Consult an agricultural expert for confirmation.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Scan again button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/home' || route.isFirst,
                );
              },
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text('Scan Another Crop',
                  style:
                      AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  bool _isDiseaseHealthy() {
    return prediction.predictedDisease.toLowerCase().contains('healthy');
  }

  Color _getConfidenceColor() {
    if (prediction.confidencePercent >= 75) return AppColors.success;
    if (prediction.confidencePercent >= 50) return AppColors.warning;
    return AppColors.danger;
  }
}
