import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../models/prediction.dart';
import '../../widgets/app_image.dart';

/// SmartCrop AI — Ultra-Premium Result Screen
/// Displays Plant Name, Disease Name, Animated Severity Gauge, and AI Confidence.
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

  Color _parseHexColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppColors.primaryLight;
    }
  }

  bool _isHealthy() {
    return prediction.diseaseName.toLowerCase().contains('healthy');
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _parseHexColor(prediction.severity.color);
    final isHealthy = _isHealthy();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diagnostic Report', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.settings.name == '/home' || route.isFirst);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.settings.name == '/home' || route.isFirst);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF0F2B20),
              Color(0xFF0A1612),
              Color(0xFF050B09),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Leaf Image with Plant Name Header Overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 220,
                        child: AppImage(imagePath: imagePath, fit: BoxFit.cover),
                      ),
                      // Gradient Shadow Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Plant Name Tag on Image
                      Positioned(
                        bottom: 14,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(crop.emoji, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(
                                    prediction.plantName.toUpperCase(),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Primary Diagnosis Card (Disease Name & Confidence)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(
                      color: isHealthy ? AppColors.healthy.withValues(alpha: 0.4) : AppColors.danger.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isHealthy ? AppColors.healthy : AppColors.danger).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DETECTED CONDITION',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              '${prediction.confidencePercent.toStringAsFixed(1)}% AI CONFIDENCE',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Disease Name in High-Impact Typography
                      Text(
                        prediction.diseaseName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: isHealthy ? AppColors.healthy : Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isHealthy ? 'Leaf is healthy and free of disease pathogens.' : 'Symptoms identified on plant foliage.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Plant Severity Gauge Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: severityColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.speed_rounded, color: severityColor, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'PLANT SEVERITY LEVEL',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              border: Border.all(color: severityColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              prediction.severity.level.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: severityColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Animated Linear Severity Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              child: LinearProgressIndicator(
                                value: isHealthy ? 0.05 : (prediction.severity.score / 100.0),
                                minHeight: 12,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(severityColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            isHealthy ? '0%' : '${prediction.severity.score.toStringAsFixed(0)}%',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: severityColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Severity Advisory Text
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.health_and_safety_rounded, color: severityColor, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                prediction.severity.advisory,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Other Candidate Possibilities
                if (prediction.topPredictions.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alternative Diagnostic Candidates',
                          style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...prediction.topPredictions.skip(1).map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.disease,
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '${(item.confidence * 100).toStringAsFixed(1)}%',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.settings.name == '/home' || route.isFirst);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                  label: const Text('Scan Another Leaf'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
