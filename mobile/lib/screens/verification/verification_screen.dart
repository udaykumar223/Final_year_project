import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../models/verification_result.dart';
import '../../services/api_service.dart';

/// SmartCrop AI — Image Verification Screen
/// Shows real OpenCV quality checks with farmer-friendly feedback
class VerificationScreen extends StatefulWidget {
  final String imagePath;
  final Crop crop;

  const VerificationScreen({
    super.key,
    required this.imagePath,
    required this.crop,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  VerificationResult? _result;
  bool _isLoading = true;
  String _currentStep = 'Checking image quality...';

  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _verifyImage();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _verifyImage() async {
    setState(() {
      _isLoading = true;
      _currentStep = 'Checking image quality...';
    });

    // Small delay for UX
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _currentStep = 'Analyzing image clarity...');

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _currentStep = 'Checking lighting...');

    final result = await _api.verifyImage(File(widget.imagePath));

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _result = result;
        _isLoading = false;
      });
      _checkController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Image Verification', style: AppTextStyles.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading ? _buildLoading() : _buildResult(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(_currentStep, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Please wait...',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final result = _result!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // Status header
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _checkController,
              curve: Curves.easeOut,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: result.valid
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: result.valid
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    result.valid
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    size: 56,
                    color: result.valid ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    result.valid
                        ? 'Image Verified'
                        : 'Image Needs Improvement',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: result.valid
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    result.message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Check details
          _buildCheckItem(
            'Image Format',
            result.formatOk,
            result.formatOk ? 'Valid image' : 'Invalid image format',
            Icons.image_rounded,
          ),
          _buildCheckItem(
            'Resolution',
            result.resolutionOk,
            result.resolutionOk ? 'Good resolution' : 'Image too small',
            Icons.aspect_ratio_rounded,
          ),
          _buildCheckItem(
            'Image Clarity',
            result.blurOk,
            result.blurOk ? 'Image is clear' : 'Image is too blurry',
            Icons.blur_on_rounded,
          ),
          _buildCheckItem(
            'Lighting',
            result.brightnessOk,
            result.brightnessOk ? 'Lighting is good' : 'Poor lighting',
            Icons.wb_sunny_rounded,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Action buttons
          if (result.valid) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/analysis',
                  arguments: {
                    'imagePath': widget.imagePath,
                    'crop': widget.crop,
                  },
                );
              },
              icon: const Icon(Icons.psychology_rounded),
              label: Text('Continue Analysis',
                  style:
                      AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                // Go back to scan
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == '/scan' ||
                             route.settings.name == '/home',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              icon: const Icon(Icons.camera_alt_rounded),
              label: Text('Retake Photo',
                  style:
                      AppTextStyles.buttonLarge.copyWith(color: Colors.white)),
            ),
          ],

          const SizedBox(height: AppSpacing.base),

          // Skip verification (if image is only slightly bad)
          if (!result.valid)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/analysis',
                  arguments: {
                    'imagePath': widget.imagePath,
                    'crop': widget.crop,
                  },
                );
              },
              child: Text(
                'Continue anyway (results may be less accurate)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(
    String label,
    bool passed,
    String description,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: passed
                  ? AppColors.successLight
                  : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              icon,
              size: 20,
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
            passed
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: passed ? AppColors.success : AppColors.danger,
            size: 24,
          ),
        ],
      ),
    );
  }
}
